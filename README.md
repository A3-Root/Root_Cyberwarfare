# Root's Cyber Warfare

![version](https://img.shields.io/badge/version-0.1.0-blue)
[![build](https://github.com/A3-Root/Root_Cyberwarfare/actions/workflows/auto-release.yml/badge.svg?branch=master)](https://github.com/A3-Root/Root_Cyberwarfare/actions/workflows/auto-release.yml)
[![license](https://img.shields.io/badge/License-APL--SA-blue.svg)](https://github.com/A3-Root/Root_Cyberwarfare/blob/master/LICENSE)

![License](https://data.bistudio.com/images/license/APL-SA.png)

An improved adaptation and expansion of the original Cyber Warfare mod, adding advanced hacking capabilities to Arma 3 missions. Control doors, lights, vehicles, drones, and more through a terminal interface powered by AE3 ArmaOS.

## Features

Root's Cyber Warfare introduces 8 distinct device types that can be hacked and controlled via laptop terminals:

- **Building Doors** - Lock and unlock doors remotely, prevent ACE breaching
- **Lights** - Control building and street lights on/off
- **Drones (UAVs)** - Change faction allegiance or disable enemy drones
- **Vehicles** - Manipulate fuel, speed, brakes, lights, engine, and alarms
- **Databases** - Download files with optional code execution
- **Custom Devices** - Create custom scripted devices with activation/deactivation code
- **GPS Trackers** - Track objects in real-time with configurable update frequencies
- **Power Grids** - Control lights in radius with optional explosion effects

### Key Capabilities

- **Power Management System** - All operations consume battery power (configurable costs in Wh)
- **Flexible Access Control** - Link devices to specific computers or make them public
- **Zeus & 3DEN Support** - 9 Zeus modules and 8 3DEN editor modules for easy setup
- **ACE Integration** - GPS tracker attachment via ACE interaction menu
- **Programmable Devices** - Custom devices with SQF activation/deactivation scripts
- **Mission Maker API** - Full programmatic access for dynamic scenarios

## Requirements

### Dependencies (Required)

- [CBA_A3](https://github.com/CBATeam/CBA_A3) - Community Base Addons
- [ACE3](https://github.com/acemod/ACE3) - Advanced Combat Environment 3
- [AE3](https://github.com/y0014984/Advanced-Equipment) - Advanced Equipment 3 (ArmaOS)
- [ZEN](https://github.com/zen-mod/ZEN) - Zeus Enhanced

## Installation

### Steam Workshop

1. Subscribe to Root's Cyber Warfare on Steam Workshop
2. Subscribe to all required dependencies (CBA, ACE3, AE3, ZEN)
3. Launch Arma 3 and enable the mod in the launcher

### Manual Installation

1. Download the latest release from [GitHub Releases](https://github.com/A3-Root/Root_Cyberwarfare/releases)
2. Extract the `@root_cyberwarfare` folder to your Arma 3 directory
3. Add `-mod=@CBA_A3;@ace;@AE3;@zen;@root_cyberwarfare` to your launch parameters

## Quick Start

### For Players

1. Open ACE interaction menu on an AE3 laptop (Windows key or ACE self-interact)
2. Select **ArmaOS** -> **Use**
3. Type `devices all` to list all hackable devices you have access to
4. Use specific commands to control devices (e.g., `door 1234 a unlock`)

### For Zeus Curators

1. Open Zeus interface (Y key by default)
2. Find **Root's Cyber Warfare** category in modules
3. Use **Add Hacking Tools** module on a laptop
4. Use **Add Hackable Object/Vehicle/etc.** modules to register devices
5. Players can now hack those devices from the laptop

### For Mission Makers

```sqf
// Add hacking tools to a laptop
[_laptop, "/network/tools", 0, "HackStation", ""] call Root_fnc_addHackingToolsZeusMain;

// Register a building with doors as hackable
[_building, 0, [], false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Register a vehicle with full control
[_vehicle, 0, [], "TargetCar", true, true, false, true, true, false, false, 2]
    remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

## Examples

### Example 1: Mission with Hackable Building

```sqf
// initServer.sqf
// Setup hacking laptop
private _laptop = _laptop1; // Reference to AE3 laptop placed in editor
[_laptop, "/home/hacker/tools", 0, "HackingStation", ""] call Root_fnc_addHackingToolsZeusMain;

// Make a building hackable
private _building = nearestBuilding player;
[_building, 0, [_laptop], false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Players can now use the laptop to lock/unlock doors:
// door <BuildingID> <DoorID> lock/unlock
```

### Example 2: GPS Tracking Mission

```sqf
// Attach GPS tracker to enemy vehicle
private _enemyVehicle = _vehicle1;
[_enemyVehicle, 0, [_laptop1], "Enemy_Car", 120, 5, "", false, true, 30, 5, true, [[], [], []]]
    remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// Players use: gpstrack <TrackerID>
// Map markers update every 5 seconds for 120 seconds
```

### Example 3: Custom Device (Alarm System)

```sqf
// Create custom alarm device on an object
private _alarmBox = _object1;
[
    _alarmBox,
    0,
    [_laptop1],
    "Base Alarm",
    "playSound3D ['a3\sounds_f\sfx\alarm.wss', _this select 0, false, getPosASL (_this select 0), 5, 1, 300];",
    "hint 'Alarm deactivated';",
    false
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];

// Activation code plays alarm sound, deactivation shows hint
```

## Documentation

Comprehensive documentation is available in the [Wiki](https://github.com/A3-Root/Root_Cyberwarfare/wiki):

- **[Player Guide](wiki/Player-Guide.md)** - Terminal commands and GPS tracker mechanics
- **[Zeus Guide](wiki/Zeus-Guide.md)** - All Zeus modules with parameters
- **[Eden Editor Guide](wiki/Eden-Editor-Guide.md)** - 3DEN modules and synchronization
- **[Mission Maker Guide](wiki/Mission-Maker-Guide.md)** - Scripting API and examples
- **[API Reference](wiki/API-Reference.md)** - Complete function reference
- **[Architecture](wiki/Architecture.md)** - Technical implementation details
- **[Configuration](wiki/Configuration.md)** - CBA settings reference

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Report Bugs** - Use [GitHub Issues](https://github.com/A3-Root/Root_Cyberwarfare/issues) with detailed reproduction steps
2. **Suggest Features** - Open an issue with the `enhancement` label
3. **Submit Pull Requests**:
   - Fork the repository
   - Create a feature branch (`git checkout -b feature/YourFeature`)
   - Follow existing code style and patterns
   - Run `hemtt check -p` to validate SQF code
   - Ensure all HEMTT linting passes with no errors
   - Update documentation if adding new features
   - Submit PR with clear description

### Development Requirements

- [HEMTT](https://github.com/BrettMayson/HEMTT) - Build tool for Arma 3 mods
- Run `hemtt dev` to build and symlink to Arma 3 directory
- Run `hemtt check -p` to validate code before committing

## License

This project is licensed under the **Arma Public License - Share Alike (APL-SA)**.

Key terms:
- **Attribution** - Credit must be given to the original author (Root)
- **Non-Commercial** - Cannot be used for commercial purposes
- **Arma Only** - Can only be used in Arma games
- **Share Alike** - Derivative works must use the same license

See [LICENSE](LICENSE) file for full terms.

## Credits

- **Root** (xMidnightSnowx) - Development and maintenance
- **Mister Adrian** - Original Cyber Warfare mod creator
- **77th JSOC** - Bug reports, feature suggestions, and testing

## Links

- [GitHub Repository](https://github.com/A3-Root/Root_Cyberwarfare)
- [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=XXXXXX)
- [Issue Tracker](https://github.com/A3-Root/Root_Cyberwarfare/issues)
- [Discord](https://discord.gg/77th-jsoc-official)
