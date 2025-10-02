private ["_logic"];

private _module = _this select 0;
private _center = getPos _module;

private _string = "";

private _allDoors = [];
private _allLamps = [];
private _allDrones = [];
private _allDatabases = [];
private _allCustom = [];

private _typeofhackable = 0;
private _linkedComputers = [];
private _allComputers = [];

// Get all existing computers with hacking tools at mission start
{
    if (_x getVariable ["ROOT_HackingTools", false]) then {
        _allComputers pushBack (netId _x);
    };
} forEach (allMissionObjects "All");

private _syncedTriggers = synchronizedObjects _module select { _x isKindOf "EmptyDetector" }; 
private _allObjects = createHashMap;
{
    private _trigger = _x;
    private _pos = getPosATL _trigger;
    private _sizeX = triggerArea _trigger select 0;
    private _sizeY = triggerArea _trigger select 1;
    private _angle = triggerArea _trigger select 2;
    private _isRectangle = triggerArea _trigger select 3;

    if(_sizeX == 0 && _sizeY == 0) then {
        private _customName = vehicleVarName _x;
        _allCustom pushBack [_customName, netId _x];
        _x setTriggerActivation ["NONE", "PRESENT", true];
        _x setTriggerArea [worldSize, worldSize, 0, true];
        _x setPos [worldSize/2, worldSize/2, 0];
    } else {
        private _objectsInTrigger = [];
        private _entitiesInTrigger = [];

        if (_isRectangle) then {
            _objectsInTrigger = nearestObjects [_pos, [], (_sizeX max _sizeY)];
            {
                if (_x inArea [_pos, _sizeX, _sizeY, _angle, _isRectangle]) then {
                    _allObjects set [str _x, _x];
                };
            } forEach _objectsInTrigger;
            _entitiesInTrigger = _pos nearEntities (_sizeX max _sizeY);
            {
                if (_x inArea [_pos, _sizeX, _sizeY, _angle, _isRectangle]) then {
                    _allObjects set [str _x, _x];
                };
            } forEach _entitiesInTrigger;
        } else {
            _objectsInTrigger = nearestObjects [_pos, [], _sizeX];
            { _allObjects set [str _x, _x]; } forEach _objectsInTrigger;

            _entitiesInTrigger = _pos nearEntities (_sizeX max _sizeY);
            { _allObjects set [str _x, _x]; } forEach _entitiesInTrigger;
        };
    };
} forEach _syncedTriggers;
private _uniqueObjects = values _allObjects;

private _buildings = _uniqueObjects select {_x isKindOf "House" || _x isKindOf "Building"};
private _lamps = _uniqueObjects select {_x isKindOf "Lamps_base_F"};
private _drones = _uniqueObjects select {unitIsUAV _x};

{
    private _buildingDoors = [];

    private _building = _x;
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

        private _buildingId = 0;
        while {true} do {
            _buildingId = (round (random 8999)) + 1000;
            private _buildingIsNew = true;
            {
                if(_x select 0 == _buildingId) then {
                    _buildingIsNew = false;
                };
            } forEach _allDoors;

            if(_buildingIsNew) then {
                break;
            };
        };
        _typeofhackable = 1;

        // Link to all computers if any exist
        _allDoors pushBack [_buildingId, _buildingNetId, _buildingDoors, _allComputers];
    };

} forEach _buildings;

for "_i" from 0 to ((count _lamps) - 1) do {
    // Link to all computers if any exist
    _allLamps pushBack [_i + 1, netId (_lamps select _i), _allComputers];
};

{
    private _droneId = 0;
    while {true} do {
        _droneId = (round (random 8999)) + 1000;
        private _droneIsNew = true;
        {
            if(_x select 0 == _droneId) then {
                _droneIsNew = false;
            };
        } forEach _allDrones;

        if(_droneIsNew) then {
            break;
        };
    };

    // Link to all computers if any exist
    _allDrones pushBack [_droneId, netId _x, _allComputers];
} forEach _drones;

private _syncedDatabases = synchronizedObjects _module select { _x isKindOf "Root_CyberWarfareAddDatabase" };
{
    private _databaseId = 0;
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

    // Link to all computers if any exist
    _allDatabases pushBack [_databaseId, netId _x, _allComputers];
} forEach _syncedDatabases;

