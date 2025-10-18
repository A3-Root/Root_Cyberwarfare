#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Consumes power from laptop battery and broadcasts via CBA event
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _powerWh <NUMBER> - Power to consume in Wh
 *
 * Return Value:
 * <BOOLEAN> - True if power was consumed successfully, false otherwise
 *
 * Example:
 * [_laptop, 10] call Root_fnc_consumePower;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_powerWh", 0, [0]]
];

if (isNull _computer) exitWith {
    LOG_ERROR("consumePower: Invalid computer object");
    false
};

if (_powerWh <= 0) exitWith { true };

// Get the laptop's internal battery (each laptop has its own battery object)
private _battery = _computer getVariable ["AE3_power_internal", objNull];
if (isNull _battery) exitWith {
    LOG_ERROR("consumePower: Battery not found or laptop has no internal battery");
    false
};

private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];
private _powerKwh = WH_TO_KWH(_powerWh);
private _newLevel = _batteryLevel - _powerKwh;

// Broadcast power consumption event to server
["root_cyberwarfare_consumePower", [_computer, _battery, _newLevel, _powerWh]] call CBA_fnc_serverEvent;

// Output to shell
private _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST", _powerWh];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;

_string = format [localize "STR_ROOT_CYBERWARFARE_NEW_POWER_LEVEL", _newLevel * 1000];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;

true
