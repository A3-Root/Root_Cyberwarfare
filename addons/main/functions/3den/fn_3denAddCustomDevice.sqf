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
private _addToPublic = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_CUSTOM_PUBLIC", true];

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Separate triggers, laptops, and target objects
private _triggers = _syncedObjects select {
	_x isKindOf "EmptyDetector"
};

private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

private _directTargets = _syncedObjects select {
	!(_x in _laptops) && !(_x in _triggers)
};

private _allTargets = [];

// If triggers exist, get objects from trigger areas
if (_triggers isNotEqualTo []) then {
	private _objectsInArea = [_triggers] call FUNC(getObjectsInTriggerArea);
	_allTargets append _objectsInArea;
};

// Add directly synchronized targets
_allTargets append _directTargets;

if (_allTargets isEqualTo []) exitWith {
	ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add Custom Device: No target objects synchronized or found in trigger areas!");
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
{
	private _target = _x;
	private _execUserId = 2; // Server

	// Call the custom device Zeus main function
	// Parameters: _targetObject, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops
	[_target, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] call FUNC(addCustomDeviceZeusMain);

} forEach _allTargets;

// Delete the logic module after execution
deleteVehicle _logic;
