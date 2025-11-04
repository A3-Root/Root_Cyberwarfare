#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Changes the lock state of doors in buildings
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _buildingId <STRING> - Building ID or "a" for all
 * 4: _doorId <STRING> - Door ID or "a" for all doors in building
 * 5: _doorDesiredState <STRING> - "lock" or "unlock"
 * 6: _commandPath <STRING> (Optional) - Command path for backdoor checking, default: ""
 *
 * Return Value:
 * None
 *
 * Example:
 * [123, _laptop, "var1", "1234", "1", "lock"] call Root_fnc_changeDoorState;
 *
 * Public: No
 */

params [
    "_owner",
    ["_computer", objNull, [objNull]],
    ["_nameOfVariable", "", [""]],
    ["_buildingId", "", [""]],
    ["_doorId", "", [""]],
    ["_doorDesiredState", "", [""]],
    ["_commandPath", "", [""]]
];

scopeName "exit";

// Check for help request
if ((_buildingId in ["-h", "help"]) || (_doorId in ["-h", "help"])) exitWith {
    [_computer, [[["DOOR COMMAND HELP", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Description:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Lock or unlock doors in buildings using this function."]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Syntax:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["door <BuildingID> <DoorID> <state>"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Parameters:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["BuildingID", "#008DF8"], ["  - ID of the building containing the door", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["DoorID", "#008DF8"], ["      - ID of the specific door (use 'a' for all doors)", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["state", "#008DF8"], ["       - 'lock' or 'unlock'", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Examples:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 1 lock       - Lock door #1 in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 a lock       - Lock all doors in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 2 unlock     - Unlock door #2 in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 a unlock     - Unlock all doors in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Note:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Each door operation costs power"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- 'a' affects all doors in the specified building"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Requires power confirmation for bulk operations"]]]] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Get power cost from CBA settings
private _powerCostPerDoor = missionNamespace getVariable [SETTING_DOOR_COST, 2];

// Normalize inputs
private _buildingIdNum = parseNumber _buildingId;
_doorDesiredState = toLower _doorDesiredState;
private _doorIdNum = parseNumber _doorId;

// Validate inputs
if (_buildingIdNum == 0) exitWith {
    private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_BUILDING_ID", _buildingId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

if !(_doorIdNum != 0 || _doorId isEqualTo "a") exitWith {
    private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_DOOR_ID", _doorId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

if !(_doorDesiredState in ["lock", "unlock"]) exitWith {
    private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_DOOR_STATE", _doorDesiredState];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Get accessible doors
private _accessibleDoors = [_computer, DEVICE_TYPE_DOOR, _commandPath] call FUNC(getAccessibleDevices);
if (_accessibleDoors isEqualTo []) exitWith {
    [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_NO_ACCESSIBLE_BUILDINGS"] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Filter for specific building
private _targetDoors = _accessibleDoors select {
    (_x select 0) == _buildingIdNum
};

if (_targetDoors isEqualTo []) exitWith {
    private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_BUILDING_NOT_FOUND", _buildingIdNum];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Get building object from first matching door entry
private _doorEntry = _targetDoors select 0;
_doorEntry params ["_bId", "_buildingNetId", "_doorsOfBuilding"];
private _building = objectFromNetId _buildingNetId;

// Handle "all doors" case
if (_doorId isEqualTo "a") then {
    // Count doors that need changing
    private _countOfChangingDoors = 0;
    {
        private _currentState = _building getVariable [format ["bis_disabled_Door_%1", _x], 5];
        if ((_doorDesiredState isEqualTo "lock" && _currentState != 1) ||
            {_doorDesiredState isEqualTo "unlock" && _currentState != 0}) then {
            _countOfChangingDoors = _countOfChangingDoors + 1;
        };
    } forEach _doorsOfBuilding;

    if (_countOfChangingDoors == 0) exitWith {
        [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_NO_BUILDINGS_CRITERIA"] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    private _totalCost = _countOfChangingDoors * _powerCostPerDoor;
    private _string = format [localize "STR_ROOT_CYBERWARFARE_AFFECTED_DOORS", _countOfChangingDoors, _totalCost];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

    // Check power and get confirmation
    if !([_computer, _totalCost] call FUNC(checkPowerAvailable)) exitWith {
        [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER"] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    if !([_computer, _totalCost] call FUNC(getUserConfirmation)) exitWith {
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    // Consume power
    [_computer, _totalCost] call FUNC(consumePower);

    // Apply changes to all doors
    private _newState = parseNumber (_doorDesiredState isEqualTo "lock");
    {
        _building setVariable [format ["bis_disabled_Door_%1", _x], _newState, true];
        // Mark/unmark door as cyber-locked for breach mod integration
        if (_doorDesiredState isEqualTo "lock") then {
            _building setVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _x], true, true];
        } else {
            _building setVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _x], nil, true];
        };
    } forEach _doorsOfBuilding;

    // Broadcast event
    ["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_DOOR, _bId, _doorDesiredState]] call CBA_fnc_serverEvent;

    _string = format [localize "STR_ROOT_CYBERWARFARE_OPERATION_COMPLETED_DOORS", _countOfChangingDoors];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

} else {
    // Handle single door
    if !(_doorIdNum in _doorsOfBuilding) exitWith {
        private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_DOOR_NOT_IN_BUILDING", _doorIdNum, _buildingIdNum];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    private _currentState = _building getVariable [format ["bis_disabled_Door_%1", _doorIdNum], 5];
    private _targetState = parseNumber (_doorDesiredState isEqualTo "lock");

    // Check if already in desired state
    if (_currentState == _targetState) exitWith {
        private _string = if (_doorDesiredState isEqualTo "lock") then {
            localize "STR_ROOT_CYBERWARFARE_DOOR_ALREADY_LOCKED"
        } else {
            localize "STR_ROOT_CYBERWARFARE_DOOR_ALREADY_UNLOCKED"
        };
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    // Check power and get confirmation
    if !([_computer, _powerCostPerDoor] call FUNC(checkPowerAvailable)) exitWith {
        [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER"] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    if !([_computer, _powerCostPerDoor] call FUNC(getUserConfirmation)) exitWith {
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    // Consume power
    [_computer, _powerCostPerDoor] call FUNC(consumePower);

    // Apply change
    _building setVariable [format ["bis_disabled_Door_%1", _doorIdNum], _targetState, true];

    // Mark/unmark door as cyber-locked for breach mod integration
    if (_doorDesiredState isEqualTo "lock") then {
        _building setVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _doorIdNum], true, true];
    } else {
        _building setVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _doorIdNum], nil, true];
    };

    // Broadcast event
    ["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_DOOR, _buildingIdNum, _doorDesiredState]] call CBA_fnc_serverEvent;

    private _string = if (_doorDesiredState isEqualTo "lock") then {
        localize "STR_ROOT_CYBERWARFARE_DOOR_LOCKED_SUCCESS"
    } else {
        localize "STR_ROOT_CYBERWARFARE_DOOR_UNLOCKED_SUCCESS"
    };
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
