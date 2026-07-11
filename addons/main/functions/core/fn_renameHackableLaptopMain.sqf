#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function that changes the link-dialog name of an already registered
 *              hackable laptop. Only the label changes: the laptop keeps its registration, its
 *              linked devices, its filesystem and its accounts, so an operator can relabel a station
 *              at any point in the mission. Zeus and 3DEN modules read the name when they build their
 *              link dialogs, so the new name shows up the next time a device is added.
 *
 * Arguments:
 * 0: _entity <OBJECT> - The registered laptop object
 * 1: _newName <STRING> - The new display name used when linking devices
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0 (resolves to owner)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_laptop, "Noddy Laptop"] remoteExec ["Root_fnc_renameHackableLaptopMain", 2];
 *
 * Public: No
 */

params ["_entity", ["_newName", "", [""]], ["_execUserId", 0, [0]]];

if (_execUserId == 0) then {
    _execUserId = owner _entity;
};

if (isNull _entity) exitWith {
    ["Root Cyber Warfare: Cannot rename a null object."] remoteExec ["systemChat", _execUserId];
};

if !(_entity getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]) exitWith {
    ["Root Cyber Warfare: This laptop is not registered as a hackable station."] remoteExec ["systemChat", _execUserId];
};

// An empty name would leave the laptop unlabelled in the link dialogs, so fall back to the class
// display name exactly as registration does.
if (_newName isEqualTo "") then {
    _newName = getText (configOf _entity >> "displayName");
};

_entity setVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _newName, true];

[format ["Root Cyber Warfare: Laptop renamed to '%1'.", _newName]] remoteExec ["systemChat", _execUserId];
