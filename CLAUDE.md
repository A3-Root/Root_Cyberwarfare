# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Root's Cyber Warfare is an Arma 3 mod that adds cyberwarfare mechanics to missions. It integrates with the AE3 (Advanced Equipment) filesystem to provide hacking capabilities through laptops and USB sticks. The mod allows players to hack doors, drones, lights, vehicles, GPS trackers, and custom devices within the game.

**Version:** 3.0.0+ (CBA_A3 Refactored)

**Key Dependencies:**
- AE3 (Advanced Equipment) - Provides the filesystem and laptop functionality
- ACE3 - Used for interaction menu and GPS tracker interactions
- CBA_A3 (Community Base Addons) - Required for settings, events, and function framework
- ZEN (Zeus Enhanced) - Provides dynamic mission editing modules

## Build System

This project uses HEMTT as the build tool for Arma 3 addon development.

**Build Commands:**
```bash
# Build the addon (development build)
hemtt dev

# Build with release configuration
hemtt release

# Check for linting errors
hemtt check
```

**Important:** The HEMTT configuration is located at `.hemtt/project.toml` and defines:
- Banned commands (execVM is prohibited)
- Enabled linting rules (undefined vars, shadowed vars, not_private, etc.)
- Project metadata (prefix: `root_cyberwarfare`, mainprefix: `z`)

## Code Architecture (Post-Refactoring)

### CBA Settings System

All configuration is now managed through CBA settings (mission-level, admin-configurable):

- **`ROOT_CYBERWARFARE_GPS_TRACKER_DEVICE`** - GPS tracker item classname (default: "ACE_Banana")
- **`ROOT_CYBERWARFARE_GPS_DETECTION_DEVICES`** - Comma-separated detection device classnames
- **`ROOT_CYBERWARFARE_DRONE_HACK_COST`** - Power cost to disable drone (Wh)
- **`ROOT_CYBERWARFARE_DRONE_SIDE_COST`** - Power cost to change drone faction (Wh)
- **`ROOT_CYBERWARFARE_DOOR_COST`** - Power cost to lock/unlock doors (Wh)
- **`ROOT_CYBERWARFARE_CUSTOM_COST`** - Power cost for custom devices (Wh)

### HashMap-Based Data Structures

The mod now uses hashmaps for O(1) lookups instead of O(n) array iterations:

**Device Cache:**
```sqf
ROOT_CYBERWARFARE_DEVICE_CACHE = createHashMap;
// Keys: "doors", "lights", "drones", "databases", "custom", "gpsTrackers", "vehicles"
```

**Link Cache:**
```sqf
ROOT_CYBERWARFARE_LINK_CACHE = createHashMap;
// computerNetId -> [[deviceType, deviceId], ...]
```

**Legacy Compatibility:** Old array-based variables (`ROOT_CYBERWARFARE_ALL_DEVICES`, etc.) are maintained for backward compatibility but deprecated.

### CBA Events System

Network communication uses CBA events instead of remoteExec:

- **`root_cyberwarfare_consumePower`** - Server-side power consumption
- **`root_cyberwarfare_deviceStateChanged`** - Device state change notifications
- **`root_cyberwarfare_gpsTrackingUpdate`** - GPS tracking status updates
- **`root_cyberwarfare_deviceLinked`** - Device linking notifications

### Device Access System

Device accessibility is determined by `Root_fnc_isDeviceAccessible` (addons/main/functions/core/fn_isDeviceAccessible.sqf):

1. **Backdoor Access**: Commands from paths marked as "backdoor" have access to all devices
2. **Public Device Check**: Checks if device is in `ROOT_CYBERWARFARE_PUBLIC_DEVICES`
3. **Private Device Links**: Uses hashmap cache (`ROOT_CYBERWARFARE_LINK_CACHE`) for O(1) lookup

### Macro System

Located in `script_macros.hpp`:

**Device Type Constants:**
```sqf
#define DEVICE_TYPE_DOOR 1
#define DEVICE_TYPE_LIGHT 2
#define DEVICE_TYPE_DRONE 3
#define DEVICE_TYPE_DATABASE 4
#define DEVICE_TYPE_CUSTOM 5
#define DEVICE_TYPE_GPS_TRACKER 6
#define DEVICE_TYPE_VEHICLE 7
```

**Cache Access Macros:**
```sqf
#define GET_DEVICE_CACHE (missionNamespace getVariable [GVAR_DEVICE_CACHE, createHashMap])
#define GET_LINK_CACHE (missionNamespace getVariable [GVAR_LINK_CACHE, createHashMap])
#define GET_PUBLIC_DEVICES (missionNamespace getVariable [GVAR_PUBLIC_DEVICES, []])
```

**Utility Macros:**
```sqf
#define VALIDATE_COMPUTER(computer) (!isNull computer && computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false])
#define WH_TO_KWH(wh) (wh / 1000)
```

### String Localization

All user-facing strings are in `stringtable.xml`. Use `localize` for all output:

```sqf
private _string = localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_INPUT";
[_computer, _string] call AE3_armaos_fnc_shell_stdout;
```

### Utility Functions

Five core utility functions simplify common operations:

- **`Root_fnc_checkPowerAvailable`** - Check if sufficient battery power
- **`Root_fnc_consumePower`** - Consume power and broadcast via CBA event
- **`Root_fnc_getUserConfirmation`** - Display Y/N prompt
- **`Root_fnc_getAccessibleDevices`** - Get accessible devices by type
- **`Root_fnc_cacheDeviceLinks`** - Update device link cache

