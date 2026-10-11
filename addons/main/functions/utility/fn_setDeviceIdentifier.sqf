#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Sets the identifier (code) a registered device answers to, and whether knowing the code
 *              grants access to it from any terminal with hacking tools (credential) or only names it
 *              (alias; normal link/public access still required). Accepts the device by type and id,
 *              or by its object (every registration of that object gets a code; the requested code
 *              goes to the first). GPS trackers keep their own identifiers and are skipped. Routed to
 *              the server when called on a client. Waits up to 60 s for an object to be registered,
 *              so it can be called right after the add module or function.
 *
 * Arguments:
 * 0: _target <NUMBER|OBJECT> - DEVICE_TYPE_* constant, or the registered object
 * 1: _deviceId <NUMBER> - Device id (ignored when _target is an object)
 * 2: _identifier <STRING> (Optional) - Wanted code; blank = random, default: ""
 * 3: _grantsAccess <BOOL> (Optional) - Code acts as a credential, default: true
 * 4: _execUserId <NUMBER> (Optional) - Client to report the assigned code to, 0 = none, default: 0
 *
 * Return Value:
 * None
 *
 * Example:
 * [1, 1004, "VAULTDR1", true] call Root_fnc_setDeviceIdentifier;
 * [_vaultBuilding, 0, "VAULTDR1", false] call Root_fnc_setDeviceIdentifier; // alias only
 *
 * Public: Yes
 */

params [
    ["_target", 0, [0, objNull]],
    ["_deviceId", 0, [0]],
    ["_identifier", "", [""]],
    ["_grantsAccess", true, [true]],
    ["_execUserId", 0, [0]]
];

if (!isServer) exitWith {
    _this remoteExec [QFUNC(setDeviceIdentifier), 2];
};

if (!canSuspend) exitWith { _this spawn FUNC(setDeviceIdentifier); };

private _registrations = [];
if (_target isEqualType objNull) then {
    private _deadline = CBA_missionTime + 60;
    waitUntil {
        _registrations = ([_target] call FUNC(findDevicesByObject)) select {(_x select 0) != DEVICE_TYPE_GPS_TRACKER};
        _registrations isNotEqualTo [] || CBA_missionTime > _deadline || {isNull _target}
    };
} else {
    _registrations = [[_target, _deviceId]];
};

private _assigned = [];
{
    _x params ["_type", "_id"];
    private _code = [_type, _id, [_identifier, ""] select (_forEachIndex > 0), _grantsAccess] call FUNC(registerDeviceIdentifier);
    if (_code isNotEqualTo "") then { _assigned pushBack format ["%1 #%2 = %3", _type, _id, _code]; };
} forEach _registrations;

if (_execUserId > 0) then {
    private _message = if (_assigned isEqualTo []) then {
        localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NOT_REGISTERED"
    } else {
        format [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_ASSIGNED", _assigned joinString ", ", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_ALIAS", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_CREDENTIAL"] select _grantsAccess]
    };
    [_message] remoteExec ["systemChat", _execUserId];
};
