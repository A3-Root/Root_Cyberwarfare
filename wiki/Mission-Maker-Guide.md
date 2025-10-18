# Mission Maker Guide

This guide covers programmatic setup of Root's Cyber Warfare using SQF scripts.

## Table of Contents

- [Overview](#overview)
- [Function Reference](#function-reference)
- [Programmatic Setup](#programmatic-setup)
- [Advanced Techniques](#advanced-techniques)
- [Examples](#examples)

## Overview

Mission makers can bypass Zeus/Eden modules and directly call functions to register devices programmatically. This is useful for:

- Dynamic mission generation
- Conditional device spawning
- Integration with other scripts
- Advanced mission logic

### Important Notes

- All `*Main` functions should be called on the **server only**
- Functions use `remoteExec` to execute on server: `[params] remoteExec ["Root_fnc_functionMain", 2]`
- Device IDs are auto-generated (random 4-digit numbers 1000-9999)

## Function Reference

### Add Hacking Tools

**Function**: `Root_fnc_addHackingToolsZeusMain`

**Syntax**:
```sqf
[object, backdoorPath, execUserId, laptopName, linkedComputerNetIds] call Root_fnc_addHackingToolsZeusMain;
```

**Parameters**:
- `object` - The laptop object
- `backdoorPath` - Backdoor access path (empty string "" for none)
- `execUserId` - User ID for feedback (0 = owner)
- `laptopName` - Display name for the laptop
- `linkedComputerNetIds` - Array of netIDs to link (empty [] for none)

**Example**:
```sqf
[laptop1, "", 0, "Field Terminal Alpha", []] call Root_fnc_addHackingToolsZeusMain;
```

### Add Building (Doors/Lights)

**Function**: `Root_fnc_addDeviceZeusMain`

**Syntax**:
```sqf
[targetObject, execUserId, linkedComputers, availableToFutureLaptops, makeUnbreachable] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Parameters**:
- `targetObject` - Building or light object
- `execUserId` - User ID (0 = auto)
- `linkedComputers` - Array of computer netIds
- `availableToFutureLaptops` - Boolean
- `makeUnbreachable` - Boolean (doors only)

**Example**:
```sqf
[building1, 0, [netId laptop1], false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

### Add Vehicle

**Function**: `Root_fnc_addVehicleZeusMain`

**Syntax** (Vehicle):
```sqf
[vehicle, execUserId, linkedComputers, vehicleName, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFutureLaptops, powerCost] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Syntax** (Drone - simplified):
```sqf
[drone, execUserId, linkedComputers, availableToFutureLaptops] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Parameters** (Vehicle):
- `vehicle` - Vehicle object
- `execUserId` - User ID (0 = auto)
- `linkedComputers` - Array of computer netIds
- `vehicleName` - Display name
- `allowFuel` - Boolean
- `allowSpeed` - Boolean
- `allowBrakes` - Boolean
- `allowLights` - Boolean (empty vehicles only)
- `allowEngine` - Boolean
- `allowAlarm` - Boolean
- `availableToFutureLaptops` - Boolean
- `powerCost` - Number (1-30 Wh)

**Example** (Vehicle):
```sqf
[car1, 0, [], "Enemy Transport", true, false, false, false, true, false, false, 5] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Example** (Drone):
```sqf
[drone1, 0, [netId laptop1], false] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

### Add Custom Device

**Function**: `Root_fnc_addCustomDeviceZeusMain`

**Syntax**:
```sqf
[object, execUserId, linkedComputers, customName, activationCode, deactivationCode, availableToFutureLaptops] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

**Parameters**:
- `object` - Any object
- `execUserId` - User ID (0 = auto)
- `linkedComputers` - Array of computer netIds
- `customName` - Display name
- `activationCode` - SQF code string (runs on activation)
- `deactivationCode` - SQF code string (runs on deactivation)
- `availableToFutureLaptops` - Boolean

**Example**:
```sqf
[generator1, 0, [], "Power Generator",
    "hint 'Generator Online!'",
    "hint 'Generator Offline!'",
    false
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

### Add Power Generator

**Function**: `Root_fnc_addPowerGeneratorZeusMain`

**Syntax**:
```sqf
[object, execUserId, linkedComputers, name, radius, allowExplosionActivate, allowExplosionDeactivate, explosionType, excludedClassnames, availableToFutureLaptops] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

**Parameters**:
- `object` - Generator object
- `execUserId` - User ID (0 = auto)
- `linkedComputers` - Array of computer netIds
- `name` - Display name
- `radius` - Area of effect (meters)
- `allowExplosionActivate` - Boolean
- `allowExplosionDeactivate` - Boolean
- `explosionType` - Classname (e.g., "HelicopterExploSmall")
- `excludedClassnames` - Array of light classnames to exclude
- `availableToFutureLaptops` - Boolean

**Example**:
```sqf
[powerStation, 0, [], "City Power Grid", 500, false, true, "HelicopterExploSmall", [], false] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

## Programmatic Setup

### Basic Mission Setup

```sqf
// init.sqf or initServer.sqf

if (!isServer) exitWith {};

// Add hacking tools to laptop
[laptop1, "", 0, "BLUFOR HQ Terminal", []] call Root_fnc_addHackingToolsZeusMain;

// Register enemy building with unbreachable doors
[enemyHQ, 0, [netId laptop1], false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Register enemy vehicle
[enemyCar, 0, [netId laptop1], "Enemy Transport", true, false, false, false, true, false, false, 10] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

### Dynamic Device Registration

```sqf
// Register all vehicles of a certain type
{
    if (_x isKindOf "Car") then {
        private _vehicleName = getText (configOf _x >> "displayName");
        [_x, 0, [], _vehicleName, true, false, false, false, true, false, false, 5] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
    };
} forEach vehicles;
```

### Conditional Setup

```sqf
// Only add hacking tools if difficulty is hard
if (difficulty >= 3) then {
    [laptop1, "", 0, "Advanced Terminal", []] call Root_fnc_addHackingToolsZeusMain;
} else {
    [laptop1, "/admin/root", 0, "Basic Terminal", []] call Root_fnc_addHackingToolsZeusMain; // With backdoor
};
```

## Advanced Techniques

### Subnet Organization

Organize devices into subnets for logical separation:

```sqf
// BLUFOR network
[bluforLaptop1, "", 0, "BLUFOR Terminal 1", []] call Root_fnc_addHackingToolsZeusMain;

// OPFOR network (separate devices)
[opforLaptop1, "", 0, "OPFOR Terminal 1", []] call Root_fnc_addHackingToolsZeusMain;

// Register building to BLUFOR only
[building1, 0, [netId bluforLaptop1], false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Register building to OPFOR only
[building2, 0, [netId opforLaptop1], false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

### Future Laptop Access Pattern

```sqf
// Register devices BEFORE laptops exist
[building1, 0, [], true, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2]; // Available to future laptops

// Later in mission, add laptops - they automatically get access
[newLaptop, "", 0, "Field Laptop", []] call Root_fnc_addHackingToolsZeusMain;
```

### Custom Device Advanced Examples

**Toggle Global Variable:**
```sqf
[
    generator1, 0, [], "Mission Generator",
    "missionNamespace setVariable ['powerActive', true, true]; hint 'Power Grid Online';",
    "missionNamespace setVariable ['powerActive', false, true]; hint 'Power Grid Offline';",
    false
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

**Spawn Enemy Reinforcements:**
```sqf
[
    alarmPanel, 0, [], "Alarm System",
    "private _grp = [getPos alarmPanel, EAST, 4] call BIS_fnc_spawnGroup; hint 'ALARM TRIGGERED!';",
    "hint 'Alarm Disabled';",
    false
] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

**Complex Multi-Step Code:**
```sqf
private _activationCode = "
    params ['_computer', '_device', '_player'];
    private _nearLights = nearestObjects [_device, ['Lamps_base_F'], 200];
    {_x switchLight 'ON'} forEach _nearLights;
    [_computer, format ['<t color=''#8ce10b''>Lights activated! %1 lights powered on.</t>', count _nearLights]] call AE3_armaos_fnc_shell_stdout;
";

private _deactivationCode = "
    params ['_computer', '_device', '_player'];
    private _nearLights = nearestObjects [_device, ['Lamps_base_F'], 200];
    {_x switchLight 'OFF'} forEach _nearLights;
    [_computer, format ['<t color=''#fa4c58''>Lights deactivated! %1 lights powered off.</t>', count _nearLights]] call AE3_armaos_fnc_shell_stdout;
";

[generator1, 0, [], "Area Lighting Control", _activationCode, _deactivationCode, false] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

### Manual Device Access Management

```sqf
// Get link cache
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];

// Add device to laptop's access list
private _computerNetId = netId laptop1;
private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
_existingLinks pushBack [7, 1234]; // Vehicle type (7), device ID (1234)
_linkCache set [_computerNetId, _existingLinks];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
```

### Device Type Constants

```sqf
DEVICE_TYPE_DOOR = 1;
DEVICE_TYPE_LIGHT = 2;
DEVICE_TYPE_DRONE = 3;
DEVICE_TYPE_DATABASE = 4;
DEVICE_TYPE_CUSTOM = 5;
DEVICE_TYPE_GPS_TRACKER = 6;
DEVICE_TYPE_VEHICLE = 7;
```

## Examples

### Complete Stealth Mission Setup

```sqf
// initServer.sqf

if (!isServer) exitWith {};

// Setup player laptop
[playerLaptop, "", 0, "Infiltrator Terminal", []] call Root_fnc_addHackingToolsZeusMain;

// Enemy base - unbreachable
[enemyBase, 0, [netId playerLaptop], false, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Enemy patrol vehicles
{
    private _vehName = format ["Patrol %1", _forEachIndex + 1];
    [_x, 0, [netId playerLaptop], _vehName, true, true, true, false, true, false, false, 15] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
} forEach [patrol1, patrol2, patrol3];

// Security cameras (custom devices)
{
    private _camName = format ["Camera %1", _forEachIndex + 1];
    [_x, 0, [netId playerLaptop], _camName,
        "hint 'Camera disabled - 30 sec';",
        "",
        false
    ] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
} forEach [camera1, camera2, camera3, camera4];

// Power generator objective
[mainGenerator, 0, [netId playerLaptop], "Main Power Grid", 300, false, true, "HelicopterExploSmall", [], false] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

### Dynamic Mission with Progressive Access

```sqf
// Initial setup - limited access
[laptop1, "", 0, "Basic Terminal", []] call Root_fnc_addHackingToolsZeusMain;

// Register critical devices as future-access only
[criticalBuilding, 0, [], true, true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
[criticalVehicle, 0, [], "VIP Transport", true, true, true, false, true, false, true, 20] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Later in mission (e.g., on trigger activation)
// Player finds upgraded laptop - automatically gets access to future devices
[upgradedLaptop, "/admin/advanced", 0, "Advanced Terminal", []] call Root_fnc_addHackingToolsZeusMain;
```

---

For more information, see:
- [API Reference](API-Reference) - Complete function documentation
- [Zeus Guide](Zeus-Guide) - Runtime module usage
- [Configuration Guide](Configuration) - CBA settings
