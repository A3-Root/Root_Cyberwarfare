#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side implementation for the "Clear Broken Device Links" ZEN module. Runs one
 * immediate cleanup sweep and reports the number of removed entries back to the requesting curator.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the curator that placed the module (feedback target)
 *
 * Return Value:
 * None
 *
 * Example:
 * [clientOwner] remoteExec ["Root_fnc_clearBrokenDeviceLinksZeusMain", 2];
 *
 * Public: No
 */

params [["_owner", 0, [0]]];

if (!isServer) exitWith {};

private _removed = call FUNC(clearBrokenDeviceLinks);

if (_owner > 0) then {
    [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_CLEAR_LINKS_RESULT", _removed]] remoteExec ["zen_common_fnc_showMessage", _owner];
};
