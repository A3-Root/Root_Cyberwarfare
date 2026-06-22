#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Displays a Y/N confirmation prompt to the user
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _powerCost <NUMBER> (Optional) - Power cost to display, default: 0
 *
 * Return Value:
 * <BOOLEAN> - True if user confirmed (Y), false if declined (N)
 *
 * Example:
 * [_laptop] call Root_fnc_getUserConfirmation;
 * [_laptop, 10] call Root_fnc_getUserConfirmation;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_powerCost", 0, [0]]
];

if (isNull _computer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("getUserConfirmation: Invalid computer object");
    false
};

private _canConfirm = true;
if (_powerCost > 0) then {
    private _batteryStatus = [_computer, _powerCost] call FUNC(getBatteryStatus);
    _batteryStatus params ["_hasBattery", "_battery", "_currentWh", "_currentPercent", "_capacityWh", "_remainingWh", "_remainingPercent"];
    if (_hasBattery isEqualTo false) then {
        ROOT_CYBERWARFARE_LOG_ERROR("getUserConfirmation: Battery not found or laptop has no internal battery");
        _canConfirm = false;
    } else {
        private _string = format [
            localize "STR_ROOT_CYBERWARFARE_POWER_CONFIRM_DETAILS",
            round _powerCost,
            round _currentWh,
            round _currentPercent,
            "%",
            round _remainingWh,
            round _remainingPercent
        ];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
};

if (!_canConfirm) exitWith { false };

// Display confirmation prompt
private _string = localize "STR_ROOT_CYBERWARFARE_CONFIRM_PROMPT";
[_computer, _string] call AE3_armaos_fnc_shell_stdout;

// Wait for user input
private _confirmed = false;
while {true} do {
    private _input = [_computer] call AE3_armaos_fnc_shell_stdin;

    if (_input in ["y", "Y"]) exitWith {
        _confirmed = true;
    };

    if (_input in ["n", "N"]) exitWith {
        _confirmed = false;
    };
};

_confirmed
