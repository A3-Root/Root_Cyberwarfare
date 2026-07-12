#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Applies server-managed braking to a land vehicle until it stops, then holds it still.
 *
 * Arguments:
 * 0: _vehicle <OBJECT> - Vehicle to brake
 * 1: _decelRate <NUMBER> - Deceleration rate in metres per second squared
 * 2: _holdTime <NUMBER> (Optional) - Seconds to keep the vehicle stationary after stopping
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]], ["_decelRate", 1, [0]], ["_holdTime", 2, [0]]];

if (isNull _vehicle || {!alive _vehicle}) exitWith {};

private _handle = _vehicle getVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", -1];
if (_handle >= 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
};

// Braking and holding a speed are mutually exclusive: whatever was driving the vehicle's velocity is
// released first so the brake handler owns it alone.
[_vehicle] call FUNC(releaseVehicleSpeedLock);

_decelRate = _decelRate max 0.1;
_holdTime = _holdTime max 0;

private _brakeHandle = [{
    params ["_args", "_handle"];
    _args params ["_vehicle", "_decelRate", "_holdTime", "_lastTime", "_holdUntil"];

    if (isNull _vehicle || {!alive _vehicle}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        _vehicle setVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", -1, true];
    };

    private _now = time;
    private _vel = velocity _vehicle;

    if (_holdUntil > 0) exitWith {
        [_vehicle, [0, 0, _vel select 2]] remoteExecCall ["setVelocity", _vehicle];
        if (_now >= _holdUntil) then {
            [_handle] call CBA_fnc_removePerFrameHandler;
            _vehicle setVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", -1, true];
        };
    };

    private _dt = (_now - _lastTime) max 0.001;
    _args set [3, _now];

    private _horizontal = [_vel select 0, _vel select 1, 0];
    private _speedNow = vectorMagnitude _horizontal;

    if (_speedNow <= 0.1) exitWith {
        [_vehicle, [0, 0, _vel select 2]] remoteExecCall ["setVelocity", _vehicle];
        _args set [4, _now + _holdTime];
    };

    private _nextSpeed = (_speedNow - (_decelRate * _dt)) max 0;
    private _scale = _nextSpeed / _speedNow;
    [_vehicle, [(_vel select 0) * _scale, (_vel select 1) * _scale, _vel select 2]] remoteExecCall ["setVelocity", _vehicle];
}, 0.05, [_vehicle, _decelRate, _holdTime, time, 0]] call CBA_fnc_addPerFrameHandler;

_vehicle setVariable ["ROOT_CYBERWARFARE_BRAKE_PFH", _brakeHandle, true];
