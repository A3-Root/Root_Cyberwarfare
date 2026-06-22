#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Checks if sufficient power is available in the laptop battery
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _powerRequiredWh <NUMBER> - Power required in Wh
 *
 * Return Value:
 * <BOOLEAN> - True if sufficient power available, false otherwise
 *
 * Example:
 * [_laptop, 10] call Root_fnc_checkPowerAvailable;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_powerRequiredWh", 0, [0]]
];

DEBUG_LOG_3("checkPowerAvailable - Computer: %1, Required: %2 Wh, Mode: %3",_computer,_powerRequiredWh,GET_DEVICE_MODE);

if (isNull _computer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("checkPowerAvailable: Invalid computer object");
    DEBUG_LOG("Computer is null - no power available");
    false
};

if (_powerRequiredWh <= 0) exitWith {
    DEBUG_LOG("No power required - check passed");
    true
};

private _batteryStatus = [_computer, _powerRequiredWh] call FUNC(getBatteryStatus);
_batteryStatus params ["_hasBattery", "_battery", "_batteryLevelWh", "_batteryPercent", "_batteryCapacityWh", "_remainingWh"];
DEBUG_LOG_1("Battery object: %1",_battery);

if (!_hasBattery) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("checkPowerAvailable: Battery not found or laptop has no internal battery");
    DEBUG_LOG("Battery is null - no power available");
    false
};

DEBUG_LOG_3("Battery level: %1 Wh, Required: %2 Wh, Remaining: %3 Wh",_batteryLevelWh,_powerRequiredWh,_remainingWh);

private _hasPower = _batteryLevelWh >= _powerRequiredWh;
DEBUG_LOG_1("Power check result: %1",_hasPower);

_hasPower
