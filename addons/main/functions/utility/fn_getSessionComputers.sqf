#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns every computer taking part in the operation being performed on a device: the
 *              computer itself, the operator's computer when this one is the target of an AE3 terminal
 *              SSH session, and the target of a Hackerman SSH session when this one is the operator.
 *              Access checks union over the result, so tools on one machine can drive links on another.
 *
 *              The two session kinds are read differently on purpose. AE3's terminal session is only
 *              known to the operator's own client (AE3 sets AE3_stdoutRedirect without a public flag),
 *              so it resolves on a client and never on the server. A Hackerman SSH session is held by
 *              the server and published on the operator's computer, so it resolves on both - which is
 *              what lets the desktop apps, whose device lists and actions are built server-side, work
 *              through a session at all.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Executing computer
 *
 * Return Value:
 * <ARRAY> - [_computer] plus any session partner, operator first where the two differ
 *
 * Example:
 * ([_computer] call Root_fnc_getSessionComputers) params ["_first", ["_second", objNull]];
 *
 * Public: Yes
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith { [] };

private _computers = [_computer];

// AE3 terminal session: this computer is the target and the operator is on the other end
private _source = _computer getVariable ["AE3_stdoutRedirect", objNull];

if (!isNull _source && (_source isNotEqualTo _computer)) then {
    _computers pushBackUnique _source;
};

// Hackerman SSH session: this computer is the operator and the target is what it reached
([_computer] call FUNC(getHackSession)) params [["_target", objNull]];

if (!isNull _target && (_target isNotEqualTo _computer)) then {
    _computers pushBackUnique _target;
};

_computers
