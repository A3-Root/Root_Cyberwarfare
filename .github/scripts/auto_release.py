#!/usr/bin/env python3
import subprocess
from pathlib import Path
from packaging.version import Version
from collections import defaultdict

def main():
    releases_dir = Path("releases")
    
    # Ensure releases directory exists
    if not releases_dir.exists():
        print("📁 Releases directory does not exist, nothing to process")
        return
    
    all_zips = list(releases_dir.glob("root_cyberwarfare-*.zip"))
    version_map = defaultdict(list)

    # Extract version from filename (e.g., root_cyberwarfare-1.2.3.4.zip)
    for zip_file in all_zips:
        name = zip_file.name
        try:
            version_str = name.split("root_cyberwarfare-")[1].split(".zip")[0]
            Version(version_str)  # validate
            version_map[version_str].append(zip_file)
        except Exception:
            continue

    # Grouping
    def get_keys(version):
        v = Version(version)
        return {
            "major": f"{v.major}",
            "minor": f"{v.major}.{v.minor}",
            "patch": f"{v.major}.{v.minor}.{v.micro}"
        }

    major_map = defaultdict(list)
    minor_map = defaultdict(list)
    patch_map = defaultdict(list)

    for v_str in version_map:
        keys = get_keys(v_str)
        major_map[keys["major"]].append(v_str)
        minor_map[keys["minor"]].append(v_str)
        patch_map[keys["patch"]].append(v_str)

    # Sort and keep latest: 1 major, 2 minor, 3 patch
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

    # Delete unused zips
    for zip_file in all_zips:
        version_str = zip_file.name.split("root_cyberwarfare-")[1].split(".zip")[0]
        if version_str not in kept_versions:
            print(f"🗑️  Deleting old archive: {zip_file}")
            zip_file.unlink()

    # Commit deletion
    subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
    subprocess.run(["git", "config", "user.email", "github-actions@github.com"], check=True)
    subprocess.run(["git", "add", "releases"], check=True)
    subprocess.run(["git", "commit", "-m", "Cleanup: remove old mod archives"], check=True)
    subprocess.run(["git", "push"], check=True)

    # Create or update releases for kept versions
    kept_files = [f for v in kept_versions for f in version_map[v]]
    latest_version = None
    latest_version_obj = None

    for zip_file in kept_files:
        version = zip_file.name.split("root_cyberwarfare-")[1].split(".zip")[0]

        # Check if tag already exists
        result = subprocess.run(["git", "tag", "--list", version], stdout=subprocess.PIPE)
        tag_exists = bool(result.stdout.decode().strip())

        if not tag_exists:
            subprocess.run(["git", "tag", version], check=True)
            subprocess.run(["git", "push", "origin", version], check=True)
        else:
            print(f"🔁 Tag {version} already exists. Updating existing release...")

        # Extract top section from changelog
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

        # Check if release exists
        release_exists = subprocess.run(
            ["gh", "release", "view", version],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        ).returncode == 0

        if release_exists:
            print(f"🧹 Existing release found for {version}, cleaning up old assets...")
            assets_proc = subprocess.run(
                ["gh", "release", "view", version, "--json", "assets", "--jq", ".assets[].name"],
                stdout=subprocess.PIPE
            )
            assets = assets_proc.stdout.decode().strip().splitlines()
            for asset in assets:
                if asset:
                    print(f"🗑️ Deleting asset: {asset}")
                    subprocess.run(["gh", "release", "delete-asset", version, asset, "--yes"], check=True)

            subprocess.run([
                "gh", "release", "upload", version, str(zip_file), "--clobber"
            ], check=True)

            subprocess.run([
                "gh", "release", "edit", version, "--notes", notes
            ], check=True)
        else:
            subprocess.run([
                "gh", "release", "create", version, str(zip_file),
                "--title", f"root_cyberwarfare {version}",
                "--notes", notes
            ], check=True)

        # Track latest version
        v_obj = Version(version)
        if not latest_version_obj or v_obj > latest_version_obj:
            latest_version = version
            latest_version_obj = v_obj

    # Attach latest.zip if exists
    latest_zip = releases_dir / "root_cyberwarfare-latest.zip"
    if latest_version and latest_zip.exists():
        print(f"📦 Attaching latest.zip to {latest_version}")
        subprocess.run([
            "gh", "release", "upload", latest_version, str(latest_zip), "--clobber"
        ], check=True)

if __name__ == "__main__":
    main()