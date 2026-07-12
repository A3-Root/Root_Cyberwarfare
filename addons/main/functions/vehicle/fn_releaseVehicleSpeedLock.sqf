// File: fn_releaseVehicleSppedLock.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Stops any speed ramp or speed lock running on a vehicle and clears the held speed, so
 *              nothing keeps rewriting its velocity. The vehicle is not braked: it keeps whatever
 *              momentum it had and slows down on its own.
 *
 * Arguments:
 * 0: _vehicle <OBJECT> - Vehicle whose speed handler is released
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle] call Root_fnc_releaseVehicleSpeedLock;
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle) exitWith {};

// The speed handlers are created and owned by the server, and a handle id only means anything on the
// machine that created it, so a request from a terminal client is passed on rather than acted on here.
if (!isServer) exitWith {
    [_vehicle] remoteExecCall [QFUNC(releaseVehicleSpeedLock), 2];
};

private _handle = _vehicle getVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1];
if (_handle >= 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
};

_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_PFH", -1, true];
_vehicle setVariable ["ROOT_CYBERWARFARE_SPEED_LOCK", 0, true];
