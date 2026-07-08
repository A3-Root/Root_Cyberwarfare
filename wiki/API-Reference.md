# API Reference

Complete reference for all public functions in Root's Cyber Warfare, organized by category.

## Table of Contents

- [Overview](#overview)
- [Device Registration Functions](#device-registration-functions)
- [Device Control Functions](#device-control-functions)
- [Access Control Functions](#access-control-functions)
- [Power Management Functions](#power-management-functions)
- [Cipher Functions](#cipher-functions)
- [Network Scanning Functions](#network-scanning-functions)
- [Rubberducky Functions](#rubberducky-functions)
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

Installs hacking tools on an AE3 laptop or USB drive. USB-installed tools become available to a laptop while the drive is mounted.

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

### Root_fnc_addDoorsZeusMain

Registers building doors as hackable. Supports direct mode (single building) and radius mode (batch-register within an area). **Note:** For lights use `Root_fnc_addLightsZeusMain`, for drones use `Root_fnc_addVehicleZeusMain`, for custom devices use `Root_fnc_addCustomDeviceZeusMain`.

**Syntax (direct mode):**
```sqf
[_targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
```

**Syntax (radius mode):**
```sqf
[_centerPosition, _radius, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
```

**Parameters (direct mode):**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _targetObject | OBJECT | - | Building object |
| 1 | _execUserId | NUMBER | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | [] | Array of computer netIds (strings) |
| 3 | _availableToFutureLaptops | BOOLEAN | false | Auto-grant access to future laptops |
| 4 | _makeUnbreachable | BOOLEAN | false | Prevent ACE breaching |

**Return Value:** None

**Example:**
```sqf
[_building1, 0, [netId _laptop1], false, true] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
[getMarkerPos "base", 500, 0, [], true, false] remoteExec ["Root_fnc_addDoorsZeusMain", 2]; // Radius mode
```

---

### Root_fnc_addLightsZeusMain

Registers lights as hackable. Supports direct mode (single lamp) and radius mode (batch-register within an area).

**Syntax (direct mode):**
```sqf
[_targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops] remoteExec ["Root_fnc_addLightsZeusMain", 2];
```

**Syntax (radius mode):**
```sqf
[_centerPosition, _radius, _execUserId, _linkedComputers, _availableToFutureLaptops] remoteExec ["Root_fnc_addLightsZeusMain", 2];
```

**Parameters (direct mode):**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _targetObject | OBJECT | - | Lamp object |
| 1 | _execUserId | NUMBER | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | [] | Array of computer netIds (strings) |
| 3 | _availableToFutureLaptops | BOOLEAN | false | Auto-grant access to future laptops |

**Return Value:** None

**Example:**
```sqf
[_lamp1, 0, [], true] remoteExec ["Root_fnc_addLightsZeusMain", 2];
```

---

### Root_fnc_registerHackableLaptopZeusMain

Marks a laptop as a hackable station (valid link target) without installing the hacking toolset. Use alongside `Root_fnc_addHackingToolsZeusMain` for laptops that need both roles.

**Syntax:**
```sqf
[_entity, _execUserId, _customLaptopName] remoteExec ["Root_fnc_registerHackableLaptopZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _entity | OBJECT | - | Laptop object |
| 1 | _execUserId | NUMBER | 0 | User ID for feedback (0 resolves to owner) |
| 2 | _customLaptopName | STRING | "" | Display label; falls back to class displayName |

**Return Value:** None

**Example:**
```sqf
[_laptop1, 0, "HQ_Terminal"] remoteExec ["Root_fnc_registerHackableLaptopZeusMain", 2];
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
[_vehicle, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost, _fuelMinPercent, _fuelMaxPercent, _speedMinValue, _speedMaxValue, _brakesMinDecel, _brakesMaxDecel, _lightsMaxToggles, _lightsCooldown, _engineMaxToggles, _engineCooldown, _alarmMinDuration, _alarmMaxDuration] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Parameters (Drones):**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _drone | OBJECT | - |
| 1 | _execUserId | NUMBER | 0 |
| 2 | _linkedComputers | ARRAY | [] |
| 3 | _availableToFutureLaptops | BOOLEAN | false |

**Parameters (Vehicles):**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _vehicle | OBJECT | - | Vehicle object |
| 1 | _execUserId | NUMBER | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | [] | Array of computer netIds |
| 3 | _vehicleName | STRING | - | Display name |
| 4 | _allowFuel | BOOLEAN | false | Enable fuel/battery control |
| 5 | _allowSpeed | BOOLEAN | false | Enable speed boost control |
| 6 | _allowBrakes | BOOLEAN | false | Enable brake control |
| 7 | _allowLights | BOOLEAN | false | Enable lights control |
| 8 | _allowEngine | BOOLEAN | true | Enable engine control |
| 9 | _allowAlarm | BOOLEAN | false | Enable car alarm control |
| 10 | _availableToFutureLaptops | BOOLEAN | false | Auto-grant access to future laptops |
| 11 | _powerCost | NUMBER | 2 | Power cost in Wh per action |
| 12 | _fuelMinPercent | NUMBER | 0 | Minimum fuel percentage (0-100%) |
| 13 | _fuelMaxPercent | NUMBER | 100 | Maximum fuel percentage (0-100%) |
| 14 | _speedMinValue | NUMBER | -50 | Minimum speed boost in km/h (-100 to 100) |
| 15 | _speedMaxValue | NUMBER | 50 | Maximum speed boost in km/h (-100 to 100) |
| 16 | _brakesMinDecel | NUMBER | 1 | Minimum deceleration rate in m/s² (0.5-20) |
| 17 | _brakesMaxDecel | NUMBER | 10 | Maximum deceleration rate in m/s² (0.5-20) |
| 18 | _lightsMaxToggles | NUMBER | -1 | Maximum light toggles (-1 = unlimited) |
| 19 | _lightsCooldown | NUMBER | 0 | Cooldown between light toggles (seconds, 0-300) |
| 20 | _engineMaxToggles | NUMBER | -1 | Maximum engine toggles (-1 = unlimited) |
| 21 | _engineCooldown | NUMBER | 0 | Cooldown between engine toggles (seconds, 0-300) |
| 22 | _alarmMinDuration | NUMBER | 1 | Minimum alarm duration (seconds, 1-300) |
| 23 | _alarmMaxDuration | NUMBER | 30 | Maximum alarm duration (seconds, 1-300) |

**Return Value:** None

**Examples:**
```sqf
// Drone (4 parameters)
[_uav1, 0, [], true] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Vehicle with default limits (24 parameters)
[_car1, 0, [], "EnemyCar", true, true, false, true, true, false, false, 3, 0, 100, -50, 50, 1, 10, -1, 0, -1, 0, 1, 30] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Vehicle with custom limits
[_hvtVehicle, 0, [], "HVT Transport", true, true, true, true, true, true, false, 10, 0, 50, -30, 30, 2, 8, 5, 10, 3, 5, 2, 20] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
// Limits: Fuel 0-50%, Speed -30 to 30 km/h, Brakes 2-8 m/s², Lights max 5/10s, Engine max 3/5s, Alarm 2-20s
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

Attaches GPS trackers to objects for real-time position tracking.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _sysChat, _ownersSelection] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _targetObject | OBJECT | - | Object to track |
| 1 | _execUserId | NUMBER | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | [] | Array of computer netIds |
| 3 | _trackerName | STRING | "" | Tracker display name |
| 4 | _trackingTime | NUMBER | 60 | Tracking duration in seconds |
| 5 | _updateFrequency | NUMBER | 5 | Position update interval in seconds |
| 6 | _customMarker | STRING | "" | Custom marker name (optional) |
| 7 | _availableToFutureLaptops | BOOLEAN | false | Auto-grant access to future laptops |
| 8 | _allowRetracking | BOOLEAN | false | Allow tracking again after completion |
| 9 | _lastPingTimer | NUMBER | **REQUIRED** | Last ping marker duration in seconds |
| 10 | _powerCost | NUMBER | **REQUIRED** | Power cost in Wh to start tracking |
| 11 | _sysChat | BOOLEAN | true | Show system chat message |
| 12 | _ownersSelection | ARRAY | [[], [], []] | Marker visibility: [[sides], [groups], [players]] |

**Owners Selection Format:** `[[sides], [groups], [players]]`

**Return Value:** None

**Example:**
```sqf
[_target, 0, [], "HVT", 120, 5, "", true, false, 30, 10, true, [[], [], []]] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

**Important:** Parameters 9 and 10 are **REQUIRED** and have no default values. Always specify them explicitly.

---

### Root_fnc_addPowerGeneratorZeusMain

Registers power generators that control lights within a radius.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _generatorName, _radius, _allowExplosionOverload, _explosionType, _excludedClassnames, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _targetObject | OBJECT | - | Generator object |
| 1 | _execUserId | NUMBER | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | [] | Array of computer netIds |
| 3 | _generatorName | STRING | "Power Generator" | Display name |
| 4 | _radius | NUMBER | 50 | Radius in meters to affect lights |
| 5 | _allowExplosionOverload | BOOLEAN | false | Create explosion on overload action |
| 6 | _explosionType | STRING | "ClaymoreDirectionalMine_Remote_Ammo_Scripted" | Ammo classname for explosion |
| 7 | _excludedClassnames | ARRAY | [] | Light classnames to exclude from control |
| 8 | _availableToFutureLaptops | BOOLEAN | false | Auto-grant access to future laptops |
| 9 | _powerCost | NUMBER | 10 | Power cost in Wh per operation |

**Return Value:** None

**Example:**
```sqf
[_gen, 0, [], "Grid", 200, true, "HelicopterExploSmall", [], true, 15] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
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

### Root_fnc_clearBrokenDeviceLinks

Immediately removes device/link entries whose object no longer exists. No strike-grace delay (unlike the automatic background loop).

**Syntax:**
```sqf
private _removed = call Root_fnc_clearBrokenDeviceLinks;
```

**Parameters:** None

**Return Value:** NUMBER - count of entries removed

**Example:**
```sqf
private _removed = call Root_fnc_clearBrokenDeviceLinks;
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
- `battery` (value: configured min-max percentage)
- `speed` (value: configured min-max km/h, supports negative)
- `brakes` (value: configured min-max m/s² deceleration rate; continues until stopped, then holds for 2 seconds)
- `lights` (value: 0-1, subject to toggle limits and cooldown)
- `engine` (value: 0-1, subject to toggle limits and cooldown)
- `alarm` (value: configured min-max seconds)

**Limit Validation:**
- All operations validate against configured min/max ranges
- Operations outside limits are rejected with detailed error messages
- Toggle operations check max usage count and cooldown timers
- Error messages include current value and allowed range

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

## Cipher Functions

### Root_fnc_cipherProcess

Runs a classical cipher against text: encrypt, decrypt, or bruteforce. Backs the `crypto`/`crack` terminal commands, the Hackerman Desktop Crypto/Crack apps, and the Zeus Cipher Tools module.

**Syntax:**
```sqf
[_algorithm, _mode, _text, _options] call Root_fnc_cipherProcess;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _algorithm | STRING | `morse`, `spelling`, `affine`, `rot`, `vigenere`, `bacon`, `alpha_sub`, `railfence`, `base32`, `base64`, `ascii85`, `unicode`, `integer`, or `all` (bruteforce only) |
| 1 | _mode | STRING | `encrypt`, `decrypt`, `bruteforce` |
| 2 | _text | STRING | Input text |
| 3 | _options | HASHMAP | Algorithm-specific options (`key`, `variant`, `a`/`b`, `rails`, `radix`, `width`, `signed`, etc.) |

**Return Value:** STRING (encrypt/decrypt) or ARRAY of ranked candidates (bruteforce)

**Example:**
```sqf
private _options = createHashMap; _options set ["key", "LEMON"];
private _cipherText = ["vigenere", "encrypt", "attack at dawn", _options] call Root_fnc_cipherProcess;
```

---

### Root_fnc_cipherOptionsFromText

Parses a `crypto`/`crack`-style CLI option string into the options hashmap `Root_fnc_cipherProcess` expects.

**Syntax:**
```sqf
private _options = [_optionString] call Root_fnc_cipherOptionsFromText;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _optionString | STRING | e.g. `"-k=LEMON --variant=13"` |

**Return Value:** HASHMAP

---

### Root_fnc_cipherRegister

Builds the list of supported ciphers, merges them into AE3's file-encryption algorithm registry, and registers the `RootCW_Crypto`/`RootCW_Crack` desktop apps. Called once automatically from `XEH_postInit.sqf` - mission makers don't need to call this themselves.

**Syntax:**
```sqf
call Root_fnc_cipherRegister;
```

**Parameters:** None

**Return Value:** None

---

## Network Scanning Functions

### Root_fnc_scanNetwork

Builds the subnet snapshot used by the `netscan` command and NetScan desktop app: IP, host type, external SSH exposure, interface, and reachable/accessible hackable device counts.

**Syntax:**
```sqf
private _rows = [_computer] call Root_fnc_scanNetwork;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _computer | OBJECT | Scanning laptop |

**Return Value:** ARRAY of `[ip, deviceType, sshAllowed, interface, deviceBreakdown]` rows

---

### Root_fnc_scanNetworkCli

Server-side driver for the `netscan` terminal command: builds the scan, prints it to the requesting client, and optionally exports it to a file in the laptop's filesystem.

**Syntax:**
```sqf
[_owner, _computer, _nameOfVariable, _exportPath] call Root_fnc_scanNetworkCli;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _owner | NUMBER | - |
| 1 | _computer | OBJECT | - |
| 2 | _nameOfVariable | STRING | - |
| 3 | _exportPath | STRING | "" |

**Return Value:** None

---

## Rubberducky Functions

### Root_fnc_seedRubberducky

Server-side: waits for a placed Rubberducky USB object's filesystem to exist, then silently installs the hacking toolset on it via `Root_fnc_addHackingToolsZeusMain`.

**Syntax:**
```sqf
[_drive] call Root_fnc_seedRubberducky;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _drive | OBJECT | The Rubberducky USB object |

**Return Value:** None

---

### Root_fnc_seedRubberduckyCredentials

Adds the configured default login (username/password) to a laptop when a hacking-tools USB is connected, unless an account with that username already exists or the feature is disabled.

**Syntax:**
```sqf
private _added = [_computer] call Root_fnc_seedRubberduckyCredentials;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _computer | OBJECT | The laptop the USB was connected to |

**Return Value:** BOOLEAN - true if a credential was added

---

### Root_fnc_setRubberduckyCredentials

Runtime API to change Rubberducky default-login behavior (mirrors the CBA settings).

**Syntax:**
```sqf
[_enabled, _username, _password] call Root_fnc_setRubberduckyCredentials;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _enabled | BOOLEAN or nil | `nil` leaves unchanged |
| 1 | _username | STRING or nil | `nil` leaves unchanged |
| 2 | _password | STRING or nil | `nil` leaves unchanged |

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

### Root_fnc_getBatteryStatus

Reads a laptop's battery through AE3 and calculates the remaining charge after a given cost, without consuming it.

**Syntax:**
```sqf
[_computer, _powerCostWh] call Root_fnc_getBatteryStatus;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _computer | OBJECT | - |
| 1 | _powerCostWh | NUMBER | 0 |

**Return Value:** ARRAY - `[success, battery, currentWh, currentPercent, capacityWh, remainingWh, remainingPercent]`

---

### Root_fnc_gridLabel

Returns a device's map-grid string for display, honoring the per-device "Allow Location View" flag. GPS trackers are exempt (they gate on tracked state instead).

**Syntax:**
```sqf
private _grid = [_obj] call Root_fnc_gridLabel;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _obj | OBJECT | The device object |

**Return Value:** STRING - grid string, `"[location hidden]"`, or `"unknown"`

---

### Root_fnc_applyVehicleBrakes

Applies server-managed braking to a land vehicle until it stops, then holds it stationary. Backs the `vehicle <id> brakes <rate>` command/action.

**Syntax:**
```sqf
[_vehicle, _decelRate, _holdTime] call Root_fnc_applyVehicleBrakes;
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _vehicle | OBJECT | - | Vehicle to brake |
| 1 | _decelRate | NUMBER | 1 | Deceleration in m/s² |
| 2 | _holdTime | NUMBER | 2 | Seconds to hold stationary after stopping |

**Return Value:** None

---

### Root_fnc_removeHackingTools

Deletes the installed toolset's command files from a laptop's filesystem and clears the installed flag. Used when a hacking USB is unplugged, revoking capability.

**Syntax:**
```sqf
[_computer, _path] call Root_fnc_removeHackingTools;
```

**Parameters:**

| Index | Name | Type | Default |
|-------|------|------|---------|
| 0 | _computer | OBJECT | - |
| 1 | _path | STRING | "/rubberducky/tools" |

**Return Value:** None

---

### Root_fnc_hasHackingToolsAvailable

Checks whether a laptop has hacking tools installed directly, or has a qualifying USB mounted.

**Syntax:**
```sqf
private _available = [_computer] call Root_fnc_hasHackingToolsAvailable;
```

**Parameters:**

| Index | Name | Type | Description |
|-------|------|------|-------------|
| 0 | _computer | OBJECT | Laptop to check |

**Return Value:** BOOLEAN

---

### Root_fnc_runDeviceLinkCleanup

Sweeps device/link caches removing entries whose object no longer resolves. Backs the automatic background cleanup loop.

**Syntax:**
```sqf
private _removed = [_useGrace] call Root_fnc_runDeviceLinkCleanup;
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | _useGrace | BOOLEAN | true | If true, requires several consecutive failed lookups before removing an entry |

**Return Value:** NUMBER - count of entries removed

---

### Root_fnc_syncDeviceData

Debounced (1s) `publicVariable` broadcast of the device registry (`ALL_DEVICES`/`LINK_CACHE`/`PUBLIC_DEVICES`/`DEVICE_LINKS`), replacing per-mutation broadcasts. Called internally after registry changes; mission scripts rarely need to call it directly.

**Syntax:**
```sqf
call Root_fnc_syncDeviceData;
```

**Parameters:** None

**Return Value:** None

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

These are the array formats used when devices are stored in `ROOT_CYBERWARFARE_ALL_DEVICES`:

**Doors:**
```sqf
[deviceId, buildingNetId, doorIds[], buildingName, availableToFuture]
// Example: [1234, "76561198123456789", [0, 1, 2], "Land_Cargo_House_V1_F", false]
```

**Lights:**
```sqf
[deviceId, lightNetId, displayName, availableToFuture]
// Example: [5678, "76561198987654321", "Land_LampStreet_small_F", true]
```

**Drones:**
```sqf
[deviceId, droneNetId, droneName, availableToFuture]
// Example: [9012, "76561198111111111", "B_UAV_02_F", false]
```

**Databases:**
```sqf
[deviceId, objectNetId, filename, filesize, linkedComputers, availableToFuture]
// Example: [3456, "76561198222222222", "intel.txt", 10, ["76561198333333333"], false]
// Note: File content and execution code are stored as object variables, not in this array
```

**Custom:**
```sqf
[deviceId, objectNetId, deviceName, activationCode, deactivationCode, availableToFuture]
// Example: [7890, "76561198444444444", "Generator", "hint 'ON'", "hint 'OFF'", true]
```

**GPS Trackers:**
```sqf
[deviceId, targetNetId, trackerName, trackingTime, updateFrequency, customMarker, linkedComputers, availableToFuture, currentStatus, allowRetracking, lastPingTimer, powerCost, ownersSelection]
// Example: [2421, "76561198555555555", "HVT", 120, 5, "", [], false, ["Untracked", 0, ""], true, 30, 10, [[], [], []]]
// currentStatus format: [status, lastUpdateTime, lastPosition]
// ownersSelection format: [[sides], [groups], [players]]
```

**Vehicles:**
```sqf
[deviceId, vehicleNetId, vehicleName, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFutureLaptops, powerCost, linkedComputers, fuelMinPercent, fuelMaxPercent, speedMinValue, speedMaxValue, brakesMinDecel, brakesMaxDecel, lightsMaxToggles, lightsCooldown, engineMaxToggles, engineCooldown, alarmMinDuration, alarmMaxDuration, ...reserved]
// Example: [1337, "76561198666666666", "Enemy APC", true, true, false, true, true, false, false, 5, ["76561198777777777"], 0, 100, -50, 50, 1, 10, -1, 0, -1, 0, 1, 30, nil, nil, nil, nil, nil, nil]
// Note: Array has 30 elements total (24 parameters + 6 reserved slots for future expansion)
```

**Power Grids:**
```sqf
[gridId, objectNetId, gridName, radius, allowExplosionOverload, explosionType, excludedClassnames, availableToFutureLaptops, powerCost, linkedComputers]
// Example: [5000, "76561198888888888", "Main Grid", 200, true, "HelicopterExploSmall", [], true, 15, []]
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
#define DEVICE_TYPE_NETSCAN 9   // GUI-only: network scanner results, not a cache entry type
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
#define ROOT_CYBERWARFARE_COLOR_SUCCESS "#8ce10b"     // Green
#define ROOT_CYBERWARFARE_COLOR_ERROR "#fa4c58"       // Red
#define ROOT_CYBERWARFARE_COLOR_WARNING "#FFD966"     // Yellow
#define ROOT_CYBERWARFARE_COLOR_INFO "#008DF8"        // Blue
```

**Usage:**
```sqf
private _message = format ["<t color='%1'>Success!</t>", ROOT_CYBERWARFARE_COLOR_SUCCESS];
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
#define SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE "ROOT_CYBERWARFARE_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE"
#define SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING "ROOT_CYBERWARFARE_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING"
```

**Access:**
```sqf
private _doorCost = missionNamespace getVariable [SETTING_DOOR_COST, 2];
```

---

**For implementation details, see [Architecture](Architecture). For usage examples, see [Mission Maker Guide](Mission-Maker-Guide).**
