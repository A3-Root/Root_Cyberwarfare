#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the computer whose battery pays for hacking operations run on a device. Inside
 *              an SSH session that is the operator's own computer, so remote targets (including
 *              mains-powered servers without a battery) never pay for the operator's commands.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Executing computer
 *
 * Return Value:
 * <OBJECT> - Computer to draw power from
 *
 * Example:
 * private _payer = [_computer] call Root_fnc_getPowerComputer;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

([_computer] call FUNC(getSessionComputers)) param [1, _computer]
