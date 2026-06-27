#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side vehicle controls for the GUI Vehicles app.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _vehicleId <NUMBER> - Vehicle id from the registry
 * 3: _action <STRING> - Requested vehicle action
 * 4: _commandPath <STRING> - Backdoor command path
 * 5: _value <NUMBER> - Slider value for bounded actions
 * 6: _lock <BOOLEAN> - Keep enforcing the selected speed
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_vehicleId", "_action", ["_commandPath", ""], ["_value", 0], ["_lock", false]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_VEHICLE, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};

_action = toLower _action;
if (!(_value isEqualType 0)) then { _value = parseNumber (str _value); };

private _valid = ["lock", "unlock", "engineon", "engineoff", "lightson", "lightsoff", "brakes", "alarm", "drain", "speedup", "slowdown", "setfuel", "setspeed", "setalarm"];
if !(_action in _valid) exitWith {};

if !([_computer, DEVICE_TYPE_VEHICLE, _vehicleId, _commandPath] call FUNC(isDeviceAccessible)) exitWith {
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply;
};

private _vehicles = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [6, []];
private _idx = _vehicles findIf { (_x select 0) == _vehicleId };
if (_idx == -1) exitWith {
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply;
};

private _vehicle = objectFromNetId ((_vehicles select _idx) select 1);
if (isNull _vehicle || {!alive _vehicle}) exitWith {
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_VEHICLE", _vehicleId], false] call _reply;
};

private _needFlag = switch (_action) do {
	case "engineon";
	case "engineoff": { "ROOT_CYBERWARFARE_VEHICLE_ENGINE" };
	case "lightson";
	case "lightsoff": { "ROOT_CYBERWARFARE_VEHICLE_LIGHTS" };
	case "brakes": { "ROOT_CYBERWARFARE_VEHICLE_BRAKES" };
	case "alarm";
	case "setalarm": { "ROOT_CYBERWARFARE_VEHICLE_DOOR" };
	case "drain";
	case "setfuel": { "ROOT_CYBERWARFARE_VEHICLE_FUEL" };
	case "speedup";
	case "slowdown";
	case "setspeed": { "ROOT_CYBERWARFARE_VEHICLE_SPEED" };
	default { "" };
};
if (_needFlag isNotEqualTo "" && {!(_vehicle getVariable [_needFlag, false])}) exitWith {
	[_owner, "This control is not enabled on this vehicle.", false] call _reply;
};

if (_action isEqualTo "brakes" && {!(_vehicle isKindOf "LandVehicle")}) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_BRAKES_LAND_ONLY", false] call _reply;
};

private _validationError = "";
if (_action isEqualTo "setfuel") then {
	private _fmin = _vehicle getVariable ["ROOT_CYBERWARFARE_FUEL_MIN", 0];
	private _fmax = _vehicle getVariable ["ROOT_CYBERWARFARE_FUEL_MAX", 100];
	private _currentFuel = round ((fuel _vehicle) * 100);
	private _fuelCeiling = _currentFuel min _fmax;
	private _fuelFloor = _fmin min _fuelCeiling;
	if (_value < _fuelFloor || {_value > _fuelCeiling}) then {
		_validationError = format ["Fuel/battery can only be reduced to %1-%2%3.", _fuelFloor, _fuelCeiling, "%"];
	};
};

if (_action isEqualTo "setspeed") then {
	private _smin = _vehicle getVariable ["ROOT_CYBERWARFARE_SPEED_MIN", -50];
	private _smax = _vehicle getVariable ["ROOT_CYBERWARFARE_SPEED_MAX", 50];
	if (_value < _smin || {_value > _smax}) then {
		_validationError = format ["Speed must be %1 to %2 km/h.", _smin, _smax];
	};
};

if (_action isEqualTo "brakes") then {
	private _bmin = _vehicle getVariable ["ROOT_CYBERWARFARE_BRAKES_MIN", 1];
	private _bmax = _vehicle getVariable ["ROOT_CYBERWARFARE_BRAKES_MAX", 10];
	if (_value < _bmin || {_value > _bmax}) then {
		_validationError = format ["Brake rate must be %1 to %2 m/s2.", _bmin, _bmax];
	};
};

