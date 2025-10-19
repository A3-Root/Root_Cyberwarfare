#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Activates or deactivates a custom device
 *
 * Arguments:
 * 0: _owner <ANY> - Owner parameter (legacy compatibility)
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _customId <STRING> - Custom device ID
 * 4: _customState <STRING> - State to set (activate/deactivate)
 * 5: _commandPath <STRING> - Command path for access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [nil, _laptop, "var1", "1234", "activate", "/tools/"] call Root_fnc_customDevice;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_customId', "_customState", "_commandPath"];

private _string = "";

// Get battery from computer
private _battery = _computer getVariable ["AE3_power_internal", objNull];
if (isNull _battery) then {
    _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_BATTERY";
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
    breakTo "exit";
};
private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];

_customState = toLower _customState;
_customId = parseNumber _customId;

if(_customId != 0 && (_customState isEqualTo "activate" || _customState isEqualTo "deactivate")) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allCosts = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []];
    private _powerCostPerCustom = _allCosts select 3;
    private _allCustom = _allDevices select 4;

    if(_batteryLevel < (_powerCostPerCustom/1000)) then {
        _string = localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _deviceFound = false;
    {
        private _storedCustomId = _x select 0;
        if(_customId == _storedCustomId) then {
            _deviceFound = true;
            private _deviceNetId = _x select 1;
            private _customName = _x select 2;
            private _activationCode = _x select 3;
            private _deactivationCode = _x select 4;

            // Get the actual device object
            private _deviceObject = objectFromNetId _deviceNetId;

            if(_customState isEqualTo "activate") then {
                _string = format [localize "STR_ROOT_CYBERWARFARE_CUSTOM_DEVICE_ACTIVATED", _customName, _customId];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                if (_activationCode != "") then {
                    [_computer, _deviceObject, _owner] spawn (compile _activationCode);
                };
            } else {
                if(_customState isEqualTo "deactivate") then {
                    _string = format [localize "STR_ROOT_CYBERWARFARE_CUSTOM_DEVICE_DEACTIVATED", _customName, _customId];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    if (_deactivationCode != "") then {
                        [_computer, _deviceObject, _owner] spawn (compile _deactivationCode);
                    };
                } else {
                    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_INPUT", _customState];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
            private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];
            private _changeWh = _powerCostPerCustom;
            private _newLevel = _batteryLevel - (_changeWh/1000);
            [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
            _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST", _changeWh];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            _string = format [localize "STR_ROOT_CYBERWARFARE_NEW_POWER_LEVEL", _newLevel*1000];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            break;
        };
    } forEach _allCustom;

    if(!_deviceFound) then {
        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_CUSTOM_DEVICE_NOT_FOUND", _customId];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
};
if(_customId == 0) then {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_CUSTOM_DEVICE_ID", _customId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};
if(!(_customState isEqualTo "activate" || _customState isEqualTo "deactivate")) then {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_CUSTOM_DEVICE_STATE", _customState];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
