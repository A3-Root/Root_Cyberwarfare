#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Controls power grid devices (on/off/overload)
 *
 * Arguments:
 * 0: _owner <ANY> - Owner parameter (legacy compatibility)
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _gridId <STRING> - Power grid ID
 * 4: _action <STRING> - Action to perform (on/off/overload)
 * 5: _commandPath <STRING> - Command path for access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [nil, _laptop, "var1", "1234", "on", "/tools/"] call Root_fnc_powerGridControl;
 *
 * Public: No
 */

params ["_owner", "_computer", "_nameOfVariable", "_gridId", "_action", "_commandPath"];

scopeName "exit";

private _string = "";
private _gridIdNum = parseNumber _gridId;

// Validate grid ID
if (_gridIdNum == 0) exitWith {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_GRID_ID", _gridId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Validate action
_action = toLower _action;
if !(_action in ["on", "off", "overload"]) exitWith {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_ACTION", _action];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Get all power grids
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allPowerGrids = _allDevices select 7;

if (_allPowerGrids isEqualTo []) exitWith {
    _string = localize "STR_ROOT_CYBERWARFARE_ERROR_NO_POWERGRIDS";
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Get battery and check power
private _battery = uiNamespace getVariable "AE3_Battery";
private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";

// Get power cost from CBA setting
private _powerCost = missionNamespace getVariable [SETTING_POWERGRID_COST, 15];

private _foundGrid = false;
{
    _x params ["_storedGridId", "_gridNetId", "_gridName", "_radius", "_allowExplosionOverload", "_explosionType", "_excludedClassnames", "_availableToFutureLaptops", "", "_linkedComputers"];

    if (_gridIdNum == _storedGridId) then {
        private _gridObject = objectFromNetId _gridNetId;

        // Check if object still exists
        if (isNull _gridObject) exitWith {
            _string = localize "STR_ROOT_CYBERWARFARE_ERROR_POWERGRID_OBJECT_NOT_FOUND";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            _foundGrid = true;
        };

        // Check access
        if !([_computer, DEVICE_TYPE_POWERGRID, _storedGridId, _commandPath] call FUNC(isDeviceAccessible)) exitWith {
            _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_POWERGRID", _gridIdNum];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            _foundGrid = true;
        };

        // Check if destroyed
        private _isDestroyed = _gridObject getVariable ["ROOT_CYBERWARFARE_GENERATOR_DESTROYED", false];
        if (_isDestroyed) exitWith {
            _string = localize "STR_ROOT_CYBERWARFARE_ERROR_GENERATOR_DESTROYED";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            _foundGrid = true;
        };

        // Check power availability
        if (_batteryLevel < (_powerCost/1000)) exitWith {
            _string = localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            _foundGrid = true;
        };

        _foundGrid = true;

        // Show warning for destructive operations
        if (_action == "overload") then {
            _string = format ["WARNING: This will permanently destroy the power grid generator!"];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        };

        // Show power cost and ask for confirmation
        _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST", _powerCost];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        _string = localize "STR_ROOT_CYBERWARFARE_CONFIRM_PROMPT";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;

        private _time = time + 10; // 10 second timeout
        private _continue = false;
        while {time < _time} do {
            private _areYouSure = [_computer] call AE3_armaos_fnc_shell_stdin;
            if ((_areYouSure isEqualTo "y") || (_areYouSure isEqualTo "Y")) then {
                _continue = true;
                break;
            };
            if ((_areYouSure isEqualTo "n") || (_areYouSure isEqualTo "N")) then {
                _string = localize "STR_ROOT_CYBERWARFARE_POWERGRID_CANCELLED";
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                missionNamespace setVariable [_nameOfVariable, true, true];
                _continue = false;
                breakTo "exit";
            };
        };

        if (!_continue) exitWith {
            _string = localize "STR_ROOT_CYBERWARFARE_POWERGRID_CONFIRMATION_TIMEOUT";
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            missionNamespace setVariable [_nameOfVariable, true, true];
            _foundGrid = true;
        };

        // Execute action
        if (_action == "on") then {
            // Get objects in radius
            private _allObjects = (9 allObjects 0);
            private _objectsInRadius = _allObjects select {(_x distance _gridObject) <= _radius};

            if (_excludedClassnames isNotEqualTo []) then {
                _objectsInRadius = _objectsInRadius select {!(typeOf _x in _excludedClassnames)};
            };

            private _lightsAffected = count _objectsInRadius;

            // Turn lights ON
            ["ON", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, true];

            // Update state
            _gridObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "ON", true];

            // No explosion on activation - just success message
            _string = format [localize "STR_ROOT_CYBERWARFARE_POWERGRID_ACTIVATED", _lightsAffected, _radius];

            [_computer, _string] call AE3_armaos_fnc_shell_stdout;

        } else {
            if (_action == "off") then {
                // Get objects in radius
                private _allObjects = (9 allObjects 0);
                private _objectsInRadius = _allObjects select {(_x distance _gridObject) <= _radius};

                if (_excludedClassnames isNotEqualTo []) then {
                    _objectsInRadius = _objectsInRadius select {!(typeOf _x in _excludedClassnames)};
                };

                private _lightsAffected = count _objectsInRadius;

                // Turn lights OFF
                ["OFF", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, true];

                // Update state
                _gridObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF", true];

                _string = format [localize "STR_ROOT_CYBERWARFARE_POWERGRID_DEACTIVATED", _lightsAffected, _radius];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;

            } else {
                if (_action == "overload") then {
                    // Check if overload explosion is allowed
                    if !(_allowExplosionOverload) exitWith {
                        _string = localize "STR_ROOT_CYBERWARFARE_ERROR_OVERLOAD_NOT_SUPPORTED";
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    };

                    // Get objects in radius
                    private _allObjects = (9 allObjects 0);
                    private _objectsInRadius = _allObjects select {(_x distance _gridObject) <= _radius};

                    if (_excludedClassnames isNotEqualTo []) then {
                        _objectsInRadius = _objectsInRadius select {!(typeOf _x in _excludedClassnames)};
                    };

                    private _lightsAffected = count _objectsInRadius;

                    // Turn lights OFF first
                    ["OFF", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, true];

                    // Create explosion and effects
                    private _generatorPosition = getPosATL _gridObject;
                    _explosionType createVehicle _generatorPosition;

                    // Mark as destroyed
                    _gridObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_DESTROYED", true, true];
                    _gridObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "DESTROYED", true];

                    // Create spark effects
                    private _surround_pos = [(_generatorPosition select 0) + random [-10, 0, 10], (_generatorPosition select 1) + random [-10, 0, 10], (_generatorPosition select 2) + random [0, 1.5, 3]];
                    private _sparkObj = createVehicle ["Sign_Sphere10cm_F", _surround_pos, [], 0, "CAN_COLLIDE"];
                    _sparkObj hideObjectGlobal true;

                    for "_i" from 1 to 5 do {
                        private _effect = "#particlesource" createVehicleLocal _surround_pos;
                        _sparkObj setPos _surround_pos;
                        _surround_pos = [(_generatorPosition select 0) + random [-10, 0, 10], (_generatorPosition select 1) + random [-10, 0, 10], (_generatorPosition select 2) + random [0, 1.5, 3]];
                        private _claymore = "ClaymoreDirectionalMine_Remote_Ammo_Scripted" createVehicle _surround_pos;
                        _claymore setDamage 1;
                        _effect setParticleParams [
                            ["\A3\data_f\ParticleEffects\Universal\Universal", 16, 0, 1],
                            "", "Billboard", 1,
                            1.2,
                            [0, 0, 0],
                            0.15,
                            [0, 0, 0.2],
                            0.1,
                            0.05,
                            0.1,
                            0.3,
                            [1, 0.7, 0.2, 1],
                            [0.1],
                            0.5,
                            0.1,
                            "", "",
                            _sparkObj
                        ];
                        _effect setDropInterval 0.01;
                        uiSleep (random [0.2, 0.3, 0.4]);
                        deleteVehicle _effect;
                        deleteVehicle _claymore;
                    };
                    deleteVehicle _sparkObj;

                    _string = format [localize "STR_ROOT_CYBERWARFARE_POWERGRID_OVERLOAD_WARNING", _lightsAffected, _radius];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
        };

        // Consume power
        private _currentBatteryLevel = _battery getVariable "AE3_power_batteryLevel";
        private _changeWh = _powerCost;
        private _newLevel = _currentBatteryLevel - (_changeWh/1000);
        [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];

        // Don't show power cost again (already shown before confirmation)
        private _newLevelWh = _newLevel * 1000;
        if (isNil "_newLevelWh" || {!finite _newLevelWh}) then {
            _newLevelWh = 0;
        };
        _string = format ["New Power Level: %1Wh", _newLevelWh];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
} forEach _allPowerGrids;

if (!_foundGrid) then {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_POWERGRID_NOT_FOUND", _gridIdNum];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