if (_action isEqualTo "setalarm") then {
	private _amin = _vehicle getVariable ["ROOT_CYBERWARFARE_ALARM_MIN", 1];
	private _amax = _vehicle getVariable ["ROOT_CYBERWARFARE_ALARM_MAX", 30];
	if (_value < _amin || {_value > _amax}) then {
		_validationError = format ["Alarm must be %1-%2 s.", _amin, _amax];
	};
};
if (_validationError isNotEqualTo "") exitWith {
	[_owner, _validationError, false] call _reply;
};

private _cost = _vehicle getVariable ["ROOT_CYBERWARFARE_VEHICLE_COST", 2];
if !([_computer, _cost] call FUNC(checkPowerAvailable)) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply;
};
[_computer, _cost] call FUNC(consumePower);

private _removeSpeedHandler = {
	params ["_vehicle"];
	private _handle = _vehicle getVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1];
	if (_handle >= 0) then {
		[_handle] call CBA_fnc_removePerFrameHandler;
		_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1, true];
	};
	_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_LOCK", 0, true];
};

private _removeBrakeHandler = {
	params ["_vehicle"];
	private _handle = _vehicle getVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", -1];
	if (_handle >= 0) then {
		[_handle] call CBA_fnc_removePerFrameHandler;
		_vehicle setVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", -1, true];
	};
};

private _setVehicleLock = {
	params ["_vehicle", "_locked"];
	if (isClass (configFile >> "CfgPatches" >> "ace_vehiclelock")) then {
		["ace_vehiclelock_setVehicleLock", [_vehicle, _locked], [_vehicle]] call CBA_fnc_targetEvent;
	} else {
		[_vehicle, [0, 2] select _locked] remoteExec ["lock", _vehicle];
	};
};

