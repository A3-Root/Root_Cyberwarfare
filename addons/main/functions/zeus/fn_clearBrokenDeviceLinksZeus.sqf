#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ZEN module to clear broken device links on demand. Asks the server to run one immediate
 * cleanup sweep (drops link/device references whose backing object no longer exists) and reports the
 * number removed back to the curator. Runs regardless of the automatic-cleanup CBA setting.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_clearBrokenDeviceLinksZeus;
 *
 * Public: No
 */

params ["_logic"];

if (hasInterface) then {
    [clientOwner] remoteExec [QFUNC(clearBrokenDeviceLinksZeusMain), 2];
};

deleteVehicle _logic;
