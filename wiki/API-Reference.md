# API Reference

Essential function reference for mission makers and developers working with Root's Cyber Warfare.

## Table of Contents

- [Device Registration Functions](#device-registration-functions)
- [Access Control Functions](#access-control-functions)
- [Power Management Functions](#power-management-functions)
- [Data Structures](#data-structures)

---

## Device Registration Functions

These are the main functions mission makers will use to register hackable devices. All functions run on **server only**.

### Root_fnc_addHackingToolsZeusMain

Install hacking tools on a laptop to enable terminal access.

**File**: `functions/zeus/fn_addHackingToolsZeusMain.sqf`

**Signature**:
```sqf
[_laptop, _installPath, _execUserId, _laptopName, _backdoorPrefix] call Root_fnc_addHackingToolsZeusMain;
```

**Parameters**:
- `_laptop` (OBJECT) - The laptop object to install hacking tools on
- `_installPath` (STRING) - Installation path for tools (default: "/rubberducky/tools")
- `_execUserId` (NUMBER) - User ID for feedback (default: 0)
- `_laptopName` (STRING) - Custom name for the laptop (default: "")
- `_backdoorPrefix` (STRING) - Backdoor prefix for admin access (default: "")

**Example**:
```sqf
// Basic installation
[_laptop, "/network/tools", 0, "MainTerminal", ""] call Root_fnc_addHackingToolsZeusMain;

// With backdoor access (admin mode)
[_laptop, "/network/tools", 0, "AdminTerminal", "/admin/"] call Root_fnc_addHackingToolsZeusMain;
```

**Notes**: Creates virtual filesystem entries for all terminal commands (devices, door, light, vehicle, etc.)

---

### Root_fnc_addDeviceZeusMain

Register buildings (doors) or lights as hackable devices.

**File**: `functions/zeus/fn_addDeviceZeusMain.sqf`

**Signature**:
```sqf
[_building, _execUserId, _linkedComputers, _availableToFuture, _makeUnbreachable] call Root_fnc_addDeviceZeusMain;
```

**Parameters**:
- `_building` (OBJECT) - The building or light object
- `_execUserId` (NUMBER) - User ID for feedback (default: 0)
- `_linkedComputers` (ARRAY) - Array of computer **netIds** (strings) to link (default: [])
- `_availableToFuture` (BOOLEAN) - Make available to future laptops (default: false)
- `_makeUnbreachable` (BOOLEAN) - Prevent breaching (doors only) (default: false)

**Example**:
```sqf
// Register building with auto-detected doors
[_building, 0, [], false, false] call Root_fnc_addDeviceZeusMain;

// Link to specific laptop with unbreachable doors
[_building, 0, [netId _laptop1], false, true] call Root_fnc_addDeviceZeusMain;

// Available to future laptops only
[_building, 0, [], true, false] call Root_fnc_addDeviceZeusMain;

// Register light
[_lamp, 0, [], false, false] call Root_fnc_addDeviceZeusMain;
```

**Notes**:
- Automatically detects all doors in a building via config parsing
- For lights, detects objects of type `Lamps_base_F`
- Unbreachable mode prevents ACE breaching charges from working

---

### Root_fnc_addVehicleZeusMain

Register vehicles or drones as hackable devices.

**File**: `functions/zeus/fn_addVehicleZeusMain.sqf`

**Signature (Vehicles)**:
```sqf
[_vehicle, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed,
 _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFuture, _powerCost]
 call Root_fnc_addVehicleZeusMain;
```

**Parameters (Vehicles)**:
- `_vehicle` (OBJECT) - The vehicle object
- `_execUserId` (NUMBER) - User ID (default: 0)
- `_linkedComputers` (ARRAY) - Array of computer **netIds** (default: [])
- `_vehicleName` (STRING) - Display name for the vehicle
- `_allowFuel` (BOOLEAN) - Enable fuel/battery control (default: false)
- `_allowSpeed` (BOOLEAN) - Enable speed manipulation (default: false)
- `_allowBrakes` (BOOLEAN) - Enable brake control (default: false)
- `_allowLights` (BOOLEAN) - Enable lights control (default: false)
- `_allowEngine` (BOOLEAN) - Enable engine on/off (default: true)
- `_allowAlarm` (BOOLEAN) - Enable alarm triggering (default: false)
- `_availableToFuture` (BOOLEAN) - Available to future laptops (default: false)
- `_powerCost` (NUMBER) - Power cost in Wh per action (default: 2)

**Signature (Drones)**:
```sqf
[_drone, _execUserId, _linkedComputers, _availableToFuture] call Root_fnc_addVehicleZeusMain;
```

**Parameters (Drones)**:
- `_drone` (OBJECT) - The UAV/drone object
- `_execUserId` (NUMBER) - User ID (default: 0)
- `_linkedComputers` (ARRAY) - Array of computer **netIds** (default: [])
- `_availableToFuture` (BOOLEAN) - Available to future laptops (default: false)

**Examples**:
```sqf
// Register vehicle with full control
[_car, 0, [], "Patrol Car", true, true, true, true, true, true, false, 5]
    call Root_fnc_addVehicleZeusMain;

// Register vehicle with engine control only (low power cost)
[_truck, 0, [netId _laptop], "Supply Truck", false, false, false, false, true, false, false, 2]
    call Root_fnc_addVehicleZeusMain;

// Register drone
[_uav, 0, [], false] call Root_fnc_addVehicleZeusMain;
```

**Notes**:
- Function automatically detects drones via parameter count (4 params) or `unitIsUAV`
- Drones support faction change and disable commands
- Vehicles support: fuel/battery manipulation, speed changes, brake application, lights toggle, engine on/off, alarm triggering

---

### Root_fnc_addCustomDeviceZeusMain

Register a custom device with scripted activation/deactivation behavior.

**File**: `functions/zeus/fn_addCustomDeviceZeusMain.sqf`

**Signature**:
```sqf
[_object, _execUserId, _linkedComputers, _deviceName, _activationCode,
 _deactivationCode, _availableToFuture] call Root_fnc_addCustomDeviceZeusMain;
```

**Parameters**:
- `_object` (OBJECT) - Any object to register as custom device
- `_execUserId` (NUMBER) - User ID (default: 0)
- `_linkedComputers` (ARRAY) - Array of computer **netIds** (default: [])
- `_deviceName` (STRING) - Display name (default: "Custom Device")
- `_activationCode` (STRING) - SQF code to execute on activation (default: "")
- `_deactivationCode` (STRING) - SQF code to execute on deactivation (default: "")
- `_availableToFuture` (BOOLEAN) - Available to future laptops (default: false)

**Examples**:
```sqf
// Simple hint device
[_obj, 0, [], "Alert System",
    "hint 'Alert Activated!'",
    "hint 'Alert Deactivated'",
    false] call Root_fnc_addCustomDeviceZeusMain;

// Generator that spawns explosion
[_generator, 0, [netId _laptop], "Power Station",
    "_obj = _this select 0; 'Bo_GBU12_LGB' createVehicle (getPos _obj);",
    "hint 'Generator offline'",
    false] call Root_fnc_addCustomDeviceZeusMain;

// Available to all future laptops
[_terminal, 0, [], "Security Terminal",
    "systemChat 'Access Granted'",
    "systemChat 'Access Revoked'",
    true] call Root_fnc_addCustomDeviceZeusMain;
```

**Notes**:
- Activation/deactivation code runs in **scheduled** environment
- Code has access to: `_this = [_computer, _customObject, _playerNetID]`
- Use `_this select 0` to get the laptop, `_this select 1` to get the device object

---

### Root_fnc_addDatabaseZeusMain

Register a downloadable file/database.

**File**: `functions/zeus/fn_addDatabaseZeusMain.sqf`

**Signature**:
```sqf
[_object, _filename, _filesize, _filecontent, _execUserId, _linkedComputers,
 _executionCode, _availableToFuture] call Root_fnc_addDatabaseZeusMain;
```

**Parameters**:
- `_object` (OBJECT) - Object to store file data on
- `_filename` (STRING) - Name of the file
- `_filesize` (NUMBER) - Download time in seconds
- `_filecontent` (STRING) - Content of the file (displayed after download)
- `_execUserId` (NUMBER) - User ID (default: 0)
- `_linkedComputers` (ARRAY) - Array of computer **netIds** (default: [])
- `_executionCode` (STRING) - Optional code to execute on download (default: "")
- `_availableToFuture` (BOOLEAN) - Available to future laptops (default: false)

**Examples**:
```sqf
// Simple classified file
[_laptop, "secrets.txt", 10, "Classified intelligence data...", 0, [], "", false]
    call Root_fnc_addDatabaseZeusMain;

// File that triggers event on download
[_computer, "virus.exe", 5, "Malware detected!", 0, [netId _hackingLaptop],
    "hint 'System compromised!'", false]
    call Root_fnc_addDatabaseZeusMain;

// Public file available to all
[_server, "readme.txt", 2, "Welcome to the network.", 0, [], "", false]
    call Root_fnc_addDatabaseZeusMain;
```

**Notes**: File content is written to laptop's `/Files/` folder via AE3 filesystem

---

### Root_fnc_addGPSTrackerZeusMain

Attach a GPS tracker to an object for tracking.

**File**: `functions/zeus/fn_addGPSTrackerZeusMain.sqf`

**Signature**:
```sqf
[_targetObject, _execUserId, _linkedComputers, _trackerName, _trackingTime,
 _updateFrequency, _customMarker, _availableToFuture, _allowRetracking,
 _lastPingTimer, _powerCost, _sysChat, _ownersSelection] call Root_fnc_addGPSTrackerZeusMain;
```

**Parameters**:
- `_targetObject` (OBJECT) - Object to track
- `_execUserId` (NUMBER) - User ID (default: 0)
- `_linkedComputers` (ARRAY) - Array of computer **netIds** (default: [])
- `_trackerName` (STRING) - Tracker display name (default: "")
- `_trackingTime` (NUMBER) - Tracking duration in seconds (default: 60)
- `_updateFrequency` (NUMBER) - Update interval in seconds (default: 5)
- `_customMarker` (STRING) - Custom marker name (default: "")
- `_availableToFuture` (BOOLEAN) - Available to future laptops (default: false)
- `_allowRetracking` (BOOLEAN) - Allow retracking after expiry (default: false)
- `_lastPingTimer` (NUMBER) - Last ping marker duration in seconds
- `_powerCost` (NUMBER) - Power cost in Wh per ping
- `_sysChat` (BOOLEAN) - Show system chat message (default: true)
- `_ownersSelection` (ARRAY) - Additional sides/groups/players to show markers (default: [[], [], []])

**Examples**:
```sqf
// Basic GPS tracker on vehicle (60s tracking, 5s updates)
[_vehicle, 0, [], "Target Vehicle", 60, 5, "", false, true, 30, 2, true, [[], [], []]]
    call Root_fnc_addGPSTrackerZeusMain;

// Tracker available to future laptops
[_vip, 0, [], "VIP Target", 120, 10, "vip_marker", true, false, 60, 5, true, [[], [], []]]
    call Root_fnc_addGPSTrackerZeusMain;
```

**Notes**:
- Players can attach GPS trackers via ACE interaction menu (requires GPS tracker item in inventory)
- Trackers can be detected/removed by searching (also via ACE interaction)

---

### Root_fnc_addPowerGeneratorZeusMain

Register a power generator that controls lights within a radius.

**File**: `functions/zeus/fn_addPowerGeneratorZeusMain.sqf`

**Signature**:
```sqf
[_generator, _execUserId, _linkedComputers, _generatorName, _radius,
 _allowExplosionActivate, _allowExplosionDeactivate, _explosionType,
 _excludedClassnames, _availableToFuture, _powerCost] call Root_fnc_addPowerGeneratorZeusMain;
```

**Parameters**:
- `_generator` (OBJECT) - The generator object
- `_execUserId` (NUMBER) - User ID (default: 0)
- `_linkedComputers` (ARRAY) - Array of computer **objects** (not netIds!) (default: [])
- `_generatorName` (STRING) - Generator name (default: "Power Generator")
- `_radius` (NUMBER) - Radius in meters to affect lights (default: 50)
- `_allowExplosionActivate` (BOOLEAN) - Create explosion on activation (default: false)
- `_allowExplosionDeactivate` (BOOLEAN) - Create explosion on deactivation (default: false)
- `_explosionType` (STRING) - Explosion ammo classname (default: "ClaymoreDirectionalMine_Remote_Ammo_Scripted")
- `_excludedClassnames` (ARRAY) - Light classnames to exclude from control (default: [])
- `_availableToFuture` (BOOLEAN) - Available to future laptops (default: false)
- `_powerCost` (NUMBER) - Power cost in Wh per operation (default: 10)

**Examples**:
```sqf
// Basic generator controlling 100m radius
[_gen, 0, [], "City Grid", 100, false, false, "", [], false, 10]
    call Root_fnc_addPowerGeneratorZeusMain;

// Generator with explosion on overload
[_powerStation, 0, [_laptop1], "Main Grid", 200, false, true, "HelicopterExploSmall", [], false, 15]
    call Root_fnc_addPowerGeneratorZeusMain;

// Exclude specific light types
[_gen, 0, [], "Street Lights", 50, false, false, "", ["Lamp_Street_small_F"], false, 10]
    call Root_fnc_addPowerGeneratorZeusMain;
```

**Notes**:
- Controls all `Lamps_base_F` objects within radius
- Terminal commands: `powergrid <id> on`, `powergrid <id> off`, `powergrid <id> overload`
- Overload permanently disables the generator

---

## Access Control Functions

### Root_fnc_isDeviceAccessible

Check if a laptop can access a specific device using the 3-tier access control system.

**File**: `functions/core/fn_isDeviceAccessible.sqf`

**Signature**:
```sqf
private _hasAccess = [_laptop, _deviceType, _deviceId, _commandPath] call Root_fnc_isDeviceAccessible;
```

**Parameters**:
- `_laptop` (OBJECT) - The laptop object
- `_deviceType` (NUMBER) - Device type constant (1-8)
- `_deviceId` (NUMBER) - Device ID
- `_commandPath` (STRING) - Command path for backdoor checking (optional, default: "")

**Return**: BOOLEAN - True if accessible, false otherwise

**Example**:
```sqf
// Check if laptop can access door device
if ([_laptop, DEVICE_TYPE_DOOR, 1234] call Root_fnc_isDeviceAccessible) then {
    hint "Access granted";
} else {
    hint "Access denied";
};

// Check with backdoor path
if ([_laptop, DEVICE_TYPE_VEHICLE, 5678, "/admin/"] call Root_fnc_isDeviceAccessible) then {
    hint "Admin access granted";
};
```

**Access Priority**:
1. **Backdoor Access** - Bypasses all checks if command path matches stored backdoor paths
2. **Public Device Access** - Device in public devices array and computer not excluded
3. **Private Link Access** - Direct computer-to-device link in link cache

**Notes**: See [Architecture](Architecture) for detailed explanation of the 3-tier access control system

---

## Power Management Functions

### Root_fnc_checkPowerAvailable

Check if a laptop has sufficient power for an operation.

**File**: `functions/utility/fn_checkPowerAvailable.sqf`

**Signature**:
```sqf
private _hasPower = [_laptop, _powerCostWh] call Root_fnc_checkPowerAvailable;
```

**Parameters**:
- `_laptop` (OBJECT) - The laptop object
- `_powerCostWh` (NUMBER) - Required power in Watt-hours (Wh)

**Return**: BOOLEAN - True if sufficient power, false otherwise

**Example**:
```sqf
// Check if laptop has 10 Wh available
if ([_laptop, 10] call Root_fnc_checkPowerAvailable) then {
    hint "Sufficient power";
    [_laptop, 10] call Root_fnc_consumePower;
} else {
    hint "Insufficient power";
};
```

**Notes**: Integrates with AE3 power system (battery stored in kWh, cost in Wh)

---

### Root_fnc_consumePower

Consume power from a laptop's battery.

**File**: `functions/utility/fn_consumePower.sqf`

**Signature**:
```sqf
[_laptop, _powerCostWh] call Root_fnc_consumePower;
```

**Parameters**:
- `_laptop` (OBJECT) - The laptop object
- `_powerCostWh` (NUMBER) - Power to consume in Watt-hours (Wh)

**Return**: None

**Example**:
```sqf
// Consume 15 Wh from laptop battery
[_laptop, 15] call Root_fnc_consumePower;
```

**Notes**:
- Automatically converts Wh to kWh for AE3 power system
- Broadcasts `root_cyberwarfare_consumePower` CBA event

---

## Data Structures

### Device Type Constants

Defined in `script_macros.hpp`:

| Constant | Value | Description |
|----------|-------|-------------|
| `DEVICE_TYPE_DOOR` | 1 | Building doors |
| `DEVICE_TYPE_LIGHT` | 2 | Lights/lamps |
| `DEVICE_TYPE_DRONE` | 3 | UAVs/drones |
| `DEVICE_TYPE_DATABASE` | 4 | Downloadable files |
| `DEVICE_TYPE_CUSTOM` | 5 | Custom scripted devices |
| `DEVICE_TYPE_GPS_TRACKER` | 6 | GPS tracking devices |
| `DEVICE_TYPE_VEHICLE` | 7 | Vehicles |
| `DEVICE_TYPE_POWERGRID` | 8 | Power generators |

**Usage**:
```sqf
// Use constants instead of magic numbers
if ([_laptop, DEVICE_TYPE_DOOR, _doorId] call Root_fnc_isDeviceAccessible) then {
    // Access granted
};
```

---

### Device Cache (HashMap)

**Global Variable**: `ROOT_CYBERWARFARE_DEVICE_CACHE`

**Access Macro**: `GET_DEVICE_CACHE`

**Structure**:
```sqf
createHashMap with keys:
├── "doors"       → [[deviceId, buildingNetId, doorIds[], buildingName, availableToFuture], ...]
├── "lights"      → [[deviceId, lightNetId, lightName, availableToFuture], ...]
├── "drones"      → [[deviceId, droneNetId, droneName, availableToFuture], ...]
├── "databases"   → [[deviceId, objectNetId, fileName, fileSize, linkedComputers, availableToFuture], ...]
├── "custom"      → [[deviceId, objectNetId, deviceName, activationCode, deactivationCode, availableToFuture], ...]
├── "gpsTrackers" → [[deviceId, targetNetId, trackerName, trackingTime, updateFreq, marker, linkedComputers, availableToFuture, status, allowRetrack, lastPingTimer, powerCost, owners], ...]
├── "vehicles"    → [[deviceId, vehicleNetId, name, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFuture, powerCost, linkedComputers], ...]
└── "powerGrids"  → [[deviceId, objectNetId, name, radius, allowExplActivate, allowExplDeactivate, explosionType, excludedClasses, availableToFuture, powerCost, linkedComputers], ...]
```

**Example**:
```sqf
// Get all doors
private _cache = GET_DEVICE_CACHE;
private _doors = _cache getOrDefault [CACHE_KEY_DOORS, []];

// Find specific door by ID
private _doorIndex = _doors findIf { (_x select 0) == _deviceId };
if (_doorIndex != -1) then {
    private _doorEntry = _doors select _doorIndex;
    _doorEntry params ["_id", "_buildingNetId", "_doorIds", "_buildingName", "_availableToFuture"];
};
```

---

### Link Cache (HashMap)

**Global Variable**: `ROOT_CYBERWARFARE_LINK_CACHE`

**Access Macro**: `GET_LINK_CACHE`

**Structure**:
```sqf
createHashMap with keys: computerNetId (string)
values: [[deviceType, deviceId], ...] (array of [int, int] pairs)
```

**Example**:
```sqf
// Get laptop's accessible devices
private _linkCache = GET_LINK_CACHE;
private _computerNetId = netId _laptop;
private _accessibleDevices = _linkCache getOrDefault [_computerNetId, []];

// Add new device link
_accessibleDevices pushBack [DEVICE_TYPE_DOOR, 1234];
_linkCache set [_computerNetId, _accessibleDevices];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
```

---

### Public Devices (Array)

**Global Variable**: `ROOT_CYBERWARFARE_PUBLIC_DEVICES`

**Access Macro**: `GET_PUBLIC_DEVICES`

**Structure**:
```sqf
[[deviceType, deviceId, [excludedComputerNetIds]], ...]
```

**Example**:
```sqf
// Get public devices
private _publicDevices = GET_PUBLIC_DEVICES;

// Add device available to all except specific laptops
_publicDevices pushBack [DEVICE_TYPE_VEHICLE, 5678, [netId _excludedLaptop1, netId _excludedLaptop2]];
missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];

// Add device available to all (no exclusions)
_publicDevices pushBack [DEVICE_TYPE_DOOR, 1234, []];
missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
```

---

## Macros

### Cache Access Macros

```cpp
GET_DEVICE_CACHE    // Get device cache HashMap (or create empty)
GET_LINK_CACHE      // Get link cache HashMap (or create empty)
GET_PUBLIC_DEVICES  // Get public devices array (or empty array)
```

### Validation Macros

```cpp
VALIDATE_COMPUTER(obj)     // Check if object has hacking tools installed
VALIDATE_DEVICE_TYPE(n)    // Check if device type is 1-8
```

### Power Conversion Macros

```cpp
WH_TO_KWH(wh)    // Convert Watt-hours to Kilowatt-hours
KWH_TO_WH(kwh)   // Convert Kilowatt-hours to Watt-hours
```

### Logging Macros

```cpp
LOG_DEBUG(msg)         // Debug log (disabled in release)
LOG_INFO(msg)          // Info log
LOG_ERROR(msg)         // Error log
LOG_DEBUG_1(msg, arg)  // Debug with 1 argument
LOG_INFO_2(msg, a, b)  // Info with 2 arguments
```

### Terminal Color Macros

```cpp
COLOR_SUCCESS    // "#8ce10b" - Green
COLOR_ERROR      // "#fa4c58" - Red
COLOR_WARNING    // "#FFD966" - Yellow
COLOR_INFO       // "#008DF8" - Blue
COLOR_NEUTRAL    // "#BCBCBC" - Gray
```

**Usage in Terminal Output**:
```sqf
[_computer, format ["<t color='%1'>%2</t>", COLOR_SUCCESS, "Operation successful"]]
    call AE3_armaos_fnc_shell_stdout;
```

---

## Related Documentation

- [Architecture](Architecture) - System design and technical details
- [Mission Maker Guide](Mission-Maker-Guide) - Usage examples and workflows
- [Configuration](Configuration) - CBA settings reference

---

**Version**: 2.20.1
**Last Updated**: 2025-10-18
