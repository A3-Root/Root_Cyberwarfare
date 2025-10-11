# Architecture & Technical Details

Technical documentation of Root's Cyber Warfare's internal architecture and design patterns.

## System Overview

Root's Cyber Warfare 2.20+ uses a hybrid storage approach with CBA_A3 framework integration:

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Layer                         │
├──────────────────┬──────────────────┬───────────────────────┤
│   AE3 Terminal   │   ACE Actions    │   Map Markers (GPS)   │
│   (User Input)   │  (Interactions)  │   (Visualization)     │
└─────────┬────────┴─────────┬────────┴───────────┬───────────┘
          │                  │                    │
          v                  v                    v
┌─────────────────────────────────────────────────────────────┐
│                       CBA Events Layer                      │
├─────────────────────────────────────────────────────────────┤
│  • root_cyberwarfare_consumePower                           │
│  • root_cyberwarfare_deviceStateChanged                     │
│  • root_cyberwarfare_gpsTrackingUpdate                      │
│  • root_cyberwarfare_deviceLinked                           │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           v
┌────────────────────────────────────────────────────────────┐
│                        Server Layer                        │
├──────────────────┬──────────────────┬──────────────────────┤
│  Device Control  │  Access Control  │    Data Storage      │
│   Functions      │    (Linking)     │   (Hashmaps/Arrays)  │
└─────────┬────────┴─────────┬────────┴───────────┬──────────┘
          │                  │                    │
          v                  v                    v
┌────────────────────────────────────────────────────────────┐
│                     Data Structures                        │
├──────────────────┬──────────────────┬──────────────────────┤
│  Device Storage  │   Link Cache     │   Public Devices     │
│    (Array)       │   (HashMap)      │     (Array)          │
└──────────────────┴──────────────────┴──────────────────────┘
```

---

## Current Architecture (Version 2.20)

### Hybrid Storage Approach

Root's Cyber Warfare uses a **hybrid approach** combining arrays and hashmaps:

| Component | Data Structure | Purpose | Benefit |
|-----------|---------------|---------|---------|
| **Device Storage** | Array (`ROOT_CYBERWARFARE_ALL_DEVICES`) | Store all devices by category | Simple iteration, easy debugging |
| **Link Cache** | HashMap (`ROOT_CYBERWARFARE_LINK_CACHE`) | Computer-to-device mappings | O(1) access checks |
| **Public Devices** | Array (`ROOT_CYBERWARFARE_PUBLIC_DEVICES`) | Devices with exclusion lists | "Available to Future Laptops" feature |

### Why Not Full HashMap?

**Design Decision**: Arrays work well for device storage because:
1. **Small scale**: Most missions have <100 devices, O(n) iteration is <1ms
2. **Simple debugging**: Easy to inspect full device list in watch/debug
3. **Lower complexity**: Fewer nested data structures to maintain
4. **Proven reliability**: Battle-tested in 2.x versions

**HashMap is used** where it matters most:
- **Link cache**: O(1) lookup for "does computer X have access to device Y?"
- Significant performance gain for access control checks

---

## Data Structures

### Device Storage (Array)

**Purpose**: Store all hackable devices organized by category.

**Structure**:
```sqf
ROOT_CYBERWARFARE_ALL_DEVICES = [
    _allDoors,      // Index 0 - Door devices
    _allLights,     // Index 1 - Light devices
    _allDrones,     // Index 2 - Drone devices
    _allDatabases,  // Index 3 - Database/file devices
    _allCustom,     // Index 4 - Custom devices
    _allGpsTrackers,// Index 5 - GPS tracker devices
    _allVehicles    // Index 6 - Vehicle devices
];
```

**Example**:
```sqf
// Get all doors
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;

