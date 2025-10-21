#!/usr/bin/env python3
import re
import os
import sys
import subprocess
from pathlib import Path
from packaging.version import Version # type: ignore
from collections import defaultdict

def get_latest_version():
    """Get the latest version from release files"""
    releases_dir = Path("releases")
    if not releases_dir.exists():
        return None
    
    versioned_zips = list(releases_dir.glob("root_cyberwarfare-*.zip"))
    latest_zip = releases_dir / "root_cyberwarfare-latest.zip"
    versioned_zips = [z for z in versioned_zips if z != latest_zip]
    
    if not versioned_zips:
        return None
    
    def get_version_from_filename(filename):
        try:
            return filename.name.split("root_cyberwarfare-")[1].split(".zip")[0]
        except:
            return None
    
    versions = []
    for zip_file in versioned_zips:
        version = get_version_from_filename(zip_file)
        if version:
            try:
                Version(version)  # Validate version
                versions.append(version)
            except:
                continue
    
    if not versions:
        return None
    
    # Return the highest version
    return sorted(versions, key=Version, reverse=True)[0]

def update_readme_version(version, status="success"):
    """Update version and build status in README.md"""
    readme_path = Path("README.md")
    if not readme_path.exists():
        print("❌ README.md not found")
        return False
    
    try:
        with open(readme_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Update version badge
        version_badge_pattern = r'!\[Version\]\(https://img\.shields\.io/badge/version-[^-]+-blue\)'
        new_version_badge = f'![Version](https://img.shields.io/badge/version-{version}-blue)'
        content = re.sub(version_badge_pattern, new_version_badge, content)
        
        # Update build status badge
        if status == "success":
            build_badge = '![Build](https://img.shields.io/badge/Build-Passing-green)'
        else:
            build_badge = '![Build](https://img.shields.io/badge/Build-Failing-red)'
        
        build_badge_pattern = r'!\[Build\]\(https://img\.shields\.io/badge/Build-(Passing|Failing)-(green|red)\)'
        content = re.sub(build_badge_pattern, build_badge, content)
        
        # Update version in the main title if present
        version_in_title_pattern = r'# Root\'s Cyber Warfare\n\n!\[Version\].*?version-([\d.]+)-blue'
        content = re.sub(version_in_title_pattern, f'# Root\'s Cyber Warfare\n\n{new_version_badge}', content)
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Updated README with version {version} and status: {status}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to update README: {e}")
        return False

def commit_readme_changes(version, status):
    """Commit the updated README back to the repository"""
    try:
        # Configure git
        subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
        subprocess.run(["git", "config", "user.email", "github-actions@github.com"], check=True)
        
        # Add and commit README
        subprocess.run(["git", "add", "README.md"], check=True)
        
        if status == "success":
            commit_message = f"docs: update README for version {version} [skip ci]"
        else:
            commit_message = f"docs: update README with build failure status [skip ci]"
        
        subprocess.run(["git", "commit", "-m", commit_message], check=True)
        subprocess.run(["git", "push"], check=True)
        
        print(f"✅ Committed README changes to repository")
        return True
        
    except Exception as e:
        print(f"❌ Failed to commit README changes: {e}")
        return False

def main():
    # Get status from command line argument
    status = "success"
    if len(sys.argv) > 1 and sys.argv[1] == "--status":
        status = sys.argv[2] if len(sys.argv) > 2 else "success"
    
    # Get latest version
    latest_version = get_latest_version()
    if not latest_version:
        print("❌ Could not determine latest version")
        # Still update build status even if version can't be determined
        latest_version = "unknown"
    
    print(f"📝 Updating README - Version: {latest_version}, Status: {status}")
    
    # Update README
    if update_readme_version(latest_version, status):
        # Commit changes back to repository
        commit_readme_changes(latest_version, status)
    else:
        print("❌ Failed to update README")
        sys.exit(1)

if __name__ == "__main__":
    main()