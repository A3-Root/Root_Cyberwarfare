#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side power grid control for the GUI Power Grid app (on/off/overload). Mirrors
 * the core of Root_fnc_powerGridControl without terminal I/O; the GUI handles confirmation for the
 * destructive overload action. Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (reply target)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _gridId <NUMBER> - Grid id from the registry
 * 3: _action <STRING> - "on" / "off" / "overload"
 * 4: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_gridId", "_action", ["_commandPath", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_POWERGRID, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};
_action = toLower _action;
if !(_action in ["on", "off", "overload"]) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_ACTION", _action], false] call _reply; };

if !([_computer, DEVICE_TYPE_POWERGRID, _gridId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_POWERGRID", _gridId], false] call _reply;
};

private _grids = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [7, []];
private _idx = _grids findIf { (_x select 0) == _gridId };
if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_POWERGRID_NOT_FOUND", _gridId], false] call _reply; };

(_grids select _idx) params ["", "_gridNetId", "_gridName", "_radius", "_allowOverload", "_explosionType", "_excludedClassnames"];
private _gridObject = objectFromNetId _gridNetId;
if (isNull _gridObject) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_POWERGRID_OBJECT_NOT_FOUND", false] call _reply; };
if (_gridObject getVariable ["ROOT_CYBERWARFARE_GENERATOR_DESTROYED", false]) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_GENERATOR_DESTROYED", false] call _reply; };

private _cost = missionNamespace getVariable [SETTING_POWERGRID_COST, 15];
if !([_computer, _cost] call FUNC(checkPowerAvailable)) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply; };

// Objects (lights) within the grid radius, minus excluded classes.
private _objectsInRadius = (9 allObjects 0) select { (_x distance _gridObject) <= _radius };
if (_excludedClassnames isNotEqualTo []) then { _objectsInRadius = _objectsInRadius select { !(typeOf _x in _excludedClassnames) }; };

switch (_action) do
{
	case "on":
	{
		["ON", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, format ["rcw_grid_%1", netId _gridObject]];
		_gridObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "ON", true];
		[_computer, _cost] call FUNC(consumePower);
		[_owner, format [localize "STR_ROOT_CYBERWARFARE_POWERGRID_ACTIVATED", count _objectsInRadius, _radius], true] call _reply;
	};
	case "off":
	{
		["OFF", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, format ["rcw_grid_%1", netId _gridObject]];
		_gridObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF", true];
		[_computer, _cost] call FUNC(consumePower);
		[_owner, format [localize "STR_ROOT_CYBERWARFARE_POWERGRID_DEACTIVATED", count _objectsInRadius, _radius], true] call _reply;
	};
	case "overload":
	{
		if !(_allowOverload) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_OVERLOAD_NOT_SUPPORTED", false] call _reply; };
		["OFF", _objectsInRadius] remoteExec ["Root_fnc_powerGeneratorLights", 0, format ["rcw_grid_%1", netId _gridObject]];
		_explosionType createVehicle (getPosATL _gridObject);
		_gridObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_DESTROYED", true, true];
		_gridObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "DESTROYED", true];
		[_computer, _cost] call FUNC(consumePower);
		[_owner, format [localize "STR_ROOT_CYBERWARFARE_POWERGRID_OVERLOAD_WARNING", count _objectsInRadius, _radius], true] call _reply;
	};
};

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_POWERGRID, _gridId, _action]] call CBA_fnc_serverEvent;
