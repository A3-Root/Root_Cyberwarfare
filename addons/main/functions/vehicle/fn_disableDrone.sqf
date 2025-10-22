#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Disables (destroys) a drone or all accessible drones
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _droneId <STRING> - Drone ID or "a" for all drones
 * 4: _commandPath <STRING> - Command path for access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [123, _laptop, "var1", "1234", "/tools/"] call Root_fnc_disableDrone;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_droneId', "_commandPath"];

private _string = "";

private _droneIdNum = parseNumber _droneId;

// Get battery from computer
private _battery = _computer getVariable ["AE3_power_internal", objNull];
if (isNull _battery) then {
    _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_BATTERY";
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
    breakTo "exit";
};
private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];

if((_droneIdNum != 0 || _droneId isEqualTo "a")) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allCosts = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []];
    private _powerCostPerDrone = _allCosts select 2;
    private _allDrones = _allDevices select 2;

    // Filter drones to only those accessible by this computer
    private _accessibleDrones = _allDrones select { 
        [_computer, 3, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
    };

    if (_accessibleDrones isEqualTo []) then {
        _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_ACCESSIBLE_DRONES";
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
            _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_ACCESSIBLE_DRONES_TO_DISABLE";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            missionNamespace setVariable [_nameOfVariable, true, true];
            breakTo "exit";
        };

        _string = format ['Affected Drones: %1. Power Cost: %2Wh.', _countOfChangingDrones, (_countOfChangingDrones * _powerCostPerDrone)];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;

        if(_batteryLevel < ((_countOfChangingDrones * _powerCostPerDrone)/1000)) then {
            _string = localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            missionNamespace setVariable [_nameOfVariable, true, true];
            breakTo "exit";
        };

        private _changeWh = (_powerCostPerDrone * _countOfChangingDrones);
        _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST", _changeWh];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        _string = localize "STR_ROOT_CYBERWARFARE_CONFIRM_PROMPT";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        
        private _time = time;
        _time = _time + 10;
        private _continue = false;
        while{time < _time} do {
            private _areYouSure = [_computer] call AE3_armaos_fnc_shell_stdin;
            if((_areYouSure isEqualTo "y") || (_areYouSure isEqualTo "Y")) then {
                _continue = true;
                break;
            };
            if((_areYouSure isEqualTo "n") || (_areYouSure isEqualTo "N")) then {
                missionNamespace setVariable [_nameOfVariable, true, true];
                _continue = false;
                breakTo "exit";
            };
        };

        if (!_continue) then {
            _string = localize "STR_ROOT_CYBERWARFARE_POWERGRID_CONFIRMATION_TIMEOUT";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            missionNamespace setVariable [_nameOfVariable, true, true];
            breakTo "exit";
        };

        private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];
        private _newLevel = _batteryLevel - (_changeWh/1000);
        [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
        _string = format [localize "STR_ROOT_CYBERWARFARE_NEW_POWER_LEVEL", _newLevel*1000];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;

        // Disable all affected drones
        {
            private _drone = objectFromNetId (_x select 1);
            (vehicle _drone) setDamage 1;
        } forEach _affectedDrones;

        _string = format [localize "STR_ROOT_CYBERWARFARE_OPERATION_COMPLETED_DRONES", _countOfChangingDrones];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    } else {
        private _foundDrone = false;
        
        {
            private _idOfDrone = _x select 0;
            if(_idOfDrone == _droneIdNum) then {
                _foundDrone = true;
                private _drone = objectFromNetId (_x select 1);
                
                if (alive _drone && damage _drone < 1) then {
                    _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST", _powerCostPerDrone];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                    if(_batteryLevel < (_powerCostPerDrone/1000)) then {
                        _string = localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER";
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        missionNamespace setVariable [_nameOfVariable, true, true];
                        breakTo "exit";
                    };

                    private _changeWh = _powerCostPerDrone;
                    _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST", _changeWh];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = localize "STR_ROOT_CYBERWARFARE_CONFIRM_PROMPT";
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    
                    private _time = time;
                    _time = _time + 10;
                    private _continue = false;
                    while{time < _time} do {
                        private _areYouSure = [_computer] call AE3_armaos_fnc_shell_stdin;
                        if((_areYouSure isEqualTo "y") || (_areYouSure isEqualTo "Y")) then {
                            _continue = true;
                            break;
                        };
                        if((_areYouSure isEqualTo "n") || (_areYouSure isEqualTo "N")) then {
                            missionNamespace setVariable [_nameOfVariable, true, true];
                            _continue = false;
                            breakTo "exit";
                        };
                    };

                    if (!_continue) then {
                        _string = localize "STR_ROOT_CYBERWARFARE_POWERGRID_CONFIRMATION_TIMEOUT";
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        missionNamespace setVariable [_nameOfVariable, true, true];
                        breakTo "exit";
                    };

                    (vehicle _drone) setDamage 1;
                    _string = localize "STR_ROOT_CYBERWARFARE_DRONE_DISABLED_SUCCESS";
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";
                    private _newLevel = _batteryLevel - (_changeWh/1000);
                    [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
                    _string = format [localize "STR_ROOT_CYBERWARFARE_NEW_POWER_LEVEL", _newLevel*1000];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                } else {
                    _string = localize "STR_ROOT_CYBERWARFARE_DRONE_ALREADY_DISABLED";
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
        } forEach _accessibleDrones;

        if (!_foundDrone) then {
            _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DRONE", _droneIdNum];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        };
    };
};

if(!(_droneIdNum != 0 || _droneId isEqualTo "a")) then {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_DRONE_ID", _droneId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
