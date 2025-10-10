#include "../../script_component.hpp"
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

if (isNull _computer) exitWith {
    LOG_ERROR("checkPowerAvailable: Invalid computer object");
    false
};

if (_powerRequiredWh <= 0) exitWith { true };

private _battery = uiNamespace getVariable ["AE3_Battery", objNull];
if (isNull _battery) exitWith {
    LOG_ERROR("checkPowerAvailable: Battery not found");
    false
};

private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];
private _powerRequiredKwh = WH_TO_KWH(_powerRequiredWh);

(_batteryLevel >= _powerRequiredKwh)
