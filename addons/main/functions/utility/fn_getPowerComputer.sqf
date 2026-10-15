#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the operator's own computer - the machine the person is sitting at - which is
 *              what pays for session-wide costs such as opening a Hackerman SSH connection, and what
 *              the battery readout refers to. In an AE3 terminal session the executing computer is the
 *              remote target and the operator is on the other end of the redirect; in a Hackerman SSH
 *              session the executing computer already is the operator. Per-device costs do not use
 *              this - see Root_fnc_getDevicePowerComputer, where the computer the device is linked to
 *              pays.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Executing computer
 *
 * Return Value:
 * <OBJECT> - The operator's computer
 *
 * Example:
 * private _payer = [_computer] call Root_fnc_getPowerComputer;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith { _computer };

// Set by AE3's ssh command on the target, pointing back at the operator
private _source = _computer getVariable ["AE3_stdoutRedirect", objNull];

if (!isNull _source && (_source isNotEqualTo _computer)) exitWith { _source };

_computer
