#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Disables a GPS tracker attached to an object and notifies linked computers
 *
 * Arguments:
 * 0: _target <OBJECT> - The object with the GPS tracker
 * 1: _trackerData <ARRAY> - GPS tracker data array
 * 2: _player <OBJECT> - The player disabling the tracker
 *
 * Return Value:
 * <BOOLEAN> - True if successful, false if tracker not found
 *
 * Example:
 * [_target, _trackerData, player] call Root_fnc_disableGPSTracker;
 *
 * Public: No
 */

params ["_target", "_trackerData", "_player"];

_trackerData params ["_trackerId", "_trackerNetId", "_trackerName", "_trackingTime", "_updateFrequency", "_customMarker", "_linkedComputers", "_availableToFutureLaptops", "_currentStatus", "_allowRetracking", "_lastPingTimer", "_powerCost"];

// Get current devices
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
private _allGpsTrackers = _allDevices select 5;

// Find and update the tracker status
private _trackerIndex = -1;
{
    if ((_x select 0) == _trackerId) exitWith {
        _trackerIndex = _forEachIndex;
    };
} forEach _allGpsTrackers;

if (_trackerIndex == -1) exitWith {
    ["Error: Tracker not found in system.", true, 1.5, 2] call ace_common_fnc_displayText;
};

// Update tracker status to "Disabled"
_allGpsTrackers set [_trackerIndex, [
    _trackerId,
    _trackerNetId,
    _trackerName,
    _trackingTime,
    _updateFrequency,
    _customMarker,
    _linkedComputers,
    _availableToFutureLaptops,
    ["Disabled", time, ""],
    _allowRetracking,
    _lastPingTimer,
    _powerCost
]];

_allDevices set [5, _allGpsTrackers];

// Sync to server
[_allDevices, _trackerId] remoteExec ["Root_fnc_disableGPSTrackerServer", 2];

// Delete any existing marker for this tracker
private _markerName = (_currentStatus select 2);
if (_markerName != "") then {
    deleteMarkerLocal _markerName;
};

// Notify all linked computers
{
    private _computerNetId = _x;
    private _computer = objectFromNetId _computerNetId;
    
    if (!isNull _computer) then {
        private _message = format ["WARNING: GPS Tracker '%1' (ID: %2) has been disabled!", _trackerName, _trackerId];
        private _compOwner = [_computer] remoteExec ["owner", 2];
        [_computer, _message] remoteExec ["AE3_armaos_fnc_shell_stdout", _compOwner];
    };
} forEach _linkedComputers;

true
