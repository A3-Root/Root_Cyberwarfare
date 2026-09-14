#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Warns the curator when the access settings just confirmed leave a device that no laptop
 *              can reach. That happens when the device is set to linked access and no laptop was ticked,
 *              either because none were offered or because none were picked, and the device is not being
 *              handed to future laptops either. The device is still registered and can be wired up later
 *              with the Manage Device Access module, but nothing in the dialog says so on its own: the
 *              form closes with the usual "added" message, and the gap only shows up when an operator
 *              sits down at a laptop and cannot find the device.
 *
 * Arguments:
 * 0: _accessMode <NUMBER> - ACCESS_MODE_* constant chosen in the dialog
 * 1: _linkedComputers <ARRAY> - Laptop netIds ticked in the dialog
 * 2: _availableToFutureLaptops <BOOL> (Optional, default: false) - Linked access extends to later laptops
 *
 * Return Value:
 * Device is currently unreachable <BOOL>
 *
 * Example:
 * [_accessMode, _linkedComputers, _availableToFutureLaptops] call Root_fnc_warnUnreachableDevice;
 *
 * Public: No
 */

params [
    ["_accessMode", ACCESS_MODE_UNASSIGNED, [0]],
    ["_linkedComputers", [], [[]]],
    ["_availableToFutureLaptops", false, [false, 0]]
];

if (_availableToFutureLaptops isEqualType 0) then {
    _availableToFutureLaptops = _availableToFutureLaptops > 0;
};

private _unreachable = (_accessMode == ACCESS_MODE_LINKED)
    && {_linkedComputers isEqualTo []}
    && {!_availableToFutureLaptops};

if (_unreachable && {hasInterface}) then {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LINKS_WARN"] call zen_common_fnc_showMessage;
};

_unreachable
