# Root's Cyber Warfare

A comprehensive cyberwarfare mod for Arma 3 that adds hacking mechanics, GPS tracking, device control, and network infiltration capabilities to enhance tactical gameplay.

![Version](https://img.shields.io/badge/version-2.20.0-blue)
![Build](https://img.shields.io/badge/Build-Passing-green)


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

| Mod | Link |
|-----|------|
| Community Based Addons (CBA_A3) | [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997) |
| Advanced Combat Environment 3 (ACE3) | [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=463939057) |
| Advanced Equipment (AE3) | [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2888888564) |
| Zeus Enhanced (ZEN) | [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1779063631) |

## Installation

### Steam Workshop
1. Subscribe to Root's Cyber Warfare on Steam Workshop
2. Launch Arma 3 with CBA_A3, ACE3, and AE3 enabled
3. The mod will load automatically

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
   - **Add Hackable Object**: Register a hackable object
   - **Add Hackable Vehicle**: Register a hackable vehicle
   - **Add Hackable File**: Register a hackable file
   - **Add GPS Tracker**: Register and attach a hackable (and traceable) GPS Tracker
   - **Modify Power**: Change power consumption of hackable objects

### For Mission Makers

```sqf
// Add hacking tools to a laptop
[_laptop, "/network/subnet1", 0, "MainHackingStation", ""] call Root_fnc_addHackingToolsZeusMain;

// Register a building with doors for hacking (auto-detects door IDs)
[_building, 0, [], false, "", "", "", false] call Root_fnc_addDeviceZeusMain;

// Register a custom device
[_generator, 0, [], true, "Generator", "hint 'Activated'", "hint 'Deactivated'", false] call Root_fnc_addDeviceZeusMain;

// Register a vehicle for hacking
[_vehicle, 0, [], "Car1", true, false, false, false, true, false, false, 2] call Root_fnc_addVehicleZeusMain;
// Parameters: [vehicle, execUserId, linkedComputers, name, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFuture, powerCost]

// Attach GPS tracker to a vehicle (via ACE interaction)
[_vehicle, player] call Root_fnc_aceAttachGPSTracker;

// Register a database/file for download
[_object, "secret.txt", 10, "Classified data...", 0, [], "", false] call Root_fnc_addDatabaseZeusMain;

// Link a device to a specific computer (give access)
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _existingLinks = _linkCache getOrDefault [netId _computer, []];
_existingLinks pushBack [DEVICE_TYPE_DOOR, 1234];
_existingLinks pushBack [DEVICE_TYPE_LIGHT, 5678];
_linkCache set [netId _computer, _existingLinks];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
```

## Configuration

### CBA Settings

Access via: Main Menu → Options → Addon Options → Root Cyberwarfare Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| GPS Tracker Item | ACE_Banana | Item classname used as GPS tracker |
| GPS Detection Devices | ["hgun_esd_01_antenna_01_F", "hgun_esd_01_antenna_02_F", "hgun_esd_01_antenna_03_F", "hgun_esd_01_base_F", "hgun_esd_01_dummy_F", "hgun_esd_01_F"] | Items that speed up tracker detection |
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
  - Actions: `engine <on|off>`, `speed <any number>`, `battery <0-200>`, `brakes <apply|release>`, `alarm <any number>`, `lights <on|off>`
  - Example: `vehicle 1337 engine off` - Turns off vehicle engine
  - Example: `vehicle 1337 speed 200` - Increases the velocity of the vehicle by 200
  - Example: `vehicle 1337 battery 50` - Sets the fuel of the vehicle to 50. Anything more than 100 makes the vehicle explode
  - Example: `vehicle 1337 brakes apply` - Applies the vehicle brakes
  - Example: `vehicle 1337 alarm 15` - Plays car alarm for 15 seconds
  - Example: `vehicle 1337 lights on` - Turns on lights (only for EMPTY vehicles)

## Architecture

### Data Storage System

The mod uses a hybrid approach for device storage and access control:

**Device Storage** (Array-based):
- **`ROOT_CYBERWARFARE_ALL_DEVICES`** - Primary storage for all devices
  - Structure: `[doors, lights, drones, databases, custom, gpsTrackers, vehicles]`
  - Each sub-array contains device entries with format specific to device type
  - Used by all Zeus registration functions (`fn_addDeviceZeusMain`, `fn_addVehicleZeusMain`, etc.)
  - Provides simple iteration and debugging

**Access Control** (Hybrid Array + HashMap):
- **`ROOT_CYBERWARFARE_LINK_CACHE`** (HashMap) - Computer-to-device private links
  - Structure: `computerNetId -> [[deviceType, deviceId], ...]`
  - O(1) lookup for checking computer access to specific devices
  - Used by `fn_isDeviceAccessible` for private device checks

- **`ROOT_CYBERWARFARE_PUBLIC_DEVICES`** (Array) - Publicly accessible devices
  - Structure: `[[deviceType, deviceId, [excludedNetIds]], ...]`
  - Contains devices available to all/most computers with optional exclusion lists
  - Used for "Available to Future Laptops" functionality

### Power System

All hacking operations consume power (Watt-hours):
- Laptops have battery levels (stored in kWh)
- Each operation has a configurable power cost
- Operations fail if insufficient power
- Curators can modify power levels via Zeus

### Access Control

Device accessibility is checked in three priority levels (checked in order by `fn_isDeviceAccessible`):

1. **Backdoor Access** (highest priority)
   - Special command paths marked as "backdoor" bypass all access checks
   - Configured via `ROOT_CYBERWARFARE_BACKDOOR_FUNCTION` variable on computer
   - Used for admin/debug access

2. **Public Device Access**
   - Devices in `ROOT_CYBERWARFARE_PUBLIC_DEVICES` array
   - Supports exclusion lists - specific computers can be blocked
   - Used for "Available to Future Laptops" feature:
     - New computers added after device registration automatically get access
     - Current computers at registration time are excluded (unless explicitly linked)
   - Access check: `!(_computerNetId in _excludedNetIds)`

3. **Private Device Links** (lowest priority)
   - Direct computer-to-device relationships in `ROOT_CYBERWARFARE_LINK_CACHE` HashMap
   - Set via Zeus "Link to Computer" checkboxes
   - O(1) lookup: `_linkCache get [computerNetId]` returns array of `[deviceType, deviceId]` pairs

## Development

### Building from Source

```bash
# Clone repository
git clone https://github.com/A3-Root/Root_CyberWarfare.git
cd Root_CyberWarfare

# Build with HEMTT
hemtt dev         # Development build with symlink
hemtt build       # Test the build before signing
hemtt release     # Production build
hemtt check -p    # Lint and validate code
```

### Function Reference

All functions are documented with SQFdoc headers. Key functions:

**Core Functions** (`functions/core/`):
- `fn_isDeviceAccessible.sqf` - Checks if computer can access a device (3-tier: backdoor → public → private)
- `fn_cleanup.sqf` - Cleanup handler for destroyed objects

**Utility Functions** (`functions/utility/`):
- `fn_checkPowerAvailable.sqf` - Check if laptop has sufficient battery
- `fn_consumePower.sqf` - Consume power and broadcast CBA event
- `fn_getUserConfirmation.sqf` - Show Y/N confirmation prompt
- `fn_getAccessibleDevices.sqf` - Get all accessible devices of a type for a computer

**Device Control** (`functions/devices/`):
- `fn_changeDoorState.sqf` - Lock/unlock building doors
- `fn_changeLightState.sqf` - Toggle lights on/off
- `fn_changeDroneFaction.sqf` - Change drone side
- `fn_disableDrone.sqf` - Disable/destroy drones
- `fn_changeVehicleParams.sqf` - Manipulate vehicle systems
- `fn_customDevice.sqf` - Activate/deactivate custom devices
- `fn_listDevicesInSubnet.sqf` - List accessible devices (for `devices` command)

**GPS Tracking** (`functions/gps/`):
- `fn_aceAttachGPSTracker.sqf` - ACE interaction to attach tracker (shows config dialog)
- `fn_gpsTrackerServer.sqf` - Server-side tracking logic
- `fn_gpsTrackerClient.sqf` - Client-side marker management
- `fn_displayGPSPosition.sqf` - Display GPS position on map
- `fn_searchForGPSTracker.sqf` - Search for hidden trackers

**Database** (`functions/database/`):
- `fn_downloadDatabase.sqf` - Download files to laptop

**Zeus Modules** (`functions/zeus/`):
- `fn_addHackingToolsZeus.sqf` / `fn_addHackingToolsZeusMain.sqf` - Add hacking tools to computer
- `fn_addDeviceZeus.sqf` / `fn_addDeviceZeusMain.sqf` - Register doors/lights/drones/custom devices
- `fn_addVehicleZeus.sqf` / `fn_addVehicleZeusMain.sqf` - Register hackable vehicles
- `fn_addDatabaseZeus.sqf` / `fn_addDatabaseZeusMain.sqf` - Register downloadable files
- `fn_addGPSTrackerZeus.sqf` / `fn_addGPSTrackerZeusMain.sqf` - Register GPS trackers
- `fn_modifyPowerZeus.sqf` / `fn_modifyPowerZeusMain.sqf` - Modify power levels

### Adding Custom Devices

**Method 1: Using Zeus Module (Recommended)**
```sqf
// Use Zeus "Add Hackable Object" module and enable "Treat as Custom Device"
// Or via script:
[_myObject, 0, [], true, "My Custom Device",
 "hint 'Device Activated'",
 "hint 'Device Deactivated'",
 false] call Root_fnc_addDeviceZeusMain;
```

**Method 2: Manual Registration**
```sqf
// 1. Load device storage
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
private _allCustom = _allDevices select 4;

// 2. Generate unique ID
private _deviceId = (round (random 8999)) + 1000;

// 3. Store activation/deactivation code on object
_myObject setVariable ["ROOT_CYBERWARFARE_ACTIVATIONCODE", "hint 'Activated'", true];
_myObject setVariable ["ROOT_CYBERWARFARE_DEACTIVATIONCODE", "hint 'Deactivated'", true];

// 4. Add to device storage
_allCustom pushBack [_deviceId, netId _myObject, "My Custom Device", "hint 'Activated'", "hint 'Deactivated'", false];
_allDevices set [4, _allCustom];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];

// 5. Link to computer (optional - skip to make it public)
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _existingLinks = _linkCache getOrDefault [netId _computer, []];
_existingLinks pushBack [5, _deviceId]; // 5 = DEVICE_TYPE_CUSTOM
_linkCache set [netId _computer, _existingLinks];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
```

**Activation/Deactivation Code**:
- Code is stored on the object and executed when player uses `custom <id> activate/deactivate`
- Access to: `_this = [_device, _state]` where `_state` is "activate" or "deactivate"
- Runs in SCHEDULED environment (like `spawn`)
- Use `_this select 0` to reference the device object

## Contributing

I welcome contributions! Please:

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

**"No accessible devices found"**
- **Cause**: Computer has no linked devices and no public devices exist
- **Solution**: Use Zeus modules to:
  - Register devices (doors, vehicles, GPS trackers, etc.)
  - Enable "Available to Future Laptops" OR select the computer in "Link to Computer" checkboxes
  - Or use `fn_addDeviceZeusMain` / `fn_addVehicleZeusMain` with appropriate linking parameters

**"Insufficient power"**
- **Cause**: Laptop battery is empty or below required power for operation
- **Solution**: Double click on the laptop to modify battery charge, or connect laptop to power generator (if using AE3 power system)

**"Building not found" / "No accessible buildings"**
- **Cause**: Building ID doesn't exist or computer doesn't have access
- **Solution**:
  - Check building ID using `devices` command
  - Check access: ensure computer is linked or device is public

**Functions not found (RPT errors like "fn_xxx not found")**
- **Cause**: Missing dependencies or incorrect mod load order
- **Solution**:
  - Ensure CBA_A3, ACE3, and AE3 are loaded BEFORE Root's Cyber Warfare
  - Check launcher mod load order
  - Verify all 3 required mods are subscribed and enabled
  - Check RPT file for detailed error messages

**Undefined variable errors (RPT errors like "_variableName is undefined")**
- **Cause**: Code issue, likely after recent refactoring
- **Solution**: Report on GitHub Issues with full RPT error message

### Debug Mode

Enable debug logging by defining `DEBUG_ENABLED_ROOT_CYBERWARFARE` in `script_component.hpp`:
```cpp
#define DEBUG_ENABLED_ROOT_CYBERWARFARE
```

Debug logs will appear in the RPT file with `[ROOT_CYBERWARFARE DEBUG]` prefix.

## Credits

**Author**: Root
**Contributors**: Mister Adrian

**Special Thanks**:
- Mister Adrian - The original creator of the MACW mod available in steam workshop and for providing permissions to take over his work.
- CBA Team - Community Base Addons framework
- ACE Team - Advanced Combat Environment
- AE3 Team - ArmaOS terminal system
- ZEN Team - Enhanced Zeus functionality

## License

This project is licensed under the APL-SA License - see [LICENSE](LICENSE) file for details.

## Links

- **GitHub**: https://github.com/A3-Root/Root_Cyberwarfare
- **Steam Workshop**: [Link to Workshop]
- **Discord**: [77th JSOC - Root](https://discord.gg/77th-jsoc-official)
- **Bug Reports**: https://github.com/A3-Root/Root_Cyberwarfare/issues
- **Wiki**: https://github.com/A3-Root/Root_Cyberwarfare/wiki

---

**Version**: 2.20.0
**Last Updated**: 2025-10-12
**Arma 3 Version**: 2.18+