// Handle device linking for all devices to all computers
if (_allComputers isNotEqualTo []) then {
    private _deviceLinks = missionNamespace getVariable ["ROOT-Device-Links", []];
    
    // Process doors (type 1)
    {
        _x params ["_deviceId", "_buildingNetId", "_buildingDoors", "_linkedComputers"];
        {
            private _computerNetId = _x;
            private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
            
            if (_existingLinks isEqualTo []) then {
                _deviceLinks pushBack [_computerNetId, [[1, _deviceId]]];
            } else {
                private _index = _deviceLinks find (_existingLinks select 0);
                private _devices = (_deviceLinks select _index) select 1;
                _devices pushBack [1, _deviceId];
                _deviceLinks set [_index, [_computerNetId, _devices]];
            };
        } forEach _allComputers;
    } forEach _allDoors;
    
    // Process lamps (type 2)
    {
        _x params ["_deviceId", "_lampNetId", "_linkedComputers"];
        {
            private _computerNetId = _x;
            private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
            
            if (_existingLinks isEqualTo []) then {
                _deviceLinks pushBack [_computerNetId, [[2, _deviceId]]];
            } else {
                private _index = _deviceLinks find (_existingLinks select 0);
                private _devices = (_deviceLinks select _index) select 1;
                _devices pushBack [2, _deviceId];
                _deviceLinks set [_index, [_computerNetId, _devices]];
            };
        } forEach _allComputers;
    } forEach _allLamps;
    
    // Process drones (type 3)
    {
        _x params ["_deviceId", "_droneNetId", "_linkedComputers"];
        {
            private _computerNetId = _x;
            private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
            
            if (_existingLinks isEqualTo []) then {
                _deviceLinks pushBack [_computerNetId, [[3, _deviceId]]];
            } else {
                private _index = _deviceLinks find (_existingLinks select 0);
                private _devices = (_deviceLinks select _index) select 1;
                _devices pushBack [3, _deviceId];
                _deviceLinks set [_index, [_computerNetId, _devices]];
            };
        } forEach _allComputers;
    } forEach _allDrones;
    
    // Process databases (type 4)
    {
        _x params ["_deviceId", "_databaseNetId", "_linkedComputers"];
        {
            private _computerNetId = _x;
            private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
            
            if (_existingLinks isEqualTo []) then {
                _deviceLinks pushBack [_computerNetId, [[4, _deviceId]]];
            } else {
                private _index = _deviceLinks find (_existingLinks select 0);
                private _devices = (_deviceLinks select _index) select 1;
                _devices pushBack [4, _deviceId];
                _deviceLinks set [_index, [_computerNetId, _devices]];
            };
        } forEach _allComputers;
    } forEach _allDatabases;
    
    missionNamespace setVariable ["ROOT-Device-Links", _deviceLinks, true];
};

private _existingDevices = missionNamespace getVariable ["ROOT-All-Devices", [[], [], [], [], []]];
_existingDevices set [0, (_existingDevices select 0) + _allDoors];
_existingDevices set [1, (_existingDevices select 1) + _allLamps];
_existingDevices set [2, (_existingDevices select 2) + _allDrones];
_existingDevices set [3, (_existingDevices select 3) + _allDatabases];
_existingDevices set [4, (_existingDevices select 4) + _allCustom];

missionNamespace setVariable ["ROOT-All-Devices", _existingDevices, true];

private _doorCost = _module getVariable ["ROOT_Hack_Door_Cost_Edit", 2];
private _droneSideCost = _module getVariable ["ROOT_Hack_Drone_Side_Cost_Edit", 20];
private _droneDestructionCost = _module getVariable ["ROOT_Hack_Drone_Disable_Cost_Edit", 10];
private _customCost = _module getVariable ["ROOT_Hack_Custom_Cost_Edit", 10];

missionNamespace setVariable ["ROOT-All-Costs", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];

_syncedObjects = synchronizedObjects _module;

{
    private _syncedNetId = netId _x;
    _x setVariable ["ROOT-Connected", true, true];
} forEach _syncedObjects;