private _msg = "";
switch (_action) do {
	case "lock": {
		[_vehicle, true] call _setVehicleLock;
		_msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_LOCKED";
	};
	case "unlock": {
		[_vehicle, false] call _setVehicleLock;
		_msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_UNLOCKED";
	};
	case "engineon": {
		[_vehicle, true] remoteExec ["engineOn", _vehicle];
		_msg = "Engine started.";
	};
	case "engineoff": {
		[_vehicle, false] remoteExec ["engineOn", _vehicle];
		_msg = localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_ENGINE_OFF";
	};
	case "lightson": {
		[_vehicle, true] remoteExec ["setPilotLight", _vehicle];
		_msg = "Lights on.";
	};
	case "lightsoff": {
		[_vehicle, false] remoteExec ["setPilotLight", _vehicle];
		_msg = "Lights off.";
	};
	case "drain": {
		[_vehicle, 0] remoteExec ["setFuel", _vehicle];
		_msg = "Fuel/battery drained.";
	};
	case "setfuel": {
		[_vehicle, (_value / 100) max 0] remoteExec ["setFuel", _vehicle];
		_msg = format ["Fuel/battery set to %1%2.", round _value, "%"];
	};
	case "setspeed": {
		[_vehicle] call _removeSpeedHandler;
		[_vehicle] call _removeBrakeHandler;
		private _dir = getDir _vehicle;
		private _forward = [sin _dir, cos _dir, 0];
		private _vel = velocity _vehicle;
		private _startSpeed = ((_vel select 0) * (_forward select 0)) + ((_vel select 1) * (_forward select 1));
		private _targetSpeed = _value / 3.6;
		private _handle = [{
			params ["_args", "_handle"];
			_args params ["_vehicle", "_startSpeed", "_targetSpeed", "_startTime", "_lock"];
			if (!alive _vehicle) exitWith {
				[_handle] call CBA_fnc_removePerFrameHandler;
				_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1, true];
			};

			private _progress = ((time - _startTime) / 5) min 1;
			private _speedNow = _startSpeed + ((_targetSpeed - _startSpeed) * _progress);
			private _dir = getDir _vehicle;
			private _vel = velocity _vehicle;
			[_vehicle, [sin _dir * _speedNow, cos _dir * _speedNow, _vel select 2]] remoteExec ["setVelocity", _vehicle];

			if (_progress >= 1) exitWith {
				[_handle] call CBA_fnc_removePerFrameHandler;
				_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1, true];
				if (_lock && {(abs _targetSpeed) > 0.01}) then {
					_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_LOCK", _targetSpeed, true];
					private _lockHandle = [{
						params ["_args", "_handle"];
						_args params ["_vehicle"];
						private _targetSpeed = _vehicle getVariable ["ROOT_CYBERWARFARE_SPEED_LOCK", 0];
						if (!alive _vehicle || {(abs _targetSpeed) <= 0.01}) exitWith {
							[_handle] call CBA_fnc_removePerFrameHandler;
							_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1, true];
						};
						private _dir = getDir _vehicle;
						private _vel = velocity _vehicle;
						[_vehicle, [sin _dir * _targetSpeed, cos _dir * _targetSpeed, _vel select 2]] remoteExec ["setVelocity", _vehicle];
					}, 0.1, [_vehicle]] call CBA_fnc_addPerFrameHandler;
					_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", _lockHandle, true];
				};
			};
		}, 0.05, [_vehicle, _startSpeed, _targetSpeed, time, _lock]] call CBA_fnc_addPerFrameHandler;
		_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", _handle, true];
		_msg = format ["Speed changing to %1 km/h over 5 seconds.", round _value];
	};
	case "setalarm": {
		if (_value < 1) then { _value = 1; };
		[_vehicle, _value] remoteExec ["Root_fnc_localSoundBroadcast", [0, -2] select isDedicated, false];
		_msg = format ["Alarm triggered for %1s.", round _value];
	};
	case "alarm": {
		private _dur = _vehicle getVariable ["ROOT_CYBERWARFARE_ALARM_MIN", 5];
		[_vehicle, _dur] remoteExec ["Root_fnc_localSoundBroadcast", [0, -2] select isDedicated, false];
		_msg = "Alarm triggered.";
	};
	case "speedup";
	case "slowdown": {
		private _speedChange = _vehicle getVariable [["ROOT_CYBERWARFARE_SPEED_MAX", "ROOT_CYBERWARFARE_SPEED_MIN"] select (_action isEqualTo "slowdown"), [50, -50] select (_action isEqualTo "slowdown")];
		private _vel = velocity _vehicle;
		private _dir = getDir _vehicle;
		[_vehicle, [(_vel select 0) + (sin _dir * _speedChange), (_vel select 1) + (cos _dir * _speedChange), _vel select 2]] remoteExec ["setVelocity", _vehicle];
		_msg = format ["Speed adjusted by %1 km/h.", _speedChange];
	};
	case "brakes": {
		[_vehicle] call _removeSpeedHandler;
		[_vehicle] call _removeBrakeHandler;
		private _handle = [{
			params ["_args", "_handle"];
			_args params ["_vehicle", "_decel"];
			if (!alive _vehicle) exitWith {
				[_handle] call CBA_fnc_removePerFrameHandler;
				_vehicle setVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", -1, true];
			};

			private _vel = velocity _vehicle;
			private _horizontal = [_vel select 0, _vel select 1, 0];
			private _speedNow = vectorMagnitude _horizontal;
			if (_speedNow <= 0.1) exitWith {
				[_vehicle, [0, 0, _vel select 2]] remoteExec ["setVelocity", _vehicle];
				[_handle] call CBA_fnc_removePerFrameHandler;
				_vehicle setVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", -1, true];
			};

			private _nextSpeed = (_speedNow - (_decel * 0.05)) max 0;
			private _scale = _nextSpeed / _speedNow;
			[_vehicle, [(_vel select 0) * _scale, (_vel select 1) * _scale, _vel select 2]] remoteExec ["setVelocity", _vehicle];
		}, 0.05, [_vehicle, _value]] call CBA_fnc_addPerFrameHandler;
		_vehicle setVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", _handle, true];
		_msg = format ["Brakes applied at %1 m/s2.", round _value];
	};
};

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_VEHICLE, _vehicleId, _action]] call CBA_fnc_serverEvent;
[_owner, _msg, true] call _reply;
