#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add hackable devices (doors, lights, drones)
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddDevices;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get module attributes (convert number to boolean)
private _addToPublic = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DEVICES_PUBLIC", 1]) isEqualTo 1;
private _makeUnbreachable = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DEVICES_UNBREACHABLE", 0]) isEqualTo 1;

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Separate laptops from devices
private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

private _devices = _syncedObjects select {
	!(_x in _laptops)
};

if (_devices isEqualTo []) exitWith {
	LOG_ERROR("3DEN Add Devices: No devices synchronized to this module!");
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

// Process each device
{
	private _device = _x;
	private _execUserId = 2; // Server

	// Call the existing Zeus main function
	// Parameters: _targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable
	[_device, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable] call FUNC(addDeviceZeusMain);

} forEach _devices;

// Delete the logic module after execution
deleteVehicle _logic;
