params ["_owner", "_computer", "_nameOfVariable", "_vehicleID", "_action", "_value", "_commandPath"];

private _string = "";
private _vehicleIDNum = parseNumber _vehicleID;

if (_vehicleIDNum != 0) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allVehicles = _allDevices param [6, []];

    if (_allVehicles isEqualTo []) then {
        _string = "Error! No vehicle found.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _foundVehicle = false;
    private _invalidOption = true;
    
    {
        // [_deviceId, _netId, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost];

        _x params ["_storedDeviceID", "_vehicleNetID", "_vehicleName", "_allowFuel", "_allowSpeed", "_allowBrakes", "_allowLights", "_allowEngine", "_allowAlarm", "_linkedComputers", "_availableToFutureLaptops", "_powerCost"];

        private _vehicleObject = objectFromNetId _vehicleNetID;

        if ((_vehicleIDNum == _storedDeviceID) && (alive _vehicleObject)) then {
            if ([_computer, 7, _storedDeviceID, _commandPath] call Root_fnc_isDeviceAccessible) then {
                _foundVehicle = true;
                _powerCost = _vehicleObject getVariable ["ROOT_CYBERWARFARE_VEHICLE_COST", 2];
                private _battery = uiNamespace getVariable "AE3_Battery";
                private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";
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
                if(_batteryLevel < ((_powerCost)/1000)) then {
                    _string = format ['Error! Insufficient Power!'];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    breakTo "exit";
                };
                private _currentBatteryLevel = _battery getVariable "AE3_power_batteryLevel";
                private _changeWh = _powerCost;
                private _newLevel = _currentBatteryLevel - (_changeWh/1000);
                [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
                _string = format ['Power Cost: %1Wh', _changeWh];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                _string = format ['New Power Level: %1Wh', _newLevel*1000];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                if (_action == "battery") then {
                    _value = parseNumber _value;
                    if (_value < 1) then {
                        _vehicleObject setFuel 0;
                        _invalidOption = false;
                    } else {
                        if (_value < 101) then {
                            _value = _value / 100;
                            _vehicleObject setFuel _value;
                            _invalidOption = false;
                        } else {
                            _vehicleObject setDamage 1;
                            _invalidOption = false;
                        };
                    };
                };

                if (_action == "speed") then {
                    _value = parseNumber _value;
                    private _vel = velocity _vehicleObject;
                    private _dir = getDir _vehicleObject;
                    _vehicleObject setVelocity [
                        (_vel select 0) + (sin _dir * _value),
                        (_vel select 1) + (cos _dir * _value),
                        (_vel select 2)
                    ];
                    _invalidOption = false;
                };

                if (_action == "brakes") then {
                    _invalidOption = false;
                    if (_vehicleObject isKindOf "LandVehicle") then {
                        [_vehicleObject] spawn {
                            params ["_vehicleObject"];
                            private _targetSpeed = 0.01;
                            private _lastTime = time;
                            private _vel = velocity _vehicleObject;
                            private _hVel = [_vel select 0, _vel select 1, 0];
                            private _speed = sqrt ((_hVel select 0)^2 + (_hVel select 1)^2);
                            while {_speed > _targetSpeed} do {
                                private _now = time;
                                private _dt = _now - _lastTime;
                                _lastTime = _now;
                                _vel = velocity _vehicleObject;
                                _hVel = [_vel select 0, _vel select 1, 0];
                                _speed = sqrt ((_hVel select 0)^2 + (_hVel select 1)^2);
                                private _newSpeed = _speed - (6 * _dt);
                                if (_newSpeed < _targetSpeed) then {_newSpeed = _targetSpeed};
                                private _dir = if (_speed > 0.001) then { [(_hVel select 0) / _speed, (_hVel select 1) / _speed, 0] } else { [0,0,0] };
                                private _newVel = [(_dir select 0) * _newSpeed, (_dir select 1) * _newSpeed, _vel select 2];
                                _vehicleObject setVelocity _newVel;
                                uiSleep 0.02;
                            };
                        };
                    } else {
                        _string = format ["Vehicle incompatible for applying brakes!"];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    };
                };

                if (_action == "lights") then {
                    _invalidOption = false;
                    if ((crew _vehicleObject select { alive _x }) isEqualTo []) then {
                        if ((_value in ["on", "ON"]) && !(isLightOn _vehicleObject)) then {
                            private _execId = clientOwner;
                            [_vehicleObject, _execId] remoteExec ["setOwner", 2];
                            uiSleep 1;
                            _vehicleObject setPilotLight true;
                        } else {
                            if ((_value in ["off", "OFF"]) && (isLightOn _vehicleObject)) then {
                                private _execId = clientOwner;
                                [_vehicleObject, _execId] remoteExec ["setOwner", 2];
                                uiSleep 1;
                                _vehicleObject setPilotLight false;
                            };
                        };
                    } else {
                        _string = format ['Unable to control lights. Physical intervention detected on hack change request.'];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    };
                };

                if (_action == "alarm") then {
                    _value = parseNumber _value;
                    if (_value < 1) then { _value = 1; };
                    [_vehicleObject, _value] remoteExec ["Root_fnc_localSoundBroadcast", [0, -2] select isDedicated, false];
                    _invalidOption = false;
                };

                if (_action == "engine") then {
                    if (_value in ["on", "ON"]) then {
                        _vehicleObject engineOn true;
                        _invalidOption = false;
                    };
                    if (_value in ["OFF", "off"]) then {
                        _vehicleObject engineOn false;
                        _invalidOption = false;
                    };
                };

            } else {
                if (alive _vehicleObject) then {
                    _string = format ["Access denied to Vehicle ID: %1.", _vehicleIDNum];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _foundVehicle = true;
                };
                _invalidOption = false;
            };
        };
    } forEach _allVehicles;

    if (!_foundVehicle) then {
        _string = format ["Vehicle ID %1 not found.", _vehicleIDNum];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
    if (_invalidOption) then {
        _string = format ["Error! Invalid Action/Value specified. Action: %1, Value: %2", _action, _value];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
} else {
    _string = format ["Error! Invalid VehicleID - %1.", _vehicleID];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
