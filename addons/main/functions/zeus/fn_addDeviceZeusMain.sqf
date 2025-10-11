#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to add a hackable device to the network
 *
 * Arguments:
 * 0: _targetObject <OBJECT> - The object to make hackable
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _treatAsCustom <BOOLEAN> (Optional) - Treat as custom device, default: false
 * 4: _customName <STRING> (Optional) - Custom device name, default: ""
 * 5: _activationCode <STRING> (Optional) - Code to run on activation, default: ""
 * 6: _deactivationCode <STRING> (Optional) - Code to run on deactivation, default: ""
 * 7: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], true, "Generator", "", "", false] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
 *
 * Public: No
 */

params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], ["_treatAsCustom", false], ["_customName", ""], ["_activationCode", ""], ["_deactivationCode", ""], ["_availableToFutureLaptops", false]];

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

private _doorCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DOOR_EDIT", 2];
private _droneSideCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT", 20];
private _droneDestructionCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT", 10];
private _customCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_CUSTOM_EDIT", 10];

missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;
private _allLamps = _allDevices select 1;
private _allDrones = _allDevices select 2;
private _allDatabases = _allDevices select 3;
private _allCustom = _allDevices select 4;
private _allGpsTrackers = _allDevices select 5;
private _allVehicles = _allDevices select 6;
private _isCustomObject = false;

private _netId = netId _targetObject;

private _existingDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];

private _displayName = getText (configOf _targetObject >> "displayName");

private _typeofhackable = 0;
private _deviceId = 0;

// Store activation/deactivation code for ALL objects
_targetObject setVariable ["ROOT_CYBERWARFARE_ACTIVATIONCODE", _activationCode, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_DEACTIVATIONCODE", _deactivationCode, true];

// Store availability setting
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];

if (_treatAsCustom) then {
    // Treat as custom device
    _isCustomObject = true;
    _deviceId = (round (random 8999)) + 1000;
    if (count _allCustom > 0) then {
        while {true} do {
            _deviceId = (round (random 8999)) + 1000;
            private _customIsNew = true;
            {
                if (_x select 0 == _deviceId) then {
                    _customIsNew = false;
                };
            } forEach _allCustom;
            if (_customIsNew) then { break };
        };
    };
    
    // Store with availability flag
    _allCustom pushBack [_deviceId, _netId, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops];
    _typeofhackable = 5; // Custom device type
} else {
    // Existing logic for standard objects
    if (_targetObject isKindOf "House" || _targetObject isKindOf "Building") then {
        _isCustomObject = true;

        private _buildingDoors = [];
        private _building = _targetObject;
        // private _config = configFile >> "CfgVehicles" >> typeOf _building;
        private _config = configOf _building;
        private _simpleObjects = getArray (_config >> "SimpleObject" >> "animate");
        {
            if(count _x == 2) then {
                private _objectName = _x select 0;
                if(_objectName regexMatch "door_.*") then {
                    private _regexFinds = _objectName regexFind ["door_([0-9]+)"];
                    private _doorNumber = parseNumber (((_regexFinds select 0) select 1) select 0);

                    if(!(_doorNumber in _buildingDoors)) then {
                        if(_buildingDoors isEqualTo []) then {
                            _buildingDoors pushBack _doorNumber;
                        };
                        if((_buildingDoors select -1) != _doorNumber) then {
                            _buildingDoors pushBack _doorNumber;
                        };
                    };
                };
            };
        } forEach _simpleObjects;

        if(_buildingDoors isNotEqualTo []) then {
            private _buildingNetId = netId _building;

            _deviceId = (round (random 8999)) + 1000;
            if (count _allDoors > 0) then {
                while {true} do {
                    _deviceId = (round (random 8999)) + 1000;
                    private _buildingIsNew = true;
                    {
                        if(_x select 0 == _deviceId) then {
                            _buildingIsNew = false;
                        };
                    } forEach _allDoors;

                    if(_buildingIsNew) then {
                        break;
                    };
                };
            };
            _typeofhackable = 1;
            _allDoors pushBack [_deviceId, _buildingNetId, _buildingDoors, _linkedComputers, _activationCode, _deactivationCode, _availableToFutureLaptops];
        };
    };

    if (_targetObject isKindOf "Lamps_base_F") then {
        _isCustomObject = true;
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
        _allLamps pushBack [_deviceId, _netId, _linkedComputers, _activationCode, _deactivationCode, _availableToFutureLaptops];
        _typeofhackable = 2;    
    };

    if (unitIsUAV _targetObject) then {
        _isCustomObject = true;
        _deviceId = (round (random 8999)) + 1000;
        if (count _allDrones > 0) then {
            while {true} do {
                _deviceId = (round (random 8999)) + 1000;
                private _droneIsNew = true;
                {
                    if (_x select 0 == _deviceId) then {
                        _droneIsNew = false;
                    };
                } forEach _allDrones;

                if(_droneIsNew) then {
                    break;
                };
            };
        };
        _allDrones pushBack [_deviceId, _netId, _linkedComputers, _activationCode, _deactivationCode, _availableToFutureLaptops];
        _typeofhackable = 3;
    };
};

if (!_isCustomObject) exitWith {
    [format ["Object (%1) is not compatible for hacking!", _targetObject]] remoteExec ["systemChat", _execUserId];
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
/// Handle public device access
if (_availableToFutureLaptops || count _linkedComputers == 0) then {
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

_existingDevices set [0, _allDoors];
_existingDevices set [1, _allLamps];
_existingDevices set [2, _allDrones];
_existingDevices set [3, _allDatabases];
_existingDevices set [4, _allCustom];
_existingDevices set [5, _allGpsTrackers];
_existingDevices set [6, _allVehicles];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _existingDevices, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];


switch (_typeofhackable) do {
    case 1: {
        [format ["Root Cyber Warfare: Building (%1) added (ID: %2)! %3.", _displayName, _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];
    };
    case 2: {
        [format ["Root Cyber Warfare: Light (%2) Added! ID: %1. %3.", _deviceId, _displayName, _availabilityText]] remoteExec ["systemChat", _execUserId];
    };
    case 3: {
        [format ["Root Cyber Warfare: Drone (%2) Added! ID: %1. %3.", _deviceId, _displayName, _availabilityText]] remoteExec ["systemChat", _execUserId];
    };
    case 5: {
        [format ["Root Cyber Warfare: Custom device '%1' added (ID: %2). %3.", _customName, _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];
    };
    default {
        [format ["ERROR! Bad Value: '_typeofhackable' in 'Root_fnc_addDeviceZeusMain'"]] remoteExec ["systemChat", _execUserId];
    };
};
