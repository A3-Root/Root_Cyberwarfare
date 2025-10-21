# Architecture

Technical architecture and implementation details of Root's Cyber Warfare.

## Table of Contents

- [System Overview](#system-overview)
- [Data Storage Architecture](#data-storage-architecture)
- [Access Control System](#access-control-system)
- [Initialization Flow](#initialization-flow)
- [Power System](#power-system)
- [Function Patterns](#function-patterns)
- [Network Architecture](#network-architecture)

---

## System Overview

Root's Cyber Warfare uses a **client-server architecture** with the following components:

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        SERVER                                │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Global Device Storage (missionNamespace)               │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • Device Cache (HashMap) - 8 device types              │  │
│  │ • Link Cache (HashMap) - Computer → Device links       │  │
│  │ • Public Devices (Array) - Public access registry      │  │
│  │ • Legacy Array (backward compatibility)                │  │
│  └────────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Access Control System (3-tier priority)                │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ 1. Backdoor Access (admin bypass)                      │  │
│  │ 2. Public Device Access (future laptops)               │  │
│  │ 3. Private Link Access (specific computers)            │  │
│  └────────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Device Control Functions                               │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • Door lock/unlock                                     │  │
│  │ • Light on/off                                         │  │
│  │ • Drone faction change/disable                         │  │
│  │ • Vehicle manipulation                                 │  │
│  │ • GPS tracking                                         │  │
│  │ • Custom device activation                             │  │
│  │ • Power grid control                                   │  │
│  └────────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Power Management System                                │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • Power availability checks (Wh)                       │  │
│  │ • Battery consumption (kWh via AE3)                    │  │
│  │ • Configurable costs (CBA settings)                    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
                           ↕
        ┌──────────────────────────────────────┐
        │ Network Synchronization              │
        │ (missionNamespace with public flag)  │
        └──────────────────────────────────────┘
                           ↕
┌──────────────────────────────────────────────────────────────┐
│                        CLIENT                                │
├──────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐  │
│  │ AE3 ArmaOS Terminal Interface                          │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • Terminal commands (devices, door, light, etc.)       │  │
│  │ • User confirmation prompts                            │  │
│  │ • Output formatting (colors, tables)                   │  │
│  └────────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ ACE Interaction Menu                                   │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • GPS tracker attachment (self-interaction)            │  │
│  │ • GPS tracker search/disable (object interaction)      │  │
│  └────────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ GPS Marker Visualization                               │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • Active ping markers (updating position)              │  │
│  │ • Last ping markers (final position)                   │  │
│  │ • Side/group/player visibility control                 │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Data Storage Architecture

Root's Cyber Warfare uses a **3-tier hybrid system** for data storage, optimized for O(1) lookups and network efficiency.

### Tier 1: Device Cache (HashMap)

**Primary storage for all registered devices, organized by type.**

**Variable:** `ROOT_CYBERWARFARE_DEVICE_CACHE`

**Structure:**
```sqf
createHashMap with 8 keys:
├─ "doors"       → Array of door device entries
├─ "lights"      → Array of light device entries
├─ "drones"      → Array of drone device entries
├─ "databases"   → Array of database/file entries
├─ "custom"      → Array of custom device entries
├─ "gpsTrackers" → Array of GPS tracker entries
├─ "vehicles"    → Array of vehicle entries
└─ "powerGrids"  → Array of power generator entries
```

**Access Pattern:**
```sqf
private _deviceCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", createHashMap];
private _doors = _deviceCache getOrDefault ["doors", []];

// Find specific device by ID
private _device = _doors select {(_x select 0) == _deviceId};
```

**Performance:** O(1) for type lookup, O(n) for device search within type (acceptable given small n per type).

**Initialization:**
```sqf
// PostInit (server)
private _deviceCache = createHashMap;
_deviceCache set ["doors", []];
_deviceCache set ["lights", []];
_deviceCache set ["drones", []];
_deviceCache set ["databases", []];
_deviceCache set ["custom", []];
_deviceCache set ["gpsTrackers", []];
_deviceCache set ["vehicles", []];
_deviceCache set ["powerGrids", []];
missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", _deviceCache, true];
```

---

### Tier 2: Link Cache (HashMap)

**Computer-to-device access mapping for private links.**

**Variable:** `ROOT_CYBERWARFARE_LINK_CACHE`

**Structure:**
```sqf
createHashMap with computer netIds as keys:
├─ "76561198123456789" → [[1, 1234], [2, 5678], [7, 9012]]
├─ "76561198987654321" → [[1, 1234], [3, 4567]]
└─ ...
```

**Entry Format:** `[[deviceType, deviceId], ...]`

**Access Pattern:**
```sqf
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _computerNetId = netId _computer;
private _links = _linkCache getOrDefault [_computerNetId, []];

// Check if computer has access to specific device
private _hasAccess = [_deviceType, _deviceId] in _links;
```

**Performance:** O(1) for computer lookup, O(n) for device check (acceptable given small n of devices per computer).

**Adding Links:**
```sqf
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
_existingLinks pushBack [_deviceType, _deviceId];
_linkCache set [_computerNetId, _existingLinks];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
```

---

### Tier 3: Public Devices (Array)

**Registry of devices accessible to all or future laptops.**

**Variable:** `ROOT_CYBERWARFARE_PUBLIC_DEVICES`

**Structure:**
```sqf
[
    [deviceType, deviceId, [excludedComputerNetIds]],
    [deviceType, deviceId, [excludedComputerNetIds]],
    ...
]
```

**Example:**
```sqf
[
    [1, 1234, ["76561198123456789"]],  // Door 1234, all except one computer
    [7, 5678, []],                      // Vehicle 5678, all computers
    [6, 9012, ["netId1", "netId2"]]     // GPS tracker 9012, all except two
]
```

**Access Pattern:**
```sqf
private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];
private _computerNetId = netId _computer;

// Check if device is public and computer not excluded
private _isPublic = _publicDevices findIf {
    _x params ["_type", "_id", "_excludedNetIds"];
    _type == _deviceType && _id == _deviceId && !(_computerNetId in _excludedNetIds)
} != -1;
```

**Performance:** O(n) linear search (acceptable given relatively small number of public devices).

**"Available to Future Laptops" Implementation:**
```sqf
// When registering device with availableToFutureLaptops = true:
// 1. Get all current computers
private _allCurrentComputers = allMissionObjects "Land_Laptop_03_base_F_AE3";
private _excludedNetIds = _allCurrentComputers apply {netId _x};

// 2. Add to public devices with exclusion list
private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];
_publicDevices pushBack [_deviceType, _deviceId, _excludedNetIds];
missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];

// Result: Current computers excluded, future computers included
```

---

### Legacy Array (Backward Compatibility)

**Variable:** `ROOT_CYBERWARFARE_ALL_DEVICES`

**Structure:**
```sqf
[
    doors[],       // Index 0
    lights[],      // Index 1
    drones[],      // Index 2
    databases[],   // Index 3
    custom[],      // Index 4
    gpsTrackers[], // Index 5
    vehicles[],    // Index 6
    powerGrids[]   // Index 7
]
```

**Note:** Maintained for backward compatibility. New code should use the HashMap-based device cache instead.

---

## Access Control System

**3-Tier Priority System** (checked in order, first match wins)

### Priority 1: Backdoor Access (Highest)

**Purpose:** Admin/debug bypass of all permission checks.

**Implementation:**
```sqf
private _backdoorPath = _computer getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", ""];
if (_backdoorPath != "") exitWith {true}; // Access granted
```

**Set During Tool Installation:**
```sqf
[_laptop, "/tools", 0, "Laptop", "backdoor_"] call Root_fnc_addHackingToolsZeusMain;
// Sets ROOT_CYBERWARFARE_BACKDOOR_FUNCTION = "backdoor_"
```

**Security:** Intended only for testing/debugging. Should not be used in production missions.

---

### Priority 2: Public Device Access

**Purpose:** Devices accessible to all or future laptops.

**Implementation:**
```sqf
private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];
private _computerNetId = netId _computer;

private _isPublic = _publicDevices findIf {
    _x params ["_type", "_id", "_excludedNetIds"];
    _type == _deviceType && _id == _deviceId && !(_computerNetId in _excludedNetIds)
} != -1;

if (_isPublic) exitWith {true}; // Access granted
```

**Exclusion Logic:**
- Empty exclusion list `[]` → All computers have access
- Non-empty exclusion list → All computers except those in the list

---

### Priority 3: Private Link Access (Lowest)

**Purpose:** Direct computer-to-device relationships.

**Implementation:**
```sqf
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _computerNetId = netId _computer;
private _links = _linkCache getOrDefault [_computerNetId, []];

private _hasLink = [_deviceType, _deviceId] in _links;
if (_hasLink) exitWith {true}; // Access granted

false // Access denied
```

---

### Access Check Flow Diagram

```
Device Access Request
         ↓
┌────────────────────┐
│ Backdoor Enabled?  │ → YES → GRANTED
└────────┬───────────┘
         NO
         ↓
┌────────────────────┐
│ Public Device?     │ → YES → Computer Excluded? → NO → GRANTED
└────────┬───────────┘                    ↓
         NO                              YES
         ↓                                ↓
┌────────────────────┐                  DENIED
│ Private Link?      │ → YES → GRANTED
└────────┬───────────┘
         NO
         ↓
      DENIED
```

---

## Initialization Flow

### PreInit Phase (CBA Macro Compilation)

**File:** `XEH_preInit.sqf`

**Execution:** Before mission start, unscheduled context

**Tasks:**
1. **Precompile all functions** using CBA's PREP macro (47 functions)
```sqf
#include "XEH_PREP.hpp"
// Expands to:
// PREP(functionName1);
// PREP(functionName2);
// ... (47 functions)
```

2. **Initialize CBA settings**
```sqf
call FUNC(initSettings); // Registers 10 CBA settings
```

3. **Set addon loaded flag**
```sqf
ADDON = true;
```

**Result:** All functions available as `Root_fnc_functionName` with O(1) access.

---

### PostInit Phase (Server)

**File:** `XEH_postInit.sqf`

**Execution:** After mission start, server only

**Tasks:**

1. **Initialize Device Cache (HashMap)**
```sqf
if (isServer) then {
    private _deviceCache = createHashMap;
    _deviceCache set ["doors", []];
    _deviceCache set ["lights", []];
    _deviceCache set ["drones", []];
    _deviceCache set ["databases", []];
    _deviceCache set ["custom", []];
    _deviceCache set ["gpsTrackers", []];
    _deviceCache set ["vehicles", []];
    _deviceCache set ["powerGrids", []];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", _deviceCache, true];
};
```

2. **Initialize Link Cache (HashMap)**
```sqf
if (isServer) then {
    private _linkCache = createHashMap;
    missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
};
```

3. **Initialize Public Devices (Array)**
```sqf
if (isServer) then {
    private _publicDevices = [];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};
```

4. **Register CBA Event Handlers** (for power, device state changes, GPS updates)

5. **Start Background Cleanup Task**
```sqf
if (isServer) then {
    [] spawn {
        while {true} do {
            sleep 300; // Every 5 minutes
            call FUNC(cleanupDeviceLinks); // Remove destroyed objects
        };
    };
};
```

---

### PostInit Phase (Client)

**Execution:** After mission start, all clients

**Tasks:**

1. **Register ACE Interaction Actions** for GPS tracker operations
```sqf
if (hasInterface) then {
    // Register self-interaction for GPS tracker attachment
    // Register object-interaction for GPS tracker search/disable
};
```

---

## Power System

### Power Units

**Two unit systems:**
- **Watt-hours (Wh)** - Used for operation costs
- **Kilowatt-hours (kWh)** - Used by AE3 for battery storage

**Conversion:**
```sqf
#define WH_TO_KWH(wh) (wh / 1000)
#define KWH_TO_WH(kwh) (kwh * 1000)

// Example:
private _powerCostWh = 10;  // 10 Watt-hours
private _powerCostKwh = WH_TO_KWH(_powerCostWh); // 0.01 Kilowatt-hours
```

---

### Power Check Flow

```
Operation Requested
         ↓
┌────────────────────────────────┐
│ Get Power Cost (Wh)            │
│ - From CBA settings            │
│ - Or per-device configuration  │
└────────┬───────────────────────┘
         ↓
┌────────────────────────────────┐
│ Check Power Available          │
│ Root_fnc_checkPowerAvailable   │
└────────┬───────────────────────┘
         ↓
    Sufficient? ──NO──→ Error: Insufficient Power
         │
        YES
         ↓
┌────────────────────────────────┐
│ Show Confirmation Prompt       │
│ (if required)                  │
└────────┬───────────────────────┘
         ↓
    Confirmed? ──NO──→ Operation Cancelled
         │
        YES
         ↓
┌────────────────────────────────┐
│ Consume Power                  │
│ Root_fnc_consumePower          │
└────────┬───────────────────────┘
         ↓
┌────────────────────────────────┐
│ Execute Operation              │
└────────────────────────────────┘
```

---

### Power Check Implementation

```sqf
// fn_checkPowerAvailable.sqf
params [
    ["_computer", objNull, [objNull]],
    ["_powerRequiredWh", 0, [0]]
];

if (isNull _computer) exitWith {false};
if (_powerRequiredWh <= 0) exitWith {true};

// Get laptop's internal battery (AE3 object)
private _battery = _computer getVariable ["AE3_power_internal", objNull];
if (isNull _battery) exitWith {false};

// Get battery level in kWh
private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];

// Convert required power to kWh and check
private _powerRequiredKwh = WH_TO_KWH(_powerRequiredWh);
(_batteryLevel >= _powerRequiredKwh)
```

---

### Power Consumption Implementation

```sqf
// fn_consumePower.sqf
params [
    ["_computer", objNull, [objNull]],
    ["_powerWh", 0, [0]]
];

if (isNull _computer) exitWith {};
if (_powerWh <= 0) exitWith {};

private _battery = _computer getVariable ["AE3_power_internal", objNull];
if (isNull _battery) exitWith {};

private _currentLevel = _battery getVariable ["AE3_power_batteryLevel", 0];
private _powerKwh = WH_TO_KWH(_powerWh);
private _newLevel = (_currentLevel - _powerKwh) max 0;

_battery setVariable ["AE3_power_batteryLevel", _newLevel, true];
```

---

### Default Power Costs

| Operation | Default (Wh) | CBA Setting |
|-----------|--------------|-------------|
| Door lock/unlock | 2 | ROOT_CYBERWARFARE_DOOR_COST |
| Drone disable | 10 | ROOT_CYBERWARFARE_DRONE_HACK_COST |
| Drone faction change | 20 | ROOT_CYBERWARFARE_DRONE_SIDE_COST |
| Custom device | 10 | ROOT_CYBERWARFARE_CUSTOM_COST |
| Power grid control | 15 | ROOT_CYBERWARFARE_POWERGRID_COST |
| Vehicle action | 2 | Per-vehicle configuration |
| GPS tracking | 2-10 | Per-tracker configuration |

---

## Function Patterns

### Two-Function Pattern (Zeus Modules)

Zeus modules use a UI + implementation pattern:

**UI Function:** `fn_moduleNameZeus.sqf`
- Opens dialog/prompts
- Collects parameters from Zeus
- Calls main function

**Implementation Function:** `fn_moduleNameZeusMain.sqf`
- Contains actual logic
- Can be called directly from scripts
- Server-side execution

**Example:**
```sqf
// fn_addDeviceZeus.sqf (UI)
params [["_mode", ""], ["_input", []]];
// ... Zeus dialog code ...
[_object, _execUserId, _linkedComputers, ...] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// fn_addDeviceZeusMain.sqf (Implementation)
params ["_object", "_execUserId", "_linkedComputers", ...];
// ... actual device registration logic ...
```

**Benefits:**
- UI code separated from logic
- Logic reusable from scripts
- Easier testing and maintenance

---

### Parameter Handling Pattern

All functions use strict type-checked parameters:

```sqf
params [
    ["_parameter1", defaultValue, [expectedType]],
    ["_parameter2", defaultValue, [expectedType1, expectedType2]], // Multiple types allowed
    ["_parameter3", defaultValue, [expectedType], [expectedCondition]]
];
```

**Example:**
```sqf
params [
    ["_computer", objNull, [objNull]],
    ["_powerCost", 0, [0]],
    ["_deviceName", "", [""]],
    ["_allowFuel", false, [true]]
];
```

---

### Error Handling Pattern

Functions use `scopeName` and `exitWith` for clean error handling:

```sqf
scopeName "exit";

// Early validation
if (!VALIDATE_COMPUTER(_computer)) exitWith {
    [_computer, format ["<t color='%1'>%2</t>", COLOR_ERROR, localize "STR_ROOT_CYBERWARFARE_ERR_INVALID_COMPUTER"]]
        call AE3_armaos_fnc_shell_stdout;
    false
};

// Power check
if (!([_computer, _powerCost] call FUNC(checkPowerAvailable))) exitWith {
    [_computer, format ["<t color='%1'>%2</t>", COLOR_ERROR, localize "STR_ROOT_CYBERWARFARE_ERR_INSUFFICIENT_POWER"]]
        call AE3_armaos_fnc_shell_stdout;
    false
};

// Main logic
// ...

true // Success
```

---

### Confirmation Prompt Pattern

Destructive or bulk operations require user confirmation:

```sqf
// Calculate total cost
private _totalCost = _affectedCount * _singleCost;

// Show confirmation prompt
private _promptMessage = format [
    "This will affect %1 device(s) and consume %2 Wh. Continue? (Y/N) [10s timeout]",
    _affectedCount,
    _totalCost
];

[_computer, _promptMessage, 10, "confirmVar"] call Root_fnc_getUserConfirmation;

// Wait for confirmation
waitUntil {_computer getVariable ["confirmVar", false] || time > _timeoutTime};

private _confirmed = _computer getVariable ["confirmVar", false];
if (!_confirmed) exitWith {
    [_computer, "Operation cancelled."] call AE3_armaos_fnc_shell_stdout;
};

// Proceed with operation
```

---

## Network Architecture

### Data Synchronization

All global device storage uses `missionNamespace` with public synchronization:

```sqf
missionNamespace setVariable ["VARIABLE_NAME", _value, true];
// 3rd parameter = true → Synced to all clients
```

**Synchronized Variables:**
- `ROOT_CYBERWARFARE_DEVICE_CACHE` (HashMap)
- `ROOT_CYBERWARFARE_LINK_CACHE` (HashMap)
- `ROOT_CYBERWARFARE_PUBLIC_DEVICES` (Array)
- `ROOT_CYBERWARFARE_ALL_DEVICES` (Array, legacy)

---

### Object Variables

Device metadata stored on objects with public sync:

```sqf
_object setVariable ["KEY", _value, true];
// Examples:
_building setVariable ["ROOT_CYBERWARFARE_DEVICE_ID", 1234, true];
_tracker setVariable ["ROOT_CYBERWARFARE_GPS_STATUS", "Tracking", true];
```

---

### CBA Events

Used for one-off network messages instead of `remoteExec`:

```sqf
// Raise event on server
["ROOT_CYBERWARFARE_GPS_UPDATE", [_trackerId, _position]] call CBA_fnc_serverEvent;

// Handle event on clients
["ROOT_CYBERWARFARE_GPS_UPDATE", {
    params ["_trackerId", "_position"];
    // Update marker position
}] call CBA_fnc_addEventHandler;
```

**Benefits:**
- More efficient than `remoteExec` for frequent updates
- Built-in event system
- Better performance with many clients

---

## Performance Considerations

### Device ID Generation

Random 4-digit IDs (1000-9999) with collision detection:

```sqf
private _deviceId = (round (random 8999)) + 1000;
if (_existingDevices isNotEqualTo []) then {
    while {true} do {
        _deviceId = (round (random 8999)) + 1000;
        private _isNew = true;
        {
            if (_x select 0 == _deviceId) then {
                _isNew = false;
            };
        } forEach _existingDevices;
        if (_isNew) exitWith {};
    };
};
```

**Collision Probability:** ~1% with 100 devices, acceptable for typical missions.

---

### Background Cleanup Task

Removes destroyed objects from caches:

```sqf
// Runs every 5 minutes on server
[] spawn {
    while {true} do {
        sleep 300;
        call ROOT_fnc_cleanupDeviceLinks;
    };
};
```

**Cleanup Logic:**
- Check if netId objects still exist
- Remove entries for destroyed objects
- Update caches and sync

---

### HashMap Performance

**Benefits:**
- O(1) average case for key lookup
- Better memory locality than nested arrays
- Native Arma 3 implementation (optimized)

**When to Use:**
- Key-value mappings (computer netId → links)
- Type-based organization (device type → device list)
- Large datasets (>100 entries)

---

### Network Bandwidth Optimization

**Minimize Syncs:**
- Batch updates when possible
- Only sync changed data
- Use local variables for intermediate calculations

**Example:**
```sqf
// Bad: Multiple syncs
{
    missionNamespace setVariable [format ["device_%1", _x], _data, true];
} forEach _devices; // N syncs

// Good: Single sync
private _deviceCache = createHashMap;
{
    _deviceCache set [format ["device_%1", _x], _data];
} forEach _devices;
missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", _deviceCache, true]; // 1 sync
```

---

**For function reference, see [API Reference](API-Reference). For usage examples, see [Mission Maker Guide](Mission-Maker-Guide).**
