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
private _valid = ["lock", "unlock", "engineon", "engineoff", "lightson", "lightsoff", "brakes", "alarm", "refuel", "drain", "speedup", "slowdown"];
if !(_action in _valid) exitWith {};

if !([_computer, DEVICE_TYPE_VEHICLE, _vehicleId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply;
};

private _vehicles = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [6, []];
private _idx = _vehicles findIf { (_x select 0) == _vehicleId };
if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply; };

private _vehicle = objectFromNetId ((_vehicles select _idx) select 1);
if (isNull _vehicle || {!alive _vehicle}) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply; };

// Feature gating: the action must be permitted for this vehicle (set at registration). Clear UX (#2).
private _needFlag = switch (_action) do {
	case "engineon"; case "engineoff": { "ROOT_CYBERWARFARE_VEHICLE_ENGINE" };
	case "lightson"; case "lightsoff": { "ROOT_CYBERWARFARE_VEHICLE_LIGHTS" };
	case "brakes": { "ROOT_CYBERWARFARE_VEHICLE_BRAKES" };
	case "alarm": { "ROOT_CYBERWARFARE_VEHICLE_DOOR" };
	case "refuel"; case "drain": { "ROOT_CYBERWARFARE_VEHICLE_FUEL" };
	case "speedup"; case "slowdown": { "ROOT_CYBERWARFARE_VEHICLE_SPEED" };
	default { "" };
};
if (_needFlag isNotEqualTo "" && {!(_vehicle getVariable [_needFlag, false])}) exitWith {
	[_owner, "This control is not enabled on this vehicle.", false] call _reply;
};
if (_action isEqualTo "brakes" && {!(_vehicle isKindOf "LandVehicle")}) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_BRAKES_LAND_ONLY", false] call _reply;
};

// Power check + consume (clear feedback on low battery, General #2).
private _cost = _vehicle getVariable ["ROOT_CYBERWARFARE_VEHICLE_COST", 2];
if !([_computer, _cost] call FUNC(checkPowerAvailable)) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply;
};
[_computer, _cost] call FUNC(consumePower);

private _msg = "";
switch (_action) do
{
	case "lock":      { _vehicle lock true;  _msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_LOCKED"; };
	case "unlock":    { _vehicle lock false; _msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_UNLOCKED"; };
	case "engineon":  { [_vehicle, true] remoteExec ["engineOn", _vehicle]; _msg = "Engine started."; };
	case "engineoff": { [_vehicle, false] remoteExec ["engineOn", _vehicle]; _msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_ENGINE_OFF"; };
	case "lightson":  { [_vehicle, true] remoteExec ["setPilotLight", _vehicle]; _msg = "Lights on."; };
	case "lightsoff": { [_vehicle, false] remoteExec ["setPilotLight", _vehicle]; _msg = "Lights off."; };
	case "refuel":    { [_vehicle, 1] remoteExec ["setFuel", _vehicle]; _msg = "Fuel/battery set to 100%."; };
	case "drain":     { [_vehicle, 0] remoteExec ["setFuel", _vehicle]; _msg = "Fuel/battery drained."; };
	case "alarm": {
		private _dur = _vehicle getVariable ["ROOT_CYBERWARFARE_ALARM_MIN", 5];
		[_vehicle, _dur] remoteExec ["Root_fnc_localSoundBroadcast", [0, -2] select isDedicated, false];
		_msg = "Alarm triggered.";
	};
	case "speedup"; case "slowdown": {
		private _value = _vehicle getVariable [["ROOT_CYBERWARFARE_SPEED_MAX", "ROOT_CYBERWARFARE_SPEED_MIN"] select (_action isEqualTo "slowdown"), [50, -50] select (_action isEqualTo "slowdown")];
		private _vel = velocity _vehicle;
		private _dir = getDir _vehicle;
		[_vehicle, [(_vel select 0) + (sin _dir * _value), (_vel select 1) + (cos _dir * _value), _vel select 2]] remoteExec ["setVelocity", _vehicle];
		_msg = format ["Speed adjusted by %1 km/h.", _value];
	};
	case "brakes": {
		[_vehicle, _vehicle getVariable ["ROOT_CYBERWARFARE_BRAKES_MAX", 10]] spawn {
			params ["_veh", "_decel"];
			private _target = 0.01;
			private _last = time;
			while {alive _veh && {abs (speed _veh) > 1}} do {
				private _dt = time - _last; _last = time;
				private _vel = velocity _veh;
				private _h = [_vel select 0, _vel select 1, 0];
				private _sp = sqrt ((_h select 0)^2 + (_h select 1)^2);
				private _ns = (_sp - (_decel * _dt)) max _target;
				private _u = if (_sp > 0.001) then { [(_h select 0)/_sp, (_h select 1)/_sp, 0] } else { [0,0,0] };
				[_veh, [(_u select 0)*_ns, (_u select 1)*_ns, _vel select 2]] remoteExec ["setVelocity", _veh];
				uiSleep 0.02;
			};
		};
		_msg = "Emergency brakes applied.";
	};
};

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_VEHICLE, _vehicleId, _action]] call CBA_fnc_serverEvent;
[_owner, _msg, true] call _reply;
