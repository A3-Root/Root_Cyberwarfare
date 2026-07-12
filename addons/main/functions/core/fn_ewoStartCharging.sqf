#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Starts a server-authoritative inventory laptop charging job using the caller's EWO
 *              backpack. Each job advances at one percent per three seconds until the backpack is
 *              empty, the laptop is removed from inventory, or it reaches full charge. The starting level
 *              is read from the laptop itself, so a half-charged laptop is topped up from where it stands
 *              rather than treated as empty. The caller is told whether the job started and why it did not,
 *              since the job itself runs unattended.
 *
 * Arguments:
 * 0: _player <OBJECT> - Player carrying the backpack and laptop item
 * 1: _item <STRING> - Laptop item class
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_player", objNull, [objNull]], ["_item", "", [""]]];

private _isCarried = _item in ([_player] call FUNC(ewoGetInventoryLaptops));
if (!isServer || {isNull _player} || {!_isCarried}) exitWith {};

private _bag = backpackContainer _player;
if (isNull _bag || {!(_bag getVariable ["ROOT_EWO_INITIALIZED", false])}) exitWith {};

private _name = [_item] call FUNC(ewoLaptopDisplayName);
private _energy = _bag getVariable ["ROOT_EWO_ENERGY", 0];

if (_energy <= 0) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_EWO_NO_ENERGY", ROOT_CYBERWARFARE_COLOR_ERROR] remoteExecCall [QFUNC(ewoNotify), _player];
};

([_item] call FUNC(ewoLaptopBattery)) params ["_charge"];

if (_charge >= 100) exitWith {
    [format [localize "STR_ROOT_CYBERWARFARE_EWO_ALREADY_FULL", _name], ROOT_CYBERWARFARE_COLOR_WARNING] remoteExecCall [QFUNC(ewoNotify), _player];
};

private _jobs = _bag getVariable ["ROOT_EWO_CHARGE_JOBS", createHashMap];
if ((_jobs getOrDefault [_item, false]) isNotEqualTo false) exitWith {
    [format [localize "STR_ROOT_CYBERWARFARE_EWO_ALREADY_CHARGING", _name], ROOT_CYBERWARFARE_COLOR_WARNING] remoteExecCall [QFUNC(ewoNotify), _player];
};

_jobs set [_item, time];
_bag setVariable ["ROOT_EWO_CHARGE_JOBS", _jobs, true];

[format [localize "STR_ROOT_CYBERWARFARE_EWO_CHARGE_STARTED", _name, round _charge, "%", round _energy], ROOT_CYBERWARFARE_COLOR_INFO] remoteExecCall [QFUNC(ewoNotify), _player];
