// File: fn_ewoStopCharging.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Disconnects a packed laptop from the EWO backpack it is charging from. Whatever charge the
 *              laptop has taken on stays with it - only the job ends. Called both when the operator pulls
 *              the charger out by hand and when the laptop leaves the inventory to be used or deployed,
 *              since a laptop that is no longer packed cannot be on charge.
 *
 * Arguments:
 * 0: _player <OBJECT> - Player carrying the backpack
 * 1: _item <STRING> - Laptop item class to disconnect, "" to disconnect every laptop on the backpack
 *
 * Return Value:
 * None
 *
 * Example:
 * [_player, _item] call Root_fnc_ewoStopCharging;
 *
 * Public: No
 */

params [["_player", objNull, [objNull]], ["_item", "", [""]]];

if (!isServer || {isNull _player}) exitWith {};

private _bag = backpackContainer _player;
if (isNull _bag || {!(_bag getVariable ["ROOT_EWO_INITIALIZED", false])}) exitWith {};

private _jobs = _bag getVariable ["ROOT_EWO_CHARGE_JOBS", createHashMap];
private _stopped = [];

if (_item isEqualTo "") then {
    _stopped = keys _jobs;
    _jobs = createHashMap;
} else {
    if (_item in _jobs) then {
        _stopped pushBack _item;
        _jobs deleteAt _item;
    };
};

if (_stopped isEqualTo []) exitWith {};

_bag setVariable ["ROOT_EWO_CHARGE_JOBS", _jobs, true];

// The status list is what the interaction menu reads, so it is trimmed here rather than left for the
// next tick: an operator who disconnects a charger should see it gone straight away.
private _status = (_bag getVariable ["ROOT_EWO_CHARGE_STATUS", []]) select {!((_x param [0, ""]) in _stopped)};
_bag setVariable ["ROOT_EWO_CHARGE_STATUS", _status, true];

{
    [format [localize "STR_ROOT_CYBERWARFARE_EWO_CHARGE_DISCONNECTED", [_x] call FUNC(ewoLaptopDisplayName)], ROOT_CYBERWARFARE_COLOR_INFO] remoteExecCall [QFUNC(ewoNotify), _player];
} forEach _stopped;
