# Mission Maker Guide

This guide covers integrating Root's Cyber Warfare into your Arma 3 missions using scripting.

# **WARNING: THIS IS A STOP GAP SOLUTION UNTIL A MORE PERMANENT 3DEN FRIENDLY MODULES ARE EVENTUALLY RELEASED.**

## Overview

While Zeus modules are great for dynamic missions, scripted integration gives you more control and allows pre-configuration. This guide shows you how to add hacking tools, devices, and configure access control via scripts.

---

## Quick Start

### Minimal Setup

Add this to your `init.sqf` or object init field:

```sqf
// 1. Add hacking tools to laptop
[_laptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];

// 2. Make building hackable
[_building] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

That's it! Players can now use the laptop to hack the building.

---

## Adding Hacking Tools

### Function: `Root_fnc_addHackingToolsZeusMain`

Installs hacking tools on a laptop.

**Syntax**:
```sqf
[_entity, _path, _execUserId, _customLaptopName, _backdoorScriptPrefix] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
```

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _entity | OBJECT | No | - | The laptop object |
| 1 | _path | STRING | Yes | "/rubberducky/tools" | Installation path |
| 2 | _execUserId | NUMBER | Yes | 0 | Owner ID for feedback |
| 3 | _customLaptopName | STRING | Yes | "" | Display name |
| 4 | _backdoorScriptPrefix | STRING | Yes | "" | Backdoor prefix |

**Examples**:

```sqf
// Basic installation
[_laptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];

// With custom name
[_laptop, "/tools", 0, "HQ_Terminal"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];

