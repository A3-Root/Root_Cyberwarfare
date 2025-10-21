#!/usr/bin/env python3
import subprocess
from pathlib import Path
from packaging.version import Version
from collections import defaultdict

def main():
    releases_dir = Path("releases")

    if not releases_dir.exists():
        print("📁 Releases directory not found. Nothing to process.")
        return

    all_zips = list(releases_dir.glob("root_cyberwarfare-*.zip"))
    latest_zip = releases_dir / "root_cyberwarfare-latest.zip"
    versioned_zips = [z for z in all_zips if z != latest_zip]

    version_map = defaultdict(list)
    for zip_file in versioned_zips:
        name = zip_file.name
        try:
            version_str = name.split("root_cyberwarfare-")[1].split(".zip")[0]
            Version(version_str)
            version_map[version_str].append(zip_file)
        except Exception:
            continue

    def get_keys(version):
        v = Version(version)
        return {
            "major": f"{v.major}",
            "minor": f"{v.major}.{v.minor}",
            "patch": f"{v.major}.{v.minor}.{v.micro}"
        }

    major_map, minor_map, patch_map = defaultdict(list), defaultdict(list), defaultdict(list)

    for v_str in version_map:
        keys = get_keys(v_str)
        major_map[keys["major"]].append(v_str)
        minor_map[keys["minor"]].append(v_str)
        patch_map[keys["patch"]].append(v_str)

    kept_versions = set()
    latest_major = sorted(major_map.keys(), key=Version, reverse=True)[:1]
    for major in latest_major:
        minors = sorted(set(f"{major}.{v.split('.')[1]}" for v in major_map[major]), key=Version, reverse=True)[:2]
        for minor in minors:
            patches = sorted(set(f"{minor}.{v.split('.')[2]}" for v in minor_map[minor]), key=Version, reverse=True)[:3]
            for patch in patches:
                builds = sorted([v for v in patch_map[patch]], key=Version, reverse=True)
                if builds:
                    kept_versions.add(builds[0])

    print("🔒 Keeping versions:", kept_versions)

    for zip_file in versioned_zips:
        version_str = zip_file.name.split("root_cyberwarfare-")[1].split(".zip")[0]
        if version_str not in kept_versions:
            print(f"🗑️  Deleting old archive: {zip_file}")
            zip_file.unlink()

    if latest_zip.exists():
        print(f"🔒 Preserving latest.zip: {latest_zip}")

    result = subprocess.run(["git", "status", "--porcelain", "releases/"],
                            stdout=subprocess.PIPE, text=True)
    if result.stdout.strip():
        subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
        subprocess.run(["git", "config", "user.email", "github-actions@github.com"], check=True)
        subprocess.run(["git", "add", "releases"], check=True)
        subprocess.run(["git", "commit", "-m", "RELEASE"], check=True)
        subprocess.run(["git", "push"], check=True)
        print("✅ Committed and pushed release changes.")
    else:
        print("✅ No changes to commit.")

    kept_files = [f for v in kept_versions for f in version_map[v]]
    latest_version = None
    latest_version_obj = None

    for zip_file in kept_files:
        version = zip_file.name.split("root_cyberwarfare-")[1].split(".zip")[0]

        tag_exists = subprocess.run(["git", "tag", "--list", version],
                                    stdout=subprocess.PIPE).stdout.decode().strip()

        if not tag_exists:
            subprocess.run(["git", "tag", version], check=True)
            subprocess.run(["git", "push", "origin", version], check=True)
        else:
            print(f"🔁 Tag {version} exists. Updating release...")

        changelog_path = Path("releases/CHANGELOG.md")
        if changelog_path.exists():
            with open(changelog_path) as f:
                lines = f.readlines()
            section = []
            in_section = False
            for line in lines:
                if line.startswith("## "):
                    if in_section:
                        break
                    else:
                        in_section = True
                if in_section:
                    section.append(line.rstrip())
            notes = "\n".join(section)
        else:
            notes = f"Automated release for version {version}."

        release_exists = subprocess.run(
            ["gh", "release", "view", version],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        ).returncode == 0

        if release_exists:
            print(f"🧹 Updating existing release {version}...")
            assets_proc = subprocess.run(
                ["gh", "release", "view", version, "--json", "assets", "--jq", ".assets[].name"],
                stdout=subprocess.PIPE
            )
            assets = assets_proc.stdout.decode().strip().splitlines()
            for asset in assets:
                if asset:
                    subprocess.run(["gh", "release", "delete-asset", version, asset, "--yes"], check=True)

            subprocess.run(["gh", "release", "upload", version, str(zip_file), "--clobber"], check=True)
            subprocess.run(["gh", "release", "edit", version, "--notes", notes], check=True)
        else:
            subprocess.run([
                "gh", "release", "create", version, str(zip_file),
                "--title", f"Root's Cyber Warfare v{version}",
                "--notes", notes
            ], check=True)

        v_obj = Version(version)
        if not latest_version_obj or v_obj > latest_version_obj:
            latest_version = version
            latest_version_obj = v_obj

    if latest_version and latest_zip.exists():
        print(f"📦 Attaching latest.zip and updating 'latest' tag to {latest_version}")
        subprocess.run([
            "gh", "release", "upload", latest_version, str(latest_zip), "--clobber"
        ], check=True)

        # Update or create the 'latest' tag
        subprocess.run(["git", "tag", "-f", "latest"], check=True)
        subprocess.run(["git", "push", "-f", "origin", "latest"], check=True)

        # Update or create a 'latest' release entry
        release_exists = subprocess.run(
            ["gh", "release", "view", "latest"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        ).returncode == 0

        if release_exists:
            print("🔁 Updating existing 'latest' release.")
            subprocess.run([
                "gh", "release", "edit", "latest",
                "--title", "Root's Cyber Warfare (Latest Build)",
                "--notes", f"Automated latest release matching version {latest_version}"
            ], check=True)
        else:
            subprocess.run([
                "gh", "release", "create", "latest", str(latest_zip),
                "--title", "Root's Cyber Warfare (Latest Build)",
                "--notes", f"Automated latest release matching version {latest_version}"
            ], check=True)

if __name__ == "__main__":
    main()
