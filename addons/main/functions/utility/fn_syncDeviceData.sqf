#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Debounced broadcast of the device data globals (ALL_DEVICES, LINK_CACHE,
 * PUBLIC_DEVICES) to all clients. Call after any server-side mutation instead of using
 * setVariable with the public flag or publicVariable directly: bursts of changes (e.g. a
 * 3DEN trigger registering 100 buildings at mission start) collapse into a single broadcast
 * about one second later, instead of one full-array broadcast per registration.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
 * call Root_fnc_syncDeviceData;
 *
 * Public: No
 */

if (!isServer) exitWith {};

if (missionNamespace getVariable ["ROOT_CYBERWARFARE_SYNC_PENDING", false]) exitWith {};
missionNamespace setVariable ["ROOT_CYBERWARFARE_SYNC_PENDING", true];

[{
	missionNamespace setVariable ["ROOT_CYBERWARFARE_SYNC_PENDING", false];

	publicVariable "ROOT_CYBERWARFARE_ALL_DEVICES";
	publicVariable "ROOT_CYBERWARFARE_LINK_CACHE";
	publicVariable "ROOT_CYBERWARFARE_PUBLIC_DEVICES";
	publicVariable "ROOT_CYBERWARFARE_DEVICE_LINKS";

	ROOT_CYBERWARFARE_LOG_DEBUG("Device data broadcast to clients (debounced)");
}, [], 1] call CBA_fnc_waitAndExecute;
