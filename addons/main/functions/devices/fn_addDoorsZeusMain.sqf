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
 *
 * RADIUS MODE (multiple objects):
 * 0: _centerPosition <ARRAY> - Position array [x, y, z] for search center
 * 1: _radius <NUMBER> - Search radius in meters
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 4: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 5: _makeUnbreachable <BOOLEAN> (Optional) - Prevent non-hacking breaching methods, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_building, 0, [], false, false] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
 * [[100, 200, 0], 500, 0, [], true, false] remoteExec ["Root_fnc_addDoorsZeusMain", 2]; // Radius mode
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
    _allowLocation = param [6, true, [false]];
} else {
    // Direct mode: object passed
    _radiusMode = false;
    _targetObject = _firstParam;
    _execUserId = param [1, 0, [0]];
    _linkedComputers = param [2, [], [[]]];
    _availableToFutureLaptops = param [3, false, [false]];
    _makeUnbreachable = param [4, false, [false]];
    _allowLocation = param [5, true, [false]];
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

    // Register each door-bearing object
    {
        private _building = _x;
        private _detectedDoors = [_building] call Root_fnc_detectBuildingDoors;

        if (_detectedDoors isNotEqualTo []) then {
            [_building, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation] call FUNC(addDoorsZeusMain);
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

        // Store unbreachable flag on building
        if (_makeUnbreachable) then {
            _building setVariable ["ROOT_CYBERWARFARE_UNBREACHABLE", true, true];
        };

        _allDoors pushBack [_deviceId, _buildingNetId, _buildingDoors, _displayName, _availableToFutureLaptops];
    };
};

if (!_isValidObject) exitWith {
    [format ["Object (%1) does not expose any door animations. Use fn_addLightsZeus for lights.", _targetObject]] remoteExec ["systemChat", _execUserId];
};

private _availabilityText = "";

// Store device linking information (for selected computers)
if (_linkedComputers isNotEqualTo []) then {
    // Add the private [type, id] link to each selected computer through the shared atomic helper.
    [_linkedComputers, _typeofhackable, _deviceId] call FUNC(addComputerDeviceLinks);
    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
};

private _excludedIdentifiers = [];
// Handle public device access
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
                        _x getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]
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
                    if (_x getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]) then {
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
                        _x getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]
                    };
                    if (_nearLaptops isNotEqualTo []) then {
                        _excludedIdentifiers pushBack (getPlayerUID _x);
                        DEBUG_LOG_2("Excluding player %1 (UID: %2)",name _x,getPlayerUID _x);
                    };
                } forEach allPlayers;
            } else {
                // Simple mode: Collect laptop netIds
                {
                    if (_x getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]) then {
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
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;
_targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];

private _unbreachableText = ["", " [UNBREACHABLE]"] select _makeUnbreachable;
[format ["Root Cyber Warfare: Building (%1) added (ID: %2)! %3.%4", _displayName, _deviceId, _availabilityText, _unbreachableText]] remoteExec ["systemChat", _execUserId];
