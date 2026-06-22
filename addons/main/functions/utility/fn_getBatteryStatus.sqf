#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Reads the laptop battery through AE3 and calculates the remaining charge after a cost.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _powerCostWh <NUMBER> - Power cost in Wh
 *
 * Return Value:
 * [success, battery, currentWh, currentPercent, capacityWh, remainingWh, remainingPercent]
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_powerCostWh", 0, [0]]
];

if (isNull _computer) exitWith {
    [false, objNull, 0, 0, 0, 0, 0]
};

private _battery = _computer getVariable ["AE3_power_internal", objNull];
if (isNull _battery) exitWith {
    [false, objNull, 0, 0, 0, 0, 0]
};

private _info = [_battery, false] call AE3_power_fnc_getBatteryLevel;
_info params [
    ["_currentWh", 0, [0]],
    ["_currentPercent", 0, [0]],
    ["_capacityWh", 0, [0]]
];

private _remainingWh = (_currentWh - _powerCostWh) max 0;
private _remainingPercent = 0;
if (_capacityWh > 0) then {
    _remainingPercent = (_remainingWh / _capacityWh) * 100;
};

[true, _battery, _currentWh, _currentPercent, _capacityWh, _remainingWh, _remainingPercent]
