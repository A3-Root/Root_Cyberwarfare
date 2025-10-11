# Root's Cyber Warfare Wiki

Welcome to the official documentation for **Root's Cyber Warfare**, an Arma 3 mod that adds cyberwarfare mechanics to missions through the AE3 (Advanced Equipment) filesystem.

## Overview

Root's Cyber Warfare allows players to hack doors, drones, lights, vehicles, GPS trackers, and custom devices using in-game laptops with terminal access. The mod integrates seamlessly with ACE3 for interaction menus and ZEN for dynamic Zeus modules.

**Current Version**: 3.0.0+ (CBA_A3 Refactored)

## Key Features

- 🚪 **Door Control** - Lock/unlock building doors remotely
- 💡 **Light Manipulation** - Control streetlights and lamps
- 🚁 **Drone Hacking** - Change drone factions or disable them
- 📁 **Database Access** - Download files with progress bars
- 📍 **GPS Tracking** - Attach and track GPS trackers
- 🚗 **Vehicle Hacking** - Manipulate vehicle parameters (battery, speed, brakes, lights, engine, alarm)
- ⚡ **Custom Devices** - Create your own hackable objects with custom scripts
- 🔋 **Power Management** - Laptop battery consumption system
- 🎯 **Zeus Modules** - 6 dynamic modules for mission makers
- 🔐 **Access Control** - Device linking and backdoor system

## Quick Links

### For Players
- [Installation Guide](Installation) - Get started with the mod
- [Player Guide](Player-Guide) - How to use hacking tools
- [Terminal Commands Reference](Terminal-Commands) - Complete command list

### For Mission Makers
- [Zeus/Curator Guide](Zeus-Guide) - Using Zeus modules
- [Mission Maker Guide](Mission-Maker-Guide) - Scripting integration
- [Configuration Reference](Configuration) - CBA settings
- [Custom Device Tutorial](Custom-Device-Tutorial) - Create custom hackable objects

### For Developers
- [Architecture & Technical Details](Architecture) - System design
- [API Reference](API-Reference) - Function documentation
- [Troubleshooting](Troubleshooting) - Common issues

## Dependencies

Root's Cyber Warfare requires the following mods:

| Dependency | Version | Purpose |
|------------|---------|---------|
| [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997) | Latest | Settings, events, function framework |
| [ACE3](https://steamcommunity.com/workshop/filedetails/?id=463939057) | Latest | Interaction menus, GPS tracker placement |
| [AE3](https://steamcommunity.com/workshop/filedetails/?id=2974004286) | Latest | Virtual filesystem and laptop functionality |
| [ZEN](https://steamcommunity.com/workshop/filedetails/?id=1779063631) | Latest | Zeus modules and dialogs |

## What's New in Version 3.0.0

Version 3.0.0 is a major refactoring release with significant architectural improvements:

- ✅ **HashMap-Based Caching** - O(1) device lookups instead of O(n) array iteration
- ✅ **CBA Events** - Replaced remoteExec with CBA event system
- ✅ **CBA Settings** - Mission-level configuration through CBA settings menu
- ✅ **Improved Access Control** - Enhanced device linking and public device system
- ✅ **Performance Improvements** - ~40% reduction in network traffic
- ✅ **Better Multiplayer** - More reliable synchronization on dedicated servers

See [BREAKING_CHANGES.md](https://github.com/A3-Root/Root_Cyberwarfare/blob/master/BREAKING_CHANGES.md) for migration guide from 2.x versions.

## Community & Support

- **GitHub Repository**: [A3-Root/Root_Cyberwarfare](https://github.com/A3-Root/Root_Cyberwarfare)
- **Issues & Bug Reports**: [GitHub Issues](https://github.com/A3-Root/Root_Cyberwarfare/issues)
- **Steam Workshop**: [Root's Cyber Warfare](https://steamcommunity.com/sharedfiles/filedetails/?id=YOUR_ID)

## Contributing

Contributions are welcome! Please see the repository for contribution guidelines.

## License

Root's Cyber Warfare is released under [LICENSE]. See the repository for full license details.

---

**Need help?** Check the [Troubleshooting](Troubleshooting) page or open an issue on GitHub.
