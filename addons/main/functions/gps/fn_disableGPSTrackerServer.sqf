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

params ["_allDevices", "_trackerId", "_trackerObject", "_linkedComputers", "_trackerName"];

missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];

// Notify all linked computers
{
    private _computerNetId = _x;
    private _computer = objectFromNetId _computerNetId;
    
    if (!isNull _computer) then {
        private _message = format ["WARNING: GPS Tracker '%1' (ID: %2) has been disabled! Last Ping Position: %3", _trackerName, _trackerId, getPosATL _trackerObject];
        [_computer, _message] call AE3_armaos_fnc_shell_stdout;
    };
} forEach _linkedComputers;

ROOT_CYBERWARFARE_LOG_INFO_1(format ["GPS Tracker ID %1 has been disabled by player search.",_trackerId]);

true
