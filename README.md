# Root's Cyber Warfare

A comprehensive cyberwarfare mod for Arma 3 that adds hacking mechanics, GPS tracking, device control, and network infiltration capabilities to enhance tactical gameplay.

![Version](https://img.shields.io/badge/version-2.19.0-blue)
![Arma 3](https://img.shields.io/badge/Arma%203-Required-red)
![CBA_A3](https://img.shields.io/badge/CBA__A3-Required-orange)
![ACE3](https://img.shields.io/badge/ACE3-Required-green)

## Overview

Root's Cyber Warfare transforms Arma 3 into a cyberpunk battlefield where players can hack into buildings, control drones, manipulate vehicles, and track enemies using GPS devices. The mod integrates seamlessly with ACE3 and uses the AE3 ArmaOS terminal system for an immersive hacking experience.

## Features

### Core Hacking Capabilities

- **Building Control**: Lock/unlock doors remotely, control lights
- **Drone Hacking**: Change drone factions, disable enemy UAVs
- **Vehicle Manipulation**: Control engine state, manipulate fuel/battery levels, lock/unlock doors, trigger alarms
- **Database Access**: Download classified files from networked computers
- **Custom Devices**: Support for mission-specific hackable objects

### GPS Tracking System

- **Covert Tracking**: Attach GPS trackers to units, vehicles, and objects
- **Detection Mechanics**: Search for hidden trackers with special equipment
- **Live Positioning**: Real-time tracking through hacked laptops
- **Map Integration**: Reveal tracker locations on the map

### Network Architecture

- **Access Control**: Device-specific permissions and computer-device linking
- **Backdoor System**: Bypass restrictions using backdoor paths
- **Public Devices**: Configure devices accessible to all players
- **Power Management**: Battery-based hacking with configurable power costs

### Zeus Integration

Curators get full control with dedicated modules:
- Add hacking tools to any computer
- Register devices (doors, lights, drones, databases, vehicles)
- Attach GPS trackers
- Modify power levels
- Configure custom laptop names for organization

## Requirements

| Mod | Version | Link |
|-----|---------|------|
| CBA_A3 | Latest | [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997) |
| ACE3 | Latest | [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=463939057) |
| AE3 ArmaOS | Latest | [GitHub](https://github.com/WildTangent4/AE3) |
| ZEN | Recommended | [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1779063631) |

## Installation

### Steam Workshop
1. Subscribe to Root's Cyber Warfare on Steam Workshop
2. Launch Arma 3 with CBA_A3, ACE3, and AE3 enabled
3. The mod will load automatically

### Manual Installation
1. Download the latest release from GitHub
2. Extract to your Arma 3 `@root_cyberwarfare` folder
3. Add `-mod=@cba_a3;@ace;@ae3_main;@root_cyberwarfare` to your launch parameters

## Quick Start Guide

### For Players

1. **Access a Computer**: Approach any laptop with hacking tools installed
2. **Open Terminal**: Use ACE interaction menu → Access Terminal
3. **View Help**: Type `cat guide` to see all available commands
4. **List Devices**: Type `devices` to see what you can hack
5. **Execute Commands**: Follow the syntax shown in the guide

**Example Commands**:
```bash
door 1454 2881 lock          # Lock door 2881 in building 1454
light 3 off                   # Turn off light #3
changedrone 2 west            # Change drone #2 to BLUFOR
gpstrack 4219                 # Track GPS device #4219
vehicle 1337 engine off       # Disable vehicle #1337's engine
```

### For Zeus/Curators

1. Open Zeus interface
2. Use custom modules under "Root Cyberwarfare":
   - **Add Hacking Tools**: Install hacking capability on a laptop
   - **Add Device**: Register a hackable object
   - **Add GPS Tracker**: Attach tracker to unit/object
   - **Modify Power**: Change laptop battery levels

### For Mission Makers

```sqf
// Add hacking tools to a laptop
[_laptop, "/network/subnet1", 0, "MainHackingStation"] call Root_fnc_addHackingToolsZeusMain;

// Register a door for hacking
private _building = nearestBuilding player;
[_building, 1234, [0,1,2]] call Root_fnc_addDeviceZeusMain; // Building with doors 0,1,2

// Attach GPS tracker to a vehicle
[_vehicle, player] call Root_fnc_aceAttachGPSTrackerObject;

// Link a device to a computer (give access)
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
_linkCache set [netId _computer, [[DEVICE_TYPE_DOOR, 1234], [DEVICE_TYPE_LIGHT, 5678]]];
```

## Configuration

### CBA Settings

Access via: Main Menu → Options → Addon Options → Root Cyberwarfare Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| GPS Tracker Item | ACE_Banana | Item classname used as GPS tracker |
| GPS Detection Devices | "" | Items that speed up tracker detection |
| Door Power Cost | 2 Wh | Power to lock/unlock a door |
| Drone Hack Power Cost | 10 Wh | Power to disable a drone |
| Drone Side Change Cost | 20 Wh | Power to change drone faction |
| Custom Device Cost | 10 Wh | Power for custom device operations |

### Device Types

| Type ID | Constant | Description |
|---------|----------|-------------|
| 1 | DEVICE_TYPE_DOOR | Building doors |
| 2 | DEVICE_TYPE_LIGHT | Building lights |
| 3 | DEVICE_TYPE_DRONE | UAVs/Drones |
| 4 | DEVICE_TYPE_DATABASE | Downloadable files |
| 5 | DEVICE_TYPE_CUSTOM | Custom scripted devices |
| 6 | DEVICE_TYPE_GPS_TRACKER | GPS tracking devices |
| 7 | DEVICE_TYPE_VEHICLE | Vehicles (cars, trucks, etc) |

## Terminal Commands Reference

### Devices Management
- `devices` - List all accessible devices on the network

### Door Control
- `door <buildingID> <doorID|a> <lock|unlock>` - Control building doors
  - Example: `door 1454 2881 lock` - Lock specific door
  - Example: `door 1454 a unlock` - Unlock all doors in building

### Light Control
- `light <lightID|a> <on|off>` - Control building lights
  - Example: `light 3 off` - Turn off light #3
  - Example: `light a on` - Turn on all accessible lights

### Drone Hacking
- `changedrone <droneID|a> <west|east|guer|civ>` - Change drone faction
  - Example: `changedrone 2 west` - Switch drone #2 to BLUFOR
- `disabledrone <droneID|a>` - Disable/destroy drone
  - Example: `disabledrone a` - Destroy all accessible drones

### Database Access
- `download <databaseID>` - Download file to Downloads folder
  - Example: `download 4823` - Download database #4823

### Custom Devices
- `custom <customID> <activate|deactivate>` - Control custom device
  - Example: `custom 5 activate` - Activate custom device #5

### GPS Tracking
- `gpstrack <trackerID>` - Start tracking a GPS device
  - Example: `gpstrack 2421` - Track GPS device #2421

### Vehicle Hacking
- `vehicle <vehicleID> <action> <value>` - Manipulate vehicle systems
  - Actions: `engine <on|off>`, `fuel <0-100>`, `battery <value>`, `doors <lock|unlock>`, `alarm <on|off>`
  - Example: `vehicle 1337 engine off` - Disable vehicle engine
  - Example: `vehicle 1337 fuel 0` - Empty vehicle fuel tank
  - Example: `vehicle 1337 doors lock` - Lock all vehicle doors

## Architecture

### Cache System

The mod uses HashMap-based caching for O(1) device lookups:

- **Device Cache**: `ROOT_CYBERWARFARE_DEVICE_CACHE` - Stores all registered devices by type
- **Link Cache**: `ROOT_CYBERWARFARE_LINK_CACHE` - Maps computers to accessible devices
- **Public Devices**: `ROOT_CYBERWARFARE_PUBLIC_DEVICES` - Lists globally accessible devices

### Power System

All hacking operations consume power (Watt-hours):
- Laptops have battery levels (stored in kWh)
- Each operation has a configurable power cost
- Operations fail if insufficient power
- Curators can modify power levels via Zeus

### Access Control

Three levels of device access:
1. **Backdoor Access**: Special paths that bypass all checks
2. **Public Access**: Devices available to all computers (with optional exclusions)
3. **Private Access**: Device-computer links stored in link cache

## Development

### Building from Source

```bash
# Clone repository
git clone https://github.com/A3-Root/Root_CyberWarfare.git
cd Root_CyberWarfare

# Build with HEMTT
hemtt dev         # Development build with symlink
hemtt release     # Production build
hemtt check -p    # Lint and validate code
```

### Function Reference

All functions are documented with SQFdoc headers. See [Wiki](../../wiki) for detailed API documentation.

**Function Categories**:
- `functions/core/` - Core system functions (settings, access control, cleanup)
- `functions/utility/` - Helper functions (power, confirmation, caching)
- `functions/devices/` - Device control (doors, lights, drones, vehicles)
- `functions/gps/` - GPS tracking system
- `functions/database/` - Database download functionality
- `functions/zeus/` - Zeus/Curator integration modules

### Adding Custom Devices

```sqf
// 1. Register device in cache
private _deviceCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", createHashMap];
private _customDevices = _deviceCache getOrDefault [CACHE_KEY_CUSTOM, []];
_customDevices pushBack [5001, netId _myObject, "My Custom Device"];
_deviceCache set [CACHE_KEY_CUSTOM, _customDevices];

// 2. Create custom activation function
MyMod_fnc_customDeviceActivate = {
    params ["_device", "_state"];
    if (_state == "activate") then {
        // Your activation code
    } else {
        // Your deactivation code
    };
};

// 3. Link to computer (give access)
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _computerLinks = _linkCache getOrDefault [netId _computer, []];
_computerLinks pushBack [DEVICE_TYPE_CUSTOM, 5001];
_linkCache set [netId _computer, _computerLinks];
```

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow SQF coding standards (see `.hemtt/project.toml`)
4. Add SQFdoc comments to new functions
5. Run `hemtt check -p` to validate code
6. Commit changes (`git commit -m 'Add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- Use CBA macros (FUNC, QFUNC, GVAR, etc.)
- Use stringtables for user-facing text
- Add proper SQFdoc headers to all functions
- Follow existing code organization patterns

## Troubleshooting

### Common Issues

**"No hacking tools installed"**
- Solution: Use Zeus module "Add Hacking Tools" on the laptop

**"No accessible devices found"**
- Solution: Devices must be registered via Zeus modules and linked to the computer

**"Insufficient power"**
- Solution: Use Zeus module "Modify Power" to add battery charge

**Functions not found (RPT errors)**
- Solution: Ensure all dependencies (CBA, ACE, AE3) are loaded
- Verify mod load order in launcher

### Debug Mode

Enable debug logging by defining `DEBUG_ENABLED_MAIN` in `script_component.hpp`:
```cpp
#define DEBUG_ENABLED_MAIN
```

Debug logs will appear in the RPT file with `[ROOT_CYBERWARFARE DEBUG]` prefix.

## Credits

**Author**: Root
**Contributors**: Mister Adrian

**Special Thanks**:
- CBA Team - Community Base Addons framework
- ACE Team - Advanced Combat Environment
- AE3 Team - ArmaOS terminal system
- ZEN Team - Enhanced Zeus functionality

## License

This project is licensed under the APL-SA License - see [LICENSE](LICENSE) file for details.

## Links

- **GitHub**: https://github.com/A3-Root/Root_CyberWarfare
- **Steam Workshop**: [Link to Workshop]
- **Discord**: [Community Discord]
- **Bug Reports**: https://github.com/A3-Root/Root_CyberWarfare/issues
- **Wiki**: https://github.com/A3-Root/Root_CyberWarfare/wiki

---

**Version**: 2.19.0
**Last Updated**: 2025-10-11
**Arma 3 Version**: 2.18+
