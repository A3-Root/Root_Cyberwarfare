#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add power generators
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddPowerGenerator;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get module attributes
private _generatorName = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_POWERGRID_NAME", "Power Generator"];
private _radius = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_POWERGRID_RADIUS", 1000];
private _allowExplosionOverload = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_POWERGRID_EXPLOSION_OVERLOAD", 0]) isEqualTo 1;
private _explosionType = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_POWERGRID_EXPLOSION_TYPE", "ClaymoreDirectionalMine_Remote_Ammo_Scripted"];
private _excludedClassnames = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_POWERGRID_EXCLUDED", ""];
private _powerCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_POWERGRID_COST", 10];
private _addToPublic = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_POWERGRID_PUBLIC", 1]) isEqualTo 1;

// Parse excluded classnames (comma-separated string to array)
private _excludedArray = [];
if (_excludedClassnames != "") then {
	_excludedArray = _excludedClassnames splitString ",";
	_excludedArray = _excludedArray apply { _x trim [" ", 2] };
};

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Separate laptops from generator objects
private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

private _generators = _syncedObjects select {
	!(_x in _laptops)
};

if (_generators isEqualTo []) exitWith {
	LOG_ERROR("3DEN Add Power Generator: No generator objects synchronized to this module!");
	deleteVehicle _logic;
};

// Get laptop netIds for linking
private _linkedComputers = _laptops;

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

// Process each generator
{
	private _generator = _x;
	private _execUserId = 2; // Server

	// Call the existing Zeus main function
	// Parameters: _targetObject, _execUserId, _linkedComputers, _generatorName, _radius, _allowExplosionOverload, _explosionType, _excludedClassnames, _availableToFutureLaptops, _powerCost
	[_generator, _execUserId, _linkedComputers, _generatorName, _radius, _allowExplosionOverload, _explosionType, _excludedArray, _availableToFutureLaptops, _powerCost] call FUNC(addPowerGeneratorZeusMain);

} forEach _generators;

// Delete the logic module after execution
deleteVehicle _logic;
