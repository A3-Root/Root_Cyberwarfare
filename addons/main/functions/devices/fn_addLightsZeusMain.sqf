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
 *
 * RADIUS MODE (multiple objects):
 * 0: _centerPosition <ARRAY> - Position array [x, y, z] for search center
 * 1: _radius <NUMBER> - Search radius in meters
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 4: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_lamp, 0, [], true] remoteExec ["Root_fnc_addLightsZeusMain", 2];
 * [[100, 200, 0], 500, 0, [], true] remoteExec ["Root_fnc_addLightsZeusMain", 2]; // Radius mode
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
} else {
    // Direct mode: object passed
    _radiusMode = false;
    _targetObject = _firstParam;
    _execUserId = param [1, 0, [0]];
    _linkedComputers = param [2, [], [[]]];
    _availableToFutureLaptops = param [3, false, [false]];
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

    // Register each light
    {
        [_x, _execUserId, _linkedComputers, _availableToFutureLaptops] call FUNC(addLightsZeusMain);
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

// Check for lamps/lights
if (_targetObject isKindOf "Lamps_base_F") then {
    _isValidObject = true;
    _deviceId = (round (random 8999)) + 1000;
    if (count _allLamps > 0) then {
        while {true} do {
            _deviceId = (round (random 8999)) + 1000;
            private _lampIsNew = true;
            {
                if (_x select 0 == _deviceId) then {
                    _lampIsNew = false;
                };
            } forEach _allLamps;
            if (_lampIsNew) then { break };
        };
    };
    _allLamps pushBack [_deviceId, _netId, _displayName, _availableToFutureLaptops];
};

if (!_isValidObject) exitWith {
    [format ["Object (%1) is not a light! Use fn_addDoorsZeus for buildings.", _targetObject]] remoteExec ["systemChat", _execUserId];
};

private _availabilityText = "";

// Store device linking information (for selected computers)
if (_linkedComputers isNotEqualTo []) then {
    // Update new hashmap-based link cache
    private _linkCache = GET_LINK_CACHE;

    {
        private _computerNetId = _x;
        private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
        _existingLinks pushBack [_typeofhackable, _deviceId];
        _linkCache set [_computerNetId, _existingLinks];
    } forEach _linkedComputers;

    missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];
    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
};

private _excludedNetIds = [];
// Handle public device access
if (_availableToFutureLaptops || _linkedComputers isEqualTo []) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario 4: Available to future + some linked
            // Exclude current laptops that are NOT linked
            {
                if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                    private _netId = netId _x;
                    if !(_netId in _linkedComputers) then {
                        _excludedNetIds pushBack _netId;
                    };
                };
            } forEach (24 allObjects 1);

            _availabilityText = _availabilityText + format [" and all future computers"];
        } else {
            // Scenario 3: Available to future + no linked
            // Exclude ALL current laptops
            {
                if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                    _excludedNetIds pushBack (netId _x);
                };
            } forEach (24 allObjects 1);
            _availabilityText = "Available to future computers only.";
        };
    } else {
        // Scenario 1: Not available to future + no linked
        // No exclusions - all current laptops get access
        _availabilityText = format ["Available to all current computers only"];
    };

    _publicDevices pushBack [_typeofhackable, _deviceId, _excludedNetIds];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};

// Update global storage with modified device arrays
_allDevices set [1, _allLamps];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];

[format ["Root Cyber Warfare: Light (%2) Added! ID: %1. %3.", _deviceId, _displayName, _availabilityText]] remoteExec ["systemChat", _execUserId];
