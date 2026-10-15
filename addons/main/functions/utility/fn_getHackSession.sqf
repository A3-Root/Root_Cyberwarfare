#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the Hackerman SSH session a computer is operating through, if any. The server
 *              reads its own session map; a client reads the half published on the computer itself, so
 *              the same call works on both sides. The target is the computer whose linked devices the
 *              operator may drive.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Operator's computer
 *
 * Return Value:
 * <ARRAY> - [_target <OBJECT>, _user <STRING>], or [] when there is no session
 *
 * Example:
 * ([_computer] call Root_fnc_getHackSession) params [["_target", objNull], ["_user", ""]];
 *
 * Public: Yes
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith { [] };

private _targetNetId = "";
private _user = "";

if (isServer) then {
    private _session = (GET_HACK_SESSIONS) getOrDefault [netId _computer, []];

    if (_session isNotEqualTo []) then {
        _targetNetId = _session param [0, ""];
        _user = _session param [1, ""];
    };
} else {
    // The published half carries no password, only who is connected to what
    private _session = _computer getVariable [VAR_HACK_SESSION, []];

    if (_session isNotEqualTo []) then {
        _targetNetId = _session param [0, ""];
        _user = _session param [2, ""];
    };
};

if (_targetNetId isEqualTo "") exitWith { [] };

private _target = objectFromNetId _targetNetId;

if (isNull _target) exitWith { [] };

[_target, _user]
