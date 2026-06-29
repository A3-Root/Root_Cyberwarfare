#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add hackable building doors
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddDoors;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get module attributes (convert number to boolean)
private _addToPublic = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_PUBLIC", 1]) isEqualTo 1;
private _makeUnbreachable = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_UNBREACHABLE", 0]) isEqualTo 1;
private _allowLocation = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_ALLOWLOCATION", 1]) isEqualTo 1;

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Separate triggers, laptops, and devices
private _triggers = _syncedObjects select {
    _x isKindOf "EmptyDetector"
};

private _laptops = _syncedObjects select {
    typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

private _directDevices = _syncedObjects select {
    !(_x in _laptops) && !(_x in _triggers) && {([_x] call Root_fnc_detectBuildingDoors) isNotEqualTo []}
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

private _allDevices = [];

// If triggers exist, get objects from trigger areas
if (_triggers isNotEqualTo []) then {
    private _objectsInArea = [_triggers] call FUNC(getObjectsInTriggerArea);

    // Keep only objects that expose door animations or door configs
    private _doorObjects = _objectsInArea select {
        private _detectedDoors = [_x] call Root_fnc_detectBuildingDoors;
        _detectedDoors isNotEqualTo []
    };

    _allDevices append _doorObjects;
};

// Add directly synchronized door-bearing objects
_allDevices append _directDevices;

if (_allDevices isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add Doors: No door-bearing objects synchronized or found in trigger areas!");
    deleteVehicle _logic;
};

// Process each device
{
    private _device = _x;
    private _execUserId = 2; // Server

    // Call the doors-specific main function
    // Parameters: _targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable
    [_device, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation] call FUNC(addDoorsZeusMain);

} forEach _allDevices;

// Delete the logic module after execution
deleteVehicle _logic;
