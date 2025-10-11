# API Reference

Complete function reference for Root's Cyber Warfare developers.

## Quick Reference Table

All 39 functions in the mod:

| Function | Category | Location | Documented |
|----------|----------|----------|------------|
| Root_fnc_isDeviceAccessible | Core | fn_isDeviceAccessible.sqf:1 | ✅ Below |
| Root_fnc_initSettings | Core | fn_initSettings.sqf:1 | ℹ️ See source |
| Root_fnc_cleanupDeviceLinks | Core | fn_cleanupDeviceLinks.sqf:1 | ✅ Below |
| Root_fnc_createDiaryEntry | Core | fn_createDiaryEntry.sqf:1 | ℹ️ See source |
| Root_fnc_checkPowerAvailable | Utility | fn_checkPowerAvailable.sqf:1 | ✅ Below |
| Root_fnc_consumePower | Utility | fn_consumePower.sqf:1 | ✅ Below |
| Root_fnc_getUserConfirmation | Utility | fn_getUserConfirmation.sqf:1 | ℹ️ See source |
| Root_fnc_getAccessibleDevices | Utility | fn_getAccessibleDevices.sqf:1 | ✅ Below |
| Root_fnc_cacheDeviceLinks | Utility | fn_cacheDeviceLinks.sqf:1 | ✅ Below |
| Root_fnc_removePower | Utility | fn_removePower.sqf:1 | ℹ️ See source |
| Root_fnc_localSoundBroadcast | Utility | fn_localSoundBroadcast.sqf:1 | ℹ️ See source |
| Root_fnc_changeDoorState | Devices | fn_changeDoorState.sqf:1 | ✅ Below |
| Root_fnc_changeLightState | Devices | fn_changeLightState.sqf:1 | ✅ Below |
| Root_fnc_changeDroneFaction | Devices | fn_changeDroneFaction.sqf:1 | ℹ️ See source |
| Root_fnc_disableDrone | Devices | fn_disableDrone.sqf:1 | ℹ️ See source |
| Root_fnc_customDevice | Devices | fn_customDevice.sqf:1 | ℹ️ See source |
| Root_fnc_listDevicesInSubnet | Devices | fn_listDevicesInSubnet.sqf:1 | ✅ Below |
| Root_fnc_changeVehicleParams | Devices | fn_changeVehicleParams.sqf:1 | ℹ️ See source |
| Root_fnc_gpsTrackerServer | GPS | fn_gpsTrackerServer.sqf:1 | ✅ Below |
| Root_fnc_gpsTrackerClient | GPS | fn_gpsTrackerClient.sqf:1 | ✅ Below |
| Root_fnc_aceAttachGPSTracker | GPS | fn_aceAttachGPSTracker.sqf:1 | ✅ Below |
| Root_fnc_disableGPSTracker | GPS | fn_disableGPSTracker.sqf:1 | ℹ️ See source |
| Root_fnc_disableGPSTrackerServer | GPS | fn_disableGPSTrackerServer.sqf:1 | ℹ️ See source |
| Root_fnc_displayGPSPosition | GPS | fn_displayGPSPosition.sqf:1 | ℹ️ See source |
| Root_fnc_searchForGPSTracker | GPS | fn_searchForGPSTracker.sqf:1 | ℹ️ See source |
| Root_fnc_revealLaptopLocations | GPS | fn_revealLaptopLocations.sqf:1 | ℹ️ See source |
| Root_fnc_downloadDatabase | Database | fn_downloadDatabase.sqf:1 | ✅ Below |
| Root_fnc_addHackingToolsZeus | Zeus | fn_addHackingToolsZeus.sqf:1 | ℹ️ See source |
| Root_fnc_addHackingToolsZeusMain | Zeus | fn_addHackingToolsZeusMain.sqf:1 | ✅ Below |
| Root_fnc_addDeviceZeus | Zeus | fn_addDeviceZeus.sqf:1 | ℹ️ See source |
| Root_fnc_addDeviceZeusMain | Zeus | fn_addDeviceZeusMain.sqf:1 | ✅ Below |
| Root_fnc_addGPSTrackerZeus | Zeus | fn_addGPSTrackerZeus.sqf:1 | ℹ️ See source |
| Root_fnc_addGPSTrackerZeusMain | Zeus | fn_addGPSTrackerZeusMain.sqf:1 | ✅ Below |
| Root_fnc_addVehicleZeus | Zeus | fn_addVehicleZeus.sqf:1 | ℹ️ See source |
| Root_fnc_addVehicleZeusMain | Zeus | fn_addVehicleZeusMain.sqf:1 | ✅ Below |
| Root_fnc_addDatabaseZeus | Zeus | fn_addDatabaseZeus.sqf:1 | ℹ️ See source |
| Root_fnc_addDatabaseZeusMain | Zeus | fn_addDatabaseZeusMain.sqf:1 | ✅ Below |
| Root_fnc_modifyPowerZeus | Zeus | fn_modifyPowerZeus.sqf:1 | ℹ️ See source |
| XEH_preInit | Init | XEH_preInit.sqf | ℹ️ See source |
| XEH_postInit | Init | XEH_postInit.sqf | ℹ️ See source |

