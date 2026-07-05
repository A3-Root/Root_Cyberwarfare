#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function that registers a laptop as a hackable station. This marks the
 *              laptop as eligible to have devices linked to it and to appear as a link target and a
 *              valid access holder, WITHOUT installing the hacking toolset. The toolset itself is
 *              provided separately (self-installed via Add Hacking Tools, or carried by a plugged-in
 *              hacking USB), so a registered laptop stays inert until tools are present.
 *
 * Arguments:
 * 0: _entity <OBJECT> - The laptop object to register
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0 (resolves to owner)
 * 2: _customLaptopName <STRING> (Optional) - Display name for linking, default: "" (uses class displayName)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_laptop, 0, "HQ_Terminal"] remoteExec ["Root_fnc_registerHackableLaptopZeusMain", 2];
 *
 * Public: No
 */

params ["_entity", ["_execUserId", 0, [0]], ["_customLaptopName", "", [""]]];

if (isNull _entity) exitWith {
    [format ["Root Cyber Warfare: Cannot register a null object as a hackable laptop."]] remoteExec ["systemChat", _execUserId];
};

if (_execUserId == 0) then {
    _execUserId = owner _entity;
};

// Fall back to the object's configured display name when no custom name was provided, so the laptop
// always has a human-readable label in the device-linking dialogs.
if (_customLaptopName isEqualTo "") then {
    _customLaptopName = getText (configOf _entity >> "displayName");
};

// Mark the laptop as a registered hacking station (broadcast) and store its link-dialog label.
_entity setVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", true, true];
_entity setVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _customLaptopName, true];

// Refresh availability so any already-present tools (self-installed or a mounted USB) surface immediately.
[_entity] call FUNC(syncHackingToolAvailability);

[format ["Root Cyber Warfare: Laptop registered as a hackable station ('%1').", _customLaptopName]] remoteExec ["systemChat", _execUserId];
