#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to add hackable lights to the network.
 * For doors use fn_addDoorsZeusMain, for drones use fn_addVehicleZeusMain,
 * for custom devices use fn_addCustomDeviceZeusMain.
 *
 * Arguments:
 * DIRECT MODE (single object):
 * 0: _targetObject <OBJECT> - The light object to make hackable
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 4: _allowLocation <BOOLEAN> (Optional) - Show grid location on the laptop, default: true
 * 5: _requestedId <NUMBER> (Optional) - Desired light ID (0 = auto-assign), default: 0
 * 6: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * RADIUS MODE (multiple objects):
 * 0: _centerPosition <ARRAY> - Position array [x, y, z] for search center
 * 1: _radius <NUMBER> - Search radius in meters
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 4: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 5: _allowLocation <BOOLEAN> (Optional) - Show grid location on the laptop, default: true
 * 6: _startId <NUMBER> (Optional) - First light ID handed out across the area (0 = auto), default: 0
 * 7: _endId <NUMBER> (Optional) - Last light ID handed out across the area (0 = auto), default: 0
 * 8: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * Return Value:
 * None
 *
 * Example:
 * [_lamp, 0, [], true, true, 0, ACCESS_MODE_PUBLIC] remoteExec ["Root_fnc_addLightsZeusMain", 2];
 * [[100, 200, 0], 500, 0, [], true, true, 0, 0, ACCESS_MODE_LINKED] remoteExec ["Root_fnc_addLightsZeusMain", 2]; // Radius mode
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
private _allowLocation = true; // "Allow Location View" (General #3); default on
private _requestedId = 0;      // Desired light ID for direct mode (0 = auto)
private _startId = 0;          // First ID handed out across a radius sweep
private _endId = 0;            // Last ID handed out across a radius sweep
private _accessMode = ACCESS_MODE_UNASSIGNED; // How the registered lights may be reached

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
    _allowLocation = param [5, true, [false]];
    _startId = param [6, 0, [0]];
    _endId = param [7, 0, [0]];
    _accessMode = param [8, ACCESS_MODE_UNASSIGNED, [0]];
} else {
    // Direct mode: object passed
    _radiusMode = false;
    _targetObject = _firstParam;
    _execUserId = param [1, 0, [0]];
    _linkedComputers = param [2, [], [[]]];
    _availableToFutureLaptops = param [3, false, [false]];
    _allowLocation = param [4, true, [false]];
    _requestedId = param [5, 0, [0]];
    _accessMode = param [6, ACCESS_MODE_UNASSIGNED, [0]];
};

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

// Handle radius mode
if (_radiusMode) exitWith {
    private _registeredCount = 0;

    // Find all objects in radius and filter by type
    private _allObjects = nearestObjects [_centerPos, [], _radius];
    private _lights = [];

    // Filter objects into lights only
    {
        if (_x isKindOf "Lamps_base_F") then {
            _lights pushBack _x;
        };
    } forEach _allObjects;

    // Hand out sequential IDs from the requested start across the found lights; once the range is
    // exhausted (or none was given) the remaining lights fall back to auto-assignment.
    private _nextId = _startId;

    // Register each light
    {
        private _assignId = 0;
        if (_nextId >= 1000 && _nextId <= 9999 && {_endId <= 0 || _nextId <= _endId}) then {
            _assignId = _nextId;
            _nextId = _nextId + 1;
        };
        [_x, _execUserId, _linkedComputers, _availableToFutureLaptops, _allowLocation, _assignId, _accessMode] call FUNC(addLightsZeusMain);
        _registeredCount = _registeredCount + 1;
    } forEach _lights;

    // Send feedback to user
    [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_SUCCESS", _registeredCount]] remoteExec ["zen_common_fnc_showMessage", _execUserId];
    [format ["Root Cyber Warfare: Registered %1 light(s) in %2m radius", _registeredCount, _radius]] remoteExec ["systemChat", _execUserId];
};

// Load device arrays from global storage (direct mode)
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allLamps = _allDevices select 1;

private _isValidObject = false;
private _netId = netId _targetObject;
private _displayName = getText (configOf _targetObject >> "displayName");
private _typeofhackable = 2; // DEVICE_TYPE_LIGHT
private _deviceId = 0;

// Store availability setting
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_ALLOW_LOCATION", _allowLocation, true]; // General #3

// Check for lamps/lights
if (_targetObject isKindOf "Lamps_base_F") then {
    _isValidObject = true;
    // Honour a caller-requested ID when free, otherwise draw a fresh unused one.
    private _usedIds = _allLamps apply { _x select 0 };
    _deviceId = [_requestedId, _usedIds] call FUNC(resolveDeviceId);
    _allLamps pushBack [_deviceId, _netId, _displayName, _availableToFutureLaptops];
};

if (!_isValidObject) exitWith {
    [format ["Object (%1) is not a light! Use fn_addDoorsZeus for buildings.", _targetObject]] remoteExec ["systemChat", _execUserId];
};

// Apply the requested reachability: private links, public registration, or nothing at all.
private _availabilityText = [_typeofhackable, _deviceId, _linkedComputers, _accessMode, _availableToFutureLaptops] call FUNC(applyDeviceAccess);

// Update global storage with modified device arrays
_allDevices set [1, _allLamps];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;
_targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];

[format ["Root Cyber Warfare: Light (%2) Added! ID: %1. %3.", _deviceId, _displayName, _availabilityText]] remoteExec ["systemChat", _execUserId];
