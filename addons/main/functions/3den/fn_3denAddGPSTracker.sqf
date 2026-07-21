#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add GPS trackers to objects
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddGPSTracker;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get module attributes
private _trackerName = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_NAME", "Target_GPS"];
private _trackingTime = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_TRACKING_TIME", 60];
private _updateFrequency = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_UPDATE_FREQ", 5];
private _lastPingTimer = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_LAST_PING", 5];
private _powerCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_POWER_COST", 10];
private _customMarker = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_MARKER", ""];
// 3DEN BOOL attributes load as numbers (1/0); coerce to real booleans.
private _allowRetracking = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_RETRACK", 0]) in [1, true];
private _addToPublic = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_PUBLIC", 1]) in [1, true];

// Optional fixed IDs. A single target uses the start value; multiple synced targets hand out
// Start..End sequentially, falling back to auto-assignment once the range is exhausted or unset.
private _startId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_ID_START", 0]);
private _endId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_ID_END", 0]);

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Separate laptops from target objects
private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

private _targets = _syncedObjects select {
	!(_x in _laptops)
};

if (_targets isEqualTo []) exitWith {
	ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add GPS Tracker: No target objects synchronized to this module!");
	deleteVehicle _logic;
};

// Get laptop netIds for linking
private _linkedComputers = _laptops apply { netId _x };

// Determine availability setting
private _availableToFutureLaptops = false;
if (_addToPublic) then {
	if (_linkedComputers isEqualTo []) then {
		// Public + no linked = all current laptops only
		_availableToFutureLaptops = false;
	} else {
		// Public + some linked = linked laptops + all future
		_availableToFutureLaptops = true;
	};
};

// Process each target object
private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", 1];

// Hand out sequential IDs from the requested start across the registered trackers.
private _nextId = _startId;

{
	private _target = _x;
	private _execUserId = 2; // Server

	// GPS tracker module expects OWNERS selection format: [sides, groups, players]
	// For 3DEN, we'll use empty arrays (no additional visibility beyond computer linking)
	private _ownersSelection = [[], [], []];

	private _assignId = 0;
	if (_nextId >= 1000 && _nextId <= 9999 && {_endId <= 0 || _nextId <= _endId}) then {
		_assignId = _nextId;
		_nextId = _nextId + 1;
	};

	// Call the existing Zeus main function
	// Parameters: _targetObject, _execUserId, _selectedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _isFromZeus, _ownersSelection
	[_target, _execUserId, _linkedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, false, _ownersSelection, _assignId] call FUNC(addGPSTrackerZeusMain);

	_index = _index + 1;
} forEach _targets;

missionNamespace setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", _index, true];

// Delete the logic module after execution
deleteVehicle _logic;
