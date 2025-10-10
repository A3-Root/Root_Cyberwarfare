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
    private _deviceLinks = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", []];
    
    {
        private _computerNetId = _x;
        private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
        
        if (_existingLinks isEqualTo []) then {
            _deviceLinks pushBack [_computerNetId, [[4, _databaseId]]]; // 4 = database type
        } else {
            private _index = _deviceLinks find (_existingLinks select 0);
            private _devices = (_deviceLinks select _index) select 1;
            _devices pushBack [4, _databaseId]; // 4 = database type
            _deviceLinks set [_index, [_computerNetId, _devices]];
        };
    } forEach _linkedComputers;

    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", _deviceLinks, true];
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
