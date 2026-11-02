#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add hackable lights
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddLights;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get module attributes (convert number to boolean)
// 3DEN checkbox attributes (typeName BOOL) load as booleans; accept both boolean and legacy numeric storage.
private _allowLocation = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_LIGHTS_ALLOWLOCATION", 1]) in [1, true];

// Optional fixed IDs. A single light uses the start value; an area hands out Start..End
// sequentially, falling back to auto-assignment once the range is exhausted or unset.
private _startId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_LIGHTS_ID_START", 0]);
private _endId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_LIGHTS_ID_END", 0]);

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Laptops to link
private _laptops = _syncedObjects select {
    typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_PortableServer_01_black_F_AE3", "Land_PortableServer_01_olive_F_AE3", "Land_PortableServer_01_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

// Synced objects and/or objects in the module area and synced trigger areas, per the Register attribute
private _registerMode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_LIGHTS_REGISTER", 1];
([_logic, _registerMode, _laptops] call FUNC(getModuleObjects)) params ["_synced", "_inArea"];

// Get laptop netIds for linking
private _linkedComputers = _laptops apply { netId _x };

// Device Access states how the registered devices may be reached. The combo's fourth entry (3) is
// the linked-plus-future variant, which resolves to a linked device that later laptops also reach.
private _accessMode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_LIGHTS_ACCESS", -1];
private _availableToFutureLaptops = false;

if (_accessMode == 3) then {
    _accessMode = ACCESS_MODE_LINKED;
    _availableToFutureLaptops = true;
};

if (_accessMode < 0) then {
    // Missions saved before Device Access existed carry only the legacy public checkbox, so map
    // that forward and leave their devices as reachable as they were.
    _accessMode = ACCESS_MODE_LINKED;
    if ((_logic getVariable ["ROOT_CYBERWARFARE_3DEN_LIGHTS_PUBLIC", 1]) in [1, true]) then {
        if (_linkedComputers isEqualTo []) then {
            _accessMode = ACCESS_MODE_PUBLIC;
        } else {
            _availableToFutureLaptops = true;
        };
    };
};

// Synced objects are registered as given; area objects only when they are lights
private _allDevices = _synced + (_inArea select { _x isKindOf "Lamps_base_F" });

if (_allDevices isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add Lights: No lights synchronized or found in the module or trigger areas!");
    deleteVehicle _logic;
};

// Hand out sequential IDs from the requested start across the registered lights.
private _nextId = _startId;

// Process each device
{
    private _device = _x;
    private _execUserId = 2; // Server

    private _assignId = 0;
    if (_nextId >= 1000 && _nextId <= 9999 && {_endId <= 0 || _nextId <= _endId}) then {
        _assignId = _nextId;
        _nextId = _nextId + 1;
    };

    // Call the lights-specific main function
    // Parameters: _targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops, _allowLocation, _requestedId
    [_device, _execUserId, _linkedComputers, _availableToFutureLaptops, _allowLocation, _assignId, _accessMode] call FUNC(addLightsZeusMain);

} forEach _allDevices;

// Delete the logic module after execution
deleteVehicle _logic;
