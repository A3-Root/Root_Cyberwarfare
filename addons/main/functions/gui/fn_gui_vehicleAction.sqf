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

// Damage limits how fast a vehicle can be driven, not whether it can be driven: a commanded speed is cut
// down to what the surviving drivetrain can deliver rather than refused. Only a vehicle with nothing left
// to turn its wheels is turned away, and that one costs the operator nothing - the request never reached
// it.
private _drivetrain = [0, 1, 1, false, DRIVETRAIN_NO_SPEED_CAP];
if (_action in ["setspeed", "speedup", "slowdown"]) then {
	_drivetrain = _vehicle call FUNC(getVehicleDrivetrain);
};
_drivetrain params ["_engineDamage", "_wheelFactor", "_effectiveness", "_blocked", "_speedCap"];

if (_blocked) exitWith {
	[_vehicle] call FUNC(releaseVehicleSpeedLock);
	[_owner, format [
		localize "STR_ROOT_CYBERWARFARE_SPEED_BLOCKED",
		round (_engineDamage * 100),
		round (_wheelFactor * 100)
	], false] call _reply;
};

private _cost = _vehicle getVariable ["ROOT_CYBERWARFARE_VEHICLE_COST", missionNamespace getVariable [SETTING_VEHICLE_COST, 2]];
if !([_computer, _cost] call FUNC(checkPowerAvailable)) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply;
};
[_computer, _cost] call FUNC(consumePower);

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
		// A speed hold or a brake run keeps the engine turning for as long as it is active, so both are
		// let go before the engine is cut - otherwise the next tick would start it again.
		[_vehicle] call FUNC(releaseVehicleSpeedLock);
		[_vehicle] call _removeBrakeHandler;
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
		[_vehicle] call FUNC(releaseVehicleSpeedLock);
		[_vehicle] call _removeBrakeHandler;
		// A vehicle only carries a commanded speed under its own power: a dead engine would leave it
		// sliding along on nothing, so the engine is started before the ramp begins.
		if (!isEngineOn _vehicle) then {
			[_vehicle, true] remoteExec ["engineOn", _vehicle];
		};
		private _dir = getDir _vehicle;
		private _forward = [sin _dir, cos _dir, 0];
		private _vel = velocity _vehicle;
		private _startSpeed = ((_vel select 0) * (_forward select 0)) + ((_vel select 1) * (_forward select 1));
		// The speed the operator asked for is what gets held, and it is kept whole rather than written
		// back already cut down to the damage of the moment. The cap is applied fresh on every tick, so a
		// vehicle repaired while it is being held climbs the rest of the way to the speed it was given
		// instead of staying stuck at whatever its wheels could manage when the order was issued.
		private _wanted = _value / 3.6;
		private _requested = ((_value max (-_speedCap)) min _speedCap);
		private _handle = [{
			params ["_args", "_handle"];
			_args params ["_vehicle", "_startSpeed", "_wanted", "_startTime", "_lock", "_owner"];

			// Damage taken while the ramp is running counts: the target is re-capped against what the
			// drivetrain can still deliver. Only a vehicle left with no drivetrain at all ends the ramp,
			// and then it is left to roll out rather than dragged along on nothing.
			(_vehicle call FUNC(getVehicleDrivetrain)) params ["", "", "", "_blocked", "_speedCap"];
			if (!alive _vehicle || _blocked) exitWith {
				[_vehicle] call FUNC(releaseVehicleSpeedLock);
				if (_blocked && {alive _vehicle}) then {
					["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_VEHICLE, localize "STR_ROOT_CYBERWARFARE_SPEED_LOCK_LOST", false], _owner] call CBA_fnc_ownerEvent;
				};
			};

			// The engine belongs to whoever holds the vehicle, and a crew member can cut it mid-ramp. It is
			// restarted for as long as the ramp runs, so the speed being commanded is always speed the
			// vehicle is making itself.
			if (!isEngineOn _vehicle) then {
				[_vehicle, true] remoteExec ["engineOn", _vehicle];
			};

			private _capMs = _speedCap / 3.6;
			private _cappedTarget = (_wanted max (-_capMs)) min _capMs;
			private _progress = ((time - _startTime) / 5) min 1;
			private _speedNow = _startSpeed + ((_cappedTarget - _startSpeed) * _progress);
			private _dir = getDir _vehicle;
			private _vel = velocity _vehicle;
			[_vehicle, [sin _dir * _speedNow, cos _dir * _speedNow, _vel select 2]] remoteExec ["setVelocity", _vehicle];

			if (_progress >= 1) exitWith {
				[_handle] call CBA_fnc_removePerFrameHandler;
				_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1, true];
				if (_lock && {(abs _wanted) > 0.01}) then {
					_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_LOCK", _wanted, true];
					private _lockHandle = [{
						params ["_args", "_handle"];
						_args params ["_vehicle", "_owner"];
						private _wanted = _vehicle getVariable ["ROOT_CYBERWARFARE_SPEED_LOCK", 0];

						// The lock holds the ordered speed for as long as any drivetrain survives to hold
						// it, following the vehicle down as wheels shred and back up again if it is
						// repaired. It lets go only when there is nothing left to drive with, and then the
						// vehicle coasts to a stop rather than being carried along on a dead engine.
						(_vehicle call FUNC(getVehicleDrivetrain)) params ["", "", "", "_blocked", "_speedCap"];
						if (!alive _vehicle || _blocked || {(abs _wanted) <= 0.01}) exitWith {
							[_vehicle] call FUNC(releaseVehicleSpeedLock);
							if (_blocked && {alive _vehicle}) then {
								["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_VEHICLE, localize "STR_ROOT_CYBERWARFARE_SPEED_LOCK_LOST", false], _owner] call CBA_fnc_ownerEvent;
							};
						};

						// The hold keeps the engine running for as long as it holds the speed, so an engine
						// switched off from the seat does not leave the vehicle being carried on a dead one.
						if (!isEngineOn _vehicle) then {
							[_vehicle, true] remoteExec ["engineOn", _vehicle];
						};

						private _capMs = _speedCap / 3.6;
						private _heldSpeed = (_wanted max (-_capMs)) min _capMs;
						private _dir = getDir _vehicle;
						private _vel = velocity _vehicle;
						[_vehicle, [sin _dir * _heldSpeed, cos _dir * _heldSpeed, _vel select 2]] remoteExec ["setVelocity", _vehicle];
					}, 0.1, [_vehicle, _owner]] call CBA_fnc_addPerFrameHandler;
					_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", _lockHandle, true];
				};
			};
		}, 0.05, [_vehicle, _startSpeed, _wanted, time, _lock, _owner]] call CBA_fnc_addPerFrameHandler;
		_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", _handle, true];
		_msg = if (round _requested isEqualTo round _value) then {
			format ["Speed changing to %1 km/h over 5 seconds.", round _value]
		} else {
			format [localize "STR_ROOT_CYBERWARFARE_SPEED_DERATED", round (_effectiveness * 100), round _requested, round _value]
		};
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
		// The step is only held if the vehicle is making the speed itself, so the engine is started first.
		if (!isEngineOn _vehicle) then {
			[_vehicle, true] remoteExec ["engineOn", _vehicle];
		};
		private _speedChange =_vehicle getVariable [["ROOT_CYBERWARFARE_SPEED_MAX", "ROOT_CYBERWARFARE_SPEED_MIN"] select (_action isEqualTo "slowdown"), [50, -50] select (_action isEqualTo "slowdown")];
		private _vel = velocity _vehicle;
		private _dir = getDir _vehicle;

		// The step is added to the speed the vehicle already carries and then capped at the top speed the
		// surviving drivetrain can reach, so a wrecked vehicle still steps up - just never past what it
		// could physically do. The cap alone does the derating: scaling the step by the drivetrain as well
		// would charge the damage twice.
		private _forwardSpeed = (((_vel select 0) * (sin _dir)) + ((_vel select 1) * (cos _dir))) * 3.6;
		private _targetSpeed = _forwardSpeed + _speedChange;
		_targetSpeed = (_targetSpeed max (-_speedCap)) min _speedCap;
		private _applied = _targetSpeed - _forwardSpeed;
		private _targetMs = _targetSpeed / 3.6;

		[_vehicle, [(sin _dir) * _targetMs, (cos _dir) * _targetMs, _vel select 2]] remoteExec ["setVelocity", _vehicle];
		_msg = format ["Speed adjusted by %1 km/h.", round _applied];
	};
	case "brakes": {
		[_vehicle, _value, 2] call FUNC(applyVehicleBrakes);
		_msg = format ["Brakes applied at %1 m/s2.", round _value];
	};
};

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_VEHICLE, _vehicleId, _action]] call CBA_fnc_serverEvent;
[_owner, _msg, true] call _reply;
