#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Public API to clear broken device links on demand. Runs one immediate cleanup sweep on
 * the server (no strike grace - candidates whose object is gone are dropped right away) and returns how
 * many entries were removed. Works whether or not the periodic cleanup loop is enabled. Intended for
 * mission scripts and the "Clear Broken Device Links" ZEN module. Call on, or remoteExec to, the server.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * <NUMBER> - Total entries removed (link/device references whose object no longer exists)
 *
 * Example:
 * private _removed = call Root_fnc_clearBrokenDeviceLinks;
 * [] remoteExec ["Root_fnc_clearBrokenDeviceLinks", 2]; // from a client
 *
 * Public: Yes
 */

if (!isServer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("clearBrokenDeviceLinks must run on the server - use remoteExec to 2.");
    0
};

private _removed = [false] call FUNC(runDeviceLinkCleanup);
ROOT_CYBERWARFARE_LOG_INFO_1(format ["Manual device link cleanup complete. Removed %1 broken entries.",_removed]);
_removed