**Legend**: ✅ = Fully documented below | ℹ️ = See source file for SQFdoc header

---

## Core Functions

### Root_fnc_isDeviceAccessible

Checks if a computer can access a specific device with optional backdoor bypass.

**Location**: `addons/main/functions/core/fn_isDeviceAccessible.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _computer | OBJECT | No | - | The laptop/computer object |
| 1 | _deviceType | NUMBER | No | - | Device type (1-7) |
| 2 | _deviceId | NUMBER | No | - | Device ID |
| 3 | _commandPath | STRING | Yes | "" | Command path for backdoor checking |

**Returns**: `<BOOLEAN>` - True if computer can access device, false otherwise

**Example**:
```sqf
// Check if laptop can access door 1234
private _canAccess = [_laptop, 1, 1234] call Root_fnc_isDeviceAccessible;

// Check with backdoor path
private _canAccess = [_laptop, 1, 1234, "/admin_door"] call Root_fnc_isDeviceAccessible;
```

**Access Logic**:
1. Backdoor check: If command path starts with backdoor prefix → grant access
2. Link cache check: If device in laptop's link cache → grant access
3. Public device check: If device is public and laptop not excluded → grant access
4. Default: Deny access

**Notes**:
- Runs server-side for security
- Uses hashmap cache for O(1) lookup performance
- Backdoor prefix stored in `ROOT_CYBERWARFARE_BACKDOOR_PREFIX` variable

---

### Root_fnc_cleanupDeviceLinks

Cleans up device links for deleted computers from the link cache.

**Location**: `addons/main/functions/core/fn_cleanupDeviceLinks.sqf:1`

**Parameters**: None

**Returns**: `<NUMBER>` - Count of cleaned up entries

**Example**:
```sqf
// Run cleanup (usually automatic via postInit)
call Root_fnc_cleanupDeviceLinks;
```

**Behavior**:
- Iterates through link cache
- Removes entries for computers that no longer exist
- Runs automatically on mission start
- Useful for long-running missions where laptops are destroyed

---

## Utility Functions

### Root_fnc_checkPowerAvailable

Checks if sufficient power is available in the laptop battery.

**Location**: `addons/main/functions/utility/fn_checkPowerAvailable.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _computer | OBJECT | No | - | The laptop/computer object |
| 1 | _powerRequiredWh | NUMBER | No | - | Power required in Wh |

**Returns**: `<BOOLEAN>` - True if sufficient power available

**Example**:
```sqf
// Check if 10 Wh available
if ([_laptop, 10] call Root_fnc_checkPowerAvailable) then {
    hint "Sufficient power";
} else {
    hint "Insufficient power";
};
```

**Notes**:
- Checks AE3 battery level
- Power measured in Wh (watt-hours)
- Does not consume power, only checks availability

---

### Root_fnc_consumePower

Consumes power from laptop battery and broadcasts via CBA event.

**Location**: `addons/main/functions/utility/fn_consumePower.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _computer | OBJECT | No | - | The laptop/computer object |
| 1 | _powerWh | NUMBER | No | - | Power to consume in Wh |

**Returns**: `<BOOLEAN>` - True if power consumed successfully

**Example**:
```sqf
// Consume 10 Wh from laptop
[_laptop, 10] call Root_fnc_consumePower;

