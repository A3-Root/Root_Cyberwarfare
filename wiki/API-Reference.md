# API Reference

Complete reference for all public functions in Root's Cyber Warfare, organized by category.

## Table of Contents

- [Overview](#overview)
- [Device Registration Functions](#device-registration-functions)
- [Device Control Functions](#device-control-functions)
- [Access Control Functions](#access-control-functions)
- [Power Management Functions](#power-management-functions)
- [Utility Functions](#utility-functions)
- [Data Structures](#data-structures)
- [Constants and Macros](#constants-and-macros)

---

## Overview

### Calling Conventions

**Server-Side Execution:**
Most functions must run on the server. Use `remoteExec` when calling from client:
```sqf
[params...] remoteExec ["Root_fnc_functionName", 2];
```

**Direct Calls:**
If already on server:
```sqf
[params...] call Root_fnc_functionName;
```

### Parameter Notation

- `<TYPE>` - Required parameter
- `<TYPE> (Optional)` - Optional parameter with default value
- `[defaultValue]` - Default value if parameter omitted

---

## Device Registration Functions

These functions register devices and make them hackable.

### Root_fnc_addHackingToolsZeusMain

Installs hacking tools on an AE3 laptop.

**Syntax:**
```sqf
[_computer, _path, _execUserId, _laptopName, _backdoorPrefix] call Root_fnc_addHackingToolsZeusMain;
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _computer | OBJECT | - | Laptop/USB object |
| 1 | _path | STRING | "/rubberducky/tools" | Tool installation path |
| 2 | _execUserId | NUMBER | 0 | User ID for feedback |
| 3 | _laptopName | STRING | "" | Custom laptop name |
| 4 | _backdoorPrefix | STRING | "" | Backdoor prefix (admin access) |

**Return Value:** None

**Example:**
```sqf
[_laptop1, "/network/tools", 0, "HackStation", ""] call Root_fnc_addHackingToolsZeusMain;
```

---

### Root_fnc_addDeviceZeusMain

Registers buildings (doors) or lights as hackable.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _treatAsCustom, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _targetObject | OBJECT | - | Building or lamp object |
| 1 | _execUserId | NUMBER | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | [] | Computer netIds array |
| 3 | _treatAsCustom | BOOLEAN | false | DEPRECATED (leave false) |
| 4 | _customName | STRING | "" | DEPRECATED (leave "") |
| 5 | _activationCode | STRING | "" | DEPRECATED (leave "") |
| 6 | _deactivationCode | STRING | "" | DEPRECATED (leave "") |
| 7 | _availableToFutureLaptops | BOOLEAN | false | Future access flag |
| 8 | _makeUnbreachable | BOOLEAN | false | Prevent ACE breaching |

**Return Value:** None

**Example:**
```sqf
[_building1, 0, [netId _laptop1], false, "", "", "", false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

### Root_fnc_addVehicleZeusMain

Registers vehicles or drones as hackable.

**Syntax (Drones):**
```sqf
[_drone, _execUserId, _linkedComputers, _availableToFutureLaptops] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Syntax (Vehicles):**
```sqf
[_vehicle, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Parameters (Drones):**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _drone | OBJECT | - |
| 1 | _execUserId | NUMBER | 0 |
| 2 | _linkedComputers | ARRAY | [] |
| 3 | _availableToFutureLaptops | BOOLEAN | false |

**Parameters (Vehicles):**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _vehicle | OBJECT | - |
| 1 | _execUserId | NUMBER | 0 |
| 2 | _linkedComputers | ARRAY | [] |
| 3 | _vehicleName | STRING | - |
| 4 | _allowFuel | BOOLEAN | false |
| 5 | _allowSpeed | BOOLEAN | false |
| 6 | _allowBrakes | BOOLEAN | false |
| 7 | _allowLights | BOOLEAN | false |
| 8 | _allowEngine | BOOLEAN | true |
| 9 | _allowAlarm | BOOLEAN | false |
| 10 | _availableToFutureLaptops | BOOLEAN | false |
| 11 | _powerCost | NUMBER | 2 |

**Return Value:** None

**Examples:**
```sqf
// Drone
[_uav1, 0, [], true] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Vehicle
[_car1, 0, [], "EnemyCar", true, true, false, true, true, false, false, 3] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

---

### Root_fnc_addCustomDeviceZeusMain

Registers custom scripted devices.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _targetObject | OBJECT | - |
| 1 | _execUserId | NUMBER | 0 |
| 2 | _linkedComputers | ARRAY | [] |
| 3 | _customName | STRING | "Custom Device" |
| 4 | _activationCode | STRING | "" |
| 5 | _deactivationCode | STRING | "" |
| 6 | _availableToFutureLaptops | BOOLEAN | false |

**Code Context:** `_this = [_deviceObject, "activate"|"deactivate"]`

**Return Value:** None

**Example:**
```sqf
[_alarm, 0, [], "Alarm", "playSound3D ['alarm.wss', _this select 0, false, getPosASL (_this select 0), 5, 1, 300];", "hint 'Off';", true] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

---

### Root_fnc_addDatabaseZeusMain

Registers downloadable files.

**Syntax:**
```sqf
[_fileObject, _filename, _filesize, _filecontent, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _fileObject | OBJECT | - |
| 1 | _filename | STRING | - |
| 2 | _filesize | NUMBER | - |
| 3 | _filecontent | STRING | - |
| 4 | _execUserId | NUMBER | 0 |
| 5 | _linkedComputers | ARRAY | [] |
| 6 | _executionCode | STRING | "" |
| 7 | _availableToFutureLaptops | BOOLEAN | false |

**Return Value:** None

**Example:**
```sqf
[_server, "intel.txt", 10, "Secret data", 0, [], "hint 'Downloaded!';", true] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
```

---

### Root_fnc_addGPSTrackerZeusMain

Attaches GPS trackers to objects.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _sysChat, _ownersSelection] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _targetObject | OBJECT | - |
| 1 | _execUserId | NUMBER | 0 |
| 2 | _linkedComputers | ARRAY | [] |
| 3 | _trackerName | STRING | "Target_GPS" |
| 4 | _trackingTime | NUMBER | 60 |
| 5 | _updateFrequency | NUMBER | 5 |
| 6 | _customMarker | STRING | "" |
| 7 | _availableToFutureLaptops | BOOLEAN | false |
| 8 | _allowRetracking | BOOLEAN | true |
| 9 | _lastPingTimer | NUMBER | 30 |
| 10 | _powerCost | NUMBER | 2 |
| 11 | _sysChat | BOOLEAN | true |
| 12 | _ownersSelection | ARRAY | [[], [], []] |

**Owners Selection Format:** `[[sides], [groups], [players]]`

**Return Value:** None

**Example:**
```sqf
[_target, 0, [], "HVT", 120, 5, "", true, false, 30, 10, true, [[], [], []]] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

---

### Root_fnc_addPowerGeneratorZeusMain

Registers power generators.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _generatorName, _radius, _allowExplosionActivate, _allowExplosionDeactivate, _explosionType, _excludedClassnames, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _targetObject | OBJECT | - |
| 1 | _execUserId | NUMBER | 0 |
| 2 | _linkedComputers | ARRAY | [] |
| 3 | _generatorName | STRING | "Power Generator" |
| 4 | _radius | NUMBER | 50 |
| 5 | _allowExplosionActivate | BOOLEAN | false |
| 6 | _allowExplosionDeactivate | BOOLEAN | false |
| 7 | _explosionType | STRING | "HelicopterExploSmall" |
| 8 | _excludedClassnames | ARRAY | [] |
| 9 | _availableToFutureLaptops | BOOLEAN | false |
| 10 | _powerCost | NUMBER | 10 |

**Return Value:** None

**Example:**
```sqf
[_gen, 0, [], "Grid", 200, false, true, "HelicopterExploSmall", [], true, 15] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

---

### Root_fnc_copyDeviceLinksZeusMain

Copies device access from one laptop to another.

**Syntax:**
```sqf
[_sourceComputerNetId, _targetComputerNetId, _execUserId] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _sourceComputerNetId | STRING | - |
| 1 | _targetComputerNetId | STRING | - |
| 2 | _execUserId | NUMBER | 0 |

**Return Value:** None

**Example:**
```sqf
[netId _laptop1, netId _laptop2, 0] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
```

---

## Device Control Functions

These functions control registered devices.

### Root_fnc_changeDoorState

Controls door lock state.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _buildingId, _doorId, _desiredState] call Root_fnc_changeDoorState;
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _owner | NUMBER | nil | Legacy parameter (use nil) |
| 1 | _computer | OBJECT | - | Laptop object |
| 2 | _nameOfVariable | STRING | - | Completion variable name |
| 3 | _buildingId | STRING | - | Building device ID |
| 4 | _doorId | STRING | - | Door ID or "a" for all |
| 5 | _desiredState | STRING | - | "lock" or "unlock" |

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "1234", "2881", "lock"] call Root_fnc_changeDoorState;
```

---

### Root_fnc_changeLightState

Controls light on/off state.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _lightId, _desiredState] call Root_fnc_changeLightState;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _lightId | STRING | - |
| 4 | _desiredState | STRING | - |

**Valid States:** "on", "off", "a" (all)

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "5678", "off"] call Root_fnc_changeLightState;
```

---

### Root_fnc_changeDroneFaction

Changes drone faction/side.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _droneId, _faction] call Root_fnc_changeDroneFaction;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _droneId | STRING | - |
| 4 | _faction | STRING | - |

**Valid Factions:** "west", "east", "guer", "civ", "a" (all)

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "2", "east"] call Root_fnc_changeDroneFaction;
```

---

### Root_fnc_disableDrone

Disables (destroys) drone.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _droneId] call Root_fnc_disableDrone;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _droneId | STRING | - |

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "2"] call Root_fnc_disableDrone;
```

---

### Root_fnc_downloadDatabase

Downloads file from database.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _databaseId] call Root_fnc_downloadDatabase;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _databaseId | STRING | - |

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "1234"] call Root_fnc_downloadDatabase;
```

---

### Root_fnc_customDevice

Activates or deactivates custom device.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _customId, _customState, _playerObject, _commandPath]; call Root_fnc_customDevice;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _customId | STRING | - |
| 4 | _customState | STRING | - |

**Valid States:** "activate", "deactivate"

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "5", "activate"] call Root_fnc_customDevice;
```

---

### Root_fnc_displayGPSPosition

Tracks GPS device position.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _trackerId, _path] call Root_fnc_displayGPSPosition;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _trackerId | STRING | - |
| 4 | _path | STRING | - |

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "2421", "/tools/gpstrack"] call Root_fnc_displayGPSPosition;
```

---

### Root_fnc_changeVehicleParams

Modifies vehicle parameters.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _vehicleId, _action, _value, _path] call Root_fnc_changeVehicleParams;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _vehicleId | STRING | - |
| 4 | _action | STRING | - |
| 5 | _value | STRING | - |
| 6 | _path | STRING | - |

**Valid Actions:**
- `battery` (value: 0-100)
- `speed` (value: 0-100)
- `brakes` (value: 0-1)
- `lights` (value: 0-1)
- `engine` (value: 0-1)
- `alarm` (value: 0-1)

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "1337", "battery", "50", "/tools/"] call Root_fnc_changeVehicleParams;
```

---

### Root_fnc_powerGridControl

Controls power generator.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _gridId, _action, _path] call Root_fnc_powerGridControl;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _gridId | STRING | - |
| 4 | _action | STRING | - |
| 5 | _path | STRING | - |

**Valid Actions:** "on", "off", "overload"

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "1234", "on", "/tools/"] call Root_fnc_powerGridControl;
```

---

## Access Control Functions

### Root_fnc_isDeviceAccessible

Checks if computer can access a device.

**Syntax:**
```sqf
[_computer, _deviceType, _deviceId, _backdoorPath] call Root_fnc_isDeviceAccessible;
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _computer | OBJECT | - | Laptop object |
| 1 | _deviceType | NUMBER | - | Device type (1-8) |
| 2 | _deviceId | NUMBER | - | Device ID |
| 3 | _backdoorPath | STRING | "" | Backdoor function path |

