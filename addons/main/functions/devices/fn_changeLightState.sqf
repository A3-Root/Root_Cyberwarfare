#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Changes the state of a light or all accessible lights
 *
 * Arguments:
 * 0: _owner <ANY> - Owner parameter (legacy compatibility)
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _lightId <STRING> - Light ID or "a" for all lights
 * 4: _lightState <STRING> - State to set (on/off)
 * 5: _commandPath <STRING> - Command path for access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [nil, _laptop, "var1", "1234", "on", "/tools/"] call Root_fnc_changeLightState;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_lightId', "_lightState", "_commandPath"];

private _string = "";

private _lightIdNum = parseNumber _lightId;

_lightState = toLower _lightState;

if((_lightIdNum != 0 || _lightId isEqualTo "a") && (_lightState isEqualTo "on" || _lightState isEqualTo "off")) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allLights = _allDevices select 1;

    // Filter lights to only those accessible by this computer
    private _accessibleLights = _allLights select { 
        [_computer, 2, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
    };

    if (_accessibleLights isEqualTo []) then {
        _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_ACCESSIBLE_LIGHTS";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    if(_lightId isEqualTo "a") then {
        private _countChanged = 0;

        {
            private _lightNetId = _x select 1;
            private _light = objectFromNetId _lightNetId;
            private _currentState = lightIsOn _light;
            
            if(_lightState isEqualTo "on" && _currentState != "ON") then {
                [_light, "ON"] remoteExec ["switchLight", 0, true];
                _countChanged = _countChanged + 1;
            };
            if(_lightState isEqualTo "off" && _currentState != "OFF") then {
                [_light, "OFF"] remoteExec ["switchLight", 0, true];
                _countChanged = _countChanged + 1;
            };
        } forEach _accessibleLights;

        _string = format [localize "STR_ROOT_CYBERWARFARE_OPERATION_COMPLETED_LIGHTS", _countChanged];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    } else {
        private _foundLight = false;
        
        {
            private _idOfLight = _x select 0;
            private _lightNetId = _x select 1;
            private _light = objectFromNetId _lightNetId;
            
            if(_lightIdNum == _idOfLight) then {
                _foundLight = true;
                private _currentState = lightIsOn _light;
                
                if(_lightState isEqualTo "on" && _currentState != "ON") then {
                    [_light, "ON"] remoteExec ["switchLight", 0, true];
                    _string = localize "STR_ROOT_CYBERWARFARE_LIGHT_TURNED_ON";
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                } else {
                    if(_lightState isEqualTo "on" && _currentState == "ON") then {
                        _string = localize "STR_ROOT_CYBERWARFARE_LIGHT_ALREADY_ON";
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    } else {
                        if(_lightState isEqualTo "off" && _currentState != "OFF") then {
                            [_light, "OFF"] remoteExec ["switchLight", 0, true];
                            _string = localize "STR_ROOT_CYBERWARFARE_LIGHT_TURNED_OFF";
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        } else {
                            if(_lightState isEqualTo "off" && _currentState == "OFF") then {
                                _string = localize "STR_ROOT_CYBERWARFARE_LIGHT_ALREADY_OFF";
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            } else {
                                _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_LIGHT_STATE", _lightState];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            };
                        };
                    };
                };
            };
        } forEach _accessibleLights;
        
        if (!_foundLight) then {
            _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_LIGHT", _lightIdNum];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        };
    };
};

if(!(_lightIdNum != 0 || _lightId isEqualTo "a")) then {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_LIGHT_ID", _lightId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

if(!(_lightState isEqualTo "on" || _lightState isEqualTo "off")) then {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_LIGHT_STATE", _lightState];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
