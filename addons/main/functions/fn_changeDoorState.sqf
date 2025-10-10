params['_owner', '_computer', '_nameOfVariable', '_buildingId', "_doorId", "_doorDesiredState", "_commandPath"];

private _string = "";
private _powerCostPerDoor = 2;

private _buildingIdNum = parseNumber _buildingId;
private _doorIdNum = parseNumber _doorId;
private _battery = uiNamespace getVariable 'AE3_Battery';
private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";

_doorDesiredState = toLower _doorDesiredState;

if(_buildingIdNum != 0 && (_doorIdNum != 0 || _doorId isEqualTo "a") && (_doorDesiredState isEqualTo "lock" || _doorDesiredState isEqualTo "unlock")) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allCosts = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []];
    private _powerCostPerDoor = _allCosts select 0;
    private _allDoors = _allDevices select 0;

    // Filter doors to only those accessible by this computer
    private _accessibleDoors = _allDoors select { 
        [_computer, 1, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
    };

    if (_accessibleDoors isEqualTo []) then {
        _string = "Error! No accessible buildings found or access denied.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    if(_doorId isEqualTo "a") then {
        private _countOfChangingDoors = 0;
        private _affectedBuildings = [];
        
        // Count only accessible doors
        {
            private _idOfBuilding = _x select 0;
            if (_idOfBuilding == _buildingIdNum) then {
                private _building = objectFromNetId (_x select 1);
                private _doorsOfBuilding = (_x select 2);
                { 
                    private _currentState = _building getVariable [format ['bis_disabled_Door_%1', _x], 5];
                    if(_doorDesiredState isEqualTo "lock" && _currentState != 1) then {
                        _countOfChangingDoors = _countOfChangingDoors + 1;
                    };
                    if(_doorDesiredState isEqualTo "unlock" && _currentState != 0) then {
                        _countOfChangingDoors = _countOfChangingDoors + 1;
                    };
                } forEach _doorsOfBuilding;
                _affectedBuildings pushBack _x;
            };
        } forEach _accessibleDoors;

        if (_affectedBuildings isEqualTo []) then {
            _string = "Error! No accessible buildings found for the specified criteria.";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            missionNamespace setVariable [_nameOfVariable, true, true];
            breakTo "exit";
        };

        _string = format ['Affected Doors: %1. Power Cost: %2W.', _countOfChangingDoors, (_countOfChangingDoors * _powerCostPerDoor)];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        
        if(_batteryLevel < ((_countOfChangingDoors * _powerCostPerDoor)/1000)) then {
            _string = format ['Error! Insufficient Power!'];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
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
        private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";
        private _changeWh = (_powerCostPerDoor * _countOfChangingDoors);
        private _newLevel = _batteryLevel - (_changeWh/1000);
        [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
        _string = format ['Power Cost: %1Wh', _changeWh];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        _string = format ['New Power Level: %1Wh', _newLevel*1000];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        
        // Apply changes to all accessible buildings
        {
            private _idOfBuilding = _x select 0;
            if (_idOfBuilding == _buildingIdNum || _buildingId isEqualTo "a") then {
                private _building = objectFromNetId (_x select 1);
                private _doorsOfBuilding = (_x select 2);
                {
                    if(_doorDesiredState isEqualTo "lock") then {
                        _building setVariable [format ["bis_disabled_Door_%1", _x], 1, true];
                    };
                    if(_doorDesiredState isEqualTo "unlock") then {
                        _building setVariable [format ["bis_disabled_Door_%1", _x], 0, true];
                    };
                } forEach _doorsOfBuilding;
            };
        } forEach _affectedBuildings;
        
        _string = format ["Operation completed on %1 doors.", _countOfChangingDoors];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    } else {
        // Single door operation
        private _foundDoor = false;
        
        {
            private _idOfBuilding = _x select 0;
            if(_idOfBuilding == _buildingIdNum) then {
                private _building = objectFromNetId (_x select 1);
                private _doorsOfBuilding = (_x select 2);
                
                if(_doorIdNum in _doorsOfBuilding) then {
                    _foundDoor = true;
                    private _currentState = _building getVariable [format ['bis_disabled_Door_%1', _doorIdNum], 5];
                    
                    if(_doorDesiredState isEqualTo "lock" && _currentState != 1) then {
                        _string = format ['Power Cost: %1Wh.', _powerCostPerDoor];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        
                        if(_batteryLevel < (_powerCostPerDoor/1000)) then {
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
                        
                        _building setVariable [format ["bis_disabled_Door_%1", _doorIdNum], 1, true];
                        _string = format ["Door locked."];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";
                        private _changeWh = _powerCostPerDoor;
                        private _newLevel = _batteryLevel - (_changeWh/1000);
                        [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
                        _string = format ['Power Cost: %1Wh', _changeWh];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        _string = format ['New Power Level: %1Wh', _newLevel*1000];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    } else {
                        if(_doorDesiredState isEqualTo "lock" && _currentState == 1) then {
                            _string = format ["Door already locked."];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        } else {
                            if(_doorDesiredState isEqualTo "unlock" && _currentState != 0) then {
                                _string = format ['Power Cost: %1Wh.', _powerCostPerDoor];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                                
                                if(_batteryLevel < (_powerCostPerDoor/1000)) then {
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
                                
                                _building setVariable [format ["bis_disabled_Door_%1", _doorIdNum], 0, true];
                                _string = format ["Door unlocked."];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                                private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";
                                private _changeWh = _powerCostPerDoor;
                                private _newLevel = _batteryLevel - (_changeWh/1000);
                                [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
                                _string = format ['Power Cost: %1Wh', _changeWh];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                                _string = format ['New Power Level: %1Wh', _newLevel*1000];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            } else {
                                if(_doorDesiredState isEqualTo "unlock" && _currentState == 0) then {
                                    _string = format ["Door already unlocked."];
                                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                                } else {
                                    _string = format ['Invalid Input: %1.', _doorDesiredState];
                                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                                };
                            };
                        };
                    };
                } else {
                    _string = format ["Error! No such door with ID: %1 in the building (ID: %2)!", _doorIdNum, _buildingIdNum];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
        } forEach _accessibleDoors;
        
        if (!_foundDoor) then {
            _string = format ["Error! Building ID %1 not found!", _buildingIdNum];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        };
    };
};

if(_buildingIdNum == 0) then {
    _string = format ["Error! Invalid BuildingID - %1.", _buildingId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

if(!(_doorIdNum != 0 || _doorId isEqualTo "a")) then {
    _string = format ["Error! Invalid DoorID - %1.", _doorId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

if(!(_doorDesiredState isEqualTo "lock" || _doorDesiredState isEqualTo "unlock")) then {
    _string = format ["Error! Invalid Door State Desired - %1.", _doorDesiredState];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
