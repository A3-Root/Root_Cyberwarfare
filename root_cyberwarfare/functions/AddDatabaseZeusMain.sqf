params ["_allDatabases", "_databaseId", "_fileObject", "_filename", "_filesize", "_filecontent", "_allDevices", "_allDoors", "_allLamps", "_allDrones", "_allCustom", ["_execUserId", 0], ["_linkedComputers", []], ["_executionCode", ""], ["_availableToFutureLaptops", false]];

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
_allDatabases pushback [_databaseId, netId _fileObject, _linkedComputers, _availableToFutureLaptops];
_fileObject setVariable ["ROOT_DatabaseName_Edit", _filename, true];
_fileObject setVariable ["ROOT_DatabaseSize_Edit", _filesize, true];
_fileObject setVariable ["ROOT_DatabaseData_Edit", _filecontent, true];
_fileObject setVariable ["ROOT_DatabaseExecutionCode", _executionCode, true];
_fileObject setVariable ["ROOT_AvailableToFutureLaptops", _availableToFutureLaptops, true];

private _availabilityText = "";

// Store database linking information (for selected computers)
if (count _linkedComputers > 0) then {
    private _deviceLinks = missionNamespace getVariable ["ROOT-Device-Links", []];
    
    {
        private _computerNetId = _x;
        private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
        
        if (count _existingLinks == 0) then {
            _deviceLinks pushBack [_computerNetId, [[4, _databaseId]]]; // 4 = database type
        } else {
            private _index = _deviceLinks find (_existingLinks select 0);
            private _devices = (_deviceLinks select _index) select 1;
            _devices pushBack [4, _databaseId]; // 4 = database type
            _deviceLinks set [_index, [_computerNetId, _devices]];
        };
    } forEach _linkedComputers;

    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
    missionNamespace setVariable ["ROOT-Device-Links", _deviceLinks, true];
};

// Handle public device access
if ((_availableToFutureLaptops) || (count _linkedComputers == 0)) then {
    private _publicDevices = missionNamespace getVariable ["ROOT-Public-Devices", []];
    private _excludedNetIds = [];

    if (_availableToFutureLaptops) then {
        if (count _linkedComputers > 0) then {
            // Scenario: Available to future + some linked            
            _availabilityText = format ["Accessible by %1 linked computer(s) and all future computers", count _linkedComputers];
        } else {
            // Scenario: Available to future + no linked
            // Exclude ALL current laptops - only future ones get access
            private _allHackingLaptops = allObjects select {_x getVariable ["ROOT_HackingTools", false]};
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
    missionNamespace setVariable ["ROOT-Public-Devices", _publicDevices, true];
};

private _existingDevices = missionNamespace getVariable ["ROOT-All-Devices", [[], [], [], [], []]];
_existingDevices set [0, _allDoors];
_existingDevices set [1, _allLamps];
_existingDevices set [2, _allDrones];
_existingDevices set [3, _allDatabases];
_existingDevices set [4, _allCustom];

missionNamespace setVariable ["ROOT-All-Devices", _existingDevices, true];

[format ["Root Cyber Warfare: File added with ID: %1. %2.", _databaseId, _availabilityText]] remoteExec ["systemChat", _execUserId];