// Find specific door
private _doorEntry = _allDoors select { (_x select 0) == 1234 } select 0;
```

**Door Device Format**:
```
[deviceId, buildingNetId, doorNumbers, linkedComputers, activationCode, deactivationCode, availableToFuture]
```

**Light Device Format**:
```
[deviceId, lightNetId, linkedComputers, activationCode, deactivationCode, availableToFuture]
```

**Drone Device Format**:
```
[deviceId, droneNetId, linkedComputers, activationCode, deactivationCode, availableToFuture]
```

**Database Format**:
```
[deviceId, objectNetId, filename, filesize, linkedComputers, availableToFuture]
```

**Custom Device Format**:
```
[deviceId, objectNetId, customName, activationCode, deactivationCode, availableToFuture]
```

**GPS Tracker Format**:
```
[deviceId, objectNetId, trackerName, trackingTime, updateFrequency, customMarker, linkedComputers, availableToFuture, [status, lastTime, markerName], allowRetracking, lastPingTimer, powerCost]
```

**Vehicle Format**:
```
[deviceId, vehicleNetId, vehicleName, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFuture, powerCost, linkedComputers]
```

---

### Link Cache (HashMap)

**Purpose**: Fast O(1) lookup of which devices a computer can access.

**Structure**:
```sqf
ROOT_CYBERWARFARE_LINK_CACHE = createHashMap;
// Key: computerNetId (string)
// Value: array of [deviceType, deviceId] pairs
```

**Example**:
```sqf
private _linkCache = GET_LINK_CACHE;
_linkCache set ["netId_laptop1", [
    [1, 1234],  // Door 1234
    [2, 5678],  // Light 5678
    [3, 9012]   // Drone 9012
]];
```

**Access Pattern**:
```sqf
// Get all devices for a laptop
private _computerNetId = netId _laptop;
private _links = GET_LINK_CACHE getOrDefault [_computerNetId, []];

// Check if laptop has access to specific device
private _hasAccess = _links findIf { _x isEqualTo [1, 1234] } != -1;
```

---

### Public Devices (Array)

**Purpose**: Track devices available to all/most laptops with exclusion lists.

**Structure**:
```sqf
ROOT_CYBERWARFARE_PUBLIC_DEVICES = [
    [deviceType, deviceId, excludedNetIds],
    ...
];
```

**Example**:
```sqf
// Device available to all except specific laptops
[1, 1234, ["netId_admin"]],  // Door 1234 - all except admin
[6, 7890, []]                 // GPS 7890 - all laptops (no exclusions)
```

**Scenarios**:
1. **Public (no exclusions)**: `[type, id, []]` - Everyone has access
2. **Future-only**: `[type, id, [allCurrentLaptops]]` - Only future laptops
3. **Most except some**: `[type, id, [laptop1, laptop2]]` - All except excluded

---

### Device Cache HashMap (Initialized but Unused)

**Note**: A hashmap device cache is **initialized** in `XEH_postInit.sqf` for potential future optimization, but is **not currently used** by the mod.

```sqf
// Initialized on server
ROOT_CYBERWARFARE_DEVICE_CACHE = createHashMap;
// Keys: "doors", "lights", "drones", etc.
```

**Current Status**: All Zeus registration functions and device operations use the array-based `ROOT_CYBERWARFARE_ALL_DEVICES` storage.

---

## Access Control System

### Three-Tier Priority System

Access is checked in this order (first match wins):

1. **Backdoor Access** (Highest Priority) - Bypass all checks for admin access
2. **Public Device Access** - Devices available to all/most computers with exclusions
3. **Private Links** (Lowest Priority) - Direct computer-to-device relationships

### Access Check Flow

```sqf
// Root_fnc_isDeviceAccessible
params ["_computer", "_deviceType", "_deviceId", "_commandPath"];

// 1. Check backdoor access
private _backdoorPaths = _computer getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", []];
if (_commandPath != "" && {_backdoorPaths isNotEqualTo []}) then {
    {
        if (_commandPath find _x == 0) exitWith { true };
    } forEach _backdoorPaths;
};

// 2. Check public devices FIRST
private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];
private _isPublic = false;
{
    _x params ["_pubDevType", "_pubDevId", ["_excludedNetIds", []]];
    if (_pubDevType == _deviceType && {_pubDevId == _deviceId}) exitWith {
        // If no exclusion list, fully public
        if (_excludedNetIds isEqualTo []) exitWith {
            _isPublic = true;
        };
        // Check if computer is NOT excluded
        private _computerNetId = netId _computer;
        _isPublic = !(_computerNetId in _excludedNetIds);
    };
} forEach _publicDevices;

// If device is public and accessible, return true
if (_isPublic) exitWith { true };

// 3. Check private device links (fallback)
private _computerNetId = netId _computer;
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _allowedDevices = _linkCache getOrDefault [_computerNetId, []];
if (_allowedDevices isEqualTo []) exitWith { false };

// Check if device is in allowed list
private _isAllowed = _allowedDevices findIf {
    _x params ["_type", "_id"];
    _type == _deviceType && {_id == _deviceId}
} != -1;

