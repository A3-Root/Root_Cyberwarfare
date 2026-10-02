#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side GPS tracker action for the GUI GPS app. Starts the same tracking
 * workflow as the terminal command and reports the result to the desktop.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (reply target)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _gpsId <NUMBER> - Tracker id from the registry
 * 3: _action <STRING> - "track" for a listed tracker, "trackid" for one named by its identifier
 * 4: _commandPath <STRING> - Backdoor command path
 * 5: _identifier <STRING> (Optional) - The identifier typed into the app. When one is given it names
 *                                      the tracker and stands in for the access check, since a hidden
 *                                      tracker is in no list for the app to have offered, default: ""
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_gpsId", "_action", ["_commandPath", ""], ["_identifier", "", [""]]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_GPS_TRACKER, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};

// An identifier is resolved here, under the same rules the terminal command works by: an unknown code
// says only that it is unknown, and a laptop off the network cannot use one at all.
private _byIdentifier = _identifier isNotEqualTo "";
private _identifierEntry = [];
if (_byIdentifier) then {
	_identifierEntry = [_identifier] call FUNC(resolveGpsIdentifier);
};

if (_byIdentifier && _identifierEntry isEqualTo []) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_GPS_IDENTIFIER_UNKNOWN", false] call _reply;
};

if (_byIdentifier && {missionNamespace getVariable [SETTING_GPS_IDENTIFIER_ONLINE, true]} && {!([_computer] call FUNC(isLaptopOnline))}) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_GPS_IDENTIFIER_OFFLINE", false] call _reply;
};

if (_byIdentifier) then {
	_gpsId = _identifierEntry select 0;
};

if (!_byIdentifier && {!([_computer, DEVICE_TYPE_GPS_TRACKER, _gpsId, _commandPath] call FUNC(isDeviceAccessible))}) exitWith
{
	[_owner, format ["Access denied to tracker %1", _gpsId], false] call _reply;
};

// The global device registry stores GPS trackers at index 5.
private _trackers = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [5, []];
private _idx = _trackers findIf { (_x select 0) == _gpsId };
if (_idx == -1) exitWith { [_owner, format ["Access denied to tracker %1", _gpsId], false] call _reply; };

private _tracker = objectFromNetId ((_trackers select _idx) select 1);
if (isNull _tracker) exitWith { [_owner, format ["Access denied to tracker %1", _gpsId], false] call _reply; };

private _entry = _trackers select _idx;
// The power cost is defaulted rather than left to the entry: a tracker registered before the per-device
// cost existed has a shorter row, and the mission-wide cost below is what such a tracker should use.
_entry params ["_storedTrackerId", "_trackerNetId", "_trackerName", "_trackingTime", "_updateFrequency", "_customMarker", "", "", "_currentStatus", "_allowRetracking", "_lastPingTimer", ["_powerCost", 0, [0]], ["_ownersSelection", [[], [], []]]];
if ((_currentStatus param [0, "Untracked"]) isEqualTo "Tracking") exitWith {
	[_owner, format ["Tracker '%1' is already being tracked.", _trackerName], false] call _reply;
};
if (((_currentStatus param [0, "Untracked"]) in ["Completed", "Tracked", "Untrackable", "Disabled"]) && {!_allowRetracking}) exitWith {
	[_owner, format ["Tracker '%1' cannot be tracked again.", _trackerName], false] call _reply;
};

if (_powerCost < 1) then { _powerCost = _tracker getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_COST", 10]; };
if !([_computer, _powerCost] call FUNC(checkPowerAvailable)) exitWith {
	[_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply;
};
[_computer, _powerCost] call FUNC(consumePower);

private _markerName = if (_customMarker isNotEqualTo "") then { _customMarker } else { format ["ROOT_GpsTracker_%1_%2", _gpsId, round (random 10000)] };
[_tracker, _markerName, _trackingTime, _updateFrequency, _storedTrackerId, _computer, _allowRetracking, _gpsId, _trackerName, _owner, _lastPingTimer, _ownersSelection] remoteExec ["Root_fnc_gpsTrackerServer", 2];

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_GPS_TRACKER, _gpsId, "track"]] call CBA_fnc_serverEvent;
[_owner, "Tracking active.", true] call _reply;
