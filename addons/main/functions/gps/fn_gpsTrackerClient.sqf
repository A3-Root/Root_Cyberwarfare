#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Client-side GPS tracker visualization - creates and updates map marker
 *
 * Arguments:
 * 0: _trackerObject <OBJECT> - The object being tracked
 * 1: _markerName <STRING> - Name for the map marker
 * 2: _trackingTime <NUMBER> - Duration in seconds to track
 * 3: _updateFrequency <NUMBER> - Frequency in seconds between updates
 * 4: _trackerName <STRING> - Display name for the tracker
 * 5: _lastPingTimer <NUMBER> - Duration in seconds to show last ping marker
 *
 * Return Value:
 * None
 *
 * Example:
 * [_target, "marker1", 60, 5, "Target_1", 30] call Root_fnc_gpsTrackerClient;
 *
 * Public: No
 */

params ["_trackerObject", "_markerName", "_trackingTime", "_updateFrequency", "_trackerName", "_lastPingTimer"];

private _startTime = time;
private _endTime = _startTime + _trackingTime;

private _trackerPos = getPos _trackerObject;
private _lastKnownPos = _trackerPos; // Store last known position

// Get marker colors from CBA settings
private _activeColor = missionNamespace getVariable [SETTING_GPS_MARKER_COLOR_ACTIVE, "ColorRed"];
private _lastPingColor = missionNamespace getVariable [SETTING_GPS_MARKER_COLOR_LASTPING, "ColorCIV"];

private _marker = createMarkerLocal [_markerName, _trackerPos];
_marker setMarkerTypeLocal "mil_dot";
_marker setMarkerTextLocal _trackerName;
_marker setMarkerColorLocal _activeColor;
private _completed = format ["%1 (Last Ping)", _trackerName];

while {time < _endTime} do {
    if (isNull _trackerObject) then {
        // Object became null, use last known position
        _markerName setMarkerPosLocal _lastKnownPos;
        _marker setMarkerColorLocal _lastPingColor;
        _marker setMarkerTextLocal _completed;
    } else {
        _trackerPos = getPos _trackerObject;
        _lastKnownPos = _trackerPos; // Update last known position
        _markerName setMarkerPosLocal _trackerPos;
    };
    uiSleep _updateFrequency;
};

_marker setMarkerTextLocal _completed;
_marker setMarkerColorLocal _lastPingColor;
// Ensure marker is at last known position
_markerName setMarkerPosLocal _lastKnownPos;

[_marker, _lastPingTimer] spawn {
    params ["_marker", "_lastPingTimer"];
    uiSleep _lastPingTimer;
    deleteMarkerLocal _marker;
};
