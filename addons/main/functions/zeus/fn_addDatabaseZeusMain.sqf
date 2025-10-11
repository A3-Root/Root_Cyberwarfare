#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Server-side function to add a hackable database/file to the network
 *
 * Arguments:
 * 0: _allDatabases <ARRAY> - Current database array
 * 1: _databaseId <NUMBER> - Database ID (will be regenerated)
 * 2: _fileObject <OBJECT> - Object to store file data on
 * 3: _filename <STRING> - Name of the file
 * 4: _filesize <NUMBER> - Size of file (download time in seconds)
 * 5: _filecontent <STRING> - Content of the file
 * 6: _allDevices <ARRAY> - Current devices array
 * 7: _allDoors <ARRAY> - Current doors array
 * 8: _allLamps <ARRAY> - Current lamps array
 * 9: _allDrones <ARRAY> - Current drones array
 * 10: _allCustom <ARRAY> - Current custom devices array
 * 11: _allGpsTrackers <ARRAY> - Current GPS trackers array
 * 12: _allVehicles <ARRAY> - Current vehicles array
 * 13: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 14: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 15: _executionCode <STRING> (Optional) - Code to execute on download, default: ""
 * 16: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_databases, 0, _obj, "secret.txt", 10, "content", _devices, ...] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
 *
 * Public: No
 */

params ["_allDatabases", "_databaseId", "_fileObject", "_filename", "_filesize", "_filecontent", "_allDevices", "_allDoors", "_allLamps", "_allDrones", "_allCustom", "_allGpsTrackers", "_allVehicles", ["_execUserId", 0], ["_linkedComputers", []], ["_executionCode", ""], ["_availableToFutureLaptops", false]];

if (_execUserId == 0) then {
    _execUserId = owner _fileObject;
};

_databaseId = (round (random 8999)) + 1000;
if (count _allDatabases > 0) then {
    while {true} do {
        _databaseId = (round (random 8999)) + 1000;
        private _databaseIsNew = true;
        {
            if(_x select 0 == _databaseId) then {
                _databaseIsNew = false;
            };
        } forEach _allDatabases;
        if(_databaseIsNew) then {
            break;
        };
    };
};

// Store database variables
_allDatabases pushBack [_databaseId, netId _fileObject, _filename, _filesize, _linkedComputers, _availableToFutureLaptops];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", _filename, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_SIZE_EDIT", _filesize, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_DATA_EDIT", _filecontent, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_EXECUTIONCODE", _executionCode, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];

private _availabilityText = "";

// Store database linking information (for selected computers)
if (_linkedComputers isNotEqualTo []) then {
    // Update new hashmap-based link cache
    private _linkCache = GET_LINK_CACHE;

    {
        private _computerNetId = _x;
        private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
        _existingLinks pushBack [4, _databaseId]; // 4 = database type
        _linkCache set [_computerNetId, _existingLinks];
    } forEach _linkedComputers;

    missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];
    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
};

private _excludedNetIds = [];
// Handle public device access
if ((_availableToFutureLaptops) || (count _linkedComputers == 0)) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario: Available to future + some linked            
            _availabilityText = format ["Accessible by %1 linked computer(s) and all future computers", count _linkedComputers];
        } else {
            // Scenario: Available to future + no linked
            // Exclude ALL current laptops - only future ones get access
            private _allObjects = 24 allObjects 1; // All objects
            private _allHackingLaptops = _allObjects select {_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]};
            {
                _excludedNetIds pushBack (netId _x);
            } forEach _allHackingLaptops;
            _availabilityText = "Available to future computers only";
        };
    } else {
        // Scenario: Not available to future + no linked
        // No exclusions - all current laptops get access
        _availabilityText = "Available to all current computers";
    };

    // Store [type, id, excludedNetIds] 
    _publicDevices pushBack [4, _databaseId, _excludedNetIds]; // 4 = database type
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};

private _existingDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
_existingDevices set [0, _allDoors];
_existingDevices set [1, _allLamps];
_existingDevices set [2, _allDrones];
_existingDevices set [3, _allDatabases];
_existingDevices set [4, _allCustom];
_existingDevices set [5, _allGpsTrackers];
_existingDevices set [6, _allVehicles];

missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _existingDevices, true];

[format ["Root Cyber Warfare: File added with ID: %1. %2.", _databaseId, _availabilityText]] remoteExec ["systemChat", _execUserId];
