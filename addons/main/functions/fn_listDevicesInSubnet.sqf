params['_owner', '_computer', '_nameOfVariable', '_commandPath'];

private _string = "";
private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", [[], [], [], [], []]];
private _allDoors = _allDevices select 0;
private _allLights = _allDevices select 1;
private _allDrones = _allDevices select 2;
private _allDatabases = _allDevices select 3;
private _allCustom = _allDevices select 4;

// Filter devices based on accessibility
private _accessibleDoors = _allDoors select { 
    [_computer, 1, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleLights = _allLights select { 
    [_computer, 2, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleDrones = _allDrones select { 
    [_computer, 3, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleDatabases = _allDatabases select { 
    [_computer, 4, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleCustom = _allCustom select { 
    [_computer, 5, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

if (_accessibleDoors isNotEqualTo []) then {
    {
        private _building = objectFromNetId (_x select 1);
        private _buildingDisplayName = getText (configFile >> "CfgVehicles" >> typeOf _building >> "displayName");
        private _mapGridPos = mapGridPosition _building;
        private _doorsOfBuilding = _x select 2;
        _string = format ["Building: %1 (%2) located at Grid - %3", (_x select 0), _buildingDisplayName, _mapGridPos];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        {
            private _currentState = _building getVariable [format ['bis_disabled_Door_%1', _x], 5];
            private _currentStateString = "";
            private _currentStateStringColor = "#8ce10b";
            if(_currentState == 1) then {
                _currentStateString = "locked ";
                _currentStateStringColor = "#fa4c58";
            } else {
                _currentStateString = "unlocked ";
            };

            private _doorAnim = format ["Door_%1_rot", _x];
            private _phase = _building animationPhase _doorAnim;

            private _phaseString = "";
            private _phaseStringColor = "#8ce10b";
            if(_phase > 0.5) then { 
                _phaseString = "open";
            } else {
                _phaseString = "closed";
                _phaseStringColor = "#fa4c58";
            };

            _string = format ["    Door: %1 ", _x];
            [_computer, [[_string, [_currentStateString, _currentStateStringColor], [_phaseString, _phaseStringColor]]]] call AE3_armaos_fnc_shell_stdout;
        } forEach _doorsOfBuilding;
    } forEach _accessibleDoors;
};

if (_accessibleLights isNotEqualTo []) then {
    _string = format ["Lights:"];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    {
        private _lightId = _x select 0;
        private _light = objectFromNetId (_x select 1);
        private _lightDisplayName = getText (configFile >> "CfgVehicles" >> typeOf _light >> "displayName");
        private _mapGridPos = mapGridPosition _light;
        private _currentState = lightIsOn _light;
        private _currentStateStringColor = "#8ce10b";
        if(_currentState isEqualTo "OFF") then {
            _currentStateStringColor = "#fa4c58 ";
        };

        _string = format ["    Light: %1 (%2) @ %3  ", _lightId, _lightDisplayName, _mapGridPos];
        [_computer, [[_string, [_currentState, _currentStateStringColor]]]] call AE3_armaos_fnc_shell_stdout;
    } forEach _accessibleLights;
};

if (_accessibleDrones isNotEqualTo []) then {
    _string = format ["Drones:"];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    {
        private _droneId = _x select 0;
        private _drone = objectFromNetId (_x select 1);
        private _droneName = getText (configFile >> "CfgVehicles" >> typeOf (vehicle _drone) >> "displayName");
        private _mapGridPos = mapGridPosition _drone;
        private _droneSide = side _drone;
        private _droneSideString = side _drone;
        private _damage = damage (vehicle _drone);
        private _droneSideColor = "#BCBCBC";
        if(_damage == 1) then {
            _droneSideString = "DEAD";
        };
        if(_droneSide == west) then {
            _droneSideColor = "#008DF8";
        };
        if(_droneSide == east) then {
            _droneSideColor = "#FA4C58";
        };
        if(_droneSide == civilian) then {
            _droneSideColor = "#FFD966";
        };
        if(_droneSide == independent) then {
            _droneSideColor = "#8CE10B";
        };

        _string = format ["    Drone: %1  ", _droneId];
        [_computer, [[_string, [format["'%1' ", _droneSideString], _droneSideColor], _droneName, "  @ ", _mapGridPos]]] call AE3_armaos_fnc_shell_stdout;
    } forEach _accessibleDrones;
};

if (_accessibleDatabases isNotEqualTo []) then {
    _string = format ["Files:"];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    {
        private _databaseId = _x select 0;
        private _database = objectFromNetId (_x select 1);
        private _databaseName = _database getVariable ["ROOT_DatabaseName_Edit", "Unknown Database"];
        private _databaseSize = _database getVariable ["ROOT_DatabaseSize_Edit", 10];
        _string = format ["    File: %2 (ID: %1)    Est. Transfer Time: %3 seconds", _databaseId, _databaseName, _databaseSize];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    } forEach _accessibleDatabases;
};

if (_accessibleCustom isNotEqualTo []) then {
    _string = format ["Custom Devices:"];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    {
        private _customId = _x select 0;
        private _customName = _x select 2;
        _string = format ["    %1 (ID: %2)", _customName, _customId];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    } forEach _accessibleCustom;
};

missionNamespace setVariable [_nameOfVariable, true, true];
