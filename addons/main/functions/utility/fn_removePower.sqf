#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Updates battery power level on both server and battery owner client
 *              This is a low-level function called by consumePower after power calculations
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _battery <OBJECT> - The battery object to update
 * 2: _newLevel <NUMBER> - New battery level in kWh
 *
 * Return Value:
 * None
 *
 * Example:
 * [_laptop, _battery, 45.5] call Root_fnc_removePower;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_battery", objNull, [objNull]],
    ["_newLevel", 0, [0]]
];

// Validate battery object
if (isNull _battery) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("removePower: Invalid battery object");
};

// Clamp new level to non-negative values
_newLevel = _newLevel max 0;

// Set battery level on server (globally synced)
_battery setVariable ["AE3_power_batteryLevel", _newLevel, true];

// Also update on battery owner's machine for immediate UI feedback
private _batteryOwner = owner _battery;
[_battery, ["AE3_power_batteryLevel", _newLevel, true]] remoteExec ["setVariable", _batteryOwner];