// Check if successful
if ([_laptop, 15] call Root_fnc_consumePower) then {
    hint "Power consumed";
} else {
    hint "Failed - insufficient power";
};
```

**Behavior**:
- Checks power availability first
- Deducts power from AE3 battery
- Broadcasts `root_cyberwarfare_consumePower` CBA event to server
- Returns false if insufficient power

---

### Root_fnc_getAccessibleDevices

Gets all accessible devices of a specific type for a computer.

**Location**: `addons/main/functions/utility/fn_getAccessibleDevices.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _computer | OBJECT | No | - | The laptop/computer object |
| 1 | _deviceType | NUMBER | No | - | Device type (1-7) |
| 2 | _commandPath | STRING | Yes | "" | Command path for backdoor checking |

**Returns**: `<ARRAY>` - Array of accessible device data

**Example**:
```sqf
// Get all accessible doors
private _doors = [_laptop, 1] call Root_fnc_getAccessibleDevices;

// Get drones with backdoor access
private _drones = [_laptop, 3, "/admin"] call Root_fnc_getAccessibleDevices;

// Iterate through devices
{
    private _deviceId = _x select 0;
    hint format ["Device ID: %1", _deviceId];
} forEach _doors;
```

**Device Types**:
- 1 = Doors
- 2 = Lights
- 3 = Drones
- 4 = Databases
- 5 = Custom devices
- 6 = GPS trackers
- 7 = Vehicles

---

### Root_fnc_cacheDeviceLinks

Caches device links for a computer in the link cache hashmap.

**Location**: `addons/main/functions/utility/fn_cacheDeviceLinks.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _computerNetId | STRING | No | - | Network ID of the computer |
| 1 | _deviceArray | ARRAY | No | - | Array of [deviceType, deviceId] pairs |

**Returns**: None

**Example**:
```sqf
// Cache links for laptop
private _netId = netId _laptop;
private _links = [
    [1, 1234],  // Door 1234
    [3, 5678]   // Drone 5678
];
[_netId, _links] call Root_fnc_cacheDeviceLinks;
```

**Notes**:
- Updates link cache hashmap
- Called automatically when devices are registered
- Used for fast O(1) access checks

---

## Device Functions

### Root_fnc_changeDoorState

Changes the lock state of doors in buildings.

**Location**: `addons/main/functions/devices/fn_changeDoorState.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _owner | ANY | No | - | Owner parameter (legacy) |
| 1 | _computer | OBJECT | No | - | The laptop object |
| 2 | _nameOfVariable | STRING | No | - | Completion flag variable |
| 3 | _doorId | STRING | No | - | Door ID or "a" for all |
| 4 | _doorNumber | STRING | No | - | Door number or "a" |
| 5 | _doorState | STRING | No | - | "lock" or "unlock" |
| 6 | _commandPath | STRING | No | - | Command path |

**Returns**: None (sets completion variable)

**Example**:
```sqf
// Lock door 1 of building 1234
[nil, _laptop, "var1", "1234", "1", "lock", "/tools/door"] call Root_fnc_changeDoorState;

// Unlock all doors
[nil, _laptop, "var2", "1234", "a", "unlock", "/tools/door"] call Root_fnc_changeDoorState;
```

**Notes**:
- Consumes power (2 Wh per door by default)
- Requires user confirmation
- Updates door state globally
- Command is typically called via AE3 terminal, not directly

---

### Root_fnc_changeLightState

Changes the state of a light or all accessible lights.

**Location**: `addons/main/functions/devices/fn_changeLightState.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _owner | ANY | No | - | Owner parameter (legacy) |
| 1 | _computer | OBJECT | No | - | The laptop object |
| 2 | _nameOfVariable | STRING | No | - | Completion flag variable |
| 3 | _lightId | STRING | No | - | Light ID or "a" for all |
| 4 | _lightState | STRING | No | - | "on" or "off" |
| 5 | _commandPath | STRING | No | - | Command path |

**Returns**: None (sets completion variable)

**Example**:
```sqf
// Turn on light 5678
[nil, _laptop, "var1", "5678", "on", "/tools/light"] call Root_fnc_changeLightState;

// Turn off all lights
[nil, _laptop, "var2", "a", "off", "/tools/light"] call Root_fnc_changeLightState;
```

**Notes**:
- No power cost (instant operation)
- No confirmation required
- Only works on `Lamps_base_F` objects
- Updates globally via `switchLight` command

---

### Root_fnc_listDevicesInSubnet

Lists all accessible devices in the subnet for a computer.

**Location**: `addons/main/functions/devices/fn_listDevicesInSubnet.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _owner | ANY | No | - | Owner parameter (legacy) |
| 1 | _computer | OBJECT | No | - | The laptop object |
| 2 | _nameOfVariable | STRING | No | - | Completion flag variable |
| 3 | _commandPath | STRING | No | - | Command path |