**Return Value:** BOOLEAN - true if accessible

**Example:**
```sqf
private _canAccess = [_laptop, 1, 1234, ""] call Root_fnc_isDeviceAccessible;
```

---

### Root_fnc_getAccessibleDevices

Gets all accessible devices of a type.

**Syntax:**
```sqf
[_computer, _deviceType, _backdoorPath] call Root_fnc_getAccessibleDevices;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _computer | OBJECT | - |
| 1 | _deviceType | NUMBER | - |
| 2 | _backdoorPath | STRING | "" |

**Return Value:** ARRAY - Array of device entries

**Example:**
```sqf
private _doors = [_laptop, 1, ""] call Root_fnc_getAccessibleDevices;
```

---

## Power Management Functions

### Root_fnc_checkPowerAvailable

Checks if laptop has sufficient power.

**Syntax:**
```sqf
[_computer, _powerRequiredWh] call Root_fnc_checkPowerAvailable;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _computer | OBJECT | - |
| 1 | _powerRequiredWh | NUMBER | - |

**Return Value:** BOOLEAN - true if sufficient power

**Example:**
```sqf
private _hasPower = [_laptop, 10] call Root_fnc_checkPowerAvailable;
```

---

### Root_fnc_consumePower

Consumes power from laptop battery.

**Syntax:**
```sqf
[_computer, _powerWh] call Root_fnc_consumePower;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _computer | OBJECT | - |
| 1 | _powerWh | NUMBER | - |

**Return Value:** None

**Example:**
```sqf
[_laptop, 10] call Root_fnc_consumePower;
```

---

### Root_fnc_removePower

Alias for consumePower (legacy compatibility).

**Syntax:**
```sqf
[_computer, _powerWh] call Root_fnc_removePower;
```

**Parameters:** Same as consumePower

**Return Value:** None

---

## Utility Functions

### Root_fnc_listDevicesInSubnet

Lists all accessible devices in terminal.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _commandPath, _type] call Root_fnc_listDevicesInSubnet;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | nil |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _commandPath | STRING | - |
| 4 | _type | STRING | "all" |

**Valid Types:** "doors", "lights", "drones", "files", "custom", "gps", "vehicles", "powergrids", "all", "a"

**Return Value:** None

**Example:**
```sqf
[123, _laptop, "var1", "/tools/", "doors"] call Root_fnc_listDevicesInSubnet;
```

---

### Root_fnc_getUserConfirmation

Displays confirmation prompt with timeout.

**Syntax:**
```sqf
[_computer, _promptMessage, _timeout, _nameOfVariable] call Root_fnc_getUserConfirmation;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _computer | OBJECT | - |
| 1 | _promptMessage | STRING | - |
| 2 | _timeout | NUMBER | 10 |
| 3 | _nameOfVariable | STRING | - |

