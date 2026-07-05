#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Seeds a Rubberducky USB drive object. The Rubberducky is a single-purpose, read-only
 *              flash drive that comes pre-armed with the hacking toolset: it carries the tools-present
 *              flag so that plugging it into a laptop makes the hacking tools available (the mount
 *              handler then provisions the laptop), and it exposes an empty, read-only filesystem so no
 *              files can be stored on it. Also tags the object so picking it up returns the single
 *              stackable Rubberducky item instead of a per-instance buffered drive.
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

// Tools are pre-installed on the drive; the USB-mount handler surfaces them on the host laptop.
_drive setVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", true, true];
// Marker used by the flash-drive pickup path to hand back the single stackable item (no per-drive id).
_drive setVariable ["ROOT_rubberducky_item", "ROOT_Rubberducky_Item", true];
// Friendly label shown in the file browser / volume list.
_drive setVariable ["ace_cargo_customName", "Rubberducky USB", true];

// Read-only, empty filesystem: owner and everyone have read+execute but no write, so no files can be
// created or stored on the drive.
private _readOnlyFs = [createHashMap, "root", [[true, false, true], [true, false, true]]];
private _loc = if (isNil "AE3_armaos_fnc_computer_getLocality") then { 2 } else { [_drive] call AE3_armaos_fnc_computer_getLocality };
_drive setVariable ["AE3_filesystem", _readOnlyFs, _loc];