// With backdoor access
[_laptop, "/admin", 0, "Admin_Terminal", "/backdoor"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
```

**Backdoor System**:

Backdoor prefix grants full access to ALL devices:

```sqf
// Admin laptop with backdoor
[_laptop, "/admin/tools", 0, "Zeus_Terminal", "/admin"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];

// Regular laptop (no backdoor)
[_laptop, "/operative/tools", 0, "Field_Laptop", ""] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
```

Result:
- Admin terminal: Full access to all devices
- Field laptop: Only linked devices

---

## Adding Devices

### Function: `Root_fnc_addDeviceZeusMain`

Makes an object hackable (auto-detects type or creates custom device).

**Syntax**:
```sqf
[_targetObject, _execUserId, _linkedComputers, _treatAsCustom, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _targetObject | OBJECT | No | - | Object to make hackable |
| 1 | _execUserId | Yes | 0 | Owner ID for feedback |
| 2 | _linkedComputers | ARRAY | Yes | [] | Array of computer netIds |
| 3 | _treatAsCustom | BOOLEAN | Yes | false | Force custom device |
| 4 | _customName | STRING | Yes | "" | Custom device name |
| 5 | _activationCode | STRING | Yes | "" | Activation script |
| 6 | _deactivationCode | STRING | Yes | "" | Deactivation script |
| 7 | _availableToFutureLaptops | BOOLEAN | Yes | false | Future laptop access |

**Examples**:

```sqf
// Basic device (auto-detected type)
[_building] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Link to specific laptop
private _laptopNetId = netId _laptop;
[_building, 0, [_laptopNetId]] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Custom device with code
[_object, 0, [], true, "Power Generator",
    "hint 'Generator activated';",
    "hint 'Generator deactivated';",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Available to future laptops only
[_building, 0, [], false, "", "", "", true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Auto-Detection**:
- Buildings with doors → Door device
- `Lamps_base_F` → Light device
- UAVs → Drone device

**Device Linking Scenarios**:

```sqf
// Scenario 1: Public device (all current laptops)
[_door] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Scenario 2: Private device (specific laptops)
private _laptop1 = netId _laptop1;
private _laptop2 = netId _laptop2;
[_door, 0, [_laptop1, _laptop2]] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Scenario 3: Future-only device
[_door, 0, [], false, "", "", "", true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Scenario 4: Specific + future laptops
[_door, 0, [_laptop1], false, "", "", "", true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Adding GPS Trackers

### Function: `Root_fnc_addGPSTrackerZeusMain`

Attaches GPS tracker to an object.

**Syntax**:
```sqf
[_targetObject, _execUserId, _linkedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _sysChat] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _targetObject | OBJECT | No | - | Object to track |
| 1 | _execUserId | NUMBER | Yes | 0 | Owner ID |
| 2 | _linkedComputers | ARRAY | Yes | [] | Computer netIds |
| 3 | _trackerName | STRING | Yes | "" | Display name |
| 4 | _trackingTime | NUMBER | Yes | 60 | Duration (seconds) |
| 5 | _updateFrequency | NUMBER | Yes | 5 | Ping frequency (seconds) |
| 6 | _customMarker | STRING | Yes | "" | Custom marker name |
| 7 | _availableToFutureLaptops | BOOLEAN | Yes | false | Future laptop access |
| 8 | _allowRetracking | BOOLEAN | Yes | false | Allow re-tracking |
| 9 | _lastPingTimer | NUMBER | No | - | Last ping duration (seconds) |
| 10 | _powerCost | NUMBER | No | - | Power cost (Wh) |
| 11 | _sysChat | BOOLEAN | Yes | true | Show system chat |

**Examples**:

```sqf
// Basic GPS tracker
[_vehicle, 0, [], "Target_Vehicle", 60, 5, "", false, true, 30, 2, true] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// Long-duration tracker
[_hvt, 0, [], "HVT_Commander", 300, 15, "", false, false, 60, 5, true] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// Link to specific laptop
private _netId = netId _laptop;
[_crate, 0, [_netId], "Supply_Cache", 120, 10, "", false, true, 30, 2, true] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

---

## Adding Vehicles

### Function: `Root_fnc_addVehicleZeusMain`

Makes a vehicle hackable with configurable control features.

**Syntax**:
```sqf
[_targetObject, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _targetObject | OBJECT | No | - | Vehicle object |
| 1 | _execUserId | NUMBER | Yes | 0 | Owner ID |
| 2 | _linkedComputers | ARRAY | Yes | [] | Computer netIds |
| 3 | _vehicleName | STRING | No | - | Display name |
| 4 | _allowFuel | BOOLEAN | Yes | false | Enable battery control |
| 5 | _allowSpeed | BOOLEAN | Yes | false | Enable speed control |
| 6 | _allowBrakes | BOOLEAN | Yes | false | Enable brakes |
| 7 | _allowLights | BOOLEAN | Yes | false | Enable lights |
| 8 | _allowEngine | BOOLEAN | Yes | true | Enable engine |
| 9 | _allowAlarm | BOOLEAN | Yes | false | Enable alarm |
| 10 | _availableToFutureLaptops | BOOLEAN | Yes | false | Future laptop access |
| 11 | _powerCost | NUMBER | Yes | 2 | Power per action (Wh) |

**Examples**:

```sqf
// Full control vehicle
[_vehicle, 0, [], "Enemy_Transport", true, true, true, true, true, true, false, 2] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Limited control (lights and alarm only)
[_civilianCar, 0, [], "Civ_Car", false, false, false, true, false, true, false, 1] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

// Link to specific laptop, enable battery drain only
private _netId = netId _laptop;
[_enemyTruck, 0, [_netId], "Supply_Truck", true, false, false, false, false, false, false, 3] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

---

## Adding Files/Databases

### Function: `Root_fnc_addDatabaseZeusMain`

Creates downloadable file in the network.

**Syntax**:
```sqf
[_allDatabases, _databaseId, _fileObject, _filename, _filesize, _filecontent, _allDevices, _allDoors, _allLamps, _allDrones, _allCustom, _allGpsTrackers, _allVehicles, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
```

**Simplified Wrapper**:

```sqf
// Helper function for easier use
ROOT_fnc_addDatabase = {
    params ["_filename", "_filesize", "_content", ["_code", ""], ["_linkedComputers", []], ["_futureAvailable", false]];

    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
    _allDevices params ["_allDoors", "_allLamps", "_allDrones", "_allDatabases", "_allCustom", "_allGpsTrackers", "_allVehicles"];

    private _fileObject = "Land_HelipadEmpty_F" createVehicle [0,0,0];

    [_allDatabases, 0, _fileObject, _filename, _filesize, _content, _allDevices, _allDoors, _allLamps, _allDrones, _allCustom, _allGpsTrackers, _allVehicles, 0, _linkedComputers, _code, _futureAvailable] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
};

// Usage
["Mission_Briefing", 10, "Your objective is...", "hint 'Briefing acquired';"] call ROOT_fnc_addDatabase;
```

**Examples**:

```sqf
// Basic file
["Intel_Report", 5, "Enemy positions: Grid 123456"] call ROOT_fnc_addDatabase;

// File with execution code
["Secret_Plans", 15, "Operation details...",
    "['TaskComplete', true] call BIS_fnc_taskSetState;"
] call ROOT_fnc_addDatabase;

// Link to specific laptop
private _netId = netId _laptop;
["Classified_File", 20, "Top secret data", "", [_netId]] call ROOT_fnc_addDatabase;
```

---

## Complete Mission Example

### Scenario: Intel Gathering

```sqf
// init.sqf

// 1. Setup laptops
private _hqLaptop = laptop1; // Object name in editor
private _fieldLaptop = laptop2;

// 2. Add hacking tools
[_hqLaptop, "/hq/tools", 0, "HQ_Terminal"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
[_fieldLaptop, "/field/tools", 0, "Field_Laptop"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];

// 3. Make enemy base buildings hackable (doors)
private _buildings = [building1, building2, building3];
{
    [_x] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach _buildings;

// 4. Add GPS tracker to enemy commander
private _commander = enemyCommander;
[_commander, 0, [netId _fieldLaptop], "HVT_Commander", 120, 10, "", false, false, 60, 3, true] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];

// 5. Add enemy plans file (triggers task on download)
["Enemy_Plans", 15, "Patrol routes and supply schedules...",
    "['IntelGathered', true] call BIS_fnc_taskSetState; hint 'Intel acquired!';"
] call ROOT_fnc_addDatabase;

// 6. Add enemy drone for hacking
private _drone = enemyDrone;
[_drone] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// 7. Configure power costs (optional)
// See Configuration Reference
```

### Scenario: Sabotage Mission

```sqf
// Custom device that triggers explosion

private _generator = powerGenerator;

[_generator, 0, [], true, "Power Generator",
    // Activation code (overload)
    "
    private _gen = objectFromNetId (netId (_this select 0));
    'Bo_Mk82' createVehicle (getPos _gen);
    hint 'GENERATOR OVERLOADED!';
    deleteVehicle _gen;
    ",
    // Deactivation code (unused)
    "",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Access Control Patterns

### Pattern 1: Public Access

All current laptops can access:

```sqf
[_device] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

### Pattern 2: Role-Based Access

```sqf
// Intel team laptops
private _intelTeam = [laptop1, laptop2] apply { netId _x };

// Ops team laptops
private _opsTeam = [laptop3, laptop4] apply { netId _x };

// Intel-only device
[_secretFile, 0, _intelTeam] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Ops-only device
[_targetDrone, 0, _opsTeam] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Shared device
[_door, 0, _intelTeam + _opsTeam] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

### Pattern 3: Progressive Access

```sqf
// Initially: Only HQ has access
private _hqNetId = netId hqLaptop;
[_device, 0, [_hqNetId]] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Later: Grant access to field teams
// (requires re-implementing device with updated links or using public devices)
```

### Pattern 4: Future Laptop System

```sqf
// Device available only to laptops added after mission start
[_device, 0, [], false, "", "", "", true] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Now add laptops - they automatically have access
[_newLaptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
```

---

## Advanced Techniques

### Dynamic Device Registration

Register devices during mission based on events:

```sqf
// When player completes task, add new devices
if (_taskComplete) then {
    [_newBuilding] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
    hint "New building access granted!";
};
```

### Conditional Access

```sqf
// Grant access based on player rank
if (rank player >= "MAJOR") then {
    private _adminLaptop = laptop1;
    [_adminLaptop, "/admin", 0, "Command_Terminal", "/admin"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
};
```

### Timed Devices

```sqf
// Device available for limited time
[_door] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Remove after 10 minutes
[{
    // Remove device from arrays (custom cleanup code)
    hint "Access window expired!";
}, [], 600] call CBA_fnc_waitAndExecute;
```

---

## Performance Considerations

### Best Practices

1. **Batch Operations**: Register multiple devices in sequence, not in loops with delays
2. **Use remoteExec Properly**: Always target server (2) for device registration
3. **Limit GPS Trackers**: Too many active trackers can impact performance
4. **Clean Up**: Remove unused devices when no longer needed

### Optimizations

```sqf
// Good: Batch registration
{
    [_x] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
} forEach _buildings;

// Bad: Delayed loops
{
    [_x] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
    sleep 1; // Unnecessary delay
} forEach _buildings;
```

---

## Testing Your Mission

### Quick Test Script

```sqf
// Place in debug console
private _laptop = cursorObject;
[_laptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
hint "Tools added to laptop under cursor";
```

### Verification

```sqf
// Check if tools installed
_laptop getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]; // Should be true

// Check device count
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
hint format ["Doors: %1, Lights: %2, Drones: %3",
    count (_allDevices select 0),
    count (_allDevices select 1),
    count (_allDevices select 2)
];
```

---

## See Also

- [Zeus Guide](Zeus-Guide) - Module-based setup
- [Configuration Reference](Configuration) - CBA settings
- [API Reference](API-Reference) - Function documentation
- [Custom Device Tutorial](Custom-Device-Tutorial) - Advanced custom devices

---

**Need help?** Join discord or raise an issue in GitHub.
