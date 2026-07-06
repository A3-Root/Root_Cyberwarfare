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

// The drive's base class (Land_USB_Dongle_01_F_AE3) already ran AE3_filesystem_fnc_initFilesystem via
// its own init handler just before this one, giving it a blank writable filesystem - populate it with
// the hacking tools here.
[_drive, "/rubberducky/tools", 0, "Rubberducky USB", "", true] call FUNC(addHackingToolsZeusMain);