_isAllowed
```

### Backdoor System

**Purpose**: Grant full access to all devices regardless of links.

**Implementation**:
```sqf
// Check if command path starts with backdoor prefix
private _backdoorPrefix = _computer getVariable ["ROOT_CYBERWARFARE_BACKDOOR_PREFIX", ""];
if (_backdoorPrefix != "" && {_commandPath find _backdoorPrefix == 0}) then {
    // Full access granted
    true
};
```

**Example**:
```sqf
// Admin laptop with backdoor
_laptop setVariable ["ROOT_CYBERWARFARE_BACKDOOR_PREFIX", "/admin", true];

// Regular command: /tools/door → checks links
// Backdoor command: /admin_door → full access
```

---

## CBA Events System

### Registered Events

**1. `root_cyberwarfare_consumePower`**

Broadcasts power consumption to server for synchronization.

```sqf
// Fire event
["root_cyberwarfare_consumePower", [_computer, _powerWh]] call CBA_fnc_serverEvent;

// Handle event (server-side)
["root_cyberwarfare_consumePower", {
    params ["_computer", "_powerWh"];
    // Update battery
}] call CBA_fnc_addEventHandler;
```

**2. `root_cyberwarfare_deviceStateChanged`**

Notifies clients of device state changes.

```sqf
// Fire event
["root_cyberwarfare_deviceStateChanged", [_deviceType, _deviceId, _newState]] call CBA_fnc_globalEvent;
```

**3. `root_cyberwarfare_gpsTrackingUpdate`**

Updates GPS tracking status.

```sqf
["root_cyberwarfare_gpsTrackingUpdate", [_trackerId, _status, _position]] call CBA_fnc_globalEvent;
```

**4. `root_cyberwarfare_deviceLinked`**

Notifies when device links change.

```sqf
["root_cyberwarfare_deviceLinked", [_computerNetId, _deviceType, _deviceId]] call CBA_fnc_globalEvent;
```

### Benefits

- **Reduced Network Traffic**: Events are optimized by CBA
- **Reliability**: Built-in error handling
- **Locality**: Automatic JIP (Join-In-Progress) compatibility
- **Debugging**: CBA event tracing

---

## Network ID Usage

**Why netId instead of object references?**

Object references don't sync reliably in multiplayer. Network IDs are strings that uniquely identify objects across all clients.

### Pattern

```sqf
// Store
private _netId = netId _object;
_deviceData pushBack _netId;

// Retrieve
private _object = objectFromNetId _netId;
if (isNull _object) then { /* Object no longer exists */ };
```

### Object Lifecycle

```sqf
// Check object is still valid
private _vehicle = objectFromNetId (_deviceData select 1);
if (!isNull _vehicle && alive _vehicle) then {
    // Object exists and is alive
};
```

---

## Macro System

### Defined in `script_macros.hpp`

**Device Type Constants**:
```cpp
#define DEVICE_TYPE_DOOR 1
#define DEVICE_TYPE_LIGHT 2
#define DEVICE_TYPE_DRONE 3
#define DEVICE_TYPE_DATABASE 4
#define DEVICE_TYPE_CUSTOM 5
#define DEVICE_TYPE_GPS_TRACKER 6
#define DEVICE_TYPE_VEHICLE 7
```

**Cache Access Macros**:
```cpp
#define GET_DEVICE_CACHE (missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_CACHE", createHashMap])
#define GET_LINK_CACHE (missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap])
#define GET_PUBLIC_DEVICES (missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []])
```

**Utility Macros**:
```cpp
#define VALIDATE_COMPUTER(computer) (!isNull computer && computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false])
#define WH_TO_KWH(wh) (wh / 1000)
```

**Variable Name Macros**:
```cpp
#define GVAR_DEVICE_CACHE "ROOT_CYBERWARFARE_DEVICE_CACHE"
#define GVAR_LINK_CACHE "ROOT_CYBERWARFARE_LINK_CACHE"
#define GVAR_PUBLIC_DEVICES "ROOT_CYBERWARFARE_PUBLIC_DEVICES"
```

### Usage

```sqf
#include "\z\root_cyberwarfare\addons\main\script_macros.hpp"

