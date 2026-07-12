// File: fn_ewoChargeTick.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Runs the EWO backpack's power budget. Every laptop on charge takes completed intervals of
 *              charge out of the pack and puts them into its own battery, and a broadcasting network takes
 *              its own steady share on top. A charging job ends when its laptop is full, when the pack runs
 *              dry, or when the laptop leaves the inventory, and the owner is told which of those happened.
 *              A pack that empties while broadcasting drops the network rather than running on nothing.
 *              Publishes a per-laptop charge snapshot on the backpack so clients can read the battery level
 *              of laptops that are still packed away.
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

// One percent of a full pack, spread over the interval it is charged for.
private _drainPerInterval = EWO_ENERGY_MAX * EWO_WIFI_DRAIN_PERCENT / 100;

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

        ([_item] call FUNC(ewoLaptopBattery)) params ["_charge"];
        private _steps = floor ((time - _started) / EWO_CHARGE_SECONDS_PER_PERCENT);
        private _applied = 0;

        if (_steps > 0 && {_energy > 0}) then {
            _applied = (_steps min _energy) min (100 - _charge);
            if (_applied > 0) then {
                _charge = _charge + _applied;
                [_item, _charge] call FUNC(ewoSetLaptopBattery);
                _energy = _energy - _applied;
                // Only the charge actually delivered is paid for: the rest of the interval carries over
                // instead of being lost to rounding on the next tick.
                _jobs set [_item, _started + (_applied * EWO_CHARGE_SECONDS_PER_PERCENT)];
            };
        };

        // A job with nothing left to do is retired here rather than left to spin: a full laptop is reported
        // as done, an exhausted backpack as out of energy.
        if (_charge >= 100) then {
            [_item, 100] call FUNC(ewoSetLaptopBattery);
            _jobs deleteAt _item;
            [format [localize "STR_ROOT_CYBERWARFARE_EWO_CHARGE_COMPLETE", _name], ROOT_CYBERWARFARE_COLOR_SUCCESS] remoteExecCall [QFUNC(ewoNotify), _owner];
        } else {
            if (_energy <= 0) then {
                _jobs deleteAt _item;
                [localize "STR_ROOT_CYBERWARFARE_EWO_DEPLETED", ROOT_CYBERWARFARE_COLOR_ERROR] remoteExecCall [QFUNC(ewoNotify), _owner];
            };
        };
    } forEach +_jobs;

    // Broadcasting costs the pack a steady share whether or not anything is charging from it. Whole
    // intervals are billed and the remainder is carried, so a network that is switched off and on again
    // is not charged twice for the same seconds.
    if (_bag getVariable ["ROOT_EWO_WIFI_ON", false]) then {
        private _since = _bag getVariable ["ROOT_EWO_WIFI_SINCE", time];
        private _intervals = floor ((time - _since) / EWO_WIFI_DRAIN_INTERVAL);
        if (_intervals > 0) then {
            _energy = (_energy - (_intervals * _drainPerInterval)) max 0;
            _bag setVariable ["ROOT_EWO_WIFI_SINCE", _since + (_intervals * EWO_WIFI_DRAIN_INTERVAL), true];
        };
        if (_energy <= 0) then {
            [_owner, false] call FUNC(ewoWifiSet);
            [localize "STR_ROOT_CYBERWARFARE_EWO_WIFI_DEPLETED", ROOT_CYBERWARFARE_COLOR_ERROR] remoteExecCall [QFUNC(ewoNotify), _owner];
        };
    };

    // Snapshot of every laptop still charging, broadcast so the charging status and disconnect actions can
    // list each laptop and its live battery level - the packed-laptop state itself stays server-side.
    private _status = [];
    {
        ([_x] call FUNC(ewoLaptopBattery)) params ["_charge"];
        _status pushBack [_x, [_x] call FUNC(ewoLaptopDisplayName), round _charge];
    } forEach (keys _jobs);

    if (_status isNotEqualTo (_bag getVariable ["ROOT_EWO_CHARGE_STATUS", []])) then {
        _bag setVariable ["ROOT_EWO_CHARGE_STATUS", _status, true];
    };

    _bag setVariable ["ROOT_EWO_ENERGY", _energy, true];
    _bag setVariable ["ROOT_EWO_CHARGE_JOBS", _jobs, true];
} forEach allPlayers;
