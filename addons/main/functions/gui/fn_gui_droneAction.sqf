#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side drone faction change for the GUI Drones app. Mirrors the core of
 * Root_fnc_changeDroneFaction without terminal I/O. Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (reply target)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _droneId <NUMBER> - Drone id from the registry
 * 3: _faction <STRING> - "west" / "east" / "guer" / "civ"
 * 4: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_droneId", "_faction", ["_commandPath", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_DRONE, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};
_faction = toLower _faction;

// The disable action permanently destroys the drone after the power check succeeds.
if (_faction isEqualTo "disable") exitWith {
	private _drones = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [2, []];
	private _idx = _drones findIf { (_x select 0) == _droneId };
	if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DRONE", _droneId], false] call _reply; };
	private _drone = objectFromNetId ((_drones select _idx) select 1);
	if (isNull _drone) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DRONE", _droneId], false] call _reply; };
	if (!alive _drone || {damage _drone >= 1}) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_DRONE_ALREADY_DISABLED", false] call _reply; };
	private _cost = [_drone, "disable"] call FUNC(getDroneCost);
	if !([_computer, _cost] call FUNC(checkPowerAvailable)) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply; };
	[_computer, _cost] call FUNC(consumePower);
	(vehicle _drone) setDamage 1;
	["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_DRONE, _droneId, "disable"]] call CBA_fnc_serverEvent;
	[_owner, localize "STR_ROOT_CYBERWARFARE_DRONE_DISABLED_SUCCESS", true] call _reply;
};

private _side = switch (_faction) do { case "west": {west}; case "east": {east}; case "guer": {independent}; case "civ": {civilian}; default {sideUnknown} };
if (_side isEqualTo sideUnknown) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_DRONE_FACTION", _faction], false] call _reply; };

if !([_computer, DEVICE_TYPE_DRONE, _droneId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DRONE", _droneId], false] call _reply;
};

private _drones = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [2, []];
private _idx = _drones findIf { (_x select 0) == _droneId };
if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DRONE", _droneId], false] call _reply; };

private _drone = objectFromNetId ((_drones select _idx) select 1);
if (isNull _drone) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DRONE", _droneId], false] call _reply; };
if (side _drone isEqualTo _side) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_DRONE_ALREADY_FACTION", _faction], false] call _reply; };

private _cost = [_drone, "side"] call FUNC(getDroneCost);
if !([_computer, _cost] call FUNC(checkPowerAvailable)) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply; };
[_computer, _cost] call FUNC(consumePower);

[_drone] joinSilent (createGroup _side);

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_DRONE, _droneId, _faction]] call CBA_fnc_serverEvent;
[_owner, localize "STR_ROOT_CYBERWARFARE_DRONE_FACTION_CHANGED", true] call _reply;
