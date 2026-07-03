#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Checks whether a computer has hacking tools installed locally or on a mounted USB drive.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Computer object to inspect
 *
 * Return Value:
 * Hacking tools availability <BOOL>
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith {false};
if (_computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) exitWith {true};

private _occupiedList = _computer getVariable ["AE3_USB_Interfaces_occupied", []];
private _mountedList = _computer getVariable ["AE3_USB_Interfaces_mounted", []];

private _mountedToolIndex = -1;
for "_index" from 0 to ((count _occupiedList) - 1) do {
    private _flashDrive = _occupiedList param [_index, objNull];
    if (
        !(isNull _flashDrive) &&
        {(_mountedList param [_index, false])} &&
        {_flashDrive getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]}
    ) exitWith {
        _mountedToolIndex = _index;
    };
};

_mountedToolIndex >= 0