**Return Value:** None (sets variable to true if confirmed, false if denied/timeout)

**Example:**
```sqf
[_laptop, "Continue? (Y/N)", 10, "confirmVar"] call Root_fnc_getUserConfirmation;
```

---

## Data Structures

### Device Cache (HashMap)

**Variable:** `ROOT_CYBERWARFARE_DEVICE_CACHE`

**Structure:**
```sqf
createHashMap with keys:
- "doors" → Array of door entries
- "lights" → Array of light entries
- "drones" → Array of drone entries
- "databases" → Array of database entries
- "custom" → Array of custom device entries
- "gpsTrackers" → Array of GPS tracker entries
- "vehicles" → Array of vehicle entries
- "powerGrids" → Array of power grid entries
```

**Access:**
```sqf
private _deviceCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", createHashMap];
private _doors = _deviceCache getOrDefault ["doors", []];
```

---

### Link Cache (HashMap)

**Variable:** `ROOT_CYBERWARFARE_LINK_CACHE`

**Structure:**
```sqf
createHashMap with keys:
- computerNetId (STRING) → Array of [deviceType, deviceId] pairs
```

**Format:**
```sqf
"76561198123456789" → [[1, 1234], [2, 5678], [7, 9012]]
```

**Access:**
```sqf
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _links = _linkCache getOrDefault [netId _computer, []];
```

