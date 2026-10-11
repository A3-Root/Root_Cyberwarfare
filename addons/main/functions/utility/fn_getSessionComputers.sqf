#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the computers taking part in the current terminal session on a device: the
 *              device itself and, when it is the target of an AE3 SSH session, the operator's computer
 *              the session was opened from. Only meaningful on the operator's machine.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Executing computer (the SSH target inside a session)
 *
 * Return Value:
 * <ARRAY> - [_computer] or [_computer, _sourceComputer]
 *
 * Example:
 * ([_computer] call Root_fnc_getSessionComputers) params ["_target", ["_source", objNull]];
 *
 * Public: Yes
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith { [] };

private _source = _computer getVariable ["AE3_stdoutRedirect", objNull];

if (isNull _source || _source isEqualTo _computer) exitWith { [_computer] };

[_computer, _source]