**Returns**: None (outputs to terminal)

**Example**:
```sqf
// List all devices
[nil, _laptop, "var1", "/tools/devices"] call Root_fnc_listDevicesInSubnet;
```

**Output Format**:
```
Building: 1234 (Land_Cargo_House_V1_F) located at Grid - 123456
    Door: 1  locked closed
    Door: 2  unlocked open

Lights:
    Light: 5678 (Land_LampShabby_F) @ 123457  OFF

Drones:
    Drone: 9012  'EAST' B_UAV_02_F  @ 123458

Files:
    File: Secret Intel (ID: 3456)    Est. Transfer Time: 10 seconds

GPS Trackers:
    Target_Vehicle (ID: 7890) - Track Time: 60s - Frequency: 5s - Untracked

Vehicles:
    Vehicle: 1111 - Offroad_01 (C_Offroad_01_F) - Battery, Speed, Engine @ 123459
```

**Notes**:
- Filters devices by access control
- Color-coded output (green/red for states)
- Shows grid coordinates
- Includes device status information

---

## GPS Functions

### Root_fnc_gpsTrackerServer

Server-side GPS tracker handler - manages tracking state and completion.

**Location**: `addons/main/functions/gps/fn_gpsTrackerServer.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _trackerObject | OBJECT | No | - | The object being tracked |
| 1 | _markerName | STRING | No | - | Name for the map marker |
| 2 | _trackingTime | NUMBER | No | - | Duration in seconds to track |
| 3 | _updateFrequency | NUMBER | No | - | Frequency in seconds between updates |
| 4 | _trackerId | NUMBER | No | - | Tracker device ID |
| 5 | _computer | OBJECT | No | - | The laptop/computer object |
| 6 | _allowRetracking | BOOLEAN | No | - | Allow retracking after completion |
| 7 | _trackerIdNum | NUMBER | No | - | Tracker ID number |
| 8 | _trackerName | STRING | No | - | Display name for the tracker |
| 9 | _clientID | NUMBER | No | - | Client owner ID |
| 10 | _lastPingTimer | NUMBER | No | - | Duration in seconds to show last ping marker |

**Returns**: None

**Example**:
```sqf
// Start tracking (remoteExec to server)
[_vehicle, "marker1", 60, 5, 1234, _laptop, true, 1234, "Target_Vehicle", owner player, 30] remoteExec ["Root_fnc_gpsTrackerServer", 2];
```

**Behavior**:
1. Updates tracker status to "Tracking"
2. Calls client visualization function
3. Waits for tracking duration
4. Updates status to "Completed" or "Untrackable"
5. Notifies computer owner with completion message

**Notes**:
- Must run on server (remoteExec to 2)
- Uses scheduled environment (`spawn`)
- Updates global device array
- Sends completion notification to original computer

---

### Root_fnc_gpsTrackerClient

Client-side GPS tracker visualization - creates and updates map marker.

**Location**: `addons/main/functions/gps/fn_gpsTrackerClient.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _trackerObject | OBJECT | No | - | The object being tracked |
| 1 | _markerName | STRING | No | - | Name for the map marker |
| 2 | _trackingTime | NUMBER | No | - | Duration in seconds to track |
| 3 | _updateFrequency | NUMBER | No | - | Frequency in seconds between updates |
| 4 | _trackerName | STRING | No | - | Display name for the tracker |
| 5 | _lastPingTimer | NUMBER | No | - | Duration in seconds to show last ping marker |

**Returns**: None

**Example**:
```sqf
// Spawn client-side tracking (called from server)
[_vehicle, "marker1", 60, 5, "Target_Vehicle", 30] spawn Root_fnc_gpsTrackerClient;
```

**Behavior**:
1. Creates blue active marker at target position
2. Updates marker position every N seconds
3. After tracking time, creates red "last ping" marker
4. Deletes last ping marker after duration

**Notes**:
- Runs client-side only
- Uses `spawn` for scheduled execution
- Markers are local to the client
- Automatically cleans up markers