---

### Public Devices (Array)

**Variable:** `ROOT_CYBERWARFARE_PUBLIC_DEVICES`

**Structure:**
```sqf
[
    [deviceType, deviceId, [excludedComputerNetIds]],
    ...
]
```

**Access:**
```sqf
private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];
```

---

### Device Entry Formats

**Doors:**
```sqf
[deviceId, buildingNetId, doorIds[], buildingName, availableToFuture]
```

**Lights:**
```sqf
[deviceId, lightNetId, displayName, availableToFuture]
```

**Drones:**
```sqf
[deviceId, droneNetId, droneName, availableToFuture]
```

**Databases:**
```sqf
[deviceId, objectNetId, filename, filesize, linkedComputers, availableToFuture]
```

**Custom:**
```sqf
[deviceId, objectNetId, deviceName, activationCode, deactivationCode, availableToFuture]
```

**GPS Trackers:**
```sqf
[deviceId, targetNetId, trackerName, trackingTime, updateFrequency, customMarker, linkedComputers, availableToFuture, currentStatus, allowRetracking, lastPingDuration, powerCost, ownersSelection]
```

**Vehicles:**
```sqf
[deviceId, vehicleNetId, vehicleName, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFutureLaptops, powerCost, linkedComputers]
```

**Power Grids:**
```sqf
[gridId, objectNetId, gridName, radius, allowExplosionActivate, allowExplosionDeactivate, explosionType, excludedClassnames, availableToFutureLaptops, powerCost, linkedComputers]
```

