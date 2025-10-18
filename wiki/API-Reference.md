# API Reference

Complete function reference for developers and advanced mission makers.

## Table of Contents

- [Zeus Functions](#zeus-functions)
- [Device Functions](#device-functions)
- [Utility Functions](#utility-functions)
- [GPS Functions](#gps-functions)
- [Core Functions](#core-functions)
- [Data Structures](#data-structures)

## Zeus Functions

### Root_fnc_addDeviceZeus

Zeus module UI for adding hackable buildings/lights.

**File**: `functions/zeus/fn_addDeviceZeus.sqf`

**Signature**:
```sqf
[_logic] call Root_fnc_addDeviceZeus;
```

**Parameters**:
- `_logic` (OBJECT): Zeus logic module

**Return**: None

**Public**: No

---

### Root_fnc_addDeviceZeusMain

Server-side function to register buildings/lights.

**File**: `functions/zeus/fn_addDeviceZeusMain.sqf`

**Signature**:
```sqf
[_targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

**Parameters**:
- `_targetObject` (OBJECT): Building or light object
- `_execUserId` (NUMBER): User ID for feedback (default: 0)
- `_linkedComputers` (ARRAY): Array of computer netIds (default: [])
- `_availableToFutureLaptops` (BOOLEAN): Future laptop access (default: false)
- `_makeUnbreachable` (BOOLEAN): Prevent breaching (default: false)

**Return**: None

**Public**: No

**Execution**: Server only

---

### Root_fnc_addVehicleZeus

Zeus module UI for adding hackable vehicles/drones.

**File**: `functions/zeus/fn_addVehicleZeus.sqf`

**Signature**:
```sqf
[_logic] call Root_fnc_addVehicleZeus;
```

**Parameters**:
- `_logic` (OBJECT): Zeus logic module

**Return**: None

**Public**: No

---

### Root_fnc_addVehicleZeusMain

Server-side function to register vehicles or drones.

**File**: `functions/zeus/fn_addVehicleZeusMain.sqf`

**Signature** (Vehicle):
```sqf
[_targetObject, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Signature** (Drone):
```sqf
[_targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
```

**Parameters** (Vehicle):
- `_targetObject` (OBJECT): Vehicle
- `_execUserId` (NUMBER): User ID (default: 0)
- `_linkedComputers` (ARRAY): Computer netIds (default: [])
- `_vehicleName` (STRING): Display name
- `_allowFuel` (BOOLEAN): Enable fuel control (default: false)
- `_allowSpeed` (BOOLEAN): Enable speed control (default: false)
- `_allowBrakes` (BOOLEAN): Enable brakes control (default: false)
- `_allowLights` (BOOLEAN): Enable lights control (default: false)
- `_allowEngine` (BOOLEAN): Enable engine control (default: true)
- `_allowAlarm` (BOOLEAN): Enable alarm control (default: false)
- `_availableToFutureLaptops` (BOOLEAN): Future access (default: false)
- `_powerCost` (NUMBER): Power per action in Wh (default: 2)

**Parameters** (Drone):
- `_targetObject` (OBJECT): Drone/UAV
- `_execUserId` (NUMBER): User ID (default: 0)
- `_linkedComputers` (ARRAY): Computer netIds (default: [])
- `_availableToFutureLaptops` (BOOLEAN): Future access (default: false)

**Return**: None

**Public**: No

**Execution**: Server only

**Notes**: Automatically detects drones via `unitIsUAV` or parameter count

---

### Root_fnc_addCustomDeviceZeus

Zeus module UI for adding custom devices.

**File**: `functions/zeus/fn_addCustomDeviceZeus.sqf`

**Signature**:
```sqf
[_logic] call Root_fnc_addCustomDeviceZeus;
```

**Parameters**:
- `_logic` (OBJECT): Zeus logic module

**Return**: None

**Public**: No

---

### Root_fnc_addCustomDeviceZeusMain

Server-side function to register custom devices.

**File**: `functions/zeus/fn_addCustomDeviceZeusMain.sqf`

**Signature**:
```sqf
[_targetObject, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
```

**Parameters**:
- `_targetObject` (OBJECT): Any object
- `_execUserId` (NUMBER): User ID (default: 0)
- `_linkedComputers` (ARRAY): Computer netIds (default: [])
- `_customName` (STRING): Display name (default: "Custom Device")
- `_activationCode` (STRING): SQF code for activation (default: "")
- `_deactivationCode` (STRING): SQF code for deactivation (default: "")
- `_availableToFutureLaptops` (BOOLEAN): Future access (default: false)

**Return**: None

**Public**: No

**Execution**: Server only

**Code Environment**: Activation/deactivation code runs in scheduled environment with params: `[_computer, _customObject, _playerNetID]`

---

### Root_fnc_addHackingToolsZeus

Zeus module UI for adding hacking tools to laptops.

**File**: `functions/zeus/fn_addHackingToolsZeus.sqf`

**Signature**:
```sqf
[_logic] call Root_fnc_addHackingToolsZeus;
```

**Parameters**:
- `_logic` (OBJECT): Zeus logic module

**Return**: None

**Public**: No

---

### Root_fnc_addHackingToolsZeusMain

Server-side function to add hacking tools to a laptop.

**File**: `functions/zeus/fn_addHackingToolsZeusMain.sqf`

**Signature**:
```sqf
[_targetObject, _backdoorPath, _execUserId, _laptopName, _linkedComputerNetIds] call Root_fnc_addHackingToolsZeusMain;
```

**Parameters**:
- `_targetObject` (OBJECT): Laptop object
- `_backdoorPath` (STRING): Backdoor access path (empty for none)
- `_execUserId` (NUMBER): User ID (default: 0)
- `_laptopName` (STRING): Display name
- `_linkedComputerNetIds` (ARRAY): NetIDs to link (default: [])

**Return**: None

**Public**: No

**Execution**: Server only

---

### Root_fnc_addPowerGeneratorZeus

Zeus module UI for adding power generators.

**File**: `functions/zeus/fn_addPowerGeneratorZeus.sqf`

**Signature**:
```sqf
[_logic] call Root_fnc_addPowerGeneratorZeus;
```

**Parameters**:
- `_logic` (OBJECT): Zeus logic module

**Return**: None

**Public**: No

---

### Root_fnc_addPowerGeneratorZeusMain

Server-side function to register power generators.

**File**: `functions/zeus/fn_addPowerGeneratorZeusMain.sqf`

**Signature**:
```sqf
[_object, _execUserId, _linkedComputers, _name, _radius, _allowExplosionActivate, _allowExplosionDeactivate, _explosionType, _excludedClassnames, _availableToFutureLaptops] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
```

**Parameters**:
- `_object` (OBJECT): Generator object
- `_execUserId` (NUMBER): User ID (default: 0)
- `_linkedComputers` (ARRAY): Computer netIds (default: [])
- `_name` (STRING): Display name
- `_radius` (NUMBER): Area of effect in meters
- `_allowExplosionActivate` (BOOLEAN): Explosion can activate
- `_allowExplosionDeactivate` (BOOLEAN): Explosion can deactivate
- `_explosionType` (STRING): Explosion classname
- `_excludedClassnames` (ARRAY): Light classnames to exclude
- `_availableToFutureLaptops` (BOOLEAN): Future access

**Return**: None

**Public**: No

**Execution**: Server only

---

## Device Functions

### Root_fnc_controlDoor

Control building doors (lock/unlock).

**File**: `functions/devices/fn_controlDoor.sqf`

**Signature**:
```sqf
[_computer, _deviceId, _action] call Root_fnc_controlDoor;
```

**Parameters**:
- `_computer` (OBJECT): Hacking laptop
- `_deviceId` (NUMBER): Device ID
- `_action` (STRING): "lock", "unlock", or "status"

**Return**: None

**Public**: No

**Power Cost**: Configurable (CBA setting)

---

### Root_fnc_controlLight

Control lights (on/off/toggle).

**File**: `functions/devices/fn_controlLight.sqf`

**Signature**:
```sqf
[_computer, _deviceId, _action] call Root_fnc_controlLight;
```

**Parameters**:
- `_computer` (OBJECT): Hacking laptop
- `_deviceId` (NUMBER): Device ID
- `_action` (STRING): "on", "off", or "toggle"

**Return**: None

**Public**: No

**Power Cost**: Configurable (CBA setting)

---

### Root_fnc_controlVehicle

Control vehicle systems.

**File**: `functions/devices/fn_controlVehicle.sqf`

**Signature**:
```sqf
[_computer, _deviceId, _feature, _value] call Root_fnc_controlVehicle;
```

**Parameters**:
- `_computer` (OBJECT): Hacking laptop
- `_deviceId` (NUMBER): Device ID
- `_feature` (STRING): "fuel", "speed", "brakes", "lights", "engine", "alarm"
- `_value` (ANY): Feature-specific value

**Return**: None

**Public**: No

**Power Cost**: Per-vehicle configuration

---

### Root_fnc_controlDrone

Control drones (faction change, disable).

**File**: `functions/devices/fn_controlDrone.sqf`

**Signature**:
```sqf
[_computer, _deviceId, _action, _side] call Root_fnc_controlDrone;
```

**Parameters**:
- `_computer` (OBJECT): Hacking laptop
- `_deviceId` (NUMBER): Device ID
- `_action` (STRING): "side" or "disable"
- `_side` (SIDE): Faction (when action = "side")

**Return**: None

**Public**: No

**Power Cost**: Configurable (CBA setting)

---

### Root_fnc_controlCustomDevice

Activate/deactivate custom devices.

**File**: `functions/devices/fn_controlCustomDevice.sqf`

**Signature**:
```sqf
[_computer, _deviceId, _action] call Root_fnc_controlCustomDevice;
```

**Parameters**:
- `_computer` (OBJECT): Hacking laptop
- `_deviceId` (NUMBER): Device ID
- `_action` (STRING): "activate" or "deactivate"

**Return**: None

**Public**: No

**Power Cost**: Configurable (CBA setting)

---

## Utility Functions

### Root_fnc_isDeviceAccessible

Check if a laptop can access a specific device.

**File**: `functions/utility/fn_isDeviceAccessible.sqf`

**Signature**:
```sqf
[_computer, _deviceType, _deviceId] call Root_fnc_isDeviceAccessible;
```

**Parameters**:
- `_computer` (OBJECT): Laptop object
- `_deviceType` (NUMBER): Device type constant (1-7)
- `_deviceId` (NUMBER): Device ID

**Return**: BOOLEAN - True if accessible, false otherwise

**Public**: No

**Notes**: Checks in order: backdoor access → public devices → private links

---

### Root_fnc_checkPowerAvailable

Check if laptop has sufficient power for an operation.

**File**: `functions/utility/fn_checkPowerAvailable.sqf`

**Signature**:
```sqf
[_computer, _powerCost] call Root_fnc_checkPowerAvailable;
```

**Parameters**:
- `_computer` (OBJECT): Laptop object
- `_powerCost` (NUMBER): Required power in Wh

**Return**: BOOLEAN - True if sufficient power, false otherwise

**Public**: No

**Notes**: Integrates with AE3 power system

---

### Root_fnc_consumePower

Consume power from laptop battery.

**File**: `functions/utility/fn_consumePower.sqf`

**Signature**:
```sqf
[_computer, _powerCost] call Root_fnc_consumePower;
```

**Parameters**:
- `_computer` (OBJECT): Laptop object
- `_powerCost` (NUMBER): Power to consume in Wh

**Return**: None

**Public**: No

**Notes**: Automatically converts Wh to kWh for AE3

---

## GPS Functions

### Root_fnc_attachGPSTracker

Attach GPS tracker to a target.

**File**: `functions/gps/fn_attachGPSTracker.sqf`

**Signature**:
```sqf
[_target, _computer] call Root_fnc_attachGPSTracker;
```

**Parameters**:
- `_target` (OBJECT): Unit or vehicle to track
- `_computer` (OBJECT): Laptop object

**Return**: None

**Public**: No

**Notes**: Called via ACE interaction menu

---

### Root_fnc_updateGPSTracker

Update GPS tracker position (automatic).

**File**: `functions/gps/fn_updateGPSTracker.sqf`

**Signature**:
```sqf
[_trackerId] call Root_fnc_updateGPSTracker;
```

**Parameters**:
- `_trackerId` (NUMBER): Tracker device ID

**Return**: None

**Public**: No

**Notes**: Called automatically at configured intervals

---

### Root_fnc_listGPSTrackers

List all GPS trackers.

**File**: `functions/gps/fn_listGPSTrackers.sqf`

**Signature**:
```sqf
[_computer] call Root_fnc_listGPSTrackers;
```

**Parameters**:
- `_computer` (OBJECT): Laptop object

**Return**: None (outputs to terminal)

**Public**: No

---

### Root_fnc_locateGPSTracker

Get detailed position for a tracker.

**File**: `functions/gps/fn_locateGPSTracker.sqf`

**Signature**:
```sqf
[_computer, _deviceId] call Root_fnc_locateGPSTracker;
```

**Parameters**:
- `_computer` (OBJECT): Laptop object
- `_deviceId` (NUMBER): Tracker device ID

**Return**: None (outputs to terminal)

**Public**: No

---

## Core Functions

### Root_fnc_initSettings

Initialize CBA settings.

**File**: `functions/core/fn_initSettings.sqf`

**Signature**:
```sqf
[] call Root_fnc_initSettings;
```

**Return**: None

**Public**: No

**Notes**: Called during PreInit

---

## Data Structures

### Device Cache (HashMap)

**Variable**: `ROOT_CYBERWARFARE_DEVICE_CACHE`

**Structure**:
```sqf
createHashMap with keys:
  "doors" → [[deviceId, buildingNetId, doorIds[], buildingName, availableToFuture], ...]
  "lights" → [[deviceId, lightNetId, lightName, availableToFuture], ...]
  "drones" → [[deviceId, droneNetId, droneName, availableToFuture], ...]
  "vehicles" → [[deviceId, vehicleNetId, name, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFuture, powerCost], ...]
  "custom" → [[deviceId, objectNetId, name, activationCode, deactivationCode, availableToFuture], ...]
  "gpsTrackers" → [[deviceId, targetNetId, name, updateInterval, isActive, lastPingTime, lastPosition], ...]
  "databases" → [[deviceId, objectNetId, fileName, fileSize, fileContent, databaseName, availableToFuture], ...]
```

---

### Link Cache (HashMap)

**Variable**: `ROOT_CYBERWARFARE_LINK_CACHE`

**Structure**:
```sqf
createHashMap with keys: computerNetId (string)
values: [[deviceType, deviceId], ...] (array of [int, int] pairs)
```

**Example**:
```sqf
"1:23" → [[1, 1234], [7, 5678]]  // Computer "1:23" can access door 1234 and vehicle 5678
```

---

### Public Devices (Array)

**Variable**: `ROOT_CYBERWARFARE_PUBLIC_DEVICES`

**Structure**:
```sqf
[[deviceType, deviceId, [excludedComputerNetIds]], ...]
```

**Example**:
```sqf
[[1, 1234, ["1:23", "1:24"]], [7, 5678, []]]
// Door 1234 is public except for computers "1:23" and "1:24"
// Vehicle 5678 is public to all
```

---

### Device Type Constants

```sqf
DEVICE_TYPE_DOOR = 1;          // Building doors
DEVICE_TYPE_LIGHT = 2;         // Lights/lamps
DEVICE_TYPE_DRONE = 3;         // UAVs/drones
DEVICE_TYPE_DATABASE = 4;      // File downloads
DEVICE_TYPE_CUSTOM = 5;        // Custom scripted devices
DEVICE_TYPE_GPS_TRACKER = 6;   // GPS trackers
DEVICE_TYPE_VEHICLE = 7;       // Vehicles
```

---

## Macros

### Cache Access

```cpp
GET_DEVICE_CACHE    // Get or create device cache HashMap
GET_LINK_CACHE      // Get or create link cache HashMap
GET_PUBLIC_DEVICES  // Get or create public devices array
```

### Validation

```cpp
VALIDATE_COMPUTER(obj)     // Check if object has hacking tools
VALIDATE_DEVICE_TYPE(n)    // Check if device type is 1-7
```

### Power Conversion

```cpp
WH_TO_KWH(wh)    // Watt-hours to Kilowatt-hours
KWH_TO_WH(kwh)   // Kilowatt-hours to Watt-hours
```

### Logging

```cpp
LOG_DEBUG(msg)   // Debug log (disabled in release)
LOG_INFO(msg)    // Info log
LOG_ERROR(msg)   // Error log
```

---

For more information, see:
- [Mission Maker Guide](Mission-Maker-Guide.md) - Usage examples
- [CLAUDE.md](../CLAUDE.md) - Architecture documentation
- Source code in `addons/main/functions/`
