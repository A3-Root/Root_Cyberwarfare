#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add hackable vehicles
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddVehicle;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get module attributes
private _vehicleName = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_NAME", "Target Vehicle"];
private _powerCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_COST", 2];
private _allowFuel = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL", true];
private _allowSpeed = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED", true];
private _allowBrakes = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES", false];
private _allowLights = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS", true];
private _allowEngine = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE", true];
private _allowAlarm = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM", false];
private _addToPublic = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_VEHICLE_PUBLIC", true];

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Separate laptops from vehicles
private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

private _vehicles = _syncedObjects select {
	!(_x in _laptops) && {_x isKindOf "AllVehicles"}
};

if (_vehicles isEqualTo []) exitWith {
	ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add Vehicle: No vehicles synchronized to this module!");
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

// Process each vehicle
{
	private _vehicle = _x;
	private _execUserId = 2; // Server

	// Check if this is a UAV/drone
	if (unitIsUAV _vehicle) then {
		// Call as drone with 4 parameters
		// Parameters: _targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops
		[_vehicle, _execUserId, _linkedComputers, _availableToFutureLaptops] call FUNC(addVehicleZeusMain);
	} else {
		// Call as vehicle with 12 parameters
		// Parameters: _targetObject, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost
		[_vehicle, _execUserId, _linkedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost] call FUNC(addVehicleZeusMain);
	};

} forEach _vehicles;

// Delete the logic module after execution
deleteVehicle _logic;
