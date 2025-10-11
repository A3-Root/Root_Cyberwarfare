#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to disable GPS tracker globally and sync to all clients
 *
 * Arguments:
 * 0: _allDevices <ARRAY> - All devices array
 * 1: _trackerId <NUMBER> - GPS tracker ID to disable
 *
 * Return Value:
 * <BOOLEAN> - Always returns true
 *
 * Example:
 * [_allDevices, 1234] remoteExec ["Root_fnc_disableGPSTrackerServer", 2];
 *
 * Public: No
 */

if (!isServer) exitWith {};

params ["_allDevices", "_trackerId"];

missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];

diag_log format ["[Root Cyber Warfare] GPS Tracker ID %1 has been disabled by player search.", _trackerId];

true
