#!/usr/bin/env python3
import re
import subprocess
from pathlib import Path
from typing import Optional, List

def run(cmd: List[str], check: bool = True, capture: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check, capture_output=capture, text=True)

def release_exists(tag: str) -> bool:
    try:
        run(["gh", "release", "view", tag], check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def get_version_from_filename(name: str) -> Optional[str]:
    m = re.search(r"(\d+\.\d+\.\d+\.\d+)", name)
    return m.group(1) if m else None

H2_HDR = re.compile(r"^##\s+")
VERSION_HDR_FMT = r"^##\s+.*?\(\s*v?{version}\s*\)\s*$"

def _extract_first_section(lines: List[str], start_idx: int) -> str:
    out = []
    for i in range(start_idx, len(lines)):
        line = lines[i]
        if i != start_idx and H2_HDR.match(line):
            break
        out.append(line.rstrip("\n"))
    return "\n".join(out).strip()

def get_changelog_notes_for_version(version: str, *, latest_fallback: bool) -> str:
    """
    Reads releases/CHANGELOG.md
    - Exact match: '## ... (v{version})'
    - If latest_fallback=True and no exact match: return topmost '## ...' section
    """
    path = Path("releases/CHANGELOG.md")
    if not path.exists():
        return "Automated release"
    try:
        lines = path.read_text(encoding="utf-8").splitlines()

        if version:
            pat = re.compile(VERSION_HDR_FMT.format(version=re.escape(version)))
            for idx, line in enumerate(lines):
                if pat.match(line):
                    return _extract_first_section(lines, idx)

        if latest_fallback:
            for idx, line in enumerate(lines):
                if H2_HDR.match(line):
                    return _extract_first_section(lines, idx)

        return "Automated release"
    except Exception as e:
        print(f"Could not read changelog: {e}")
        return "Automated release"

def main() -> None:
    # Collect versioned zip files in repo root or ./releases
    roots = [Path("."), Path("releases")]
    zips: List[Path] = []
    for root in roots:
        if root.exists():
            zips.extend(p for p in root.glob("*.zip") if p.is_file())

    # Process each versioned zip
    for zip_file in sorted(zips):
        version = get_version_from_filename(zip_file.name)
        if not version:
            continue

        tag = version
        title = f"Version {version}"
        notes_exact = get_changelog_notes_for_version(version, latest_fallback=False)

        if release_exists(tag):
            print(f"Updating {tag}")
            run(["gh", "release", "upload", tag, str(zip_file), "--clobber"], check=True)
            run(["gh", "release", "edit", tag, "--title", title], check=True)
            if notes_exact and notes_exact != "Automated release":
                run(["gh", "release", "edit", tag, "--notes", notes_exact], check=True)
            print(f"Done {tag}")
        else:
            print(f"Creating {tag}")
            create_notes = notes_exact if (notes_exact and notes_exact != "Automated release") else "Automated release"
            run([
                "gh", "release", "create", tag, str(zip_file),
                "--title", title,
                "--notes", create_notes
            ], check=True)
            print(f"Done {tag}")

    # Maintain moving 'latest' if it exists
    if release_exists("latest"):
        print("Updating [Latest]")
        latest_notes = get_changelog_notes_for_version("", latest_fallback=True)
        run(["gh", "release", "edit", "latest", "--title", "[Latest]", "--notes", latest_notes], check=True)
        print("Done [Latest]")

if __name__ == "__main__":
    main()
