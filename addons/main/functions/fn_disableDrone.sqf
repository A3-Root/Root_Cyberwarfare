params['_owner', '_computer', '_nameOfVariable', '_droneId', "_commandPath"];

private _string = "";

private _droneIdNum = parseNumber _droneId;
private _battery = uiNamespace getVariable 'AE3_Battery';
private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";

if((_droneIdNum != 0 || _droneId isEqualTo "a")) then {
    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
    private _allCosts = missionNamespace getVariable ["ROOT-All-Costs", []];
    private _powerCostPerDrone = _allCosts select 2;
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

    if(_droneId isEqualTo "a") then {
        private _countOfChangingDrones = 0;
        private _affectedDrones = [];
        
        // Count only accessible drones
        {
            private _drone = objectFromNetId (_x select 1);
            if (alive _drone && damage _drone < 1) then {
                _countOfChangingDrones = _countOfChangingDrones + 1;
                _affectedDrones pushBack _x;
            };
        } forEach _accessibleDrones;

        if (_affectedDrones isEqualTo []) then {
            _string = "Error! No accessible drones found to disable.";
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

        [_computer, _battery, (_powerCostPerDrone * _countOfChangingDrones)] remoteExecCall ["Root_fnc_removePower", 2];
        
        // Disable all affected drones
        {
            private _drone = objectFromNetId (_x select 1);
            (vehicle _drone) setDamage 1;
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
                
                if (alive _drone && damage _drone < 1) then {
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
                    
                    (vehicle _drone) setDamage 1;
                    _string = format ["Drone disabled."];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    [_computer, _battery, _powerCostPerDrone] remoteExecCall ["Root_fnc_removePower", 2];
                } else {
                    _string = format ["Error! Drone is already disabled or destroyed."];
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

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
