#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Cables an EWO backpack to an AE3 power source so the pack takes energy back in while it
 *              stands beside it. Any AE3 provider counts - a generator, a solar panel, a battery pack -
 *              and it has to be running, since a source that is switched off has nothing to give. The
 *              connection is only the pairing: the charging tick is what moves the energy, and it drops
 *              the pairing again when the source stops or the carrier walks away.
 *
 * Arguments:
 * 0: _player <OBJECT> - Player wearing the backpack
 * 1: _source <OBJECT> - The AE3 power source to draw from
 *
 * Return Value:
 * None
 *
 * Example:
 * [_player, _generator] call Root_fnc_ewoConnectPower;
 *
 * Public: No
 */

params [["_player", objNull, [objNull]], ["_source", objNull, [objNull]]];

if (!isServer || {isNull _player} || {isNull _source}) exitWith {};

private _bag = backpackContainer _player;
if (isNull _bag || {!(_bag getVariable ["ROOT_EWO_INITIALIZED", false])}) exitWith {};

// The same tests the tick keeps applying, so a connection is never made in a state it would be dropped
// from on the next pass.
if ((_source getVariable ["AE3_power_powerState", 0]) != 1) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_EWO_POWER_OFF", ROOT_CYBERWARFARE_COLOR_ERROR] remoteExecCall [QFUNC(ewoNotify), _player];
};

if ((_player distance _source) > EWO_POWER_SOURCE_RANGE) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_EWO_POWER_FAR", ROOT_CYBERWARFARE_COLOR_ERROR] remoteExecCall [QFUNC(ewoNotify), _player];
};

_bag setVariable ["ROOT_EWO_POWER_SOURCE", _source, true];
// Energy is counted from the moment the cable went in.
_bag setVariable ["ROOT_EWO_POWER_SINCE", time, true];

private _name = [_source, true] call ace_cargo_fnc_getNameItem;

[
    format [
        localize "STR_ROOT_CYBERWARFARE_EWO_POWER_CONNECTED",
        _name,
        missionNamespace getVariable [SETTING_EWO_RECHARGE_RATE, EWO_RECHARGE_RATE_DEFAULT]
    ],
    ROOT_CYBERWARFARE_COLOR_SUCCESS
] remoteExecCall [QFUNC(ewoNotify), _player];
