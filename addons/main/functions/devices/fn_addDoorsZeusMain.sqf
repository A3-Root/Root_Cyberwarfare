#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to add hackable building doors to the network.
 * For lights use fn_addLightsZeusMain, for drones use fn_addVehicleZeusMain,
 * for custom devices use fn_addCustomDeviceZeusMain.
 *
 * Arguments:
 * DIRECT MODE (single object):
 * 0: _targetObject <OBJECT> - The building object to make hackable
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 4: _makeUnbreachable <BOOLEAN> (Optional) - Prevent non-hacking breaching methods, default: false
 * 5: _allowLocation <BOOLEAN> (Optional) - Show grid location on the laptop, default: true
 * 6: _requestedId <NUMBER> (Optional) - Desired building ID (0 = auto-assign), default: 0
 * 7: _doorIdMap <ARRAY> (Optional) - Per-door overrides [[realDoor, customId], ...], default: []
 * 8: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * RADIUS MODE (multiple objects):
 * 0: _centerPosition <ARRAY> - Position array [x, y, z] for search center
 * 1: _radius <NUMBER> - Search radius in meters
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 4: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 5: _makeUnbreachable <BOOLEAN> (Optional) - Prevent non-hacking breaching methods, default: false
 * 6: _allowLocation <BOOLEAN> (Optional) - Show grid location on the laptop, default: true
 * 7: _startId <NUMBER> (Optional) - First building ID handed out across the area (0 = auto), default: 0
 * 8: _endId <NUMBER> (Optional) - Last building ID handed out across the area (0 = auto), default: 0
 * 9: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * Return Value:
 * None
 *
 * Example:
 * [_building, 0, [], false, false, true, 0, [], ACCESS_MODE_PUBLIC] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
 * [[100, 200, 0], 500, 0, [], true, false, true, 0, 0, ACCESS_MODE_LINKED] remoteExec ["Root_fnc_addDoorsZeusMain", 2]; // Radius mode
 *
 * Public: No
 */

// Detect mode based on first parameter type
private _radiusMode = false;
private _centerPos = [];
private _targetObject = objNull;
private _radius = 0;
private _execUserId = 0;
private _linkedComputers = [];
private _availableToFutureLaptops = false;
private _makeUnbreachable = false;
private _allowLocation = true; // "Allow Location View" (General #3); default on
private _requestedId = 0;      // Desired building ID for direct mode (0 = auto)
private _doorIdMapInput = [];  // Caller-supplied per-door overrides for direct mode
private _startId = 0;          // First ID handed out across a radius sweep
private _endId = 0;            // Last ID handed out across a radius sweep
private _accessMode = ACCESS_MODE_UNASSIGNED; // How the registered buildings may be reached

private _firstParam = _this select 0;

// Check if first parameter is an array (position array for radius mode) or object (direct mode)
if (typeName _firstParam == "ARRAY") then {
    // Radius mode: position array passed
    _radiusMode = true;
    _centerPos = _firstParam;
    _radius = param [1, 1000, [0]];
    _execUserId = param [2, 0, [0]];
    _linkedComputers = param [3, [], [[]]];
    _availableToFutureLaptops = param [4, false, [false]];
    // The unbreachable flag is forwarded to every building the sweep registers.
    _makeUnbreachable = param [5, false, [false]];
    _allowLocation = param [6, true, [false]];
    _startId = param [7, 0, [0]];
    _endId = param [8, 0, [0]];
    _accessMode = param [9, ACCESS_MODE_UNASSIGNED, [0]];
} else {
    // Direct mode: object passed
    _radiusMode = false;
    _targetObject = _firstParam;
    _execUserId = param [1, 0, [0]];
    _linkedComputers = param [2, [], [[]]];
    _availableToFutureLaptops = param [3, false, [false]];
    _makeUnbreachable = param [4, false, [false]];
    _allowLocation = param [5, true, [false]];
    _requestedId = param [6, 0, [0]];
    _doorIdMapInput = param [7, [], [[]]];
    _accessMode = param [8, ACCESS_MODE_UNASSIGNED, [0]];
};

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

