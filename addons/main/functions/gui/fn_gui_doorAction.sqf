#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side door lock/unlock for the GUI Doors app. Locks or unlocks every door of a
 * building the computer can access, consuming power per changed door. Mirrors the core behaviour of
 * Root_fnc_changeDoorState but without the terminal I/O (the GUI handles confirmation and feedback).
 * Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (for the result reply)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _buildingId <NUMBER> - Building id from the device registry
 * 3: _state <STRING> - "lock" or "unlock"
 * 4: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_buildingId", "_state", ["_commandPath", ""], ["_doorId", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_DOOR, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};
if !(_state in ["lock", "unlock"]) exitWith {};

private _cost = missionNamespace getVariable [SETTING_DOOR_COST, 2];

private _doors = [_computer, DEVICE_TYPE_DOOR, _commandPath] call FUNC(getAccessibleDevices);
private _idx = _doors findIf { (_x select 0) == _buildingId };
if (_idx == -1) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_BUILDING_NOT_FOUND", false] call _reply; };

(_doors select _idx) params ["_bId", "_bNetId", "_doorIds", "", "", ["_doorIdMap", []]];
private _building = objectFromNetId _bNetId;
if (isNull _building) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_BUILDING_NOT_FOUND", false] call _reply; };

private _newState = parseNumber (_state isEqualTo "lock");
// A specific door id (#2) restricts the operation to that single door; otherwise the whole building.
// The id sent by the GUI is the mission-maker's custom door ID, resolved back to the engine number.
if (_doorId isNotEqualTo "") then {
	private _d = parseNumber _doorId;
	private _realDoor = _d;
	{
		if ((_x select 0) == _d) exitWith { _realDoor = _x select 1; };
	} forEach _doorIdMap;
	_doorIds = _doorIds select { _x == _realDoor };
};
private _changing = _doorIds select { (_building getVariable [format ["bis_disabled_Door_%1", _x], 5]) != _newState };

if (_changing isEqualTo []) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_NO_BUILDINGS_CRITERIA", false] call _reply; };

private _total = (count _changing) * _cost;
if !([_computer, _total] call FUNC(checkPowerAvailable)) exitWith
{
	[_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply;
};

[_computer, _total] call FUNC(consumePower);

{
	_building setVariable [format ["bis_disabled_Door_%1", _x], _newState, true];
	if (_state isEqualTo "lock") then
	{
		_building setVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _x], true, true];
	}
	else
	{
		_building setVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _x], nil, true];
	};
} forEach _changing;

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_DOOR, _bId, _state]] call CBA_fnc_serverEvent;

[_owner, format [localize "STR_ROOT_CYBERWARFARE_OPERATION_COMPLETED_DOORS", count _changing], true] call _reply;
