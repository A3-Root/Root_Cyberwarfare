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
    LOG_ERROR("getUserConfirmation: Invalid computer object");
    false
};

// Display power cost if provided
if (_powerCost > 0) then {
    private _string = format [localize "STR_ROOT_CYBERWARFARE_POWER_COST_PREVIEW", _powerCost];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

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
