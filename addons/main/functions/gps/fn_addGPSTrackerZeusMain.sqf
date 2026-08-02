#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Server-side function to add a GPS tracker to the network
 *
 * Arguments:
 * 0: _targetObject <OBJECT> - The object to track
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _trackerName <STRING> (Optional) - Tracker display name, default: ""
 * 4: _trackingTime <NUMBER> (Optional) - Tracking duration in seconds, default: 60
 * 5: _updateFrequency <NUMBER> (Optional) - Update frequency in seconds, default: 5
 * 6: _customMarker <STRING> (Optional) - Custom marker name, default: ""
 * 7: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 8: _allowRetracking <BOOLEAN> (Optional) - Allow retracking, default: false
 * 9: _lastPingTimer <NUMBER> - Last ping marker duration
 * 10: _powerCost <NUMBER> - Power cost per ping
 * 11: _sysChat <BOOLEAN> (Optional) - Show system chat message, default: true
 * 12: _ownersSelection <ARRAY> (Optional) - Additional sides, groups, or players, to get GPS Pings marked on map, default: [[], [], []]
 * 13: _requestedId <NUMBER> (Optional) - Fixed device id, 0 = auto-assign, default: 0
 * 14: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Tracker1", 60, 5, "", false, true, 30, 2, true, [[], [], []], 0, ACCESS_MODE_PUBLIC] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
 *
 * Public: No
 */

params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], ["_trackerName", ""], ["_trackingTime", 60], ["_updateFrequency", 5], ["_customMarker", ""], ["_availableToFutureLaptops", false], ["_allowRetracking", false], "_lastPingTimer", "_powerCost", ["_sysChat", true], ["_ownersSelection", [[], [], []]], ["_requestedId", 0], ["_accessMode", ACCESS_MODE_UNASSIGNED, [0]]];

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allGpsTrackers = _allDevices select 5;

private _netId = netId _targetObject;

// Honour a caller-requested ID when free, otherwise draw a fresh unused one.
private _deviceId = [_requestedId, _allGpsTrackers apply { _x select 0 }] call FUNC(resolveDeviceId);

// Store the tracker with initial status "Untracked" and owners selection
_allGpsTrackers pushBack [_deviceId, _netId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _linkedComputers, _availableToFutureLaptops, ["Untracked", 0, ""], _allowRetracking, _lastPingTimer, _powerCost, _ownersSelection];

// Update the allDevices array with the new GPS trackers category
_allDevices set [5, _allGpsTrackers];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;


// Store variables on the target object
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_ID", _deviceId, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_NAME", _trackerName, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_TIME", _trackingTime, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_FREQUENCY", _updateFrequency, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_MARKER", _customMarker, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_RETRACK", _allowRetracking, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_PING", _lastPingTimer, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_COST", _powerCost, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_OWNERS", _ownersSelection, true];

// Apply the requested reachability: private links, public registration, or nothing at all.
private _availabilityText = [DEVICE_TYPE_GPS_TRACKER, _deviceId, _linkedComputers, _accessMode, _availableToFutureLaptops] call FUNC(applyDeviceAccess);

if (_sysChat) then {
    [format ["Root Cyber Warfare: GPS Tracker '%1' added (ID: %2). %3", _trackerName, _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];
};
