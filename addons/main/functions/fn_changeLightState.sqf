params['_owner', '_computer', '_nameOfVariable', '_lightId', "_lightState", "_commandPath"];

private _string = "";

private _lightIdNum = parseNumber _lightId;

_lightState = toLower _lightState;

if((_lightIdNum != 0 || _lightId isEqualTo "a") && (_lightState isEqualTo "on" || _lightState isEqualTo "off")) then {
    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
    private _allLights = _allDevices select 1;

    // Filter lights to only those accessible by this computer
    private _accessibleLights = _allLights select { 
        [_computer, 2, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
    };

    if (_accessibleLights isEqualTo []) then {
        _string = "Error! No accessible lights found or access denied.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    if(_lightId isEqualTo "a") then {
        private _countChanged = 0;
        
        {
            private _idOfLight = _x select 0;
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
        
        _string = format ["Operation completed on %1 lights.", _countChanged];
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
                    _string = format ["Light turned on."];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                } else {
                    if(_lightState isEqualTo "on" && _currentState == "ON") then {
                        _string = format ["Light already on."];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    } else {
                        if(_lightState isEqualTo "off" && _currentState != "OFF") then {
                            [_light, "OFF"] remoteExec ["switchLight", 0, true];
                            _string = format ["Light turned off."];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                        } else {
                            if(_lightState isEqualTo "off" && _currentState == "OFF") then {
                                _string = format ["Light already off."];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            } else {
                                _string = format ['Error! Invalid Light State - %1.', _lightState];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            };
                        };
                    };
                };
            };
        } forEach _accessibleLights;
        
        if (!_foundLight) then {
            _string = format ["Error! Light ID %1 not found or access denied.", _lightIdNum];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        };
    };
};

if(!(_lightIdNum != 0 || _lightId isEqualTo "a")) then {
    _string = format ['Error! Invalid LightID - %1.', _lightId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

if(!(_lightState isEqualTo "on" || _lightState isEqualTo "off")) then {
    _string = format ['Error! Invalid Light State - %1.', _lightState];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
