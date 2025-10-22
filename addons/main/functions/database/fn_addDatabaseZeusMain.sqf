#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Server-side function to add a hackable database/file to the network
 *
 * Arguments:
 * 0: _fileObject <OBJECT> - Object to store file data on
 * 1: _filename <STRING> - Name of the file
 * 2: _filesize <NUMBER> - Size of file (download time in seconds)
 * 3: _filecontent <STRING> - Content of the file
 * 4: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 5: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 6: _executionCode <STRING> (Optional) - Code to execute on download, default: ""
 * 7: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, "secret.txt", 10, "content", 0, [], "", false] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
 *
 * Public: No
 */

params ["_fileObject", "_filename", "_filesize", "_filecontent", ["_execUserId", 0], ["_linkedComputers", []], ["_executionCode", ""], ["_availableToFutureLaptops", false]];

if (_execUserId == 0) then {
    _execUserId = owner _fileObject;
};

// Load device arrays from global storage
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allDatabases = _allDevices select 3;

// Generate unique database ID
private _databaseId = (round (random 8999)) + 1000;
if (_allDatabases isNotEqualTo []) then {
    while {true} do {
        _databaseId = (round (random 8999)) + 1000;
        private _databaseIsNew = true;
        {
            if (_x select 0 == _databaseId) then {
                _databaseIsNew = false;
            };
        } forEach _allDatabases;
        if (_databaseIsNew) then {
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

// Update global storage with new database
_allDevices set [3, _allDatabases];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];

[format ["Root Cyber Warfare: File added with ID: %1. %2.", _databaseId, _availabilityText]] remoteExec ["systemChat", _execUserId];
