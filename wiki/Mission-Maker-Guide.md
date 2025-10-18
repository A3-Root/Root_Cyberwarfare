# Mission Maker Guide

This guide covers programmatic device registration and advanced scripting for Root's Cyber Warfare, enabling mission makers to create dynamic cyber warfare scenarios with SQF code.

## Table of Contents

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Device Registration Functions](#device-registration-functions)
  - [Add Hacking Tools](#add-hacking-tools)
  - [Register Buildings (Doors/Lights)](#register-buildings-doorslights)
  - [Register Vehicles](#register-vehicles)
  - [Register Custom Devices](#register-custom-devices)
  - [Register Databases/Files](#register-databasesfiles)
  - [Register GPS Trackers](#register-gps-trackers)
  - [Register Power Generators](#register-power-generators)
  - [Copy Device Links](#copy-device-links)
- [Access Control Patterns](#access-control-patterns)
- [Practical Examples](#practical-examples)
- [initServer.sqf Template](#initserversqf-template)
- [Advanced Techniques](#advanced-techniques)

## Introduction

While Zeus and 3DEN modules provide visual configuration, **programmatic registration** offers:

- **Dynamic registration**: Create devices during gameplay based on events
- **Conditional logic**: Register devices based on mission conditions
- **Randomization**: Create unpredictable scenarios
- **Complex access control**: Fine-grained permissions
- **Integration**: Tie cyber warfare into existing mission systems

All registration functions should be called **on the server** (use `remoteExec` if calling from client).

---

## Getting Started

### Where to Put Code

**initServer.sqf** (Recommended for mission initialization)
```sqf
// This file runs only on the server when the mission starts
// Place initial device registration here

// Example:
[_laptop1, "/network/tools", 0, "HackingStation", ""] call Root_fnc_addHackingToolsZeusMain;
[_building1, 0, [], false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Triggered Scripts** (For dynamic registration)
```sqf
// In a trigger or script:
if (someCondition) then {
    [_newVehicle, 0, [_laptop1], "NewTarget", true, false, false, true, true, false, false, 3]
        remoteExec ["Root_fnc_addVehicleZeusMain", 2];
};
```

**Functions** (For reusable code)
```sqf
// In functions\fn_setupCyberWarfare.sqf:
params ["_laptops", "_buildings"];

{
    [_x, "/tools", 0, "", ""] call Root_fnc_addHackingToolsZeusMain;
} forEach _laptops;

{
    [_x, 0, _laptops apply {netId _x}, false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach _buildings;
```

### Important Notes

1. **Server execution**: All registration functions must run on the server
   - If calling from client or uncertain context: `remoteExec ["FunctionName", 2]`
   - If already on server: `call FunctionName`

2. **netId vs object**: Some parameters require `netId` (string), others require object reference
   - `linkedComputers` parameter: Array of `netId` strings
   - `_computer` parameter: Object reference

3. **Timing**: Registration can occur anytime, but typically:
   - Mission start: `initServer.sqf`
   - Player joins: `onPlayerConnected` handler
   - Mission events: Triggers, scripts

---

## Device Registration Functions

### Add Hacking Tools

**Function:** `Root_fnc_addHackingToolsZeusMain`

**Description:** Installs hacking tools on an AE3 laptop or USB stick.

**Syntax:**
```sqf
[_computer, _path, _execUserId, _laptopName, _backdoorPrefix] call Root_fnc_addHackingToolsZeusMain;
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_computer` | OBJECT | (required) | Laptop or USB object |
| 1 | `_path` | STRING | `"/rubberducky/tools"` | Tool installation path. No trailing `/`. |
| 2 | `_execUserId` | NUMBER | `0` | User ID for feedback messages |
| 3 | `_laptopName` | STRING | `""` | Custom display name for laptop |
| 4 | `_backdoorPrefix` | STRING | `""` | Backdoor function prefix (leave empty for normal use) |

**Examples:**
```sqf
// Basic installation
[_laptop1, "/network/tools", 0, "MainHackingStation", ""] call Root_fnc_addHackingToolsZeusMain;

// Multiple laptops with loop
{
    [_x, "/tools", 0, "", ""] call Root_fnc_addHackingToolsZeusMain;
} forEach [_laptop1, _laptop2, _laptop3];

// With backdoor access (testing/admin)
[_adminLaptop, "/admin/tools", 0, "AdminConsole", "backdoor_"] call Root_fnc_addHackingToolsZeusMain;
```

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Must be called before registering devices
- Backdoor prefix enables admin access (bypasses all permissions)
- Can be called on the same laptop multiple times (overwrites previous installation)

---

### Register Buildings (Doors/Lights)

**Function:** `Root_fnc_addDeviceZeusMain`

**Description:** Registers buildings (with doors) or lights as hackable devices.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _treatAsCustom, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_targetObject` | OBJECT | (required) | Building or lamp object |
| 1 | `_execUserId` | NUMBER | `0` | User ID for feedback |
| 2 | `_linkedComputers` | ARRAY | `[]` | Array of computer netIds (NOT objects) |
| 3 | `_treatAsCustom` | BOOLEAN | `false` | DEPRECATED - leave as false |
| 4 | `_customName` | STRING | `""` | DEPRECATED - leave as "" |
| 5 | `_activationCode` | STRING | `""` | DEPRECATED - leave as "" |
| 6 | `_deactivationCode` | STRING | `""` | DEPRECATED - leave as "" |
| 7 | `_availableToFutureLaptops` | BOOLEAN | `false` | Auto-grant access to future laptops |
| 8 | `_makeUnbreachable` | BOOLEAN | `false` | Prevent ACE breaching (doors only) |

**Examples:**
```sqf
// Public building (all laptops)
[_building1, 0, [], false, "", "", "", true, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Private building (specific laptops)
[_building2, 0, [netId _laptop1, netId _laptop2], false, "", "", "", false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Unbreachable building (future laptops only)
[_building3, 0, [], false, "", "", "", true, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Register multiple buildings
{
    [_x, 0, [netId _laptop1], false, "", "", "", false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach [_building1, _building2, _building3];

// Light registration
[_streetLamp1, 0, [], false, "", "", "", true, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Auto-Detection:**
- **Buildings**: All doors are automatically detected and registered
- **Lights**: Single light device registered

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Automatically generates unique 4-digit device ID (1000-9999)
- `linkedComputers` must be netId strings, not object references
- Get netId with: `netId _laptop`
- Unbreachable flag prevents ACE explosive breaching and lockpicking

---

### Register Vehicles

**Function:** `Root_fnc_addVehicleZeusMain`

**Description:** Registers vehicles or drones as hackable. Auto-detects drone vs vehicle based on parameters.

**Syntax (Drones - 4 parameters):**
```sqf
[_drone, _execUserId, _linkedComputers, _availableToFutureLaptops] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Syntax (Vehicles - 12 parameters):**
```sqf
[_vehicle, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Parameters (Drones):**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_drone` | OBJECT | (required) | Drone/UAV object |
| 1 | `_execUserId` | NUMBER | `0` | User ID for feedback |
| 2 | `_linkedComputers` | ARRAY | `[]` | Array of computer netIds |
| 3 | `_availableToFutureLaptops` | BOOLEAN | `false` | Auto-grant access to future laptops |

**Parameters (Vehicles):**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_vehicle` | OBJECT | (required) | Vehicle object |
| 1 | `_execUserId` | NUMBER | `0` | User ID for feedback |
| 2 | `_linkedComputers` | ARRAY | `[]` | Array of computer netIds |
| 3 | `_vehicleName` | STRING | (required) | Display name |
| 4 | `_allowFuel` | BOOLEAN | `false` | Enable fuel/battery control (0-100%) |
| 5 | `_allowSpeed` | BOOLEAN | `false` | Enable max speed control (0-100%) |
| 6 | `_allowBrakes` | BOOLEAN | `false` | Enable brake control (0-1) |
| 7 | `_allowLights` | BOOLEAN | `false` | Enable lights control (0-1) |
| 8 | `_allowEngine` | BOOLEAN | `true` | Enable engine control (0-1) |
| 9 | `_allowAlarm` | BOOLEAN | `false` | Enable car alarm control (0-1) |
| 10 | `_availableToFutureLaptops` | BOOLEAN | `false` | Auto-grant access to future laptops |
| 11 | `_powerCost` | NUMBER | `2` | Power cost in Wh per action |

**Examples:**
```sqf
// Drone (4 parameters)
[_uav1, 0, [], true] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Drone with specific laptop access
[_uav2, 0, [netId _laptop1], false] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Vehicle with full control
[_enemyCar, 0, [], "Enemy Sedan", true, true, false, true, true, false, true, 2]
    remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Vehicle with limited control (fuel and engine only)
[_truck1, 0, [netId _laptop1], "Supply Truck", true, false, false, false, true, false, false, 5]
    remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// High-value target with expensive operations
[_commanderVehicle, 0, [], "HVT Transport", true, true, true, true, true, true, true, 10]
    remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Register all vehicles in an array
{
    [_x, 0, [netId _laptop1], "Enemy Vehicle", true, false, false, true, true, false, false, 3]
        remoteExec ["Root_fnc_addVehicleZeusMain", 2];
} forEach [_car1, _car2, _car3];
```

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Function auto-detects drone vs vehicle based on parameter count (4 vs 12)
- Drones use `changedrone` and `disabledrone` commands
- Vehicles use `vehicle` command with enabled actions only
- Power cost applies to each individual vehicle action

---

### Register Custom Devices

**Function:** `Root_fnc_addCustomDeviceZeusMain`

**Description:** Registers custom scripted devices with user-defined activation/deactivation code.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_targetObject` | OBJECT | (required) | Object representing the device |
| 1 | `_execUserId` | NUMBER | `0` | User ID for feedback |
| 2 | `_linkedComputers` | ARRAY | `[]` | Array of computer netIds |
| 3 | `_customName` | STRING | `"Custom Device"` | Display name |
| 4 | `_activationCode` | STRING | `""` | SQF code for activation |
| 5 | `_deactivationCode` | STRING | `""` | SQF code for deactivation |
| 6 | `_availableToFutureLaptops` | BOOLEAN | `false` | Auto-grant access to future laptops |

**Code Context:**
In activation/deactivation code, `_this` is:
```sqf
_this = [_deviceObject, "activate"|"deactivate"]
```

**Examples:**
```sqf
// Simple alarm system
[
    _alarmBox,
    0,
    [netId _laptop1],
    "Base Alarm",
    "playSound3D ['a3\sounds_f\sfx\alarm.wss', _this select 0, false, getPosASL (_this select 0), 5, 1, 300];",
    "hint 'Alarm deactivated.';",
    false
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];

// Generator with light control
[
    _generator,
    0,
    [],
    "Power Generator",
    "
        private _device = _this select 0;
        private _lights = nearestObjects [_device, ['Lamps_base_F'], 100];
        {_x switchLight 'ON';} forEach _lights;
        _device setVariable ['lightsOn', true, true];
    ",
    "
        private _device = _this select 0;
        private _lights = nearestObjects [_device, ['Lamps_base_F'], 100];
        {_x switchLight 'OFF';} forEach _lights;
        _device setVariable ['lightsOn', false, true];
    ",
    true
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];

// Objective trigger
[
    _terminal,
    0,
    [netId _laptop1],
    "Mainframe Terminal",
    "
        'ObjectiveHack' call BIS_fnc_taskSetState 'SUCCEEDED';
        hint 'Objective complete: Mainframe hacked!';
    ",
    "",
    false
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];

// Spawner device
[
    _spawner,
    0,
    [],
    "Reinforcement Caller",
    "
        private _device = _this select 0;
        private _pos = getPosATL _device;
        private _group = createGroup east;
        for '_i' from 1 to 5 do {
            _group createUnit ['O_Soldier_F', _pos, [], 10, 'FORM'];
        };
        hint 'Enemy reinforcements incoming!';
    ",
    "",
    true
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Code executes in scheduled environment (can use `sleep`, `waitUntil`, etc.)
- Code runs on the server
- Use `remoteExec` within code for client-side effects
- Device object is accessible: `_this select 0`
- Can store persistent state in device variables: `_device setVariable ["key", value, true]`

---

### Register Databases/Files

**Function:** `Root_fnc_addDatabaseZeusMain`

**Description:** Registers downloadable files with optional code execution.

**Syntax:**
```sqf
[_fileObject, _filename, _filesize, _filecontent, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_fileObject` | OBJECT | (required) | Object "storing" the file |
| 1 | `_filename` | STRING | (required) | File name (with or without extension) |
| 2 | `_filesize` | NUMBER | (required) | Download time in seconds |
| 3 | `_filecontent` | STRING | (required) | File contents (shown with `cat` command) |
| 4 | `_execUserId` | NUMBER | `0` | User ID for feedback |
| 5 | `_linkedComputers` | ARRAY | `[]` | Array of computer netIds |
| 6 | `_executionCode` | STRING | `""` | Optional SQF code executed on download |
| 7 | `_availableToFutureLaptops` | BOOLEAN | `false` | Auto-grant access to future laptops |

**Examples:**
```sqf
// Simple intel file
[
    _server1,
    "enemy_positions.txt",
    10,
    "Alpha Squad: Grid 045-182\nBravo Squad: Grid 112-209",
    0,
    [netId _laptop1],
    "",
    false
] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];

// File with objective trigger
[
    _mainframe,
    "classified_intel.dat",
    20,
    "TOP SECRET\n==========\nOperation Codename: BLACKOUT\nTarget: Power Grid Alpha",
    0,
    [],
    "
        hint 'Intel downloaded! New objective unlocked.';
        'IntelObjective' call BIS_fnc_taskSetState 'SUCCEEDED';
        'SabotageObjective' call BIS_fnc_taskSetState 'ASSIGNED';
    ",
    true
] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];

// Multiline content with formatting
private _content = "ENEMY CONVOY SCHEDULE\n";
_content = _content + "=====================\n\n";
_content = _content + "Convoy Alpha: 0800 hrs - Route 7\n";
_content = _content + "Convoy Bravo: 1200 hrs - Highway 12\n";
_content = _content + "Convoy Charlie: 1600 hrs - Coastal Road";

[
    _computerTerminal,
    "convoy_schedule.txt",
    15,
    _content,
    0,
    [netId _laptop1, netId _laptop2],
    "",
    false
] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];

// Dynamic file with spawn trigger
[
    _database,
    "activation_codes.txt",
    30,
    "Activation Code: ALPHA-BRAVO-CHARLIE-123",
    0,
    [],
    "
        private _pos = getMarkerPos 'spawnMarker';
        private _veh = createVehicle ['O_MRAP_02_F', _pos, [], 0, 'NONE'];
        hint 'Download complete. Enemy QRF dispatched to your location!';
    ",
    true
] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
```

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Download time is real seconds
- File saved to `/home/user/Downloads/<filename>` on laptop
- Execution code runs after download completes
- Players read files with `cat /home/user/Downloads/<filename>`
- Content supports newlines (`\n`) and special characters

---

### Register GPS Trackers

**Function:** `Root_fnc_addGPSTrackerZeusMain`

**Description:** Attaches GPS trackers to objects for real-time position tracking.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _sysChat, _ownersSelection] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_targetObject` | OBJECT | (required) | Object to track |
| 1 | `_execUserId` | NUMBER | `0` | User ID for feedback |
| 2 | `_linkedComputers` | ARRAY | `[]` | Array of computer netIds |
| 3 | `_trackerName` | STRING | `"Target_GPS"` | Display name and default marker name |
| 4 | `_trackingTime` | NUMBER | `60` | Maximum tracking duration (seconds) |
| 5 | `_updateFrequency` | NUMBER | `5` | Position update interval (seconds) |
| 6 | `_customMarker` | STRING | `""` | Custom marker name (optional) |
| 7 | `_availableToFutureLaptops` | BOOLEAN | `false` | Auto-grant access to future laptops |
| 8 | `_allowRetracking` | BOOLEAN | `true` | Allow tracking again after completion |
| 9 | `_lastPingTimer` | NUMBER | `30` | Last ping marker duration (seconds) |
| 10 | `_powerCost` | NUMBER | `2` | Power cost in Wh to start tracking |
| 11 | `_sysChat` | BOOLEAN | `true` | Show system chat message |
| 12 | `_ownersSelection` | ARRAY | `[[], [], []]` | Marker visibility: `[[sides], [groups], [players]]` |

**Marker Visibility Format:**
```sqf
_ownersSelection = [[sides], [groups], [players]]

// Examples:
[[], [], []]                      // Everyone
[[west], [], []]                  // Only BLUFOR
[[west, independent], [], []]     // BLUFOR and Independent
[[], [group player], []]          // Only specific group
[[], [], [player1, player2]]      // Only specific players
```

**Examples:**
```sqf
// Basic tracking (all laptops, all players see markers)
[
    _enemyCommander,
    0,
    [],
    "HVT_Commander",
    120,
    5,
    "",
    true,
    false,
    30,
    10,
    true,
    [[], [], []]
] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// Private tracking (specific laptop, BLUFOR only)
[
    _enemyVehicle,
    0,
    [netId _laptop1],
    "Enemy_APC",
    180,
    10,
    "Enemy APC Position",
    false,
    true,
    60,
    5,
    true,
    [[west], [], []]
] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// Long-duration tracking with retracking
[
    _supplyTruck,
    0,
    [],
    "Supply_Convoy",
    300,
    15,
    "",
    true,
    true,
    120,
    3,
    true,
    [[], [], []]
] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// Track multiple targets
{
    [
        _x,
        0,
        [netId _laptop1],
        format ["Target_%1", _forEachIndex],
        90,
        5,
        "",
        false,
        false,
        30,
        8,
        true,
        [[west], [], []]
    ] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
} forEach [_target1, _target2, _target3];
```

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Marker colors configured via CBA settings (see [Configuration](Configuration.md))
- Tracking creates two markers: Active Ping (updates) and Last Ping (final position)
- If target is destroyed, tracking status changes to "Dead"
- Players can physically search for and disable trackers

---

### Register Power Generators

**Function:** `Root_fnc_addPowerGeneratorZeusMain`

**Description:** Creates power generators that control lights within a radius.

**Syntax:**
```sqf
[_targetObject, _execUserId, _linkedComputers, _generatorName, _radius, _allowExplosionActivate, _allowExplosionDeactivate, _explosionType, _excludedClassnames, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_targetObject` | OBJECT | (required) | Object representing generator |
| 1 | `_execUserId` | NUMBER | `0` | User ID for feedback |
| 2 | `_linkedComputers` | ARRAY | `[]` | Array of computer netIds |
| 3 | `_generatorName` | STRING | `"Power Generator"` | Display name |
| 4 | `_radius` | NUMBER | `50` | Effect radius in meters |
| 5 | `_allowExplosionActivate` | BOOLEAN | `false` | Create explosion on activation |
| 6 | `_allowExplosionDeactivate` | BOOLEAN | `false` | Create explosion on deactivation/overload |
| 7 | `_explosionType` | STRING | `"HelicopterExploSmall"` | Ammo classname for explosion |
| 8 | `_excludedClassnames` | ARRAY | `[]` | Light classnames to exclude |
| 9 | `_availableToFutureLaptops` | BOOLEAN | `false` | Auto-grant access to future laptops |
| 10 | `_powerCost` | NUMBER | `10` | Power cost in Wh per operation |

**Examples:**
```sqf
// Basic power grid
[
    _generator1,
    0,
    [],
    "Base Power Grid",
    200,
    false,
    false,
    "HelicopterExploSmall",
    [],
    true,
    15
] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];

// Dangerous generator with explosion
[
    _unstableGenerator,
    0,
    [netId _laptop1],
    "Unstable Generator",
    100,
    false,
    true,
    "Bo_GBU12_LGB",
    [],
    false,
    20
] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];

// Generator with excluded lights
[
    _cityGenerator,
    0,
    [],
    "City Power",
    500,
    false,
    true,
    "HelicopterExploSmall",
    ["Land_LampDecor_F", "Land_LampHalogen_F"],
    true,
    10
] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];

// Register generators at multiple locations
{
    private _name = format ["Generator_%1", _forEachIndex + 1];
    [
        _x,
        0,
        [netId _laptop1],
        _name,
        300,
        false,
        true,
        "HelicopterExploSmall",
        [],
        false,
        15
    ] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
} forEach [_gen1, _gen2, _gen3];
```

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Controls all lights (class `Lamps_base_F`) within radius
- Excluded classnames are not affected by on/off/overload
- Overload permanently destroys the generator object
- Explosion creates damage, visual, and audio effects

---

### Copy Device Links

**Function:** `Root_fnc_copyDeviceLinksZeusMain`

**Description:** Copies all device access permissions from one laptop to another.

**Syntax:**
```sqf
[_sourceComputerNetId, _targetComputerNetId, _execUserId] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
```

**Parameters:**

| Index | Name | Type | Default | Description |
|-------|------|------|---------|-------------|
| 0 | `_sourceComputerNetId` | STRING | (required) | Source laptop's netId |
| 1 | `_targetComputerNetId` | STRING | (required) | Target laptop's netId |
| 2 | `_execUserId` | NUMBER | `0` | User ID for feedback |

**Examples:**
```sqf
// Copy permissions from laptop1 to laptop2
[netId _laptop1, netId _laptop2, 0] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];

// Copy to multiple targets
{
    [netId _sourceLaptop, netId _x, 0] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
} forEach [_laptop2, _laptop3, _laptop4];

// Dynamic copying based on condition
if (playerSide == west) then {
    [netId _bluforMasterLaptop, netId _playerLaptop, 0] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
};
```

**Returns:** None (feedback message sent to execUserId)

**Notes:**
- Only copies **private link access**, not backdoor or public access
- Additive operation (doesn't remove existing permissions from target)
- Both laptops must have hacking tools installed
- Uses netId strings, not object references

---

## Access Control Patterns

### Pattern 1: Public Access (All Laptops)

All laptops can access the device immediately.

```sqf
// Register device with public access
[_building1, 0, [], false, "", "", "", true, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
// availableToFutureLaptops = true, linkedComputers = []
```

**Use Case:** Training missions, cooperative scenarios, open access

---

### Pattern 2: Private Access (Specific Laptops)

Only specified laptops can access the device.

```sqf
// Register device with private access
private _laptopNetIds = [netId _laptop1, netId _laptop2];
[_vehicle1, 0, _laptopNetIds, "TargetVehicle", true, true, false, true, true, false, false, 3]
    remoteExec ["Root_fnc_addVehicleZeusMain", 2];
// linkedComputers = laptop netIds, availableToFutureLaptops = false
```

**Use Case:** Team-specific devices, competitive scenarios, segmented access

---

### Pattern 3: Future Access Only

Only laptops added AFTER device registration get access (current laptops excluded).

```sqf
// Register device
[_building1, 0, [], false, "", "", "", true, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
// linkedComputers = [], availableToFutureLaptops = true

// Laptops that existed BEFORE this registration are excluded
// Laptops added AFTER will have access
```

**Use Case:** Progressive missions, dynamic access grants, new player advantages

---

### Pattern 4: Mixed Access (Specific + Future)

Specific laptops get immediate access, future laptops also get access.

```sqf
// Register device with mixed access
[_file1, "intel.txt", 10, "Content", 0, [netId _laptop1], "", true]
    remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
// linkedComputers = [laptop1], availableToFutureLaptops = true

// laptop1: immediate access (linked)
// Future laptops: automatic access
// Current laptops (except laptop1): excluded
```

**Use Case:** VIP laptop + public access, founder advantages

---

### Pattern 5: Backdoor Access (Admin/Debug)

Laptop bypasses all permission checks.

```sqf
// Install tools with backdoor
[_adminLaptop, "/admin/tools", 0, "AdminConsole", "backdoor_"] call Root_fnc_addHackingToolsZeusMain;
// backdoorPrefix = "backdoor_"

// This laptop now has access to ALL devices, regardless of registration
```

**Use Case:** Testing, debugging, admin control, mission recovery

---

### Pattern 6: Dynamic Access (Event-Based)

Grant access based on mission events.

```sqf
// Initial registration (no access)
[_secretVault, 0, [], false, "", "", "", false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Later, when player completes objective:
if ("KeycardObjective" call BIS_fnc_taskCompleted) then {
    // Manually add access to player's laptop
    private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
    private _laptopNetId = netId _playerLaptop;
    private _existingLinks = _linkCache getOrDefault [_laptopNetId, []];
    _existingLinks pushBack [1, _vaultDeviceId]; // Device type 1 = doors, device ID from registration
    _linkCache set [_laptopNetId, _existingLinks];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];

    hint "Access granted: Secret Vault unlocked!";
};
```

**Use Case:** Quest/objective-based access, progressive unlocks, earned permissions

---

## Practical Examples

### Example 1: Complete Mission Setup

```sqf
// initServer.sqf

// Setup laptops
private _bluforLaptops = [laptop_blufor_1, laptop_blufor_2];
private _opforLaptops = [laptop_opfor_1];

// Install hacking tools
{
    [_x, "/network/tools", 0, "BLUFOR Station", ""] call Root_fnc_addHackingToolsZeusMain;
} forEach _bluforLaptops;

{
    [_x, "/network/tools", 0, "OPFOR Station", ""] call Root_fnc_addHackingToolsZeusMain;
} forEach _opforLaptops;

// Register buildings (team-specific)
private _bluforBuildingNetIds = _bluforLaptops apply {netId _x};
private _opforBuildingNetIds = _opforLaptops apply {netId _x};

{
    [_x, 0, _bluforBuildingNetIds, false, "", "", "", false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach [building_blufor_1, building_blufor_2];

{
    [_x, 0, _opforBuildingNetIds, false, "", "", "", false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach [building_opfor_1, building_opfor_2];

// Register vehicles
[
    vehicle_blufor_1,
    0,
    _opforBuildingNetIds,
    "BLUFOR Transport",
    true, true, false, true, true, false,
    false,
    5
] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// GPS trackers
[
    hvt_target,
    0,
    _bluforBuildingNetIds,
    "HVT_Tracker",
    180,
    10,
    "",
    false,
    false,
    60,
    15,
    true,
    [[west], [], []]
] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

---

### Example 2: Random Device Distribution

```sqf
// Randomly assign devices to laptops

private _allLaptops = [laptop1, laptop2, laptop3];
private _allBuildings = [building1, building2, building3, building4, building5];

// Each building gets access from 1-2 random laptops
{
    private _building = _x;
    private _numLaptops = 1 + (floor random 2); // 1 or 2
    private _assignedLaptops = _allLaptops call BIS_fnc_arrayShuffle;
    _assignedLaptops resize _numLaptops;
    private _laptopNetIds = _assignedLaptops apply {netId _x};

    [_building, 0, _laptopNetIds, false, "", "", "", false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach _allBuildings;
```

---

### Example 3: Progressive Unlock System

```sqf
// Devices unlock as objectives complete

// Register all devices initially with no access
{
    [_x, 0, [], false, "", "", "", false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach [tier1_building, tier2_building, tier3_building];

// When objective 1 completes, grant access to tier1
"Objective1" call BIS_fnc_taskCompleted; // Example trigger
[netId masterLaptop, netId tier1Laptop, 0] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
hint "Tier 1 Access Granted!";

// Similar for other tiers...
```

---

### Example 4: File Download Chain

```sqf
// Files that unlock subsequent files

// File 1 (public)
[
    server1,
    "access_log.txt",
    5,
    "Recent Access: User 'admin' - IP 192.168.1.50",
    0,
    [],
    "
        hint 'Clue found! Check server at 192.168.1.50';
        missionNamespace setVariable ['file1Downloaded', true, true];
    ",
    true
] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];

// File 2 (unlocked by file 1's execution code)
[
    server2,
    "admin_credentials.txt",
    10,
    "Username: admin\nPassword: hunter2",
    0,
    [],
    "
        hint 'Credentials acquired! Access granted to mainframe.';
        missionNamespace setVariable ['file2Downloaded', true, true];
    ",
    false
] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];

// Monitor and grant access when file1 downloaded
[] spawn {
    waitUntil {missionNamespace getVariable ["file1Downloaded", false]};
    sleep 2;
    // Grant access to file 2 (via linking)
    // ... linking code here ...
};
```

---

## initServer.sqf Template

Here's a complete template for a cyber warfare mission:

```sqf
/*
 * initServer.sqf
 * Root's Cyber Warfare Mission Template
 */

// ===========================
// 1. INSTALL HACKING TOOLS
// ===========================

private _bluforLaptops = [laptop_blufor_1];
private _opforLaptops = [laptop_opfor_1];

{
    [_x, "/network/tools", 0, "BLUFOR Laptop", ""] call Root_fnc_addHackingToolsZeusMain;
} forEach _bluforLaptops;

{
    [_x, "/network/tools", 0, "OPFOR Laptop", ""] call Root_fnc_addHackingToolsZeusMain;
} forEach _opforLaptops;

// ===========================
// 2. REGISTER BUILDINGS
// ===========================

// BLUFOR base (private to BLUFOR laptops)
private _bluforNetIds = _bluforLaptops apply {netId _x};
{
    [_x, 0, _bluforNetIds, false, "", "", "", false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach [blufor_hq, blufor_barracks];

// OPFOR base (private to OPFOR laptops)
private _opforNetIds = _opforLaptops apply {netId _x};
{
    [_x, 0, _opforNetIds, false, "", "", "", false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach [opfor_hq, opfor_barracks];

// Neutral buildings (public)
{
    [_x, 0, [], false, "", "", "", true, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach [civilian_building_1, civilian_building_2];

// ===========================
// 3. REGISTER VEHICLES
// ===========================

// BLUFOR vehicles (hackable by OPFOR)
{
    [
        _x,
        0,
        _opforNetIds,
        "BLUFOR Vehicle",
        true, true, false, true, true, false,
        false,
        3
    ] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
} forEach [blufor_truck_1, blufor_apc_1];

// OPFOR vehicles (hackable by BLUFOR)
{
    [
        _x,
        0,
        _bluforNetIds,
        "OPFOR Vehicle",
        true, false, false, true, true, false,
        false,
        3
    ] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
} forEach [opfor_truck_1];

// ===========================
// 4. REGISTER GPS TRACKERS
// ===========================

// BLUFOR HVT (trackable by OPFOR)
[
    blufor_commander,
    0,
    _opforNetIds,
    "BLUFOR_Commander",
    120,
    5,
    "",
    false,
    false,
    30,
    10,
    true,
    [[east], [], []]
] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// ===========================
// 5. REGISTER CUSTOM DEVICES
// ===========================

// Alarm system
[
    alarm_box_1,
    0,
    _bluforNetIds,
    "Base Alarm",
    "playSound3D ['a3\\sounds_f\\sfx\\alarm.wss', _this select 0, false, getPosASL (_this select 0), 5, 1, 300];",
    "hint 'Alarm deactivated.';",
    false
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];

// ===========================
// 6. REGISTER DATABASES
// ===========================

// Intel file
[
    intel_terminal,
    "enemy_intel.txt",
    15,
    "CLASSIFIED INTEL\n===============\nEnemy convoy: Route 7, 0800 hrs",
    0,
    _bluforNetIds,
    "hint 'Intel downloaded!'; 'IntelObjective' call BIS_fnc_taskSetState 'SUCCEEDED';",
    false
] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];

// ===========================
// 7. REGISTER POWER GRIDS
// ===========================

// Base power generator
[
    generator_1,
    0,
    [],
    "Main Power Grid",
    300,
    false,
    true,
    "HelicopterExploSmall",
    [],
    true,
    15
] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];

// ===========================
// END OF SETUP
// ===========================

systemChat "Cyber Warfare systems initialized.";
```

---

## Advanced Techniques

### Technique 1: Delayed Registration

Register devices after a delay or trigger:

```sqf
// Spawn new hackable vehicle after 5 minutes
[] spawn {
    sleep 300;
    private _veh = createVehicle ["O_MRAP_02_F", getMarkerPos "spawnPoint", [], 0, "NONE"];
    [
        _veh,
        0,
        [netId laptop1],
        "New Target",
        true, false, false, true, true, false,
        false,
        5
    ] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
    hint "New hackable vehicle detected!";
};
```

---

### Technique 2: Conditional Registration

Register based on player choice or mission state:

```sqf
// Register different devices based on player faction
if (playerSide == west) then {
    [building_opfor, 0, [netId playerLaptop], false, "", "", "", false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} else {
    [building_blufor, 0, [netId playerLaptop], false, "", "", "", false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
};
```

---

### Technique 3: Device Lifecycle Management

Remove access or deactivate devices:

```sqf
// Disable a device by removing it from all caches
private _deviceId = 1234;
private _deviceType = 1; // Doors

// Remove from device cache
private _deviceCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", createHashMap];
private _doors = _deviceCache getOrDefault ["doors", []];
_doors = _doors select {(_x select 0) != _deviceId};
_deviceCache set ["doors", _doors];
missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", _deviceCache, true];

// Remove from link cache
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
{
    private _links = _y;
    _links = _links select {!(_x isEqualTo [_deviceType, _deviceId])};
    _linkCache set [_x, _links];
} forEach _linkCache;
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];

hint format ["Device %1 disabled.", _deviceId];
```

---

### Technique 4: Bulk Registration

Register many devices efficiently:

```sqf
// Register all buildings in a trigger area
private _buildings = nearestObjects [getMarkerPos "baseMarker", ["House"], 500];
{
    [_x, 0, [netId laptop1], false, "", "", "", false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach _buildings;

systemChat format ["Registered %1 buildings.", count _buildings];
```

---

**Need lower-level details?** Check the [API Reference](API-Reference.md) for complete function signatures and the [Architecture](Architecture.md) guide for internal data structures.
