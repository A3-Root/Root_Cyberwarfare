// File: fn_ewoChargeTick.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Runs the EWO backpack's power budget. Every laptop on charge takes completed steps of
 *              charge out of the pack and puts them into its own battery, a broadcasting network takes
 *              its own steady share on top, and a pack cabled to a power source takes energy back in.
 *              What each of those costs or returns per minute is a mission setting, so the tick works
 *              from the rate rather than from a fixed interval. A charging job ends when its laptop is
 *              full, when the pack runs dry, or when the laptop leaves the inventory, and the owner is
 *              told which of those happened. A pack that empties while broadcasting drops the network
 *              rather than running on nothing, and one whose power source is switched off or left behind
 *              is unplugged. Publishes a per-laptop charge snapshot on the backpack so clients can read
 *              the battery level of laptops that are still packed away.
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

// The settings are given in energy per minute; the tick bills whole units of energy, so each rate is
// turned into the seconds one unit takes. A rate of zero means that side of the budget never moves.
private _drainRate = missionNamespace getVariable [SETTING_EWO_WIFI_DRAIN, EWO_WIFI_DRAIN_DEFAULT];
private _chargeRate = missionNamespace getVariable [SETTING_EWO_CHARGE_RATE, EWO_CHARGE_RATE_DEFAULT];
private _rechargeRate = missionNamespace getVariable [SETTING_EWO_RECHARGE_RATE, EWO_RECHARGE_RATE_DEFAULT];

private _drainSeconds = if (_drainRate > 0) then {60 / _drainRate} else {0};
private _chargeSeconds = if (_chargeRate > 0) then {60 / _chargeRate} else {0};
private _rechargeSeconds = if (_rechargeRate > 0) then {60 / _rechargeRate} else {0};

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
        private _steps = if (_chargeSeconds > 0) then {floor ((time - _started) / _chargeSeconds)} else {0};
        private _applied = 0;

        if (_steps > 0 && {_energy > 0}) then {
            _applied = (_steps min _energy) min (100 - _charge);
            if (_applied > 0) then {
                _charge = _charge + _applied;
                [_item, _charge] call FUNC(ewoSetLaptopBattery);
                _energy = _energy - _applied;
                // Only the charge actually delivered is paid for: the rest of the step carries over
                // instead of being lost to rounding on the next tick.
                _jobs set [_item, _started + (_applied * _chargeSeconds)];
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

    // A pack plugged into a generator, a solar panel or a battery pack takes energy back in for as long
    // as the source is running and the carrier stays beside it. Walking off with the pack pulls the cable,
    // and so does the source being switched off, since neither leaves anything to draw from.
    private _source = _bag getVariable ["ROOT_EWO_POWER_SOURCE", objNull];
    if (!isNull _source) then {
        private _connected = alive _source
            && {(_source getVariable ["AE3_power_powerState", 0]) == 1}
            && {(_owner distance _source) <= EWO_POWER_SOURCE_RANGE};

        if (_connected) then {
            private _since = _bag getVariable ["ROOT_EWO_POWER_SINCE", time];
            private _units = if (_rechargeSeconds > 0) then {floor ((time - _since) / _rechargeSeconds)} else {0};
            if (_units > 0) then {
                _energy = ((_energy + _units) min EWO_ENERGY_MAX) max 0;
                _bag setVariable ["ROOT_EWO_POWER_SINCE", _since + (_units * _rechargeSeconds), true];
            };
            // A full pack draws nothing, and the seconds it spent full are not banked against a later
            // drain: the clock starts again from the moment there is room for energy to go in.
            if (_energy >= EWO_ENERGY_MAX) then {
                _bag setVariable ["ROOT_EWO_POWER_SINCE", time, true];
            };
        } else {
            [_owner] call FUNC(ewoDisconnectPower);
            [localize "STR_ROOT_CYBERWARFARE_EWO_POWER_LOST", ROOT_CYBERWARFARE_COLOR_WARNING] remoteExecCall [QFUNC(ewoNotify), _owner];
        };
    };

    // Broadcasting costs the pack a steady share whether or not anything is charging from it. Whole
    // units of energy are billed and the remainder is carried, so a network that is switched off and on
    // again is not charged twice for the same seconds.
    if (_bag getVariable ["ROOT_EWO_WIFI_ON", false]) then {
        private _since = _bag getVariable ["ROOT_EWO_WIFI_SINCE", time];
        private _units = if (_drainSeconds > 0) then {floor ((time - _since) / _drainSeconds)} else {0};
        if (_units > 0) then {
            _energy = (_energy - _units) max 0;
            _bag setVariable ["ROOT_EWO_WIFI_SINCE", _since + (_units * _drainSeconds), true];
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
