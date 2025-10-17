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
private _allowRetracking = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_RETRACK", false];
private _addToPublic = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_GPS_PUBLIC", true];

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
	LOG_ERROR("3DEN Add GPS Tracker: No target objects synchronized to this module!");
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

{
	private _target = _x;
	private _execUserId = 2; // Server

	// GPS tracker module expects OWNERS selection format: [sides, groups, players]
	// For 3DEN, we'll use empty arrays (no additional visibility beyond computer linking)
	private _ownersSelection = [[], [], []];

	// Call the existing Zeus main function
	// Parameters: _targetObject, _execUserId, _selectedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _isFromZeus, _ownersSelection
	[_target, _execUserId, _linkedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, false, _ownersSelection] call FUNC(addGPSTrackerZeusMain);

	_index = _index + 1;
} forEach _targets;

missionNamespace setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", _index, true];

// Delete the logic module after execution
deleteVehicle _logic;
