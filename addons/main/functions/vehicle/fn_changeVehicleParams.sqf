#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Modifies vehicle parameters (battery, speed, brakes, lights, engine, alarm).
 * All operations validate against configured min/max limits and enforce cooldowns/toggle counts.
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _vehicleID <STRING> - Vehicle ID
 * 4: _action <STRING> - Action to perform (battery/speed/brakes/lights/engine/alarm)
 * 5: _value <STRING> - Value for the action
 * 6: _commandPath <STRING> - Command path for access checking
 *
 * Actions and Validation:
 * - battery: Validates fuel percentage against configured min/max (default 0-100%)
 * - speed: Validates speed boost (km/h) against configured min/max (default -50 to 50)
 * - brakes: Validates deceleration rate (m/s²) against configured min/max (default 1-10)
 * - lights: Checks toggle count limit and cooldown timer before toggling
 * - engine: Checks toggle count limit and cooldown timer before toggling
 * - alarm: Validates duration (seconds) against configured min/max (default 1-30)
 *
 * Return Value:
 * None
 *
 * Example:
 * [123, _laptop, "var1", "1234", "battery", "50", "/tools/"] call Root_fnc_changeVehicleParams;
 * [123, _laptop, "var1", "1234", "speed", "20", "/tools/"] call Root_fnc_changeVehicleParams;
 * [123, _laptop, "var1", "1234", "brakes", "5", "/tools/"] call Root_fnc_changeVehicleParams;
 *
 * Public: No
 */

params ["_owner", "_computer", "_nameOfVariable", "_vehicleID", "_action", "_value", "_commandPath"];

