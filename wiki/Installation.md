# Installation Guide

This guide covers installing Root's Cyber Warfare for Arma 3.

## Requirements

Before installing, ensure you have:

| Requirement | Version | Download Link |
|-------------|---------|---------------|
| Arma 3 | Latest stable | [Steam](https://store.steampowered.com/app/107410/Arma_3/) |
| CBA_A3 | Latest | [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=450814997) |
| ACE3 | Latest | [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=463939057) |
| AE3 (Advanced Equipment) | Latest | [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=2974004286) |
| ZEN (Zeus Enhanced) | Latest | [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=1779063631) |

**Minimum Arma 3 Version**: 2.00 or higher

## Installation Methods

Choose one of the following installation methods:

---

## Method 1: Steam Workshop (Recommended)

This is the easiest installation method and provides automatic updates.

### Steps:

1. **Subscribe to all dependencies** in order:
   - [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997)
   - [ACE3](https://steamcommunity.com/workshop/filedetails/?id=463939057)
   - [AE3](https://steamcommunity.com/workshop/filedetails/?id=2974004286)
   - [ZEN](https://steamcommunity.com/workshop/filedetails/?id=1779063631)

2. **Subscribe to Root's Cyber Warfare**:
   - Visit the [Steam Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=YOUR_ID)
   - Click the **Subscribe** button
   - Wait for the download to complete

3. **Launch Arma 3** and verify the mod is loaded:
   - Go to Main Menu → Expansions
   - Verify "Root's Cyber Warfare" appears in the list with a green checkmark
   - Verify all dependencies are also loaded

**Done!** The mod is now installed and ready to use.

---

## Method 2: Manual Installation

For advanced users or server administrators who want manual control.

### Steps:

1. **Download the mod**:
   - Download the latest release from [GitHub Releases](https://github.com/A3-Root/Root_Cyberwarfare/releases)
   - Extract the archive to a temporary location

2. **Install dependencies manually**:
   - Download and install CBA_A3, ACE3, AE3, and ZEN using the same manual process

3. **Copy mod files**:
   ```
   Copy the @root_cyberwarfare folder to your Arma 3 root directory
   Example: C:\Program Files (x86)\Steam\steamapps\common\Arma 3\
   ```

4. **Verify folder structure**:
   ```
   Arma 3\
   ├── @root_cyberwarfare\
   │   ├── addons\
   │   │   └── root_cyberwarfare_main.pbo
   │   └── mod.cpp
   ```

5. **Launch Arma 3 with mods**:
   - Add launch parameter: `-mod=@CBA_A3;@ace;@AE3;@zen;@root_cyberwarfare`
   - Or use a launcher like Arma 3 Launcher to enable the mods

---

## Server Installation

For dedicated server administrators:

### Steps:

1. **Install all dependencies** on the server using manual installation method

2. **Copy Root's Cyber Warfare**:
   ```
   Upload @root_cyberwarfare folder to server's Arma 3 directory
   ```

3. **Add to server startup parameters**:
   ```bash
   -mod=@CBA_A3;@ace;@AE3;@zen;@root_cyberwarfare
   ```

4. **Configure CBA settings** (optional):
   - Edit `userconfig/cba_settings.sqf` on the server
   - Set Root's Cyber Warfare settings (see [Configuration Reference](Configuration))
   - Example:
   ```sqf
   force root_cyberwarfare_gps_tracker_device = "ACE_Banana";
   force root_cyberwarfare_drone_hack_cost = 10;
   ```

5. **Restart the server** and verify the mod loads without errors in the RPT log

---

## Verifying Installation

After installation, verify everything works:

### In-Game Check:

1. **Start Arma 3** and load any mission
2. **Open the Virtual Arsenal** or place a laptop in the editor
3. **Check for AE3 interaction** - You should see ACE interaction menu options
4. **Open Zeus** (if available) - Verify Root's Cyber Warfare modules appear in Zeus menu

### Console Check:

Open the debug console and run:
```sqf
hint str (isClass (configFile >> "CfgPatches" >> "root_cyberwarfare_main"));
```
- **Result should be `true`** - Mod is loaded correctly
- **Result is `false`** - Mod failed to load, check RPT log

### RPT Log Check:

Open your RPT log file:
```
C:\Users\YourName\AppData\Local\Arma 3\
```

Search for `Root_Cyberwarfare` - you should see:
```
[CBA] Root_Cyberwarfare: Settings initialized
[CBA] Root_Cyberwarfare: Functions compiled
```

No errors should appear.

---

## Troubleshooting Installation

### Common Issues:

#### "Addon 'root_cyberwarfare_main' requires addon 'cba_main'"

**Cause**: CBA_A3 is not loaded or wrong load order

**Solution**:
- Ensure CBA_A3 is subscribed/installed
- Check mod load order (CBA must load first)
- Verify `-mod=` parameter includes `@CBA_A3` before `@root_cyberwarfare`

#### "Missing AE3_filesystem"

**Cause**: AE3 is not installed or not loaded

**Solution**:
- Install AE3 from [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=2974004286)
- Verify AE3 is in the mod load order

#### "Zeus modules not appearing"

**Cause**: ZEN is not loaded or outdated

**Solution**:
- Install/update ZEN from [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=1779063631)
- Verify Zeus/Curator role in mission

#### Mod loads but no hacking tools available

**Cause**: Hacking tools not added to laptop

**Solution**:
- Use Zeus module "Add Hacking Tools" on a laptop object
- Or use script: `[_laptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];`

---

## Updating the Mod

### Steam Workshop:
Updates are automatic. Just restart Arma 3 after Steam downloads the update.

### Manual Installation:
1. Download the new release from GitHub
2. Delete the old `@root_cyberwarfare` folder
3. Extract the new version to the same location
4. Restart Arma 3/Server

---

## Uninstallation

### Steam Workshop:
1. Go to Steam Workshop
2. Find Root's Cyber Warfare in your subscriptions
3. Click "Unsubscribe"
4. Restart Arma 3

### Manual Installation:
1. Delete the `@root_cyberwarfare` folder from your Arma 3 directory
2. Remove from launch parameters
3. Restart Arma 3

---

## Next Steps

- [Player Guide](Player-Guide) - Learn how to use hacking tools
- [Zeus Guide](Zeus-Guide) - Add hacking capabilities to your missions
- [Configuration Reference](Configuration) - Customize settings

**Need more help?** See [Troubleshooting](Troubleshooting) or open an issue on GitHub.
