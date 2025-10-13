# Root's Cyber Warfare Wiki

Welcome to the official documentation for **Root's Cyber Warfare**, an Arma 3 mod that adds cyberwarfare mechanics to missions through the AE3 (Advanced Equipment) filesystem.

## Overview

Root's Cyber Warfare allows players to hack doors, drones, lights, vehicles, GPS trackers, and custom devices using in-game laptops with terminal access. The mod integrates seamlessly with ACE3 for interaction menus and ZEN for dynamic Zeus modules.

**Current Version**: 2.20.0

## Key Features

- 🚪 **Door Control** - Lock/unlock building doors remotely
- 💡 **Light Manipulation** - Control streetlights and lamps
- 🚁 **Drone Hacking** - Change drone factions or disable them
- 📁 **Database Access** - Download files with progress bars
- 📍 **GPS Tracking** - Attach and track GPS trackers
- 🚗 **Vehicle Hacking** - Manipulate vehicle parameters (battery, speed, brakes, lights, engine, alarm)
- ⚡ **Custom Devices** - Create your own hackable objects with custom scripts
- 💡 **Power Generators** - Control lights within radius with optional explosions
- 🔋 **Power Management** - Laptop battery consumption system
- 🎯 **Zeus Modules** - 7 dynamic modules for mission makers
- 🏗️ **Eden Modules** - 7 pre-mission configuration modules
- 🔐 **Access Control** - Device linking and backdoor system

## Documentation Table of Contents

### 1. [Home](Home)
Welcome page with mod overview and key features

### 2. [Player Guide](Player-Guide)
Learn how to use hacking tools and interact with devices in-game

### 3. [Terminal Commands Reference](Terminal-Commands)
Complete reference for all terminal commands available to players

### 4. [Zeus/Curator Guide](Zeus-Guide)
Guide for Zeus/Curator on using 7 dynamic modules to add hackable devices

### 5. [Mission Maker Guide](Mission-Maker-Guide)
Scripting integration and advanced mission-making techniques

### 6. [Eden Modules Reference](Eden-Modules)
Pre-mission configuration using 7 Eden Editor modules

### 7. [Configuration Reference](Configuration)
CBA settings and configuration options

### 8. [Custom Device Tutorial](Custom-Device-Tutorial)
Step-by-step guide to creating your own custom hackable objects

### 9. [Architecture & Technical Details](Architecture)
Technical documentation on system design and implementation

### 10. [API Reference](API-Reference)
Complete function documentation for developers

## Dependencies

Root's Cyber Warfare requires the following mods:

| Dependency | Required | Purpose |
|------------|----------|---------|
| [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997) | **Yes** | Settings, events, function framework |
| [ACE3](https://steamcommunity.com/workshop/filedetails/?id=463939057) | **Yes** | Interaction menus, GPS tracker placement |
| [AE3](https://steamcommunity.com/workshop/filedetails/?id=2888888564) | **Yes** | Virtual filesystem and laptop functionality |
| [ZEN](https://steamcommunity.com/workshop/filedetails/?id=1779063631) | **Yes** | Zeus modules and configuration dialogs |

## What's New in Version 2.20.0

Version 2.20.0 includes new features, refactoring, and bug fixes:

- ✨ **Power Generator Module** - New Zeus/Eden module for radius-based light control with optional explosions
- ✨ **Eden Modules** - Full 3DEN Editor integration with 7 pre-mission configuration modules
- ✅ **Two-Step Workflow** - Eden modules create device links, hacking tools enable access
- ✅ **GPS Improvements** - Fixed duplicate position printing, improved null object tracking
- ✅ **Bug Fixes** - Fixed door control errors, 3DEN module type conversions, cache initialization
- ✅ **Code Cleanup** - Removed redundant parameter passing, improved code organization
- ✅ **Documentation** - Comprehensive wiki updates including dedicated Eden Modules page
- ✅ **Access Control** - Fixed "Available to Future Laptops" functionality with proper cache persistence

### Architecture

The mod uses a hybrid storage approach:
- **Array-based device storage** (`ROOT_CYBERWARFARE_ALL_DEVICES`) for simple iteration
- **HashMap-based link cache** (`ROOT_CYBERWARFARE_LINK_CACHE`) for O(1) computer-to-device lookups
- **Array-based public devices** with exclusion lists for "Available to Future Laptops" feature

## Community & Support

- **GitHub Repository**: [A3-Root/Root_Cyberwarfare](https://github.com/A3-Root/Root_Cyberwarfare)
- **Issues & Bug Reports**: [GitHub Issues](https://github.com/A3-Root/Root_Cyberwarfare/issues)
- **Steam Workshop**: [Root's Cyber Warfare](https://steamcommunity.com/sharedfiles/filedetails/?id=YOUR_ID)

## Contributing

Contributions are welcome! Please see the repository for contribution guidelines.

## License

Root's Cyber Warfare is released under Arma 3 Public License - Share Alike (APL-SA). See the repository for full license details.

---

**Need help?** Join discord or raise an issue in GitHub.