---

### Root_fnc_aceAttachGPSTracker

Unified ACE interaction handler to attach a GPS tracker to any target (object, vehicle, or self).

**Location**: `addons/main/functions/gps/fn_aceAttachGPSTracker.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _target | OBJECT | No | - | The object to attach the tracker to |
| 1 | _player | OBJECT | No | - | The player attaching the tracker |

**Returns**: None

**Example**:
```sqf
// Attach to vehicle
[_vehicle, player] call Root_fnc_aceAttachGPSTracker;

// Attach to self/vehicle player is in
[vehicle player, player] call Root_fnc_aceAttachGPSTracker;
```

**Behavior**:
1. Shows ZEN configuration dialog for tracker settings (tracking time, update frequency)
2. After user confirms configuration, shows ACE progress bar (5 seconds)
3. After progress bar completes, attaches tracker and removes GPS item from player inventory
4. If cancelled at any stage, tracker is not attached

**Configuration Options**:
- **Tracking Time**: Duration in seconds the tracking will stay active (1-30000, default: 60)
- **Update Frequency**: Frequency in seconds between ping updates (1-3000, default: 5)

**Default Settings**:
- Last ping timer: 30 seconds
- Power cost: 2 Wh per tracking session
- Allow retracking: Yes
- Available to all laptops: Yes

**Notes**:
- Replaces both `Root_fnc_aceAttachGPSTrackerSelf` and `Root_fnc_aceAttachGPSTrackerObject` (deprecated)
- Configuration dialog appears BEFORE physical action (improved UX)
- Requires GPS tracker item in player inventory (configurable via CBA settings)
- Item is consumed only after successful attachment
- Automatically increments tracker index for unique naming
- Called automatically by ACE interaction menus

---

## Database Functions

### Root_fnc_downloadDatabase

Downloads a database file to the computer's filesystem.

**Location**: `addons/main/functions/database/fn_downloadDatabase.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _owner | ANY | No | - | Owner parameter (legacy) |
| 1 | _computer | OBJECT | No | - | The laptop object |
| 2 | _nameOfVariable | STRING | No | - | Completion flag variable |
| 3 | _databaseId | STRING | No | - | Database ID to download |
| 4 | _commandPath | STRING | No | - | Command path |

**Returns**: None (creates file in AE3 filesystem)

**Example**:
```sqf
// Download file 1234
[nil, _laptop, "var1", "1234", "/tools/download"] call Root_fnc_downloadDatabase;
```

**Behavior**:
1. Validates database ID and access
2. Shows animated progress bar (1 second per size unit)
3. Creates file in `/path/Files/` directory
4. Executes custom code if database has execution script
5. Displays file location

**Notes**:
- No power cost
- File size determines download time
- Filename is sanitized (spaces → underscores)
- Execution code runs in scheduled environment

---

## Zeus Functions

### Root_fnc_addHackingToolsZeusMain

Server-side function to install hacking tools on a computer.

**Location**: `addons/main/functions/zeus/fn_addHackingToolsZeusMain.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _entity | OBJECT | No | - | The computer/laptop object |
| 1 | _path | STRING | Yes | "/rubberducky/tools" | Installation path for tools |
| 2 | _execUserId | NUMBER | Yes | 0 | User ID for feedback |
| 3 | _customLaptopName | STRING | Yes | "" | Custom name for the laptop |
| 4 | _backdoorScriptPrefix | STRING | Yes | "" | Backdoor prefix for special access |

**Returns**: None

**Example**:
```sqf
// Basic installation
[_laptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];

