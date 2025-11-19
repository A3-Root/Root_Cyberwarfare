#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to add hackable building(s) (doors/lights) to the network.
 * This function ONLY handles doors and lights. For drones use fn_addVehicleZeusMain,
 * for custom devices use fn_addCustomDeviceZeusMain, for vehicles use fn_addVehicleZeusMain.
 *
 * DEPRECATED: This module is deprecated. Use fn_addDoorsZeusMain for buildings/doors or
 * fn_addLightsZeusMain for lights. This function remains for backward compatibility.
 *
 * Arguments:
 * DIRECT MODE (single object):
 * 0: _targetObject <OBJECT> - The building/light object to make hackable
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 4: _makeUnbreachable <BOOLEAN> (Optional) - Prevent non-hacking breaching methods (doors only), default: false
 *
 * RADIUS MODE (multiple objects):
 * 0: _centerPosition <ARRAY> - Position array [x, y, z] for search center
 * 1: _radius <NUMBER> - Search radius in meters
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 4: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 5: _makeUnbreachable <BOOLEAN> (Optional) - Prevent non-hacking breaching methods (doors only), default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_building, 0, [], false, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
 * [_lamp, 0, [], true, false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
 * [[100, 200, 0], 500, 0, [], true] remoteExec ["Root_fnc_addDeviceZeusMain", 2]; // Radius mode with position
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
    _makeUnbreachable = param [5, false, [false]];
} else {
    // Direct mode: object passed
    _radiusMode = false;
    _targetObject = _firstParam;
    _execUserId = param [1, 0, [0]];
    _linkedComputers = param [2, [], [[]]];
    _availableToFutureLaptops = param [3, false, [false]];
    _makeUnbreachable = param [4, false, [false]];
};

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

// Handle radius mode
if (_radiusMode) exitWith {
    // DEPRECATION WARNING
    ROOT_CYBERWARFARE_LOG_INFO("DEPRECATED: fn_addDeviceZeusMain is deprecated. Use fn_addDoorsZeusMain or fn_addLightsZeusMain instead.");

    private _registeredCount = 0;

    // Find all objects in radius and filter by type
    private _allObjects = nearestObjects [_centerPos, [], _radius];
    private _buildings = [];
    private _lights = [];

    // Filter objects into buildings and lights
    {
        if ((_x isKindOf "House") || (_x isKindOf "Building")) then {
            _buildings pushBack _x;
        };
        if (_x isKindOf "Lamps_base_F") then {
            _lights pushBack _x;
        };
    } forEach _allObjects;

    // Register each building
    {
        private _building = _x;
        // Check if building has doors by checking config
        private _config = configOf _building;
        private _simpleObjects = getArray (_config >> "SimpleObject" >> "animate");
        private _hasDoors = false;
        {
            if (count _x == 2) then {
                private _objectName = _x select 0;
                if (_objectName regexMatch "door_.*") exitWith {
                    _hasDoors = true;
                };
            };
        } forEach _simpleObjects;

        if (_hasDoors) then {
            [_building, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable] call FUNC(addDeviceZeusMain);
            _registeredCount = _registeredCount + 1;
        };
    } forEach _buildings;

    // Register each light
    {
        [_x, _execUserId, _linkedComputers, _availableToFutureLaptops, false] call FUNC(addDeviceZeusMain);
        _registeredCount = _registeredCount + 1;
    } forEach _lights;

    // Send feedback to user
    [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_SUCCESS", _registeredCount]] remoteExec ["zen_common_fnc_showMessage", _execUserId];
    [format ["Root Cyber Warfare: Registered %1 device(s) in %2m radius", _registeredCount, _radius]] remoteExec ["systemChat", _execUserId];
};

// Load device arrays from global storage (direct mode)
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;
private _allLamps = _allDevices select 1;

private _isValidObject = false;
private _netId = netId _targetObject;
private _displayName = getText (configOf _targetObject >> "displayName");
private _typeofhackable = 0;
private _deviceId = 0;

// Store availability setting
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];

