#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Seeds a freshly-created Rubberducky USB drive object with a real, per-drive filesystem
 *              (same buffered persistence as a regular AE3 flash drive - see ITEM_ID_LIST on
 *              ROOT_Rubberducky_Item) pre-loaded with the hacking toolset, so plugging it into a laptop
 *              makes the hacking tools available immediately. Only runs on a drive that has no
 *              filesystem yet: a restored, previously-connected instance already carries its own
 *              buffered filesystem, which is reapplied after this init handler runs and takes priority.
 *
 * Arguments:
 * 0: _drive <OBJECT> - The Rubberducky drive/world object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_drive] call Root_fnc_seedRubberducky;
 *
 * Public: No
 */

params [["_drive", objNull, [objNull]]];

if (isNull _drive) exitWith {};
if (!isServer) exitWith {};

// Friendly label shown in the file browser / volume list.
_drive setVariable ["ace_cargo_customName", "Rubberducky USB", true];

// The drive's base class (Land_USB_Dongle_01_F_AE3) creates the blank writable filesystem through its
// own init handler (AE3_filesystem_fnc_initFilesystem), but that can land a frame or more after this
// child init handler fires, so AE3_filesystem is often still nil at this point - seeding immediately
// then fails with "no filesystem initialized". Wait until the base init has published the filesystem,
// then populate it with the hacking tools. Seeding only after the filesystem exists also means a later
// base init can't overwrite the tools we add. Stops early if the drive is picked up/deleted meanwhile.
[
    {
        params ["_drive"];
        isNull _drive || {!isNil {_drive getVariable "AE3_filesystem"}}
    },
    {
        params ["_drive"];
        if (isNull _drive) exitWith {};
        [_drive, "/rubberducky/tools", 0, "Rubberducky USB", "", true] call FUNC(addHackingToolsZeusMain);
    },
    [_drive]
] call CBA_fnc_waitUntilAndExecute;
