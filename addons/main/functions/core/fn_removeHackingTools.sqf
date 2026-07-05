#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function that removes a previously installed hacking toolset from a
 *              computer's virtual filesystem and clears its tools-present flag. Used to withdraw the
 *              toolset from a laptop when the hacking USB that provisioned it is unplugged, so pulling
 *              the drive removes the laptop's hacking capability.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop object to strip
 * 1: _path <STRING> (Optional) - Installation path the toolset was written to, default: "/rubberducky/tools"
 *
 * Return Value:
 * None
 *
 * Example:
 * [_laptop, "/rubberducky/tools"] call Root_fnc_removeHackingTools;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]], ["_path", "/rubberducky/tools", [""]]];

if (isNull _computer) exitWith {};
if (isNil "AE3_filesystem_fnc_delObj") exitWith {};

private _filesystem = _computer getVariable ["AE3_filesystem", []];
if (_filesystem isEqualTo []) exitWith {};

// Delete each command file the installer wrote under the tool path (skip any that are absent).
{
    private _target = _path + "/" + _x;
    if ([[], _filesystem, _target, "root"] call AE3_filesystem_fnc_fsObjExists) then {
        [[], _filesystem, _target, "root"] call AE3_filesystem_fnc_delObj;
    };
} forEach ["guide", "devices", "door", "light", "changedrone", "disabledrone", "download", "custom", "gpstrack", "vehicle", "powergrid", "netscan"];

// Persist the pruned filesystem with the correct locality for this computer, then clear the
// tools-present flag and refresh availability so the desktop apps disappear again.
_computer setVariable ["AE3_filesystem", _filesystem, [_computer] call AE3_armaos_fnc_computer_getLocality];
_computer setVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false, true];
[_computer] call FUNC(syncHackingToolAvailability);