// Check for help request
if ((_vehicleID in ["-h", "help"]) || (_action in ["-h", "help"])) exitWith {
    [_computer, [[["VEHICLE COMMAND HELP", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Description:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Hack vehicles to modify their parameters and control various systems."]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Syntax:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["vehicle <VehicleID> <action> <value>"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Available Actions:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["battery", "#008DF8"], [" <0-100+>    - Set fuel level (0-100%), values >100 destroy vehicle", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                      Example: vehicle 1234 battery 50"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["speed", "#008DF8"], [" <number>      - Increase vehicle speed by given value", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                      Example: vehicle 1234 speed 20"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["brakes", "#008DF8"], [" <any>        - Apply emergency brakes (land vehicles only)", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                      Example: vehicle 1234 brakes 1"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["lights", "#008DF8"], [" <on/off>    - Toggle vehicle lights", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                      Example: vehicle 1234 lights on"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["engine", "#008DF8"], [" <on/off>    - Start or stop engine", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                      Example: vehicle 1234 engine on"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["alarm", "#008DF8"], [" <seconds>    - Trigger vehicle alarm for specified duration", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                      Example: vehicle 1234 alarm 5"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Note:", "#FFD966"], [" Each operation requires power confirmation.", ""]]]] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

private _string = "";
private _vehicleIDNum = parseNumber _vehicleID;

if (_vehicleIDNum != 0) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allVehicles = _allDevices param [6, []];

    if (_allVehicles isEqualTo []) then {
        _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_ACCESSIBLE_VEHICLES";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _foundVehicle = false;
    private _invalidOption = true;

    // Get battery from computer
    private _battery = _computer getVariable ["AE3_power_internal", objNull];
    if (isNull _battery) then {
        _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_BATTERY";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };
    private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];
    private _powerCost = 2;

    {
        // [_deviceId, _netId, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost];

        _x params [
            "_storedDeviceID", "_vehicleNetID", "_vehicleName",
            "_allowFuel", "_allowSpeed", "_allowBrakes", "_allowLights", "_allowEngine", "_allowAlarm",
            "_linkedComputers", "_availableToFutureLaptops", "_powerCost",
            ["_fuelMinPercent", 0], ["_fuelMaxPercent", 100],
            ["_speedMinValue", -50], ["_speedMaxValue", 50],
            ["_brakesMinDecel", 1], ["_brakesMaxDecel", 10],
            ["_lightsMaxToggles", -1], ["_lightsCooldown", 0],
            ["_engineMaxToggles", -1], ["_engineCooldown", 0],
            ["_alarmMinDuration", 1], ["_alarmMaxDuration", 30]
        ];
        private _vehicleObject = objectFromNetId _vehicleNetID;
        _powerCost = _vehicleObject getVariable ["ROOT_CYBERWARFARE_VEHICLE_COST", 2];
        if(_batteryLevel < ((_powerCost)/1000)) then {
            _string = localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            breakTo "exit";
        };

        if ((_vehicleIDNum == _storedDeviceID) && (alive _vehicleObject)) then {
            if ([_computer, 7, _storedDeviceID, _commandPath] call Root_fnc_isDeviceAccessible) then {
                _foundVehicle = true;
                private _changeWh = _powerCost;
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
                if (_action == "battery") then {
                    _invalidOption = false;
                    _value = parseNumber _value;

                    // Retrieve configured limits
                    private _fuelMin = _vehicleObject getVariable ["ROOT_CYBERWARFARE_FUEL_MIN", 0];
                    private _fuelMax = _vehicleObject getVariable ["ROOT_CYBERWARFARE_FUEL_MAX", 100];

                    // Validate against limits
                    if (_value < _fuelMin || _value > _fuelMax) then {
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_FUEL_OUT_OF_RANGE", _value, _fuelMin, _fuelMax];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    // Apply fuel change
                    if (_value < 1) then {
                        [_vehicleObject, 0] remoteExec ["setFuel", _vehicleObject];
                    } else {
                        if (_value < 101) then {
                            _value = _value / 100;
                            [_vehicleObject, _value] remoteExec ["setFuel", _vehicleObject];
                        } else {
                            [_vehicleObject, 1] remoteExec ["setDamage", _vehicleObject];
                        };
                    };
                };

                if (_action == "speed") then {
                    _invalidOption = false;
                    _value = parseNumber _value;

                    // Retrieve configured limits
                    private _speedMin = _vehicleObject getVariable ["ROOT_CYBERWARFARE_SPEED_MIN", -50];
                    private _speedMax = _vehicleObject getVariable ["ROOT_CYBERWARFARE_SPEED_MAX", 50];

                    // Validate against limits
                    if (_value < _speedMin || _value > _speedMax) then {
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_SPEED_OUT_OF_RANGE", _value, _speedMin, _speedMax];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    // Apply speed change
                    private _vel = velocity _vehicleObject;
                    private _dir = getDir _vehicleObject;
                    [_vehicleObject, [
                        (_vel select 0) + (sin _dir * _value),
                        (_vel select 1) + (cos _dir * _value),
                        (_vel select 2)
                    ]] remoteExec ["setVelocity", _vehicleObject];
                };

                if (_action == "brakes") then {
                    _invalidOption = false;

                    if !(_vehicleObject isKindOf "LandVehicle") then {
                        _string = localize "STR_ROOT_CYBERWARFARE_BRAKES_LAND_ONLY";
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    private _decelRate = parseNumber _value;

                    // Retrieve configured limits
                    private _brakesMin = _vehicleObject getVariable ["ROOT_CYBERWARFARE_BRAKES_MIN", 1];
                    private _brakesMax = _vehicleObject getVariable ["ROOT_CYBERWARFARE_BRAKES_MAX", 10];

                    // Validate against limits
                    if (_decelRate < _brakesMin || _decelRate > _brakesMax) then {
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_BRAKES_OUT_OF_RANGE", _decelRate, _brakesMin, _brakesMax];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    // Apply brakes with configured deceleration rate
                    [_vehicleObject, _decelRate] spawn {
                        params ["_vehicleObject", "_decelRate"];
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
                            private _newSpeed = _speed - (_decelRate * _dt);
                            if (_newSpeed < _targetSpeed) then {_newSpeed = _targetSpeed};
                            private _dir = if (_speed > 0.001) then { [(_hVel select 0) / _speed, (_hVel select 1) / _speed, 0] } else { [0,0,0] };
                            private _newVel = [(_dir select 0) * _newSpeed, (_dir select 1) * _newSpeed, _vel select 2];
                            [_vehicleObject, _newVel] remoteExec ["setVelocity", _vehicleObject];
                            uiSleep 0.02;
                        };
                    };
                };

                if (_action == "lights") then {
                    _invalidOption = false;

                    // Retrieve configuration and state
                    private _maxToggles = _vehicleObject getVariable ["ROOT_CYBERWARFARE_LIGHTS_MAX_TOGGLES", -1];
                    private _cooldown = _vehicleObject getVariable ["ROOT_CYBERWARFARE_LIGHTS_COOLDOWN", 0];
                    private _currentCount = _vehicleObject getVariable ["ROOT_CYBERWARFARE_LIGHTS_TOGGLE_COUNT", 0];
                    private _lastToggle = _vehicleObject getVariable ["ROOT_CYBERWARFARE_LIGHTS_LAST_TOGGLE", -999];

                    // Check max toggle limit
                    if (_maxToggles >= 0 && _currentCount >= _maxToggles) then {
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_LIGHTS_MAX_TOGGLES", _maxToggles, _currentCount];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    // Check cooldown
                    if (_cooldown > 0 && (time - _lastToggle) < _cooldown) then {
                        private _remainingTime = (_cooldown - (time - _lastToggle)) toFixed 1;
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_LIGHTS_COOLDOWN", _remainingTime];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    private _valueLower = toLower _value;
                    private _hasAI = (crew _vehicleObject select {alive _x && !isPlayer _x}) isNotEqualTo [];
                    private _isLightOn = isLightOn _vehicleObject;

                    // Dynamic detection of all light-related hitpoints
                    private _hitPoints = getAllHitPointsDamage _vehicleObject select 0;
                    private _lightKeywords = ["light", "lamp", "spot"];
                    private _lightHitPoints = _hitPoints select {
                        private _lower = toLower _x;
                        _lightKeywords findIf {_lower find _x > -1} > -1
                    };

                    // Functions to destroy or repair light hitpoints
                    private _destroyVehicleLights = {
                        params ["_veh", "_hitPoints"];
                        {
                            _veh setHitPointDamage [_x, 1];
                        } forEach _hitPoints;
                    };

                    private _fixVehicleLights = {
                        params ["_veh", "_hitPoints"];
                        {
                            _veh setHitPointDamage [_x, 0];
                        } forEach _hitPoints;
                    };

                    switch (_valueLower) do {
                        case "on": {
                            if (!_isLightOn) then {
                                if (_hasAI) then {
                                    [_vehicleObject, "LIGHTS"] remoteExec ["enableAI", 0];
                                };
                                [_vehicleObject, _lightHitPoints] call _fixVehicleLights;
                                [_vehicleObject, true] remoteExec ["setPilotLight", _vehicleObject];
                            };
                        };

                        case "off": {
                            if (_isLightOn) then {
                                if (_hasAI) then {
                                    [_vehicleObject, "LIGHTS"] remoteExec ["disableAI", 0];
                                };
                                [_vehicleObject, _lightHitPoints] call _destroyVehicleLights;
                                [_vehicleObject, false] remoteExec ["setPilotLight", _vehicleObject];
                            };
                        };
                    };

                    // Update counter and timestamp AFTER successful toggle
                    _vehicleObject setVariable ["ROOT_CYBERWARFARE_LIGHTS_TOGGLE_COUNT", _currentCount + 1, true];
                    _vehicleObject setVariable ["ROOT_CYBERWARFARE_LIGHTS_LAST_TOGGLE", time, true];
                };

                if (_action == "alarm") then {
                    _invalidOption = false;
                    _value = parseNumber _value;

                    // Retrieve configured limits
                    private _alarmMin = _vehicleObject getVariable ["ROOT_CYBERWARFARE_ALARM_MIN", 1];
                    private _alarmMax = _vehicleObject getVariable ["ROOT_CYBERWARFARE_ALARM_MAX", 30];

                    // Validate against limits
                    if (_value < _alarmMin || _value > _alarmMax) then {
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_ALARM_OUT_OF_RANGE", _value, _alarmMin, _alarmMax];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    // Enforce minimum value
                    if (_value < 1) then { _value = 1; };

                    // Trigger alarm
                    [_vehicleObject, _value] remoteExec ["Root_fnc_localSoundBroadcast", [0, -2] select isDedicated, false];
                };

                if (_action == "engine") then {
                    _invalidOption = false;

                    // Retrieve configuration and state
                    private _maxToggles = _vehicleObject getVariable ["ROOT_CYBERWARFARE_ENGINE_MAX_TOGGLES", -1];
                    private _cooldown = _vehicleObject getVariable ["ROOT_CYBERWARFARE_ENGINE_COOLDOWN", 0];
                    private _currentCount = _vehicleObject getVariable ["ROOT_CYBERWARFARE_ENGINE_TOGGLE_COUNT", 0];
                    private _lastToggle = _vehicleObject getVariable ["ROOT_CYBERWARFARE_ENGINE_LAST_TOGGLE", -999];

                    // Check max toggle limit
                    if (_maxToggles >= 0 && _currentCount >= _maxToggles) then {
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_ENGINE_MAX_TOGGLES", _maxToggles, _currentCount];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    // Check cooldown
                    if (_cooldown > 0 && (time - _lastToggle) < _cooldown) then {
                        private _remainingTime = (_cooldown - (time - _lastToggle)) toFixed 1;
                        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_ENGINE_COOLDOWN", _remainingTime];
                        [_computer, [[[_string, ROOT_CYBERWARFARE_COLOR_ERROR]]]] call AE3_armaos_fnc_shell_stdout;
                        breakTo "exit";
                    };

                    // Apply engine toggle
                    if (_value in ["on", "ON"]) then {
                        [_vehicleObject, true] remoteExec ["engineOn", _vehicleObject];
                    };
                    if (_value in ["OFF", "off"]) then {
                        [_vehicleObject, false] remoteExec ["engineOn", _vehicleObject];
                    };

                    // Update counter and timestamp
                    _vehicleObject setVariable ["ROOT_CYBERWARFARE_ENGINE_TOGGLE_COUNT", _currentCount + 1, true];
                    _vehicleObject setVariable ["ROOT_CYBERWARFARE_ENGINE_LAST_TOGGLE", time, true];
                };

            } else {
                if (alive _vehicleObject) then {
                    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleIDNum];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _foundVehicle = true;
                };
                _invalidOption = false;
            };
        };
    } forEach _allVehicles;

    if (!_foundVehicle) then {
        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_VEHICLE_NOT_FOUND", _vehicleIDNum];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        breakTo "exit";
    };
    if (_invalidOption) then {
        _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_ACTION_VALUE", _action, _value];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        breakTo "exit";
    } else {
        private _currentBatteryLevel = _battery getVariable "AE3_power_batteryLevel";
        private _changeWh = _powerCost;
        private _newLevel = _currentBatteryLevel - (_changeWh/1000);
        [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
        _string = format [localize "STR_ROOT_CYBERWARFARE_NEW_POWER_LEVEL", _newLevel*1000];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
} else {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_VEHICLE_ID", _vehicleID];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    breakTo "exit";
};

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
