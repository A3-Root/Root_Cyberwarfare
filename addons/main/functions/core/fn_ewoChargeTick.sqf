#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Applies completed EWO charging intervals to packed laptop state and consumes the
 *              matching backpack energy. Jobs stop when their item leaves the owner's inventory.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!isServer || {!(missionNamespace getVariable [SETTING_EWO_MODE, false])}) exitWith {};

private _buffer = missionNamespace getVariable ["AE3_LAPTOP_ITEM", createHashMap];
{
    private _owner = _x;
    private _bag = backpackContainer _owner;
    if (isNull _bag || {!(_bag getVariable ["ROOT_EWO_INITIALIZED", false])}) then {continue};
    private _jobs = _bag getVariable ["ROOT_EWO_CHARGE_JOBS", createHashMap];
    private _energy = _bag getVariable ["ROOT_EWO_ENERGY", 0];
    {
        private _item = _x;
        private _started = _y;
        private _isCarried = _item in ([_owner] call FUNC(ewoGetInventoryLaptops));
        if (_isCarried isEqualTo false) then {
            _jobs deleteAt _item;
        } else {
            private _steps = floor ((time - _started) / 3);
            if (_steps > 0 && {_energy > 0} && {_item in _buffer}) then {
                private _state = _buffer get _item;
                private _charge = _state getOrDefault ["ROOT_EWO_BATTERY_PERCENT", 0];
                private _applied = (_steps min _energy) min (100 - _charge);
                if (_applied > 0) then {
                    _state set ["ROOT_EWO_BATTERY_PERCENT", _charge + _applied];
                    _buffer set [_item, _state];
                    _energy = _energy - _applied;
                    _jobs set [_item, _started + (_applied * 3)];
                };
                if ((_charge + _applied) >= 100 || {_energy <= 0}) then {_jobs deleteAt _item;};
            };
        };
    } forEach +_jobs;
    _bag setVariable ["ROOT_EWO_ENERGY", _energy, true];
    _bag setVariable ["ROOT_EWO_CHARGE_JOBS", _jobs, true];
} forEach allPlayers;

missionNamespace setVariable ["AE3_LAPTOP_ITEM", _buffer, false];
