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
 * 12: _requestedId <NUMBER> (Optional) - Fixed device id, 0 = auto-assign, default: 0
 * 13: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, "secret.txt", 10, "content", 0, [], "", false, true, "rot", "rot13", "", 0, ACCESS_MODE_PUBLIC] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
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
    ["_encryptionOptions", ""],
    ["_requestedId", 0],
    ["_accessMode", ACCESS_MODE_UNASSIGNED, [0]]
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

// Honour a caller-requested ID when free, otherwise draw a fresh unused one.
private _databaseId = [_requestedId, _allDatabases apply { _x select 0 }] call FUNC(resolveDeviceId);

// Store database variables
_allDatabases pushBack [_databaseId, netId _fileObject, _filename, _filesize, _linkedComputers, _availableToFutureLaptops];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", _filename, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_SIZE_EDIT", _filesize, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_DATA_EDIT", _filecontent, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_DATABASE_EXECUTIONCODE", _executionCode, true];
_fileObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];

// Apply the requested reachability: private links, public registration, or nothing at all.
private _availabilityText = [DEVICE_TYPE_DATABASE, _databaseId, _linkedComputers, _accessMode, _availableToFutureLaptops] call FUNC(applyDeviceAccess);

// Update global storage with new database
_allDevices set [3, _allDatabases];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;

[format ["Root Cyber Warfare: File added with ID: %1. %2.", _databaseId, _availabilityText]] remoteExec ["systemChat", _execUserId];
