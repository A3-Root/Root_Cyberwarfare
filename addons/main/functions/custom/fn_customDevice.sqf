#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Activates or deactivates a custom device
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _customId <STRING> - Custom device ID
 * 4: _customState <STRING> - State to set (activate/deactivate)
 * 5: _playerObject <OBJECT> - Object of the _owner
 * 6: _commandPath <STRING> - Command path for access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [123, _laptop, "var1", "1234", "activate", User1, "/tools/"] call Root_fnc_customDevice;
 *
 * Public: No
 */

params["_owner", "_computer", "_nameOfVariable", "_customId", "_customState", "_playerObject", "_commandPath"];

// Check for help request
if ((_customId in ["-h", "help"]) || (_customState in ["-h", "help"])) exitWith {
    [_computer, [[["CUSTOM COMMAND HELP", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Description:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Activate or deactivate custom scripted devices with special functionality."]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Syntax:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["custom <DeviceID> <state>"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Parameters:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["DeviceID", "#008DF8"], ["  - ID of the custom device", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["state", "#008DF8"], ["     - 'activate' or 'deactivate'", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Examples:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  custom 1234 activate     - Activate custom device #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  custom 1234 deactivate   - Deactivate custom device #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Note:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Custom devices execute mission-specific scripts"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Effects depend on how the device was configured"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Requires power confirmation"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Check device description for specific behavior"]]]] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

private _string = "";

_customState = toLower _customState;
_customId = parseNumber _customId;

if(_customId != 0 && (_customState isEqualTo "activate" || _customState isEqualTo "deactivate")) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allCosts = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []];
    private _powerCostPerCustom = _allCosts select 3;
    private _allCustom = _allDevices select 4;

    if !([_computer, _powerCostPerCustom] call FUNC(checkPowerAvailable)) then {
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
            if !([_computer, _powerCostPerCustom] call FUNC(getUserConfirmation)) then {
                missionNamespace setVariable [_nameOfVariable, true, true];
                breakTo "exit";
            };
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
                    [_computer, _deviceObject, _playerObject, _owner] spawn (compile _activationCode);
                };
            } else {
                if(_customState isEqualTo "deactivate") then {
                    _string = format [localize "STR_ROOT_CYBERWARFARE_CUSTOM_DEVICE_DEACTIVATED", _customName, _customId];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    if (_deactivationCode != "") then {
                        [_computer, _deviceObject, _playerObject, _owner] spawn (compile _deactivationCode);
                    };
                } else {
                    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_INPUT", _customState];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
        };
    } forEach _allCustom;

    if(_deviceFound) then {
        [_computer, _powerCostPerCustom] call FUNC(consumePower);
    } else {
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

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
