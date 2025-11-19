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

DEBUG_LOG_2("consumePower - Computer: %1, Amount: %2 Wh",_computer,_powerWh);

if (isNull _computer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("consumePower: Invalid computer object");
    DEBUG_LOG("Computer is null - cannot consume power");
    false
};

if (_powerWh <= 0) exitWith {
    DEBUG_LOG("No power to consume");
    true
};

// Get the laptop's internal battery (each laptop has its own battery object)
private _battery = _computer getVariable ["AE3_power_internal", objNull];
DEBUG_LOG_1("Battery object: %1",_battery);

if (isNull _battery) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("consumePower: Battery not found or laptop has no internal battery");
    DEBUG_LOG("Battery is null - cannot consume power");
    false
};

private _batteryLevel = _battery getVariable ["AE3_power_batteryLevel", 0];
private _powerKwh = WH_TO_KWH(_powerWh);
private _newLevel = _batteryLevel - _powerKwh;

DEBUG_LOG_4("Power consumption - Old level: %1 kWh, Consuming: %2 kWh (%3 Wh), New level: %4 kWh",_batteryLevel,_powerKwh,_powerWh,_newLevel);

// Broadcast power consumption event to server
["root_cyberwarfare_consumePower", [_computer, _battery, _newLevel, _powerWh]] call CBA_fnc_serverEvent;
DEBUG_LOG("Power consumption event broadcast to server");

// Output to shell
private _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST", _powerWh];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;

_string = format [localize "STR_ROOT_CYBERWARFARE_NEW_POWER_LEVEL", _newLevel * 1000];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;

DEBUG_LOG("Power consumption complete");
true