---

## Constants and Macros

### Device Type Constants

```cpp
#define DEVICE_TYPE_DOOR 1
#define DEVICE_TYPE_LIGHT 2
#define DEVICE_TYPE_DRONE 3
#define DEVICE_TYPE_DATABASE 4
#define DEVICE_TYPE_CUSTOM 5
#define DEVICE_TYPE_GPS_TRACKER 6
#define DEVICE_TYPE_VEHICLE 7
#define DEVICE_TYPE_POWERGRID 8
```

---

### Cache Access Macros

```cpp
#define GET_DEVICE_CACHE (missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", createHashMap])
#define GET_LINK_CACHE (missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap])
#define GET_PUBLIC_DEVICES (missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []])
```

---

### Validation Macros

```cpp
#define VALIDATE_COMPUTER(computer) (!isNull computer && computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false])
#define VALIDATE_DEVICE_TYPE(type) (type >= DEVICE_TYPE_DOOR && type <= DEVICE_TYPE_POWERGRID)
```

---

### Power Conversion Macros

```cpp
#define WH_TO_KWH(wh) (wh / 1000)
#define KWH_TO_WH(kwh) (kwh * 1000)
```

**Usage:**
```sqf
private _kwh = WH_TO_KWH(500); // 500 Wh = 0.5 kWh
private _wh = KWH_TO_WH(0.5);  // 0.5 kWh = 500 Wh
```

---

### Color Constants

```cpp
#define COLOR_SUCCESS "#8ce10b"     // Green
#define COLOR_ERROR "#fa4c58"       // Red
#define COLOR_WARNING "#FFD966"     // Yellow
#define COLOR_INFO "#008DF8"        // Blue
```

**Usage:**
```sqf
private _message = format ["<t color='%1'>Success!</t>", COLOR_SUCCESS];
[_computer, _message] call AE3_armaos_fnc_shell_stdout;
```

---

### Global Variable Names

```cpp
#define GVAR_DEVICE_CACHE "ROOT_CYBERWARFARE_DEVICE_CACHE"
#define GVAR_LINK_CACHE "ROOT_CYBERWARFARE_LINK_CACHE"
#define GVAR_PUBLIC_DEVICES "ROOT_CYBERWARFARE_PUBLIC_DEVICES"
#define GVAR_ALL_DEVICES "ROOT_CYBERWARFARE_ALL_DEVICES"  // Legacy
```

---

### CBA Setting Names

```cpp
#define SETTING_DOOR_COST "ROOT_CYBERWARFARE_DOOR_COST"
#define SETTING_DRONE_HACK_COST "ROOT_CYBERWARFARE_DRONE_HACK_COST"
#define SETTING_DRONE_SIDE_COST "ROOT_CYBERWARFARE_DRONE_SIDE_COST"
#define SETTING_CUSTOM_COST "ROOT_CYBERWARFARE_CUSTOM_COST"
#define SETTING_POWERGRID_COST "ROOT_CYBERWARFARE_POWERGRID_COST"
#define SETTING_GPS_TRACKER_DEVICE "ROOT_CYBERWARFARE_GPS_TRACKER_DEVICE"
#define SETTING_GPS_SPECTRUM_DEVICES "ROOT_CYBERWARFARE_GPS_SPECTRUM_DEVICES"
#define SETTING_GPS_SEARCH_CHANCE_NORMAL "ROOT_CYBERWARFARE_GPS_SEARCH_CHANCE_NORMAL"
#define SETTING_GPS_SEARCH_CHANCE_TOOL "ROOT_CYBERWARFARE_GPS_SEARCH_CHANCE_TOOL"
#define SETTING_GPS_MARKER_COLOR_ACTIVE "ROOT_CYBERWARFARE_GPS_MARKER_COLOR_ACTIVE"
#define SETTING_GPS_MARKER_COLOR_LASTPING "ROOT_CYBERWARFARE_GPS_MARKER_COLOR_LASTPING"
```

**Access:**
```sqf
private _doorCost = missionNamespace getVariable [SETTING_DOOR_COST, 2];
```

---

**For implementation details, see [Architecture](Architecture). For usage examples, see [Mission Maker Guide](Mission-Maker-Guide).**