// With custom settings
[_laptop, "/admin/tools", 0, "Admin_Terminal", "/admin"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
```

**Installed Commands**:
- devices, guide, door, light, changedrone, disabledrone, download, custom, gpstrack, vehicle

**Notes**:
- Must run on server
- Creates virtual filesystem entries via AE3
- Sets `ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED` variable
- Backdoor prefix grants full device access

---

### Root_fnc_addDeviceZeusMain

Server-side function to add a hackable device to the network.

**Location**: `addons/main/functions/zeus/fn_addDeviceZeusMain.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _targetObject | OBJECT | No | - | The object to make hackable |
| 1 | _execUserId | NUMBER | Yes | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | Yes | [] | Array of computer netIds |
| 3 | _treatAsCustom | BOOLEAN | Yes | false | Treat as custom device |
| 4 | _customName | STRING | Yes | "" | Custom device name |
| 5 | _activationCode | STRING | Yes | "" | Code to run on activation |
| 6 | _deactivationCode | STRING | Yes | "" | Code to run on deactivation |
| 7 | _availableToFutureLaptops | BOOLEAN | Yes | false | Available to future laptops |

**Returns**: None

**Example**:
```sqf
// Auto-detect device type
[_building] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Custom device with code
[_object, 0, [], true, "Generator", "hint 'Activated';", "hint 'Deactivated';", false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Auto-Detection**:
- Buildings with doors → Door device
- `Lamps_base_F` → Light device
- UAVs → Drone device

---

### Root_fnc_addGPSTrackerZeusMain

Server-side function to add a GPS tracker to the network.

**Location**: `addons/main/functions/zeus/fn_addGPSTrackerZeusMain.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _targetObject | OBJECT | No | - | The object to track |
| 1 | _execUserId | NUMBER | Yes | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | Yes | [] | Array of computer netIds |
| 3 | _trackerName | STRING | Yes | "" | Tracker display name |
| 4 | _trackingTime | NUMBER | Yes | 60 | Tracking duration in seconds |
| 5 | _updateFrequency | NUMBER | Yes | 5 | Update frequency in seconds |
| 6 | _customMarker | STRING | Yes | "" | Custom marker name |
| 7 | _availableToFutureLaptops | BOOLEAN | Yes | false | Available to future laptops |
| 8 | _allowRetracking | BOOLEAN | Yes | false | Allow retracking |
| 9 | _lastPingTimer | NUMBER | No | - | Last ping marker duration |
| 10 | _powerCost | NUMBER | No | - | Power cost per tracking session |
| 11 | _sysChat | BOOLEAN | Yes | true | Show system chat |

**Returns**: None

**Example**:
```sqf
// Basic GPS tracker
[_vehicle, 0, [], "Target_Vehicle", 60, 5, "", false, true, 30, 2, true] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
```

---

### Root_fnc_addVehicleZeusMain

Server-side function to add a hackable vehicle to the network.

**Location**: `addons/main/functions/zeus/fn_addVehicleZeusMain.sqf:1`

**Parameters**:
| # | Name | Type | Optional | Default | Description |
|---|------|------|----------|---------|-------------|
| 0 | _targetObject | OBJECT | No | - | The vehicle to make hackable |
| 1 | _execUserId | NUMBER | Yes | 0 | User ID for feedback |
| 2 | _linkedComputers | ARRAY | Yes | [] | Array of computer netIds |
| 3 | _vehicleName | STRING | No | - | Vehicle display name |
| 4 | _allowFuel | BOOLEAN | Yes | false | Enable fuel/battery control |
| 5 | _allowSpeed | BOOLEAN | Yes | false | Enable speed control |
| 6 | _allowBrakes | BOOLEAN | Yes | false | Enable brakes control |
| 7 | _allowLights | BOOLEAN | Yes | false | Enable lights control |
| 8 | _allowEngine | BOOLEAN | Yes | true | Enable engine control |
| 9 | _allowAlarm | BOOLEAN | Yes | false | Enable alarm control |
| 10 | _availableToFutureLaptops | BOOLEAN | Yes | false | Available to future laptops |
| 11 | _powerCost | NUMBER | Yes | 2 | Power cost per action |

**Returns**: None

**Example**:
```sqf
// Full control vehicle
[_vehicle, 0, [], "Enemy_Transport", true, true, true, true, true, true, false, 2] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

---

### Root_fnc_addDatabaseZeusMain

Server-side function to add a hackable database/file to the network.

**Location**: `addons/main/functions/zeus/fn_addDatabaseZeusMain.sqf:1`

**Parameters**: (Complex - see Mission Maker Guide for simplified wrapper)

**Example**:
```sqf
// Use simplified wrapper from Mission Maker Guide
["Intel_Report", 10, "Enemy positions...", "hint 'Intel acquired';"] call ROOT_fnc_addDatabase;
```

---

## See Also

- [Mission Maker Guide](Mission-Maker-Guide) - Integration examples
- [Architecture](Architecture) - System design
- [Configuration](Configuration) - Settings reference

---

**For full SQFdoc**: See individual function files in `addons/main/functions/`