### Module System

The mod provides Zeus modules (all use ZEN framework):

- `ROOT_CyberWarfareAddHackingToolsZeus` - Dynamically add hacking tools
- `ROOT_CyberWarfareAddDeviceZeus` - Dynamically add hackable objects
- `ROOT_CyberWarfareModifyPowerZeus` - Modify power costs during mission
- `ROOT_CyberWarfareAddFileZeus` - Dynamically add files
- `ROOT_CyberWarfareAddGPSTrackerZeus` - Add GPS trackers to objects
- `ROOT_CyberWarfareAddVehicleZeus` - Add hackable vehicles

### GPS Tracker System

GPS trackers work through a client-server architecture:
- `fn_gpsTrackerServer.sqf` - Server-side tracking logic
- `fn_gpsTrackerClient.sqf` - Client-side marker display
- ACE interactions allow players to attach and search for GPS trackers

### Function Organization

Functions are organized by category in `CfgFunctions.hpp`:

- **Core** - Core functionality (isDeviceAccessible, settings, cleanup)
- **Devices** - Device hacking (doors, lights, drones, vehicles)
- **GPS** - GPS tracker functionality
- **Database** - File/database operations
- **Zeus** - Zeus module handlers
- **Utility** - Utility functions (power, confirmation, caching)

### Network ID Usage

The mod heavily uses `netId` and `objectFromNetId` for network-synchronized object references. Device data stores `netId` strings rather than object references to ensure multiplayer compatibility.

## Code Standards

### CBA_A3 Best Practices

- Use CBA macros from `script_macros.hpp`
- Use CBA events instead of remoteExec
- Use CBA settings for configuration
- Use `params` for all function parameters
- Add function header comments (see template below)
- Use localized strings from stringtable.xml
- Use hashmaps for caching and lookups
- Trust params (don't add explicit type checking)

### Function Header Template

```sqf
#include "script_component.hpp"
/*
 * Author: Root
 * Description: Function description
 *
 * Arguments:
 * 0: _param1 <TYPE> - Description
 * 1: _param2 <TYPE> (Optional) - Description, default: value
 *
 * Return Value:
 * <TYPE> - Description
 *
 * Example:
 * [arg1, arg2] call Root_fnc_functionName;
 *
 * Public: Yes/No
 */
```

### HEMTT Linting Rules

- Do NOT use `execVM` - it's banned
- All variables must be properly declared private
- Avoid shadowed variables
- Check for undefined variables and orphan code
- Use `configOf` instead of `configFile >> "CfgVehicles" >> typeOf`

## File Structure

```
addons/main/
├── config.cpp              - Main config entry point
├── CfgFunctions.hpp        - Function definitions (categorized)
├── CfgVehicles.hpp         - Zeus module definitions
├── CfgEventHandlers.hpp    - CBA XEH setup
├── CfgSounds.hpp           - Sound definitions
├── XEH_preInit.sqf         - PreInit (CBA settings)
├── XEH_postInit.sqf        - PostInit (events, cache init, ACE)
├── XEH_PREP.hpp            - Function precompilation list
├── script_component.hpp    - Component definition
├── script_macros.hpp       - Mod-specific macros
├── script_mod.hpp          - CBA macro integration
├── script_version.hpp      - Version numbers
├── stringtable.xml         - Localized strings
└── functions/
    ├── core/               - Core functions
    ├── devices/            - Device hacking functions
    ├── gps/                - GPS tracker functions
    ├── database/           - Database/file functions
    ├── zeus/               - Zeus module handlers
    └── utility/            - Utility functions
```

## Testing Approach

1. Build with `hemtt dev`
2. Test CBA settings in-game (ESC > Addon Options > Root Cyberwarfare Configuration)
3. Test all Zeus modules
4. Test device hacking (doors, lights, drones, vehicles)
5. Test GPS tracker attachment and tracking
6. Test multiplayer synchronization on dedicated server
7. Check RPT log for errors

## Performance Considerations

- **Runtime Performance**: O(1) hashmap lookups instead of O(n) forEach
- **Network Bandwidth**: CBA events batch updates, ~40% reduction in network traffic
- **Initial Load Time**: Functions are precompiled via CBA's compilation cache

## Important Implementation Notes

- Device IDs are randomly generated (1000-9999 range) and checked for uniqueness
- Door detection uses regex matching on "door_*" animations in SimpleObject configs
- The mod integrates with AE3's virtual filesystem - hacking tools are "installed" to virtual paths
- Power costs are measured in Wh (watt-hours) and consumed from AE3 laptop batteries
- Marker names for GPS trackers use format: `ROOT_GPS_TRACKER_[uniqueId]`
- CBA events are server-side only for power consumption and device state changes

## Breaking Changes

See `BREAKING_CHANGES.md` for detailed migration guide from pre-3.0.0 versions.

## Development Notes

- Always include `#include "script_component.hpp"` at the top of function files
- Use macros for device types (DEVICE_TYPE_*) instead of magic numbers
- Use utility functions (checkPowerAvailable, consumePower, getUserConfirmation) to reduce duplication
- Add all new strings to stringtable.xml
- Test with CBA cache disabled during development: `cba_cache_disable` addon
