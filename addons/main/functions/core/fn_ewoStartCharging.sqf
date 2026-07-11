#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Starts a server-authoritative inventory laptop charging job using the caller's EWO
 *              backpack. Each job advances at one percent per three seconds until the backpack is
 *              empty, the laptop is removed from inventory, or it reaches full charge.
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
if ((_bag getVariable ["ROOT_EWO_ENERGY", 0]) <= 0) exitWith {};

private _jobs = _bag getVariable ["ROOT_EWO_CHARGE_JOBS", createHashMap];
if ((_jobs getOrDefault [_item, false]) isNotEqualTo false) exitWith {};
_jobs set [_item, time];
_bag setVariable ["ROOT_EWO_CHARGE_JOBS", _jobs, true];
