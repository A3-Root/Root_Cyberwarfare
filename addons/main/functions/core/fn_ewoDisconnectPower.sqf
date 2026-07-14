#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Pulls an EWO backpack's cable out of the power source it was drawing from. The energy the
 *              pack has taken on is kept; only the intake stops. Called both by the operator's own
 *              disconnect action and by the charging tick when the source stops running or is left
 *              behind, so it says nothing on its own - the caller reports what happened.
 *
 * Arguments:
 * 0: _player <OBJECT> - Player wearing the backpack
 *
 * Return Value:
 * Source <OBJECT> - The power source the pack was connected to, objNull if it was not connected
 *
 * Example:
 * [_player] call Root_fnc_ewoDisconnectPower;
 *
 * Public: No
 */

params [["_player", objNull, [objNull]]];

if (!isServer || {isNull _player}) exitWith {objNull};

private _bag = backpackContainer _player;
if (isNull _bag) exitWith {objNull};

private _source = _bag getVariable ["ROOT_EWO_POWER_SOURCE", objNull];

_bag setVariable ["ROOT_EWO_POWER_SOURCE", objNull, true];
_bag setVariable ["ROOT_EWO_POWER_SINCE", time, true];

_source
