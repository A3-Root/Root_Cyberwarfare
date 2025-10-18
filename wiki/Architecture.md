# Architecture

This document provides a comprehensive overview of Root's Cyber Warfare mod architecture, including system design, data structures, execution flow, and integration patterns.

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Data Storage Architecture](#data-storage-architecture)
- [Access Control System](#access-control-system)
- [Initialization Flow](#initialization-flow)
- [Function Architecture](#function-architecture)
- [Network Architecture](#network-architecture)
- [Power System](#power-system)
- [Integration Points](#integration-points)
- [Performance Considerations](#performance-considerations)

## Overview

Root's Cyber Warfare is built as a **single-addon Arma 3 modification** that integrates with CBA, ACE3, AE3 ArmaOS, and ZEN to provide cyber warfare capabilities. The architecture prioritizes:

- **Performance**: O(1) device lookups using HashMap structures
- **Network Efficiency**: CBA events for client-server communication
- **Modularity**: Device types are extensible without core changes
- **Reliability**: Automatic cleanup of orphaned device references

### Core Design Principles

1. **Single Source of Truth**: All device state is authoritative on the server
2. **Type Safety**: Strict parameter validation via SQF `params` with type checks
3. **Fail-Fast**: Early validation with `exitWith` to minimize wasted computation
4. **Declarative Configuration**: CBA settings for mission-specific customization
5. **Separation of Concerns**: UI (Zeus/Eden) separated from business logic (Main functions)

## System Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Root's Cyber Warfare Mod                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────┐   ┌─────────────────┐   ┌────────────────┐  │
│  │  UI Layer      │   │  Business Logic │   │  Data Layer    │  │
│  ├────────────────┤   ├─────────────────┤   ├────────────────┤  │
│  │ Zeus Modules   │──>│ Device Control  │──>│ Device Cache   │  │
│  │ Eden Modules   │   │ GPS Tracking    │   │ Link Cache     │  │
│  │ ACE Actions    │   │ Power Mgmt      │   │ Public Devices │  │
│  └────────────────┘   │ Access Control  │   └────────────────┘  │
│                       └─────────────────┘                       │
│                                                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Network Communication Layer                   │ │
│  │  (CBA Events for Client-Server Communication)              │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
     ┌────────┐           ┌────────┐         ┌────────────┐
     │  CBA   │           │  ACE3  │         │    AE3     │
     │ (Core) │           │ (Menu) │         │ (Terminal) │
     └────────┘           └────────┘         └────────────┘
```

### File Structure

```
addons/main/
├── config.cpp                   # Addon configuration
├── CfgVehicles.hpp             # Zeus/Eden module definitions
├── stringtable.xml             # Localization strings
├── script_component.hpp        # Component identity
├── script_macros.hpp           # Constants and macros
├── XEH_preInit.sqf            # Function precompilation
├── XEH_postInit.sqf           # Server/client initialization
├── XEH_PREP.hpp               # Function registration
└── functions/
    ├── 3den/          # Eden Editor modules (7 functions)
    ├── core/          # Core system (4 functions)
    ├── devices/       # Device operations (7 functions)
    ├── database/      # File downloads (1 function)
    ├── gps/           # GPS tracking (8 functions)
    ├── utility/       # Helper functions (7 functions)
    └── zeus/          # Zeus modules (13 functions)
```

**Total**: 47 functions precompiled for O(1) access via CBA's PREP system.

## Data Storage Architecture

The mod uses a **hybrid 3-tier storage system** optimized for different access patterns:

### 1. Device Cache (HashMap) - PRIMARY STORAGE

**Purpose**: Fast device lookup by type with O(1) complexity

**Global Variable**: `ROOT_CYBERWARFARE_DEVICE_CACHE` (HashMap)

**Structure**:
```sqf
createHashMap with keys:
├── "doors"       → [[deviceId, buildingNetId, doorIds[], buildingName, availableToFuture], ...]
├── "lights"      → [[deviceId, lightNetId, lightName, availableToFuture], ...]
├── "drones"      → [[deviceId, droneNetId, droneName, availableToFuture], ...]
├── "databases"   → [[deviceId, objectNetId, fileName, fileSize, fileContent, databaseName, availableToFuture], ...]
├── "custom"      → [[deviceId, objectNetId, deviceName, activationCode, deactivationCode, availableToFuture], ...]
├── "gpsTrackers" → [[deviceId, targetNetId, trackerName, updateInterval, isActive, lastPingTime, lastPosition], ...]
├── "vehicles"    → [[deviceId, vehicleNetId, vehicleName, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, powerCost, availableToFuture], ...]
└── "powerGrids"  → [[deviceId, objectNetId, name, radius, allowExplActivate, allowExplDeactivate, explosionType, excludedClasses, availableToFuture], ...]
```

**Access Pattern**:
```sqf
// Get all doors
private _cache = GET_DEVICE_CACHE;
private _doors = _cache getOrDefault [CACHE_KEY_DOORS, []];

// Find specific door by ID
private _door = _doors findIf { (_x select 0) == _deviceId };
```

**Initialization**: Created in `XEH_postInit.sqf` (server-side only)

### 2. Link Cache (HashMap) - ACCESS CONTROL

**Purpose**: O(1) lookup of computer-specific device access (private links)

**Global Variable**: `ROOT_CYBERWARFARE_LINK_CACHE` (HashMap)

**Structure**:
```sqf
createHashMap with keys: computerNetId (string)
values: [[deviceType, deviceId], ...] (array of [int, int] pairs)
```

**Example**:
```sqf
// Computer with netId "1:23" has access to door 1234 and vehicle 5678
"1:23" → [[1, 1234], [7, 5678]]
```

**Access Pattern**:
```sqf
private _linkCache = GET_LINK_CACHE;
private _computerLinks = _linkCache getOrDefault [netId _computer, []];
private _hasAccess = [_deviceType, _deviceId] in _computerLinks;
```

**Initialization**: Created in `XEH_postInit.sqf`, can be pre-populated by 3DEN modules

### 3. Public Devices (Array) - GLOBAL ACCESS

**Purpose**: Devices available to all or future laptops with optional exclusions

**Global Variable**: `ROOT_CYBERWARFARE_PUBLIC_DEVICES` (Array)

**Structure**:
```sqf
[[deviceType, deviceId, [excludedComputerNetIds]], ...]
```

**Example**:
```sqf
[
    [1, 1234, ["1:23", "1:24"]],  // Door 1234 public except computers "1:23" and "1:24"
    [7, 5678, []]                 // Vehicle 5678 public to all computers
]
```

**Access Pattern**:
```sqf
private _publicDevices = GET_PUBLIC_DEVICES;
private _isPublic = _publicDevices findIf {
    _x params ["_type", "_id", "_excludedNetIds"];
    _type == _deviceType && _id == _deviceId && !(_computerNetId in _excludedNetIds)
} != -1;
```

**Initialization**: Created in `XEH_postInit.sqf`, can be pre-populated by 3DEN modules

### 4. Legacy Array (Backward Compatibility)

**Global Variable**: `ROOT_CYBERWARFARE_ALL_DEVICES` (Array)

**Structure**:
```sqf
[doors[], lights[], drones[], databases[], custom[], gpsTrackers[], vehicles[], powerGrids[]]
```

**Status**: **Deprecated** - maintained for backward compatibility with mission scripts. New code should use the HashMap-based device cache instead.

### Device Type Constants

Defined in `script_macros.hpp`:

| Constant | Value | Description |
|----------|-------|-------------|
| `DEVICE_TYPE_DOOR` | 1 | Building doors (lockable) |
| `DEVICE_TYPE_LIGHT` | 2 | Building lights (switchable) |
| `DEVICE_TYPE_DRONE` | 3 | UAVs (faction change, disable) |
| `DEVICE_TYPE_DATABASE` | 4 | Downloadable files |
| `DEVICE_TYPE_CUSTOM` | 5 | Custom scripted devices |
| `DEVICE_TYPE_GPS_TRACKER` | 6 | GPS tracking devices |
| `DEVICE_TYPE_VEHICLE` | 7 | Vehicles (engine, fuel, alarms) |
| `DEVICE_TYPE_POWERGRID` | 8 | Power generators (light control) |

## Access Control System

Device accessibility is determined by a **3-tier priority system** implemented in `fn_isDeviceAccessible.sqf`:

### Priority Order (Highest to Lowest)

```
1. Backdoor Access (Admin/Debug)
         ↓ (if no backdoor)
2. Public Device Access
         ↓ (if not public or excluded)
3. Private Link Access
         ↓ (if no link)
   ACCESS DENIED
```

### 1. Backdoor Access (Highest Priority)

**Purpose**: Admin/debug access bypassing all checks

**Implementation**:
```sqf
private _backdoorPath = _computer getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", ""];
if (_backdoorPath != "") exitWith { true };  // Full access
```

**Use Case**: Mission makers can grant specific laptops unrestricted access to all devices

**Configuration**:
```sqf
// Add backdoor access to a laptop
_laptop setVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", "/network/admin", true];
```

### 2. Public Device Access

**Purpose**: Devices accessible to all or future computers with optional exclusions

**Implementation**:
```sqf
private _publicDevices = GET_PUBLIC_DEVICES;
private _computerNetId = netId _computer;

private _isPublic = _publicDevices findIf {
    _x params ["_type", "_id", "_excludedNetIds"];
    _type == _deviceType && _id == _deviceId && !(_computerNetId in _excludedNetIds)
} != -1;

if (_isPublic) exitWith { true };
```

**Use Case**: "Available to Future Laptops" checkbox in Zeus modules

**Behavior**:
- Devices added with `availableToFuture = true` are placed in public devices array
- **Exclusion List**: All computers that existed at registration time are excluded
- New computers added after registration automatically get access (not in exclusion list)

**Example**:
```sqf
// Register vehicle available to future laptops
[_vehicle, 0, [], "Car1", true, false, false, false, true, false, true, 2]
    call Root_fnc_addVehicleZeusMain;
// All computers added AFTER this call will have access
// Computers that existed at this moment are in exclusion list
```

### 3. Private Link Access (Lowest Priority)

**Purpose**: Direct computer-to-device relationships

**Implementation**:
```sqf
private _linkCache = GET_LINK_CACHE;
private _links = _linkCache getOrDefault [netId _computer, []];
private _hasLink = [_deviceType, _deviceId] in _links;

if (_hasLink) exitWith { true };
```

**Use Case**: Explicit device linking via Zeus "Link to Computer" checkboxes

**Configuration**:
```sqf
// Link door 1234 to a specific computer
private _linkCache = GET_LINK_CACHE;
private _existingLinks = _linkCache getOrDefault [netId _computer, []];
_existingLinks pushBack [DEVICE_TYPE_DOOR, 1234];
_linkCache set [netId _computer, _existingLinks];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
```

### Access Control Flow Diagram

```
┌─────────────────────────────────────────┐
│ Player executes device control command  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  fn_isDeviceAccessible(_computer,       │
│                        _deviceType,     │
│                        _deviceId)       │
└──────────────┬──────────────────────────┘
               │
               ▼
       ┌───────────────┐
       │ Has backdoor? │──YES──> ALLOW ACCESS
       └───────┬───────┘
               │ NO
               ▼
       ┌───────────────┐
       │ Is public &   │──YES──> ALLOW ACCESS
       │ not excluded? │
       └───────┬───────┘
               │ NO
               ▼
       ┌───────────────┐
       │  Has private  │──YES──> ALLOW ACCESS
       │     link?     │
       └───────┬───────┘
               │ NO
               ▼
         DENY ACCESS
```

## Initialization Flow

### Phase 1: PreInit (`XEH_preInit.sqf`)

**Context**: Unscheduled, runs before mission objects spawn

**Responsibilities**:
1. Precompile all 47 functions using CBA's PREP macro
2. Initialize CBA settings (power costs, GPS config, etc.)
3. Set `ADDON = true` flag

**Key Operations**:
```sqf
// 1. Precompile functions
#include "XEH_PREP.hpp"  // Loads all functions into mission namespace

// 2. Initialize settings
call FUNC(initSettings);  // Registers CBA settings

// 3. Mark ready
ADDON = true;
```

**Execution Order**: `PreInit → PostInit → Mission Objects → Mission Start`

### Phase 2: PostInit (`XEH_postInit.sqf`)

**Context**: Scheduled, runs after mission objects created but before mission starts

#### Server-Side Initialization

```sqf
if (isServer) then {
    // 1. Register CBA event handlers
    ["root_cyberwarfare_consumePower", {...}] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_deviceStateChanged", {...}] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gpsTrackingUpdate", {...}] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_deviceLinked", {...}] call CBA_fnc_addEventHandler;

    // 2. Initialize device cache HashMap (8 keys)
    private _deviceCache = createHashMap;
    _deviceCache set [CACHE_KEY_DOORS, []];
    _deviceCache set [CACHE_KEY_LIGHTS, []];
    _deviceCache set [CACHE_KEY_DRONES, []];
    _deviceCache set [CACHE_KEY_DATABASES, []];
    _deviceCache set [CACHE_KEY_CUSTOM, []];
    _deviceCache set [CACHE_KEY_GPS_TRACKERS, []];
    _deviceCache set [CACHE_KEY_VEHICLES, []];
    _deviceCache set [CACHE_KEY_POWERGRIDS, []];
    missionNamespace setVariable [GVAR_DEVICE_CACHE, _deviceCache, true];

    // 3. Initialize link cache (only if not pre-populated by 3DEN)
    if (isNil GVAR_LINK_CACHE) then {
        missionNamespace setVariable [GVAR_LINK_CACHE, createHashMap, true];
    };

    // 4. Initialize public devices array (only if not pre-populated)
    if (isNil GVAR_PUBLIC_DEVICES) then {
        missionNamespace setVariable [GVAR_PUBLIC_DEVICES, [], true];
    };

    // 5. Initialize legacy array (backward compatibility)
    if (isNil "ROOT_CYBERWARFARE_ALL_DEVICES") then {
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES",
            [[], [], [], [], [], [], [], []], true];
    };

    // 6. Start cleanup task
    call FUNC(cleanupDeviceLinks);
};
```

#### Client-Side Initialization

```sqf
if (hasInterface) then {
    // Wait for player and mission time
    [{(!isNull ACE_player) && (CBA_missionTime > 0)}, {
        // 1. Create diary entry
        call FUNC(createDiaryEntry);

        // 2. Register ACE interaction: Attach GPS Tracker
        private _actionAttach = [...] call ace_interact_menu_fnc_createAction;
        ["All", 0, ["ACE_MainActions"], _actionAttach, true]
            call ace_interact_menu_fnc_addActionToClass;

        // 3. Register ACE interaction: Search for GPS Tracker
        private _actionSearch = [...] call ace_interact_menu_fnc_createAction;
        ["All", 0, ["ACE_MainActions"], _actionSearch, true]
            call ace_interact_menu_fnc_addActionToClass;
    }] call CBA_fnc_waitUntilAndExecute;
};
```

### Initialization Timeline

```
Mission Load
     │
     ├─> PreInit (Unscheduled)
     │   ├─> Precompile 47 functions
     │   ├─> Register CBA settings
     │   └─> Set ADDON = true
     │
     ├─> 3DEN Modules Execute (if in editor)
     │   └─> Pre-populate link cache & public devices
     │
     ├─> Mission Objects Spawn
     │
     ├─> PostInit (Scheduled)
     │   ├─> Server: Initialize device cache (8 device types)
     │   ├─> Server: Initialize link cache (if not pre-populated)
     │   ├─> Server: Register CBA event handlers
     │   ├─> Server: Start cleanup task
     │   └─> Client: Register ACE interactions (GPS tracker)
     │
     └─> Mission Start
```

## Function Architecture

### Naming Conventions

Root's Cyber Warfare follows a **two-function pattern** for Zeus modules:

1. **`fn_functionZeus.sqf`** - UI/dialog handling, parameter collection
2. **`fn_functionZeusMain.sqf`** - Implementation logic (can be called directly)

**Example**:
```sqf
// Zeus UI function (dialog handling)
fn_addVehicleZeus.sqf

// Main implementation (callable from mission scripts)
fn_addVehicleZeusMain.sqf
```

**Benefit**: Mission makers can bypass Zeus UI and call Main functions directly:
```sqf
// Called programmatically in mission init
[_vehicle, 0, [], "Car1", true, false, false, false, true, false, false, 2]
    call Root_fnc_addVehicleZeusMain;
```

### Function Categories

#### 1. Zeus Functions (`functions/zeus/`)

**Purpose**: Zeus module UI and device registration

**Pattern**: Paired functions (Zeus + ZeusMain)

**Examples**:
- `fn_addDeviceZeus.sqf` + `fn_addDeviceZeusMain.sqf` (doors/lights)
- `fn_addVehicleZeus.sqf` + `fn_addVehicleZeusMain.sqf` (vehicles/drones)
- `fn_addGPSTrackerZeus.sqf` + `fn_addGPSTrackerZeusMain.sqf` (GPS trackers)

**Execution**: Zeus functions run in **scheduled** context

#### 2. 3DEN Functions (`functions/3den/`)

**Purpose**: Eden Editor module implementation for pre-mission setup

**Pattern**: Single function per module (no UI, config-driven)

**Examples**:
- `fn_3denAddHackingTools.sqf` - Pre-install hacking tools
- `fn_3denAddDevices.sqf` - Pre-register doors/lights
- `fn_3denAddVehicle.sqf` - Pre-register vehicles

**Execution**: Runs during mission load, before PostInit

#### 3. Device Functions (`functions/devices/`)

**Purpose**: Device control implementation (called from terminal commands)

**Examples**:
- `fn_changeDoorState.sqf` - Lock/unlock doors
- `fn_changeLightState.sqf` - Toggle lights
- `fn_changeVehicleParams.sqf` - Manipulate vehicle systems
- `fn_customDevice.sqf` - Execute custom device code

**Execution**: Unscheduled (called via `call`)

#### 4. Utility Functions (`functions/utility/`)

**Purpose**: Helper functions for common operations

**Examples**:
- `fn_isDeviceAccessible.sqf` - Check access (3-tier system)
- `fn_checkPowerAvailable.sqf` - Validate battery level
- `fn_consumePower.sqf` - Deduct power from battery
- `fn_getAccessibleDevices.sqf` - Filter devices by access

**Execution**: Unscheduled (pure functions)

#### 5. GPS Functions (`functions/gps/`)

**Purpose**: GPS tracker attachment, searching, and positioning

**Examples**:
- `fn_aceAttachGPSTracker.sqf` - ACE interaction handler
- `fn_gpsTrackerServer.sqf` - Server-side tracking loop
- `fn_gpsTrackerClient.sqf` - Client-side marker management
- `fn_searchForGPSTracker.sqf` - Search for hidden trackers

**Execution**: Mixed (ACE actions scheduled, server loops spawned)

#### 6. Core Functions (`functions/core/`)

**Purpose**: Core system functionality

**Examples**:
- `fn_initSettings.sqf` - CBA settings registration
- `fn_cleanupDeviceLinks.sqf` - Cleanup destroyed objects
- `fn_createDiaryEntry.sqf` - Add briefing entry

**Execution**: Mixed (init unscheduled, cleanup spawned)

### Parameter Handling Pattern

All functions use **strict type-checked parameters** via SQF `params`:

```sqf
params [
    ["_parameter1", defaultValue, [expectedType]],
    ["_parameter2", defaultValue, [expectedType, alternateType]]
];
```

**Example from `fn_changeDoorState.sqf`**:
```sqf
params [
    ["_computer", objNull, [objNull]],
    ["_deviceId", -1, [0]],
    ["_doorIds", [], [[]]],
    ["_action", "", [""]]
];

// Early validation
if (isNull _computer) exitWith { LOG_ERROR("Computer is null"); };
if (_deviceId < 0) exitWith { LOG_ERROR("Invalid device ID"); };
if !(_action in ["lock", "unlock"]) exitWith { LOG_ERROR("Invalid action"); };
```

### Error Handling Pattern

Functions use `scopeName` and `exitWith` for early returns:

```sqf
scopeName "exit";

// Validation 1
if (!VALIDATE_COMPUTER(_computer)) exitWith {
    [_computer, format ["<t color='%1'>%2</t>", COLOR_ERROR,
        localize "STR_ROOT_CYBERWARFARE_ERR_INVALID_COMPUTER"]]
        call AE3_armaos_fnc_shell_stdout;
};

// Validation 2
if (!([_computer, _powerCost] call FUNC(checkPowerAvailable))) exitWith {
    [_computer, format ["<t color='%1'>%2</t>", COLOR_ERROR,
        localize "STR_ROOT_CYBERWARFARE_ERR_INSUFFICIENT_POWER"]]
        call AE3_armaos_fnc_shell_stdout;
};

// Main logic here
```

## Network Architecture

### Communication Strategy

Root's Cyber Warfare uses **CBA events** instead of `remoteExec` for client-server communication:

**Benefits**:
- Better bandwidth management
- Type-safe parameter passing
- Event queuing and reliability
- Easier debugging

### Registered Events

Defined in `XEH_postInit.sqf` (server-side):

#### 1. Power Consumption Event

```sqf
["root_cyberwarfare_consumePower", {
    params ["_computer", "_battery", "_newLevel", "_powerWh"];
    [_computer, _battery, _newLevel] call FUNC(removePower);
}] call CBA_fnc_addEventHandler;
```

**Triggered**: When a hacking operation consumes battery power
**Direction**: Client → Server
**Parameters**: Computer object, battery item, new power level (kWh), power consumed (Wh)

#### 2. Device State Change Event

```sqf
["root_cyberwarfare_deviceStateChanged", {
    params ["_deviceType", "_deviceId", "_newState"];
    LOG_DEBUG_3("Device state changed - Type: %1, ID: %2, State: %3", ...);
}] call CBA_fnc_addEventHandler;
```

**Triggered**: When a device changes state (door locked, light toggled, etc.)
**Direction**: Server → Clients (broadcast)
**Parameters**: Device type constant, device ID, new state description

#### 3. GPS Tracking Update Event

```sqf
["root_cyberwarfare_gpsTrackingUpdate", {
    params ["_trackerId", "_status"];
    LOG_DEBUG_2("GPS tracking update - ID: %1, Status: %2", ...);
}] call CBA_fnc_addEventHandler;
```

**Triggered**: When a GPS tracker updates its position
**Direction**: Server → Clients (broadcast)
**Parameters**: Tracker device ID, status string

#### 4. Device Linked Event

```sqf
["root_cyberwarfare_deviceLinked", {
    params ["_computerNetId", "_deviceType", "_deviceId"];
    LOG_DEBUG_3("Device linked - Computer: %1, Type: %2, ID: %3", ...);
}] call CBA_fnc_addEventHandler;
```

**Triggered**: When a computer is granted access to a device
**Direction**: Server → Clients (broadcast)
**Parameters**: Computer netId, device type, device ID

### Network Synchronization

**Global Variables** are synchronized using `publicVariable`:

```sqf
// Set variable with public sync (3rd param = true)
missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", _deviceCache, true];

// Explicit broadcast
publicVariable "ROOT_CYBERWARFARE_ALL_DEVICES";
```

**Object Variables** for device metadata:

```sqf
// Store metadata on object with public sync
_object setVariable ["ROOT_CYBERWARFARE_DEVICE_ID", _deviceId, true];
_building setVariable ["ROOT_CYBERWARFARE_DOOR_IDS", _doorIds, true];
```

### Network Data Flow

```
┌────────────┐                          ┌────────────┐
│   Client   │                          │   Server   │
└─────┬──────┘                          └──────┬─────┘
      │                                        │
      │  1. Player executes terminal command   │
      ├───────────────────────────────────────>│
      │     (via AE3 ArmaOS terminal)          │
      │                                        │
      │  2. Validate access & power            │
      │                                   ┌────▼────┐
      │                                   │ Check:  │
      │                                   │ - Access│
      │                                   │ - Power │
      │                                   └────┬────┘
      │                                        │
      │  3. CBA Event: consumePower            │
      │<───────────────────────────────────────┤
      │                                        │
      │  4. Update device state (server)       │
      │                                   ┌────▼────┐
      │                                   │ Update: │
      │                                   │ - Cache │
      │                                   │ - Object│
      │                                   └────┬────┘
      │                                        │
      │  5. CBA Event: deviceStateChanged      │
      │<───────────────────────────────────────┤
      │   (broadcasted to all clients)         │
      │                                        │
      │  6. Display result to player           │
      ├───────────────────────────────────────>│
      │    (AE3 terminal output)               │
      │                                        │
```

## Power System

### Overview

All hacking operations consume **battery power** from laptops. Power is managed by the AE3 power system.

### Power Units

- **Configuration**: Power costs configured in **Watt-hours (Wh)** via CBA settings
- **Storage**: Laptop battery levels stored in **Kilowatt-hours (kWh)** by AE3
- **Conversion**: Macros `WH_TO_KWH()` and `KWH_TO_WH()` handle conversion

### Power Costs (CBA Settings)

Defined in `fn_initSettings.sqf`:

| Operation | Setting | Default | Range |
|-----------|---------|---------|-------|
| Door lock/unlock | `SETTING_DOOR_COST` | 2 Wh | 0-100 Wh |
| Drone disable | `SETTING_DRONE_HACK_COST` | 10 Wh | 0-100 Wh |
| Drone faction change | `SETTING_DRONE_SIDE_COST` | 20 Wh | 0-100 Wh |
| Custom device | `SETTING_CUSTOM_COST` | 10 Wh | 0-100 Wh |
| Power grid control | `SETTING_POWERGRID_COST` | 15 Wh | 0-100 Wh |
| Vehicle control | Per-vehicle | 2 Wh | 0-100 Wh |

### Power Check Flow

```sqf
// 1. Check if sufficient power available
if (!([_computer, _powerCost] call FUNC(checkPowerAvailable))) exitWith {
    // Display error to user
    [_computer, format ["<t color='%1'>%2</t>", COLOR_ERROR,
        localize "STR_ROOT_CYBERWARFARE_ERR_INSUFFICIENT_POWER"]]
        call AE3_armaos_fnc_shell_stdout;
};

// 2. Consume power
[_computer, _powerCost] call FUNC(consumePower);

// 3. Execute operation
// ... device control logic ...
```

### Power Management Functions

#### `fn_checkPowerAvailable.sqf`

**Purpose**: Check if laptop has sufficient power

**Signature**:
```sqf
[_computer, _powerCostWh] call Root_fnc_checkPowerAvailable;
```

**Implementation**:
```sqf
params [
    ["_computer", objNull, [objNull]],
    ["_powerCostWh", 0, [0]]
];

// Get battery item from AE3
private _battery = _computer getVariable ["AE3_power_battery", objNull];
if (isNull _battery) exitWith { false };

// Get current charge (kWh)
private _currentCharge = _battery getVariable ["AE3_power_charge", 0];

// Convert required power to kWh
private _requiredKWh = WH_TO_KWH(_powerCostWh);

// Check if sufficient
_currentCharge >= _requiredKWh
```

#### `fn_consumePower.sqf`

**Purpose**: Consume power from laptop battery

**Signature**:
```sqf
[_computer, _powerCostWh] call Root_fnc_consumePower;
```

**Implementation**:
```sqf
params [
    ["_computer", objNull, [objNull]],
    ["_powerCostWh", 0, [0]]
];

private _battery = _computer getVariable ["AE3_power_battery", objNull];
if (isNull _battery) exitWith {};

private _currentCharge = _battery getVariable ["AE3_power_charge", 0];
private _requiredKWh = WH_TO_KWH(_powerCostWh);
private _newCharge = (_currentCharge - _requiredKWh) max 0;

// Broadcast CBA event to update power
["root_cyberwarfare_consumePower", [_computer, _battery, _newCharge, _powerCostWh]]
    call CBA_fnc_serverEvent;
```

## Integration Points

### CBA_A3 Integration

**Purpose**: Core framework for addon development

**Usage**:
- **Macros**: `FUNC()`, `QFUNC()`, `GVAR()`, `QUOTE()`, `DOUBLES()`, `TRIPLES()`
- **Function Precompilation**: `PREP()` macro for all 47 functions
- **Settings System**: CBA mission parameters for power costs, GPS config
- **Event System**: `CBA_fnc_addEventHandler` for network communication
- **Wait Functions**: `CBA_fnc_waitUntilAndExecute` for delayed client initialization

**Example**:
```sqf
// Function call using FUNC macro
[_computer, _deviceId] call FUNC(changeDoorState);

// CBA event broadcast
["root_cyberwarfare_deviceStateChanged", [_deviceType, _deviceId, _newState]]
    call CBA_fnc_serverEvent;
```

### ACE3 Integration

**Purpose**: Interaction menu system for GPS tracker operations

**Usage**:
- **Action Creation**: `ace_interact_menu_fnc_createAction`
- **Action Registration**: `ace_interact_menu_fnc_addActionToClass`
- **Progress Bars**: `ace_common_fnc_progressBar` for GPS tracker searches
- **Display Text**: `ace_common_fnc_displayText` for notifications

**Example**:
```sqf
// Create ACE interaction action
private _actionAttach = [
    "ROOT_AttachGPSTracker_Object",
    localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_OBJECT",
    "",
    {
        params ["_target", "_player", "_params"];
        [_target, _player] call FUNC(aceAttachGPSTracker);
    },
    {
        // Condition: player has GPS tracker item
        private _gpsClass = missionNamespace getVariable [SETTING_GPS_TRACKER_DEVICE, "ACE_Banana"];
        _gpsClass in (items _player);
    }
] call ace_interact_menu_fnc_createAction;

// Register action to all objects
["All", 0, ["ACE_MainActions"], _actionAttach, true]
    call ace_interact_menu_fnc_addActionToClass;
```

### AE3 ArmaOS Integration

**Purpose**: Terminal system for executing hacking commands

**Usage**:
- **Terminal Output**: `AE3_armaos_fnc_shell_stdout` for command feedback
- **Power System**: Battery management via AE3 power variables
- **Terminal Access**: Laptops with hacking tools show "Access Terminal" ACE action

**Example**:
```sqf
// Output success message to terminal
[_computer, format ["<t color='%1'>%2</t>", COLOR_SUCCESS,
    localize "STR_ROOT_CYBERWARFARE_DOOR_LOCKED"]]
    call AE3_armaos_fnc_shell_stdout;

// Output error message
[_computer, format ["<t color='%1'>%2</t>", COLOR_ERROR,
    localize "STR_ROOT_CYBERWARFARE_ERR_INSUFFICIENT_POWER"]]
    call AE3_armaos_fnc_shell_stdout;
```

### ZEN Integration

**Purpose**: Zeus module base classes and dialog system

**Usage**:
- **Module Base Classes**: Zeus modules inherit from `zen_modules_moduleBase`
- **Dialog Functions**: `zen_dialog_fnc_create` for Zeus UI
- **Curator Feedback**: `zen_common_fnc_showMessage` for Zeus notifications

**Example**:
```sqf
// Zeus module definition (CfgVehicles.hpp)
class ROOT_CYBERWARFARE_addVehicleZeus: zen_modules_moduleBase {
    displayName = "Add Hackable Vehicle";
    function = "Root_fnc_addVehicleZeus";
    category = "ROOT_CYBERWARFARE";
};
```

## Performance Considerations

### HashMap vs Array Performance

**Device Lookup**:
- **HashMap**: O(1) lookup by device type
- **Array**: O(n) linear search

**Benchmark** (1000 devices):
- HashMap: ~0.001ms per lookup
- Array: ~0.050ms per lookup (50x slower)

**Decision**: Use HashMap for device cache, array for public devices (small size)

### Function Precompilation

All 47 functions are precompiled in PreInit using CBA's PREP system:

```sqf
// XEH_PREP.hpp
PREP(changeDoorState);
PREP(changeLightState);
PREP(changeVehicleParams);
// ... 44 more functions
```

**Benefit**:
- O(1) function access via `FUNC(name)` macro
- No runtime compilation overhead
- Functions stored in `missionNamespace` for fast access

### Network Optimization

**Strategy**: Minimize network traffic using:
1. **CBA Events**: Event queuing and bandwidth management
2. **Public Variables**: Sync only when necessary (3rd param = `true`)
3. **Server Authority**: All device state managed server-side
4. **Client Prediction**: None (simplicity over responsiveness)

### Memory Management

**Cleanup Task** (`fn_cleanupDeviceLinks.sqf`):
- Runs every 60 seconds (server-side)
- Removes orphaned device links (destroyed computers/objects)
- Uses `objectFromNetId` to validate references
- Prevents memory leaks from deleted objects

**Example**:
```sqf
// Cleanup loop (spawned in PostInit)
[{
    private _linkCache = GET_LINK_CACHE;

    // Remove links for destroyed computers
    {
        private _computerNetId = _x;
        private _computer = objectFromNetId _computerNetId;

        if (isNull _computer) then {
            _linkCache deleteAt _computerNetId;
        };
    } forEach (keys _linkCache);

    missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];
}, 60, []] call CBA_fnc_addPerFrameHandler;
```

---

## Related Documentation

- [API Reference](API-Reference) - Function reference for developers
- [Mission Maker Guide](Mission-Maker-Guide) - Programmatic usage examples
- [Configuration Guide](Configuration) - CBA settings and customization

---

**Version**: 2.20.1
**Last Updated**: 2025-10-18
