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
 * 8: _isEncrypted <BOOLEAN> (Optional) - Encrypt stored content, default: false
 * 9: _encryptionAlgorithm <STRING> (Optional) - Cipher algorithm, default: "morse"
 * 10: _encryptionKey <STRING> (Optional) - Primary key or variant, default: ""
 * 11: _encryptionOptions <STRING|HASHMAP> (Optional) - Additional cipher options, default: ""
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, "secret.txt", 10, "content", 0, [], "", false, true, "rot", "rot13"] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
 *
 * Public: No
 */

params [
    "_fileObject",
    "_filename",
    "_filesize",
    "_filecontent",
    ["_execUserId", 0],
    ["_linkedComputers", []],
    ["_executionCode", ""],
    ["_availableToFutureLaptops", false],
    ["_isEncrypted", false],
    ["_encryptionAlgorithm", "morse"],
    ["_encryptionKey", ""],
    ["_encryptionOptions", ""]
];

if (_execUserId == 0) then {
    _execUserId = owner _fileObject;
};

if (_isEncrypted) then {
    private _cipherOptions = [_encryptionKey, _encryptionOptions] call FUNC(cipherOptionsFromText);
    private _encryptedContent = [_encryptionAlgorithm, "encrypt", _filecontent, _cipherOptions] call FUNC(cipherProcess);
    if (_encryptedContent isEqualType "") then {
        _filecontent = _encryptedContent;
    };
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
    // Add the private [type, id] link to each selected computer through the shared atomic helper.
    [_linkedComputers, DEVICE_TYPE_DATABASE, _databaseId] call FUNC(addComputerDeviceLinks);
    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
};

private _excludedIdentifiers = [];
// Handle public device access
if ((_availableToFutureLaptops) || (count _linkedComputers == 0)) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

    DEBUG_LOG_2("Device setup mode: %1, Future laptops: %2",GET_DEVICE_MODE,_availableToFutureLaptops);

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario: Available to future + some linked
            DEBUG_LOG("Available to future + some linked computers");
            _availabilityText = format ["Accessible by %1 linked computer(s) and all future computers", count _linkedComputers];
        } else {
            // Scenario: Available to future + no linked
            // Exclude ALL current laptops - only future ones get access
            DEBUG_LOG("Scenario 3: Excluding all current computers");

            if (IS_EXPERIMENTAL_MODE) then {
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
                private _allObjects = 24 allObjects 1;
                private _allHackingLaptops = _allObjects select {_x getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]};
                {
                    _excludedIdentifiers pushBack (netId _x);
                    DEBUG_LOG_1("Excluding laptop netId: %1",netId _x);
                } forEach _allHackingLaptops;
            };

            _availabilityText = "Available to future computers only";
        };
    } else {
        // Scenario: Not available to future + no linked
        // No exclusions - all current laptops get access
        DEBUG_LOG("Scenario 1: All current computers get access");
        _availabilityText = "Available to all current computers";
    };

    DEBUG_LOG_1("Excluded identifiers: %1",_excludedIdentifiers);
    // Store [type, id, excludedIdentifiers]
    _publicDevices pushBack [4, _databaseId, _excludedIdentifiers]; // 4 = database type
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};

// Update global storage with new database
_allDevices set [3, _allDatabases];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;

[format ["Root Cyber Warfare: File added with ID: %1. %2.", _databaseId, _availabilityText]] remoteExec ["systemChat", _execUserId];
