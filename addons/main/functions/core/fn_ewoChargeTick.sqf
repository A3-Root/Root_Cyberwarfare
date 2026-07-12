#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Applies completed EWO charging intervals to packed laptop state and consumes the
 *              matching backpack energy. A job ends when its laptop reaches full charge, when the
 *              backpack runs dry, or when the item leaves the owner's inventory, and the owner is
 *              told which of those happened. Publishes a per-laptop charge snapshot on the backpack
 *              so clients can read the battery level of laptops that are still packed away.
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
    private _carried = [_owner] call FUNC(ewoGetInventoryLaptops);
    {
        private _item = _x;
        private _started = _y;
        private _name = [_item] call FUNC(ewoLaptopDisplayName);

        if !(_item in _carried) then {
            _jobs deleteAt _item;
            [format [localize "STR_ROOT_CYBERWARFARE_EWO_CHARGE_CANCELLED", _name], ROOT_CYBERWARFARE_COLOR_WARNING] remoteExecCall [QFUNC(ewoNotify), _owner];
            continue;
        };

        if !(_item in _buffer) then {continue};

        private _state = _buffer get _item;
        private _charge = _state getOrDefault ["ROOT_EWO_BATTERY_PERCENT", 0];
        private _steps = floor ((time - _started) / 3);
        private _applied = 0;

        if (_steps > 0 && {_energy > 0}) then {
            _applied = (_steps min _energy) min (100 - _charge);
            if (_applied > 0) then {
                _charge = _charge + _applied;
                _state set ["ROOT_EWO_BATTERY_PERCENT", _charge];
                _buffer set [_item, _state];
                _energy = _energy - _applied;
                _jobs set [_item, _started + (_applied * 3)];
            };
        };

        // A job that has nothing left to do is retired here rather than left to spin: a full laptop is
        // reported as done, an exhausted backpack as out of energy.
        if (_charge >= 100) then {
            _state set ["ROOT_EWO_BATTERY_PERCENT", 100];
            _buffer set [_item, _state];
            _jobs deleteAt _item;
            [format [localize "STR_ROOT_CYBERWARFARE_EWO_CHARGE_COMPLETE", _name], ROOT_CYBERWARFARE_COLOR_SUCCESS] remoteExecCall [QFUNC(ewoNotify), _owner];
        } else {
            if (_energy <= 0) then {
                _jobs deleteAt _item;
                [localize "STR_ROOT_CYBERWARFARE_EWO_DEPLETED", ROOT_CYBERWARFARE_COLOR_ERROR] remoteExecCall [QFUNC(ewoNotify), _owner];
            };
        };
    } forEach +_jobs;

    // Snapshot of every laptop still charging, broadcast so the charging status action can list each
    // laptop and its live battery level - the packed-laptop buffer itself stays server-side.
    private _status = [];
    {
        private _charge = (_buffer getOrDefault [_x, createHashMap]) getOrDefault ["ROOT_EWO_BATTERY_PERCENT", 0];
        _status pushBack [_x, [_x] call FUNC(ewoLaptopDisplayName), round _charge];
    } forEach (keys _jobs);

    if (_status isNotEqualTo (_bag getVariable ["ROOT_EWO_CHARGE_STATUS", []])) then {
        _bag setVariable ["ROOT_EWO_CHARGE_STATUS", _status, true];
    };

    _bag setVariable ["ROOT_EWO_ENERGY", _energy, true];
    _bag setVariable ["ROOT_EWO_CHARGE_JOBS", _jobs, true];
} forEach allPlayers;

missionNamespace setVariable ["AE3_LAPTOP_ITEM", _buffer, false];
