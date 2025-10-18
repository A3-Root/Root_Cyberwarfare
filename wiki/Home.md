# Root's Cyber Warfare

Welcome to the Root's Cyber Warfare documentation wiki! This mod adds comprehensive cyber warfare capabilities to Arma 3, allowing players to hack vehicles, drones, buildings, and custom devices using laptops with hacking tools.

## Quick Links

- [Player Guide](Player-Guide) - Learn how to use hacking tools in-game
- [Zeus Guide](Zeus-Guide) - How to set up hackable objects as a Zeus/Game Master
- [Eden Editor Guide](Eden-Editor-Guide) - Pre-mission setup in the Eden Editor
- [Mission Maker Guide](Mission-Maker-Guide) - Script-based mission creation
- [Configuration Guide](Configuration) - CBA settings and customization options
- [API Reference](API-Reference) - Function reference for developers
- [Architecture](Architecture) - Technical architecture and system design

## Features

### Hackable Devices

- **Buildings** - Lock/unlock doors remotely, with optional unbreachable mode
- **Lights** - Control street lamps and building lights
- **Vehicles** - Control fuel, speed, brakes, lights, engine, and alarms
- **Drones/UAVs** - Change faction or disable drones
- **Custom Devices** - Create scripted devices with custom activation/deactivation code
- **GPS Trackers** - Attach trackers to units and vehicles for real-time positioning
- **Power Generators** - Control power grids affecting lights in a radius
- **Databases** - Downloadable files with customizable content

### Access Control System

The mod features a sophisticated 3-tier access control system:

1. **Backdoor Access** - Admin/debug access bypassing all checks
2. **Public Device Access** - Devices available to all or future laptops
3. **Private Link Access** - Direct computer-to-device relationships

### Power System

All hacking operations consume power from the laptop's battery (managed by AE3 ArmaOS). Power costs are configurable via CBA settings and vary by operation type.

## Dependencies

This mod requires the following dependencies (all are mandatory):

- **CBA_A3** - Community Base Addons (framework, macros, events, settings)
- **ACE3** - Advanced Combat Environment (interaction menu system)
- **AE3 (Advanced Equipment 3)** - ArmaOS terminal system
- **ZEN (Zeus Enhanced)** - Zeus module base classes

## Getting Started

### For Players

1. Read the [Player Guide](Player-Guide) to understand how to use hacking tools
2. Check the [Terminal Guide](Terminal-Commands) for available commands
3. Access terminals via ACE interaction menu on laptops with hacking tools

### For Mission Makers

1. Review the [Zeus Guide](Zeus-Guide) for quick in-game setup
2. Check the [Eden Editor Guide](Eden-Editor-Guide) for pre-mission configuration
3. See the [Mission Maker Guide](Mission-Maker-Guide) for scripted setups

### For Developers

1. Review the [API Reference](API-Reference) for function documentation
2. Check the [Configuration Guide](Configuration) for CBA settings

## Support

For bug reports, feature requests, or general support, please visit the [GitHub Issues](https://github.com/A3-Root/Root_Cyberwarfare/issues) page.

## Version

Current Version: **2.20.1**

## License

![License](https://data.bistudio.com/images/license/APL-SA.png)

This project is licensed under the **Arma Public License - Share Alike (APL-SA)**. With this license you are free to adapt (i.e. modify, rework or update) and share (i.e. copy, distribute or transmit) the material under the following conditions:

- **Attribution** - You must attribute the material in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the material).
- **Noncommercial** - You may not use this material for any commercial purposes.
- **Arma Only** - You may not convert or adapt this material to be used in other games than Arma.
- **Share Alike** - If you adapt, or build upon this material, you may distribute the resulting material only under the same license.

See [LICENSE](https://github.com/A3-Root/Root_Cyberwarfare/LICENSE) file for more details.

## Credits

- **Author**: Root
- **Framework**: CBA_A3 by CBA Team
- **Dependencies**: ACE3 Team, AE3 Team, ZEN Team
