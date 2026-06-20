#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side vehicle control for the GUI Vehicles app (lock / unlock / engine off).
 * Self-contained simple actions; runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (reply target)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _vehicleId <NUMBER> - Vehicle id from the registry
 * 3: _action <STRING> - "lock" / "unlock" / "engineoff"
 * 4: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_vehicleId", "_action", ["_commandPath", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_VEHICLE, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};
_action = toLower _action;
if !(_action in ["lock", "unlock", "engineoff"]) exitWith {};

if !([_computer, DEVICE_TYPE_VEHICLE, _vehicleId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply;
};

private _vehicles = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [6, []];
private _idx = _vehicles findIf { (_x select 0) == _vehicleId };
if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply; };

private _vehicle = objectFromNetId ((_vehicles select _idx) select 1);
if (isNull _vehicle) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply; };

private _msg = "";
switch (_action) do
{
	case "lock":      { _vehicle lock true;  _msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_LOCKED"; };
	case "unlock":    { _vehicle lock false; _msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_UNLOCKED"; };
	case "engineoff": { _vehicle engineOn false; _msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_ENGINE_OFF"; };
};

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_VEHICLE, _vehicleId, _action]] call CBA_fnc_serverEvent;
[_owner, _msg, true] call _reply;