// Handle radius mode
if (_radiusMode) exitWith {
    private _registeredCount = 0;

    // Find all objects in radius and keep only those with door animations or configs
    private _allObjects = nearestObjects [_centerPos, [], _radius];
    private _doorObjects = [];

    // Filter objects into door-bearing objects only
    {
        if (([_x] call Root_fnc_detectBuildingDoors) isNotEqualTo []) then {
            _doorObjects pushBack _x;
        };
    } forEach _allObjects;

    // Hand out sequential IDs across the area from the requested start; once the Start..End range is
    // exhausted (or no range was given) the remaining buildings pass 0 and fall back to auto-assignment.
    private _nextId = _startId;

    // Register each door-bearing object
    {
        private _building = _x;
        private _detectedDoors = [_building] call Root_fnc_detectBuildingDoors;

        if (_detectedDoors isNotEqualTo []) then {
            private _assignId = 0;
            if (_nextId >= 1000 && _nextId <= 9999 && {_endId <= 0 || _nextId <= _endId}) then {
                _assignId = _nextId;
                _nextId = _nextId + 1;
            };
            [_building, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation, _assignId, [], _accessMode] call FUNC(addDoorsZeusMain);
            _registeredCount = _registeredCount + 1;
        };
    } forEach _doorObjects;

    // Send feedback to user
    [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_SUCCESS", _registeredCount]] remoteExec ["zen_common_fnc_showMessage", _execUserId];
    [format ["Root Cyber Warfare: Registered %1 door(s) in %2m radius", _registeredCount, _radius]] remoteExec ["systemChat", _execUserId];
};

// Load device arrays from global storage (direct mode)
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;

private _isValidObject = false;
private _displayName = getText (configOf _targetObject >> "displayName");
private _typeofhackable = 1; // DEVICE_TYPE_DOOR
private _deviceId = 0;

// Store availability setting
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];
// Store "Allow Location View" so CLI/GUI can hide the grid when disabled (General #3).
_targetObject setVariable ["ROOT_CYBERWARFARE_ALLOW_LOCATION", _allowLocation, true];

// Check for buildings with doors
if (([_targetObject] call Root_fnc_detectBuildingDoors) isNotEqualTo []) then {
    _isValidObject = true;

    private _building = _targetObject;
    private _buildingDoors = [_building] call Root_fnc_detectBuildingDoors;

    if (_buildingDoors isNotEqualTo []) then {
        private _buildingNetId = netId _building;

        // Honour a caller-requested ID when it is free, otherwise draw a fresh unused one.
        private _usedIds = _allDoors apply { _x select 0 };
        _deviceId = [_requestedId, _usedIds] call FUNC(resolveDeviceId);

        // Build the per-door ID map: start from an identity map (custom == engine number) and apply any
        // caller overrides. Overrides that are non-numeric, non-positive, or duplicate another door's
        // custom ID fall back to that door's engine number so every door stays addressable.
        private _doorIdMap = [];
        private _usedCustom = [];
        {
            private _real = _x;
            private _custom = _real;
            {
                if ((_x select 0) == _real) exitWith {
                    private _override = _x select 1;
                    if (_override isEqualType 0 && {_override > 0} && {!(_override in _usedCustom)}) then {
                        _custom = _override;
                    };
                };
            } forEach _doorIdMapInput;
            _usedCustom pushBack _custom;
            _doorIdMap pushBack [_custom, _real];
        } forEach _buildingDoors;

        // Store unbreachable flag on building
        if (_makeUnbreachable) then {
            _building setVariable ["ROOT_CYBERWARFARE_UNBREACHABLE", true, true];
        };

        _allDoors pushBack [_deviceId, _buildingNetId, _buildingDoors, _displayName, _availableToFutureLaptops, _doorIdMap];
    };
};

if (!_isValidObject) exitWith {
    [format ["Object (%1) does not expose any door animations. Use fn_addLightsZeus for lights.", _targetObject]] remoteExec ["systemChat", _execUserId];
};

// Apply the requested reachability: private links, public registration, or nothing at all.
private _availabilityText = [_typeofhackable, _deviceId, _linkedComputers, _accessMode, _availableToFutureLaptops] call FUNC(applyDeviceAccess);


// Update global storage with modified device arrays
_allDevices set [0, _allDoors];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;
_targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];

private _unbreachableText = ["", " [UNBREACHABLE]"] select _makeUnbreachable;
[format ["Root Cyber Warfare: Building (%1) added (ID: %2)! %3.%4", _displayName, _deviceId, _availabilityText, _unbreachableText]] remoteExec ["systemChat", _execUserId];
