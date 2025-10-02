params['_owner', '_computer', '_nameOfVariable', '_customId', "_customState", "_commandPath"];

private _string = "";

private _battery = uiNamespace getVariable 'AE3_Battery';
private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";

_customState = toLower _customState;
_customId = parseNumber _customId;

if(_customId != 0 && (_customState isEqualTo "activate" || _customState isEqualTo "deactivate")) then {
    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
    private _allCosts = missionNamespace getVariable ["ROOT-All-Costs", []];
    private _powerCostPerCustom = _allCosts select 3;
    private _allCustom = _allDevices select 4;

    if(_batteryLevel < (_powerCostPerCustom/1000)) then {
        _string = format ['Error! Insufficient Power.'];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _deviceFound = false;
    {
        private _storedCustomId = _x select 0;
        if(_customId == _storedCustomId) then {
            _deviceFound = true;
            private _customName = _x select 2;
            private _activationCode = _x select 3;
            private _deactivationCode = _x select 4;

            if(_customState isEqualTo "activate") then {
                _string = format ["Custom device '%1' (ID: %2) activated.", _customName, _customId];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                [_computer, _battery, _powerCostPerCustom] call compile preprocessFileLineNumbers "root_cyberwarfare\functions\fn_removePower.sqf";
                if (_activationCode != "") then {
                    [_computer] spawn (compile _activationCode);
                };
            } else {
                if(_customState isEqualTo "deactivate") then {
                    _string = format ["Custom device '%1' (ID: %2) deactivated.", _customName, _customId];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    [_computer, _battery, _powerCostPerCustom] call compile preprocessFileLineNumbers "root_cyberwarfare\functions\fn_removePower.sqf";
                    if (_deactivationCode != "") then {
                        [_computer] spawn (compile _deactivationCode);
                    };
                } else {
                    _string = format ['Error! Invalid Input - %1.', _customState];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
            break;
        };
    } forEach _allCustom;
    
    if(!_deviceFound) then {
        _string = format ["Custom device with ID %1 not found.", _customId];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
};
if(_customId == 0) then {
    _string = format ['Invalid input customId: %1.', _customId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};
if(!(_customState isEqualTo "activate" || _customState isEqualTo "deactivate")) then {
    _string = format ['Invalid input customState: %1.', _customState];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
