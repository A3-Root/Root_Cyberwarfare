#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Opens, closes, locks or unlocks doors in buildings (terminal "door" command)
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _buildingId <STRING> - Building ID or "a" for all
 * 4: _doorId <STRING> - Door ID or "a" for all doors in building
 * 5: _doorDesiredState <STRING> - "open", "close", "lock", "unlock", "lockopen" or "lockclosed"
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

DEBUG_LOG_4("changeDoorState - Computer: %1, Building: %2, Door: %3, State: %4",_computer,_buildingId,_doorId,_doorDesiredState);

scopeName "exit";

// Check for help request
if ((_buildingId in ["-h", "help"]) || (_doorId in ["-h", "help"])) exitWith {
    DEBUG_LOG("Showing help text");

    [_computer, [[["DOOR COMMAND HELP", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Description:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Open, close, lock or unlock doors in buildings."]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Syntax:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["door <BuildingID> <DoorID> <state>"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Parameters:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["BuildingID", "#008DF8"], ["  - ID of the building containing the door", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["DoorID", "#008DF8"], ["      - ID of the specific door (use 'a' for all doors)", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["state", "#008DF8"], ["       - open, close  : move the door, lock unchanged", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                 lock, unlock : set the lock, door does not move"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["                 lockopen, lockclosed : move the door and lock it"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Examples:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 1 lock       - Lock door #1 in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 a lock       - Lock all doors in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 2 unlock     - Unlock door #2 in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 a open       - Open all doors in building #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  door 1234 3 lockopen   - Open door #3 and lock it open"]]]] call AE3_armaos_fnc_shell_stdout;
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

if !(_doorDesiredState in DOOR_STATES) exitWith {
    private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_DOOR_STATE", _doorDesiredState];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// "Open, Locked" style text for one door, optionally as it ends up after a state is applied
private _stateText = {
    params ["_building", "_door", ["_state", ""]];
    ([_building, _door] call FUNC(getDoorState)) params ["_isOpen", "_isLocked"];
    if (_state in ["open", "lockopen"]) then { _isOpen = true; };
    if (_state in ["close", "lockclosed"]) then { _isOpen = false; };
    if (_state in ["lock", "lockopen", "lockclosed"]) then { _isLocked = true; };
    if (_state isEqualTo "unlock") then { _isLocked = false; };
    format ["%1, %2",
        localize (["STR_ROOT_CYBERWARFARE_DOOR_CLOSED", "STR_ROOT_CYBERWARFARE_DOOR_OPEN"] select _isOpen),
        localize (["STR_ROOT_CYBERWARFARE_DOOR_UNLOCKED", "STR_ROOT_CYBERWARFARE_DOOR_LOCKED"] select _isLocked)]
};

// Get accessible doors
private _accessibleDoors = [_computer, DEVICE_TYPE_DOOR, _commandPath] call FUNC(getAccessibleDevices);
DEBUG_LOG_1("Accessible doors found: %1",count _accessibleDoors);

if (_accessibleDoors isEqualTo []) exitWith {
    DEBUG_LOG("No accessible doors - operation failed");
    [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_NO_ACCESSIBLE_BUILDINGS"] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Filter for specific building
private _targetDoors = _accessibleDoors select {
    (_x select 0) == _buildingIdNum
};

DEBUG_LOG_2("Target building %1 - matching doors: %2",_buildingIdNum,count _targetDoors);

if (_targetDoors isEqualTo []) exitWith {
    DEBUG_LOG_1("Building %1 not found or not accessible",_buildingIdNum);
    private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_BUILDING_NOT_FOUND", _buildingIdNum];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

// Get building object from first matching door entry
private _doorEntry = _targetDoors select 0;
_doorEntry params ["_bId", "_buildingNetId", "_doorsOfBuilding", "", "", ["_doorIdMap", []]];
private _building = objectFromNetId _buildingNetId;

// Handle "all doors" case
if (_doorId isEqualTo "a") then {
    // Doors that need changing
    private _changingDoors = [_building, _doorsOfBuilding, _doorDesiredState, true] call FUNC(setDoorState);
    private _countOfChangingDoors = count _changingDoors;

    if (_countOfChangingDoors == 0) exitWith {
        [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_NO_BUILDINGS_CRITERIA"] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    private _totalCost = _countOfChangingDoors * _powerCostPerDoor;
    private _string = format [localize "STR_ROOT_CYBERWARFARE_AFFECTED_DOORS", _countOfChangingDoors, _totalCost];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

    // Check power and get confirmation
    if !([_computer, _totalCost, DEVICE_TYPE_DOOR, parseNumber (str _buildingId)] call FUNC(checkPowerAvailable)) exitWith {
        [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER"] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    if !([_computer, _totalCost, DEVICE_TYPE_DOOR, parseNumber (str _buildingId)] call FUNC(getUserConfirmation)) exitWith {
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    // Consume power
    [_computer, _totalCost, DEVICE_TYPE_DOOR, parseNumber (str _buildingId)] call FUNC(consumePower);

    // Apply changes to all doors
    [_building, _changingDoors, _doorDesiredState] call FUNC(setDoorState);

    // Broadcast event
    ["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_DOOR, _bId, _doorDesiredState]] call CBA_fnc_serverEvent;

    _string = format [localize "STR_ROOT_CYBERWARFARE_OPERATION_COMPLETED_DOORS", _countOfChangingDoors];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

} else {
    // Handle single door. The typed ID is resolved through the building's custom door-ID map first
    // (mission-maker assigned IDs), then falls back to the raw engine door number.
    private _realDoor = -1;
    {
        if ((_x select 0) == _doorIdNum) exitWith { _realDoor = _x select 1; };
    } forEach _doorIdMap;
    if (_realDoor == -1 && {_doorIdNum in _doorsOfBuilding}) then { _realDoor = _doorIdNum; };

    if (_realDoor == -1) exitWith {
        private _string = format [localize "STR_ROOT_CYBERWARFARE_ERROR_DOOR_NOT_IN_BUILDING", _doorIdNum, _buildingIdNum];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    // Check if already in desired state
    if (([_building, [_realDoor], _doorDesiredState, true] call FUNC(setDoorState)) isEqualTo []) exitWith {
        private _string = format [localize "STR_ROOT_CYBERWARFARE_DOOR_ALREADY_IN_STATE", [_building, _realDoor] call _stateText];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    // Check power and get confirmation
    if !([_computer, _powerCostPerDoor, DEVICE_TYPE_DOOR, parseNumber (str _buildingId)] call FUNC(checkPowerAvailable)) exitWith {
        [_computer, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER"] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    if !([_computer, _powerCostPerDoor, DEVICE_TYPE_DOOR, parseNumber (str _buildingId)] call FUNC(getUserConfirmation)) exitWith {
        missionNamespace setVariable [_nameOfVariable, true, true];
    };

    // Consume power
    [_computer, _powerCostPerDoor, DEVICE_TYPE_DOOR, parseNumber (str _buildingId)] call FUNC(consumePower);

    // Apply change
    [_building, [_realDoor], _doorDesiredState] call FUNC(setDoorState);

    // Broadcast event
    ["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_DOOR, _buildingIdNum, _doorDesiredState]] call CBA_fnc_serverEvent;

    private _string = format [localize "STR_ROOT_CYBERWARFARE_DOOR_STATE_SET", _doorIdNum, [_building, _realDoor, _doorDesiredState] call _stateText];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
