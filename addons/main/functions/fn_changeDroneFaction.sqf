params['_owner', '_computer', '_nameOfVariable', '_droneId', "_droneFaction", "_commandPath"];

private _string = "";

private _droneIdNum = parseNumber _droneId;
private _battery = uiNamespace getVariable 'AE3_Battery';
private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";

_droneFaction = toLower _droneFaction;

if((_droneIdNum != 0 || _droneId isEqualTo "a") && (_droneFaction isEqualTo "west" || _droneFaction isEqualTo "east" || _droneFaction isEqualTo "guer" || _droneFaction isEqualTo "civ")) then {
    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
    private _allCosts = missionNamespace getVariable ["ROOT-All-Costs", []];
    private _powerCostPerDrone = _allCosts select 1;
    private _allDrones = _allDevices select 2;

    // Filter drones to only those accessible by this computer
    private _accessibleDrones = _allDrones select { 
        [_computer, 3, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
    };

    if (_accessibleDrones isEqualTo []) then {
        _string = "Error! No accessible drones found or access denied.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _side = west;

    if(_droneFaction isEqualTo "west") then {
        _side = west;
    };
    if(_droneFaction isEqualTo "east") then {
        _side = east;
    };
    if(_droneFaction isEqualTo "guer") then {
        _side = independent;
    };
    if(_droneFaction isEqualTo "civ") then {
        _side = civilian;
    };

    if(_droneId isEqualTo "a") then {
        private _countOfChangingDrones = 0;
        private _affectedDrones = [];
        
        // Count only accessible drones that need changing
        {
            private _drone = objectFromNetId (_x select 1);
            private _currentState = side _drone;
            if((_side isNotEqualTo _currentState)) then {
                _countOfChangingDrones = _countOfChangingDrones + 1;
                _affectedDrones pushBack _x;
            };
        } forEach _accessibleDrones;

        if (_affectedDrones isEqualTo []) then {
            _string = "Error! No accessible drones found that need faction change.";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            missionNamespace setVariable [_nameOfVariable, true, true];
            breakTo "exit";
        };

        _string = format ['Affected Drones: %1. Power Cost: %2Wh.', _countOfChangingDrones, (_countOfChangingDrones * _powerCostPerDrone)];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        
        if(_batteryLevel < ((_countOfChangingDrones * _powerCostPerDrone)/1000)) then {
            _string = format ['Error! Insufficient Power!'];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            missionNamespace setVariable [_nameOfVariable, true, true];
            breakTo "exit";
        };
        
        _string = format ['Are you sure? (Y/N): '];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        
        while{true} do {
            private _areYouSure = [_computer] call AE3_armaos_fnc_shell_stdin;
            if((_areYouSure isEqualTo "y") || (_areYouSure isEqualTo "Y")) then {
                break;
            };
            if((_areYouSure isEqualTo "n") || (_areYouSure isEqualTo "N")) then {
                missionNamespace setVariable [_nameOfVariable, true, true];
                breakTo "exit";
            };
        };

        [_computer, _battery, (_powerCostPerDrone * _countOfChangingDrones)] call compile preprocessFileLineNumbers "root_cyberwarfare\functions\fn_removePower.sqf";
        
        // Apply changes to all affected drones
        {
            private _drone = objectFromNetId (_x select 1);
            private _newGroup = createGroup _side;
            [_drone] joinSilent _newGroup;            
        } forEach _affectedDrones;
        
        _string = format ["Operation completed on %1 drones.", _countOfChangingDrones];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    } else {
        private _foundDrone = false;
        
        {
            private _idOfDrone = _x select 0;
            if(_idOfDrone == _droneIdNum) then {
                _foundDrone = true;
                private _drone = objectFromNetId (_x select 1);
                private _currentState = side _drone;
                
                if((_side isNotEqualTo _currentState)) then {
                    _string = format ['Power Cost: %1Wh.', _powerCostPerDrone];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    
                    if(_batteryLevel < (_powerCostPerDrone/1000)) then {
                        _string = format ['Error! Insufficient Power!'];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        missionNamespace setVariable [_nameOfVariable, true, true];
                        breakTo "exit";
                    };
                    
                    _string = format ['Are you sure? (Y/N): '];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    
                    while{true} do {
                        private _areYouSure = [_computer] call AE3_armaos_fnc_shell_stdin;
                        if((_areYouSure isEqualTo "y") || (_areYouSure isEqualTo "Y")) then {
                            break;
                        };
                        if((_areYouSure isEqualTo "n") || (_areYouSure isEqualTo "N")) then {
                            missionNamespace setVariable [_nameOfVariable, true, true];
                            breakTo "exit";
                        };
                    };
                    
                    private _newGroup = createGroup _side;
                    [_drone] joinSilent _newGroup;
                    _string = format ["Drone side changed."];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    [_computer, _battery, _powerCostPerDrone] call compile preprocessFileLineNumbers "root_cyberwarfare\functions\fn_removePower.sqf";
                } else {
                    _string = format ["Error! Drone already of side %1.", _droneFaction];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
        } forEach _accessibleDrones;
        
        if (!_foundDrone) then {
            _string = format ["Error! Drone ID %1 not found or access denied.", _droneIdNum];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        };
    };
};

if(!(_droneIdNum != 0 || _droneId isEqualTo "a")) then {
    _string = format ["Error! Invalid DroneID - %1.", _droneId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

if(!((_droneFaction isEqualTo "west" || _droneFaction isEqualTo "east" || _droneFaction isEqualTo "guer" || _droneFaction isEqualTo "civ"))) then {
    _string = format ["Error! Invalid Drone Faction - %1.", _droneFaction];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
