#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Reads the laptop battery through AE3 and calculates the remaining charge after a cost.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _powerCostWh <NUMBER> - Power cost in Wh
 * 2: _deviceType <NUMBER> (Optional) - Device the cost is for, so the computer it is linked to is read
 * 3: _deviceId <NUMBER> (Optional) - Device ID
 *
 * Return Value:
 * [success, battery, currentWh, currentPercent, capacityWh, remainingWh, remainingPercent, payer]
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_powerCostWh", 0, [0]],
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]]
];

if (isNull _computer) exitWith {
    [false, objNull, 0, 0, 0, 0, 0, objNull]
};

// Operating a device draws on whichever computer the device is linked to; anything else draws on the
// operator's own machine.
private _payer = [_computer, _deviceType, _deviceId] call FUNC(getDevicePowerComputer);
private _battery = _payer getVariable ["AE3_power_internal", objNull];
if (isNull _battery) exitWith {
    [false, objNull, 0, 0, 0, 0, 0, _payer]
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

[true, _battery, _currentWh, _currentPercent, _capacityWh, _remainingWh, _remainingPercent, _payer]
