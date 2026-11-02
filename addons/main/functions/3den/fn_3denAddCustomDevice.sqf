#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add custom hackable devices
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddCustomDevice;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get module attributes
private _customName = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_NAME", "Custom Device"];
private _activationCode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_ACTIVATE", "// Example: Display Hint when triggered\nhint 'Custom device activated';"];
private _deactivationCode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_DEACTIVATE", "// Example: Display Hint when triggered\nhint 'Custom device deactivated';"];
// 3DEN BOOL attribute loads as a number (1/0); coerce to a real boolean.
// 3DEN checkbox attribute (typeName BOOL) loads as a boolean; accept both boolean and legacy numeric storage.
private _allowLocation = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_ALLOWLOCATION", 1]) in [1, true];

// Optional fixed IDs. A single device uses the start value; an area hands out Start..End
// sequentially, falling back to auto-assignment once the range is exhausted or unset.
private _startId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_ID_START", 0]);
private _endId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_ID_END", 0]);

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Laptops to link
private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_PortableServer_01_black_F_AE3", "Land_PortableServer_01_olive_F_AE3", "Land_PortableServer_01_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

// Synced objects and/or mission-placed objects in the module area and synced trigger areas, per the Register attribute
private _registerMode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_REGISTER", 0];
([_logic, _registerMode, _laptops] call FUNC(getModuleObjects)) params ["_synced", "_inArea"];
private _allTargets = _synced + (_inArea arrayIntersect (allMissionObjects "All"));

if (_allTargets isEqualTo []) exitWith {
	ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add Custom Device: No target objects synchronized or found in the module or trigger areas!");
	deleteVehicle _logic;
};

// Get laptop netIds for linking
private _linkedComputers = _laptops apply { netId _x };

// Device Access states how the registered devices may be reached. The combo's fourth entry (3) is
// the linked-plus-future variant, which resolves to a linked device that later laptops also reach.
private _accessMode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_ACCESS", -1];
private _availableToFutureLaptops = false;

if (_accessMode == 3) then {
    _accessMode = ACCESS_MODE_LINKED;
    _availableToFutureLaptops = true;
};

if (_accessMode < 0) then {
    // Missions saved before Device Access existed carry only the legacy public checkbox, so map
    // that forward and leave their devices as reachable as they were.
    _accessMode = ACCESS_MODE_LINKED;
    if ((_logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_PUBLIC", 1]) in [1, true]) then {
        if (_linkedComputers isEqualTo []) then {
            _accessMode = ACCESS_MODE_PUBLIC;
        } else {
            _availableToFutureLaptops = true;
        };
    };
};

// Hand out sequential IDs from the requested start across the registered devices.
private _nextId = _startId;

// Process each target object
{
	private _target = _x;
	private _execUserId = 2; // Server

	private _assignId = 0;
	if (_nextId >= 1000 && _nextId <= 9999 && {_endId <= 0 || _nextId <= _endId}) then {
		_assignId = _nextId;
		_nextId = _nextId + 1;
	};

	// Call the custom device Zeus main function
	// Parameters: _targetObject, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops
	[_target, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops, _allowLocation, _assignId, _accessMode] call FUNC(addCustomDeviceZeusMain);
	_target setVariable ["ROOT_CYBERWARFARE_ALLOW_LOCATION", _allowLocation, true]; // General #3

} forEach _allTargets;

// Delete the logic module after execution
deleteVehicle _logic;
