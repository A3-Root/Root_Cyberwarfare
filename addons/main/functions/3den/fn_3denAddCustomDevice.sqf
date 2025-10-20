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

// Separate laptops from target objects
private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

private _targets = _syncedObjects select {
	!(_x in _laptops)
};

if (_targets isEqualTo []) exitWith {
	LOG_ERROR("3DEN Add Custom Device: No target objects synchronized to this module!");
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

} forEach _targets;

// Delete the logic module after execution
deleteVehicle _logic;