// Use macros
private _cache = GET_DEVICE_CACHE;
private _isDoor = (_deviceType == DEVICE_TYPE_DOOR);
if (VALIDATE_COMPUTER(_laptop)) then {
    // Laptop is valid
};
```

---

## GPS Tracking System

### Architecture

**Client-Server Split**:

```
┌──────────────┐                     ┌──────────────┐
│    Client    │                     │    Server    │
├──────────────┤                     ├──────────────┤
│              │  gpstrack command   │              │
│  Terminal    ├────────────────────>│  Validate    │
│              │                     │  Access      │
│              │<────────────────────┤              │
│              │   Start tracking    │  Update      │
│              │                     │  Status      │
│ ┌──────────┐ │                     │              │
│ │ Marker   │ │<────remoteExec─────┤  Track Loop  │
│ │ Display  │ │    every N secs    │  (scheduled) │
│ │ (client) │ │                     │              │
│ └──────────┘ │                     │              │
│              │                     │  Completion  │
│              │<────────────────────┤  Notify      │
└──────────────┘                     └──────────────┘
```

### Server-Side (`fn_gpsTrackerServer`)

```sqf
// 1. Update status to "Tracking"
_allGpsTrackers set [_index, [..., ["Tracking", time, _markerName], ...]];

// 2. Start client visualization
[...] remoteExec ["Root_fnc_gpsTrackerClient", _clientID];

// 3. Wait for tracking time
uiSleep _trackingTime;

// 4. Update status to "Completed" or "Untrackable"
_allGpsTrackers set [_index, [..., [_newStatus, time, _markerName], ...]];

// 5. Notify computer owner
[_computer, _completionMessage] remoteExec ["AE3_armaos_fnc_shell_stdout", _clientID];
```

### Client-Side (`fn_gpsTrackerClient`)

```sqf
// Create marker
createMarkerLocal [_markerName, getPos _trackerObject];

// Update loop
private _startTime = time;
while {time < _startTime + _trackingTime} do {
    _marker setMarkerPosLocal (getPos _trackerObject);
    uiSleep _updateFrequency;
};

// Create last ping marker
createMarkerLocal [_lastPingMarker, getPos _trackerObject];
uiSleep _lastPingTimer;
deleteMarkerLocal _lastPingMarker;
```

---

## String Localization

All user-facing strings use `stringtable.xml` for multi-language support.

**Format**:
```xml
<Key ID="STR_ROOT_CYBERWARFARE_ERROR_INVALID_INPUT">
    <English>Error! Invalid input.</English>
    <German>Fehler! Ungültige Eingabe.</German>
    <French>Erreur! Entrée invalide.</French>
</Key>
```

**Usage**:
```sqf
private _string = localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_INPUT";
[_computer, _string] call AE3_armaos_fnc_shell_stdout;
```

---

## Performance Considerations

### Optimizations in 3.0+

1. **Hashmap Lookups**: O(1) instead of O(n) forEach
2. **CBA Events**: Batched network updates
3. **Cached Access Checks**: Pre-computed device links
4. **Lazy Loading**: Devices only loaded when accessed
5. **Network IDs**: Reduced object reference overhead

### Performance Characteristics

| Operation | Complexity | Typical Time (100 devices) |
|-----------|------------|----------------------------|
| Device lookup | O(n) | ~2-5ms |
| Access check (public) | O(n) | ~1-3ms |
| Access check (private) | O(1) | ~0.5ms |
| Device registration | O(n) | ~5-10ms (ID uniqueness check) |

**Note**: Performance is acceptable for typical mission scale (<100 devices). For larger scales, consider the hashmap migration path documented in the codebase.

### Best Practices

1. **Batch Operations**: Register multiple devices at once
2. **Avoid Polling**: Use CBA events for state changes
3. **Cache Results**: Store frequently-used values
4. **Clean Up**: Remove unused devices
5. **Limit GPS Trackers**: Active tracking is client-side resource-intensive

---

## Security Considerations

### Access Control

- All device access checks run server-side
- Client input is validated before execution
- Backdoor system requires server-side variable (not exploitable)
- Network IDs prevent object injection

### Anti-Cheat

- Power consumption validated server-side
- Device state changes broadcasted via CBA events (tamper-proof)
- No client-side trust for critical operations

---

## See Also

- [API Reference](API-Reference) - Function documentation
- [Mission Maker Guide](Mission-Maker-Guide) - Integration examples
- [Configuration Reference](Configuration) - Settings
- [Custom Device Tutorial](Custom-Device-Tutorial) - Extending the system

---

**For developers**: See the source code at [GitHub Repository](https://github.com/A3-Root/Root_Cyberwarfare)
