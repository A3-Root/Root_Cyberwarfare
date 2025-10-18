# Root's Cyber Warfare

![Version](https://img.shields.io/badge/version-2.20.1-blue.svg)
![Arma 3](https://img.shields.io/badge/Arma%203-1.0+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A comprehensive cyber warfare mod for Arma 3 that adds hacking capabilities for vehicles, drones, buildings, and custom devices.

---

## Features

### Hackable Devices

- **Buildings** - Lock/unlock doors remotely with optional unbreachable mode
- **Lights** - Control street lamps and building lights
- **Vehicles** - Manipulate fuel, speed, brakes, lights, engine, and alarms
- **Drones/UAVs** - Change faction or permanently disable drones
- **Custom Devices** - Create scripted devices with custom activation/deactivation code
- **GPS Trackers** - Real-time position tracking for units and vehicles
- **Power Generators** - Control power grids affecting lights in a radius
- **Databases** - Downloadable files with customizable content

### Access Control System

Sophisticated 3-tier access control:

1. **Backdoor Access** - Admin/debug access bypassing all checks
2. **Public Device Access** - Devices available to all or future laptops
3. **Private Link Access** - Direct computer-to-device relationships

### Power Management

All hacking operations consume power from the laptop's battery (managed by AE3 ArmaOS). Power costs are fully configurable via CBA settings and vary by operation type.

### Integration

- **Zeus Enhanced (ZEN)** - Runtime device registration via Zeus modules
- **Eden Editor** - Pre-mission device setup with dedicated modules
- **Scripting API** - Programmatic device registration for mission makers
- **ACE3 Integration** - GPS tracker attachment via ACE interaction menu
- **AE3 ArmaOS** - Terminal interface for all hacking operations

---

## Installation

1. Download the latest release from [Releases](https://github.com/ROOT/Root_Cyberwarfare/releases)
2. Extract to your Arma 3 mods folder
3. Enable the mod in the Arma 3 launcher

**Required Dependencies** (all mandatory):
- [CBA_A3](https://github.com/CBATeam/CBA_A3) - Community Base Addons
- [ACE3](https://github.com/acemod/ACE3) - Advanced Combat Environment
- [AE3](https://github.com/WildTangent/Advanced-Equipment) - Advanced Equipment (ArmaOS)
- [ZEN](https://github.com/zen-mod/ZEN) - Zeus Enhanced

---

## Usage

### For Players

1. Find a laptop with hacking tools installed
2. Use ACE interaction menu (Windows key) → "Access Terminal"
3. Use the `devices` command to list hackable devices
4. Execute commands to control devices (e.g., `door 1234 unlock`)

**See**: [Player Guide](wiki/Player-Guide.md) | [Terminal Commands](wiki/Terminal-Commands.md)

### For Zeus / Game Masters

1. Open Zeus interface (Y key)
2. Navigate to Modules → Root Cyber Warfare
3. Use modules to add hacking tools and register devices

**Available Modules**:
- Add Hacking Tools (Laptop)
- Add Hackable Building/Light
- Add Hackable Vehicle (auto-detects drones)
- Add Custom Device
- Add Power Generator

**See**: [Zeus Guide](wiki/Zeus-Guide.md)

### For Mission Makers

**Eden Editor**:
- Place laptop → Add "Add Hacking Tools" module
- Place devices → Add corresponding modules
- Sync modules to laptops for access control

**Scripting**:
```sqf
// Add hacking tools to laptop
[laptop1, "", 0, "HQ Terminal", []] call Root_fnc_addHackingToolsZeusMain;

// Register enemy building
[building1, 0, [netId laptop1], false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Register vehicle
[car1, 0, [], "Enemy Transport", true, false, false, false, true, false, false, 5] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**See**: [Eden Editor Guide](wiki/Eden-Editor-Guide.md) | [Mission Maker Guide](wiki/Mission-Maker-Guide.md) | [API Reference](wiki/API-Reference.md)

---

## CBA Configuration

Configure power costs and settings via:

**Main Menu → Options → Addon Options → Root's Cyber Warfare**

**Available Settings**:
- Power cost for door operations (default: 2 Wh)
- Power cost for light operations (default: 2 Wh)
- Power cost for drone faction change (default: 20 Wh)
- Power cost for drone disable (default: 10 Wh)
- Power cost for custom devices (default: 10 Wh)
- GPS tracker update interval (default: 10 seconds)
- GPS tracker maximum range (default: unlimited)

**See**: [Configuration Guide](wiki/Configuration.md)

---

## Documentation

### Guides

- [Home](wiki/Home.md) - Documentation overview
- [Player Guide](wiki/Player-Guide.md) - How to use hacking tools in-game
- [Zeus Guide](wiki/Zeus-Guide.md) - Runtime setup as Zeus/GM
- [Eden Editor Guide](wiki/Eden-Editor-Guide.md) - Pre-mission setup
- [Mission Maker Guide](wiki/Mission-Maker-Guide.md) - Script-based mission creation
- [Configuration Guide](wiki/Configuration.md) - CBA settings and customization
- [Terminal Commands](wiki/Terminal-Commands.md) - Complete command reference
- [API Reference](wiki/API-Reference.md) - Function reference for developers

### Architecture

See [CLAUDE.md](CLAUDE.md) for:
- Build system (HEMTT) usage
- Code architecture and organization
- Data storage structure (3-tier hybrid system)
- Function patterns and naming conventions
- Development workflows

---

## Building from Source

This mod uses [HEMTT](https://github.com/BrettMayson/HEMTT) for building and packaging.

**Common Commands**:
```bash
hemtt dev         # Development build with symlink
hemtt build       # Test build before signing
hemtt release     # Production build with signing
hemtt check -p    # Lint and validate all SQF code
```

**Requirements**:
- HEMTT v0.8.0+
- Arma 3 Tools (for signing)

**See**: [CLAUDE.md](CLAUDE.md) for detailed build instructions

---

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Code Style**: Follow existing patterns in CLAUDE.md
2. **Linting**: Run `hemtt check -p` before committing (must pass with no errors)
3. **Documentation**: Update wiki pages for user-facing changes
4. **Testing**: Test changes in Arma 3 with all dependencies
5. **Commits**: Use clear, descriptive commit messages

**Pull Request Process**:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run `hemtt check -p` and `hemtt build` to validate
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

**Bug Reports**:
- Use [GitHub Issues](https://github.com/ROOT/Root_Cyberwarfare/issues)
- Include RPT log excerpts
- Provide reproduction steps
- List mod versions and dependencies

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Credits

- **Author**: Root
- **Framework**: CBA_A3 by CBA Team
- **Dependencies**: ACE3 Team, AE3 Team, ZEN Team

---

## Support

- **Issues**: [GitHub Issues](https://github.com/ROOT/Root_Cyberwarfare/issues)
- **Documentation**: [Wiki](wiki/Home.md)
- **Discord**: [Link to Discord Server]

---

## Changelog

### 2.20.1 (Current)
- New modules and todolist
- Power fixes
- Bugfixes
- GPS fix

### Previous Versions
See [CHANGELOG.md](CHANGELOG.md) for full version history.

---

## Screenshots

[Add screenshots here showing:]
- Terminal interface with device list
- Zeus module placement
- Hacking operations in action
- GPS tracker display
- Custom device examples

---

## Roadmap

- [ ] Network packet interception
- [ ] Firewall bypass mechanics
- [ ] Multi-stage hacking challenges
- [ ] Countermeasure systems
- [ ] Additional device types
- [ ] Mission templates and examples

---

**Enjoy hacking in Arma 3!**