// Check for buildings with doors
if (_targetObject isKindOf "House" || _targetObject isKindOf "Building") then {
    _isValidObject = true;

    private _buildingDoors = [];
    private _building = _targetObject;
    private _config = configOf _building;
    private _simpleObjects = getArray (_config >> "SimpleObject" >> "animate");
    {
        if (count _x == 2) then {
            private _objectName = _x select 0;
            if (_objectName regexMatch "door_.*") then {
                private _regexFinds = _objectName regexFind ["door_([0-9]+)"];
                private _doorNumber = parseNumber (((_regexFinds select 0) select 1) select 0);

                if (!(_doorNumber in _buildingDoors)) then {
                    if (_buildingDoors isEqualTo []) then {
                        _buildingDoors pushBack _doorNumber;
                    };
                    if ((_buildingDoors select -1) != _doorNumber) then {
                        _buildingDoors pushBack _doorNumber;
                    };
                };
            };
        };
    } forEach _simpleObjects;

    if (_buildingDoors isNotEqualTo []) then {
        private _buildingNetId = netId _building;

        _deviceId = (round (random 8999)) + 1000;
        if (count _allDoors > 0) then {
            while {true} do {
                _deviceId = (round (random 8999)) + 1000;
                private _buildingIsNew = true;
                {
                    if (_x select 0 == _deviceId) then {
                        _buildingIsNew = false;
                    };
                } forEach _allDoors;

                if (_buildingIsNew) then {
                    break;
                };
            };
        };
        _typeofhackable = 1;

        // Store unbreachable flag on building
        if (_makeUnbreachable) then {
            _building setVariable ["ROOT_CYBERWARFARE_UNBREACHABLE", true, true];
        };

        _allDoors pushBack [_deviceId, _buildingNetId, _buildingDoors, _displayName, _availableToFutureLaptops];
    };
};

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
    _typeofhackable = 2;
};

if (!_isValidObject) exitWith {
    [format ["Object (%1) is not a building or light! Use appropriate module for drones, vehicles, or custom devices.", _targetObject]] remoteExec ["systemChat", _execUserId];
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

private _excludedIdentifiers = [];
/// Handle public device access
if (_availableToFutureLaptops || _linkedComputers isEqualTo []) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

    DEBUG_LOG_2("Device setup mode: %1, Future laptops: %2",GET_DEVICE_MODE,_availableToFutureLaptops);

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario 4: Available to future + some linked
            // Exclude current laptops that are NOT linked
            DEBUG_LOG("Scenario 4: Excluding current non-linked computers");

            if (IS_EXPERIMENTAL_MODE) then {
                // Experimental mode: Collect player UIDs
                {
                    private _nearLaptops = nearestObjects [_x, [], 3] select {
                        _x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]
                    };
                    if (_nearLaptops isNotEqualTo []) then {
                        private _uid = getPlayerUID _x;
                        if !(_uid in _linkedComputers) then {
                            _excludedIdentifiers pushBack _uid;
                            DEBUG_LOG_2("Excluding player %1 (UID: %2)",name _x,_uid);
                        };
                    };
                } forEach allPlayers;
            } else {
                // Simple mode: Collect laptop netIds
                {
                    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                        private _netId = netId _x;
                        if !(_netId in _linkedComputers) then {
                            _excludedIdentifiers pushBack _netId;
                            DEBUG_LOG_1("Excluding laptop netId: %1",_netId);
                        };
                    };
                } forEach (24 allObjects 1);
            };

            _availabilityText = _availabilityText + format [" and all future computers"];
        } else {
            // Scenario 3: Available to future + no linked
            // Exclude ALL current laptops
            DEBUG_LOG("Scenario 3: Excluding all current computers");

            if (IS_EXPERIMENTAL_MODE) then {
                // Experimental mode: Collect player UIDs
                {
                    private _nearLaptops = nearestObjects [_x, [], 3] select {
                        _x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]
                    };
                    if (_nearLaptops isNotEqualTo []) then {
                        _excludedIdentifiers pushBack (getPlayerUID _x);
                        DEBUG_LOG_2("Excluding player %1 (UID: %2)",name _x,getPlayerUID _x);
                    };
                } forEach allPlayers;
            } else {
                // Simple mode: Collect laptop netIds
                {
                    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                        _excludedIdentifiers pushBack (netId _x);
                        DEBUG_LOG_1("Excluding laptop netId: %1",netId _x);
                    };
                } forEach (24 allObjects 1);
            };

            _availabilityText = "Available to future computers only.";
        };
    } else {
        // Scenario 1: Not available to future + no linked
        // No exclusions - all current laptops get access
        DEBUG_LOG("Scenario 1: All current computers get access");
        _availabilityText = format ["Available to all current computers only"];
    };

    DEBUG_LOG_1("Excluded identifiers: %1",_excludedIdentifiers);
    _publicDevices pushBack [_typeofhackable, _deviceId, _excludedIdentifiers];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};

// Update global storage with modified device arrays
_allDevices set [0, _allDoors];
_allDevices set [1, _allLamps];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];

switch (_typeofhackable) do {
    case 1: {
        private _unbreachableText = ["", " [UNBREACHABLE]"] select _makeUnbreachable;
        [format ["Root Cyber Warfare: Building (%1) added (ID: %2)! %3.%4", _displayName, _deviceId, _availabilityText, _unbreachableText]] remoteExec ["systemChat", _execUserId];
    };
    case 2: {
        [format ["Root Cyber Warfare: Light (%2) Added! ID: %1. %3.", _deviceId, _displayName, _availabilityText]] remoteExec ["systemChat", _execUserId];
    };
    default {
        [format ["ERROR! Bad Value: '_typeofhackable' in 'Root_fnc_addDeviceZeusMain'"]] remoteExec ["systemChat", _execUserId];
    };
};
