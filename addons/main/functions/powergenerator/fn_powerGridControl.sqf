#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Controls power grid devices (on/off/overload)
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
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
 * [123, _laptop, "var1", "1234", "on", "/tools/"] call Root_fnc_powerGridControl;
 *
 * Public: No
 */

params ["_owner", "_computer", "_nameOfVariable", "_gridId", "_action", "_commandPath"];

scopeName "exit";

// Check for help request
if ((_gridId in ["-h", "help"]) || (_action in ["-h", "help"])) exitWith {
    [_computer, [[["POWERGRID COMMAND HELP", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Description:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Control power grid generators to manage lights and electrical systems in an area."]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Syntax:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["powergrid <GridID> <action>"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Parameters:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["GridID", "#008DF8"], ["  - ID of the power grid generator", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["action", "#008DF8"], ["  - Action to perform: 'on', 'off', or 'overload'", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Examples:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  powergrid 1234 on         - Turn on power grid #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  powergrid 1234 off        - Turn off power grid #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  powergrid 1234 overload   - Overload and destroy grid #1234 (if enabled)"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Actions:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["on", "#008DF8"], ["       - Activate lights in radius", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["off", "#008DF8"], ["      - Deactivate lights in radius", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["overload", "#008DF8"], [" - Cause explosion and permanent destruction (if allowed)", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Warning:", "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["OVERLOAD is PERMANENT and will destroy the generator!"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Note:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Affects all lights within configured radius"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Requires power confirmation"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Once destroyed, grid cannot be repaired"]]]] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

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

// Get power cost from CBA setting
private _powerCost = missionNamespace getVariable [SETTING_POWERGRID_COST, 15];

private _foundGrid = false;
{
    _x params ["_storedGridId", "_gridNetId", "_gridName", "_radius", "_allowExplosionOverload", "_explosionType", "_excludedClassnames", "_availableToFutureLaptops", "", "_linkedComputers"];

    if (_gridIdNum == _storedGridId) then {
        private _gridObject = objectFromNetId _gridNetId;
        private _success = true;

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
        if !([_computer, _powerCost] call FUNC(checkPowerAvailable)) exitWith {
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

        if !([_computer, _powerCost] call FUNC(getUserConfirmation)) exitWith {
            _string = localize "STR_ROOT_CYBERWARFARE_POWERGRID_CANCELLED";
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
            ["ON", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, format ["rcw_grid_%1", netId _gridObject]];

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
                ["OFF", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, format ["rcw_grid_%1", netId _gridObject]];

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
                        _success = false;
                    };

                    // Get objects in radius
                    private _allObjects = (9 allObjects 0);
                    private _objectsInRadius = _allObjects select {(_x distance _gridObject) <= _radius};

                    if (_excludedClassnames isNotEqualTo []) then {
                        _objectsInRadius = _objectsInRadius select {!(typeOf _x in _excludedClassnames)};
                    };

                    private _lightsAffected = count _objectsInRadius;

                    // Turn lights OFF first
                    ["OFF", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, format ["rcw_grid_%1", netId _gridObject]];

                    // Create explosion and effects
                    private _generatorPosition = getPosATL _gridObject;
                    _explosionType createVehicle _generatorPosition;

                    // Mark as destroyed
                    _gridObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_DESTROYED", true, true];
                    _gridObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "DESTROYED", true];

                    // Create spark effects
                    private _surround_pos = [(_generatorPosition select 0) + (floor random (10) - 5), (_generatorPosition select 1) + (floor random (10) - 5), (_generatorPosition select 2) + (floor random (3))];
                    for "_i" from 1 to 5 do {
                        _surround_pos = [(_generatorPosition select 0) + (floor random (10) - 5), (_generatorPosition select 1) + (floor random (10) - 5), (_generatorPosition select 2) + (floor random (3))];
                        private _claymore = "ClaymoreDirectionalMine_Remote_Ammo_Scripted" createVehicle _surround_pos;
                        _claymore setDamage 1;
                        uiSleep (random [0.1, 0.2, 0.3]);
                        deleteVehicle _claymore;
                    };

                    _string = format [localize "STR_ROOT_CYBERWARFARE_POWERGRID_OVERLOAD_WARNING", _lightsAffected, _radius];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            };
        };

        if (_success) then {
            [_computer, _powerCost] call FUNC(consumePower);
        };
    };
} forEach _allPowerGrids;

if (!_foundGrid) then {
    _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_POWERGRID_NOT_FOUND", _gridIdNum];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
