#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Closes Hackerman SSH sessions that can no longer stand up: a computer that is gone or
 *              switched off, a target that stopped allowing SSH, a route that no longer resolves, or a
 *              session left idle longer than the mission allows. The conditions are the ones AE3's own
 *              session watchdog re-tests, so a scripted session dies for the same reasons a typed one
 *              does. Registered and removed by Root_fnc_manageHackSweep, so a mission with no sessions
 *              runs none of this. Server only.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call Root_fnc_hackSessionSweep;
 *
 * Public: No
 */

if (!isServer) exitWith {};

private _sessions = GET_HACK_SESSIONS;
private _idleTimeout = missionNamespace getVariable [SETTING_HACK_SSH_IDLE_TIMEOUT, 0];
private _now = serverTime;
private _toClose = [];

{
    private _operatorNetId = _x;
    _y params [["_targetNetId", ""], ["_user", ""], ["_startedAt", _now], ["_lastUsedAt", _now]];

    private _operator = objectFromNetId _operatorNetId;
    private _target = objectFromNetId _targetNetId;
    private _reason = "";

    switch (true) do {
        case (isNull _operator || {!alive _operator}): { _reason = "STR_ROOT_CYBERWARFARE_HACKSSH_DISCONNECTED" };
        case (isNull _target || {!alive _target}): { _reason = "STR_ROOT_CYBERWARFARE_HACKSSH_LOST" };
        case ((_operator getVariable ["AE3_power_powerState", 0]) != 1): { _reason = "STR_ROOT_CYBERWARFARE_HACKSSH_LOST" };
        case ((_target getVariable ["AE3_power_powerState", 0]) != 1): { _reason = "STR_ROOT_CYBERWARFARE_HACKSSH_LOST" };
        case (!(_target getVariable ["AE3_ssh_enabled", true])): { _reason = "STR_ROOT_CYBERWARFARE_HACKSSH_LOST" };
        case (_idleTimeout > 0 && {(_now - _lastUsedAt) > _idleTimeout}): { _reason = "STR_ROOT_CYBERWARFARE_HACKSSH_TIMED_OUT" };
        default {
            // The route is re-walked last, because it is the most expensive test of the set
            private _address = _target getVariable ["AE3_network_address", [127, 0, 0, 1]];
            private _resolved = ([_operator, _address] call AE3_network_fnc_resolve) param [0, objNull];

            if (_resolved isNotEqualTo _target) then { _reason = "STR_ROOT_CYBERWARFARE_HACKSSH_LOST" };
        };
    };

    if (_reason isNotEqualTo "") then {
        _toClose pushBack [_operatorNetId, _reason];
    };
} forEach _sessions;

{
    _x params ["_operatorNetId", "_reason"];

    [_operatorNetId, _reason] call FUNC(hackSshDisconnectMain);
} forEach _toClose;
