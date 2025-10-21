#!/usr/bin/env python3
import subprocess
import os
from pathlib import Path
from packaging.version import Version
from collections import defaultdict

def get_changelog_notes():
    """Extract the top section from CHANGELOG.md"""
    changelog_path = Path("releases/CHANGELOG.md")
    if not changelog_path.exists():
        return "Automated release"
    
    try:
        with open(changelog_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        section = []
        in_section = False
        for line in lines:
            if line.startswith("## "):
                if in_section:
                    break
                else:
                    in_section = True
                    section.append(line.strip())
            elif in_section:
                section.append(line.rstrip())

        return "\n".join(section) if section else "Automated release"
    except Exception as e:
        print(f"⚠️  Could not read changelog: {e}")
        return "Automated release"

def get_version_from_filename(filename):
    """Extract version from filename like root_cyberwarfare-1.2.3.4.zip"""
    try:
        return filename.split("root_cyberwarfare-")[1].split(".zip")[0]
    except:
        return None

def main():
    releases_dir = Path("releases")
    
    # Ensure releases directory exists
    if not releases_dir.exists():
        print("📁 Releases directory does not exist, nothing to process")
        return
    
    # Get all versioned zip files (excluding latest.zip)
    all_zips = list(releases_dir.glob("root_cyberwarfare-*.zip"))
    latest_zip = releases_dir / "root_cyberwarfare-latest.zip"
    
    # Separate versioned files from latest
    versioned_zips = [z for z in all_zips if z != latest_zip]
    
    if not versioned_zips:
        print("📭 No versioned release files found")
        return

    print(f"📦 Found {len(versioned_zips)} versioned release files")

    # Process each versioned file
    for zip_file in versioned_zips:
        version = get_version_from_filename(zip_file.name)
        if not version:
            print(f"⚠️  Could not extract version from {zip_file.name}, skipping")
            continue

        print(f"🚀 Processing version: {version}")

        # Get release notes from changelog
        notes = get_changelog_notes()
        title = f"Root's Cyber Warfare v{version}"

        # Check if release already exists
        result = subprocess.run(
            ["gh", "release", "view", version],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        release_exists = result.returncode == 0

        if release_exists:
            print(f"🔄 Release {version} exists, updating...")
            
            # Delete existing assets
            assets_proc = subprocess.run(
                ["gh", "release", "view", version, "--json", "assets", "--jq", ".assets[].name"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            if assets_proc.returncode == 0:
                assets = assets_proc.stdout.decode().strip().splitlines()
                for asset in assets:
                    if asset:
                        print(f"🗑️  Deleting old asset: {asset}")
                        subprocess.run(
                            ["gh", "release", "delete-asset", version, asset, "--yes"],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE
                        )

            # Upload new file and update release
            subprocess.run([
                "gh", "release", "upload", version, str(zip_file), "--clobber"
            ], check=True)

            subprocess.run([
                "gh", "release", "edit", version, 
                "--title", title,
                "--notes", notes
            ], check=True)
            
            print(f"✅ Updated release: {version}")
        else:
            print(f"🆕 Creating new release: {version}")
            subprocess.run([
                "gh", "release", "create", version, str(zip_file),
                "--title", title,
                "--notes", notes
            ], check=True)
            print(f"✅ Created new release: {version}")

    # Handle latest release
    if latest_zip.exists():
        print("🔁 Processing latest release...")
        notes = get_changelog_notes()
        title = "Root's Cyber Warfare Latest Release"
        
        # Check if latest release exists
        result = subprocess.run(
            ["gh", "release", "view", "latest"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        release_exists = result.returncode == 0

        if release_exists:
            print("🔄 Latest release exists, updating...")
            
            # Delete existing assets from latest release
            assets_proc = subprocess.run(
                ["gh", "release", "view", "latest", "--json", "assets", "--jq", ".assets[].name"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            if assets_proc.returncode == 0:
                assets = assets_proc.stdout.decode().strip().splitlines()
                for asset in assets:
                    if asset:
                        print(f"🗑️  Deleting old asset from latest: {asset}")
                        subprocess.run(
                            ["gh", "release", "delete-asset", "latest", asset, "--yes"],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE
                        )

            # Upload latest.zip
            subprocess.run([
                "gh", "release", "upload", "latest", str(latest_zip), "--clobber"
            ], check=True)

            subprocess.run([
                "gh", "release", "edit", "latest",
                "--title", title,
                "--notes", notes
            ], check=True)
        else:
            print("🆕 Creating latest release...")
            subprocess.run([
                "gh", "release", "create", "latest", str(latest_zip),
                "--title", title,
                "--notes", notes
            ], check=True)
        
        print("✅ Latest release updated")
    else:
        print("⚠️  latest.zip not found, skipping latest release")

    # Clean up old releases (retention policy)
    print("🧹 Applying retention policy...")
    apply_retention_policy(versioned_zips)

def apply_retention_policy(versioned_zips):
    """Keep 1 major, 2 minor, 3 patch versions and delete the rest locally"""
    version_map = defaultdict(list)
    
    # Group files by version
    for zip_file in versioned_zips:
        version = get_version_from_filename(zip_file.name)
        if version:
            try:
                Version(version)  # Validate version
                version_map[version].append(zip_file)
            except:
                continue

    if not version_map:
        print("📭 No valid versioned files found for retention policy")
        return

    # Group versions by major.minor.patch
    def get_version_keys(version_str):
        v = Version(version_str)
        return {
            "major": f"{v.major}",
            "minor": f"{v.major}.{v.minor}",
            "patch": f"{v.major}.{v.minor}.{v.micro}"
        }

    major_map = defaultdict(list)
    minor_map = defaultdict(list)
    patch_map = defaultdict(list)

    for v_str in version_map:
        keys = get_version_keys(v_str)
        major_map[keys["major"]].append(v_str)
        minor_map[keys["minor"]].append(v_str)
        patch_map[keys["patch"]].append(v_str)

    # Apply retention: 1 major, 2 minor, 3 patch
    kept_versions = set()
    
    # Get latest major version
    latest_major = sorted(major_map.keys(), key=Version, reverse=True)[:1]
    
    for major in latest_major:
        # Get 2 latest minor versions in this major
        minors = sorted(set([f"{major}.{Version(v).minor}" for v in major_map[major]]), 
                       key=Version, reverse=True)[:2]
        
        for minor in minors:
            # Get 3 latest patch versions in this minor
            patches = sorted(set([f"{minor}.{Version(v).micro}" for v in minor_map[minor]]), 
                            key=Version, reverse=True)[:3]
            
            for patch in patches:
                # Get the latest build for this patch version
                builds = sorted([v for v in patch_map[patch]], key=Version, reverse=True)
                if builds:
                    kept_versions.add(builds[0])

    print(f"🔒 Keeping versions: {sorted(kept_versions)}")

    # Delete old local files
    deleted_any = False
    for zip_file in versioned_zips:
        version = get_version_from_filename(zip_file.name)
        if version and version not in kept_versions:
            print(f"🗑️  Deleting old local archive: {zip_file.name}")
            zip_file.unlink()
            deleted_any = True

    # Commit deletions if any occurred
    if deleted_any:
        subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
        subprocess.run(["git", "config", "user.email", "github-actions@github.com"], check=True)
        subprocess.run(["git", "add", "releases/"], check=True)
        subprocess.run(["git", "commit", "-m", "Cleanup: remove old mod releases"], check=True)
        subprocess.run(["git", "push"], check=True)
        print("✅ Cleanup committed to repository")
    else:
        print("✅ No old files to clean up")

if __name__ == "__main__":
    main()