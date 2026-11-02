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
// 3DEN checkbox attributes (typeName BOOL) load as booleans; accept both boolean and legacy numeric storage.
private _makeUnbreachable = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_UNBREACHABLE", 0]) in [1, true];
private _allowLocation = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_ALLOWLOCATION", 1]) in [1, true];
private _startState = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_STARTSTATE", -1];

// Optional fixed building IDs. A single building uses the start value; an area hands out
// Start..End sequentially, falling back to auto-assignment once the range is exhausted or unset.
private _startId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_ID_START", 0]);
private _endId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_ID_END", 0]);

// Optional per-door ID overrides, e.g. "1:101,2:102" (engineDoor:customID). Parsed into
// [[realDoor, customId], ...] and applied to every registered building that exposes those doors.
private _doorIdMapText = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_IDMAP", ""];
private _doorIdMap = [];
{
    private _pair = _x splitString ":";
    if (count _pair == 2) then {
        private _real = floor (parseNumber (_pair select 0));
        private _custom = floor (parseNumber (_pair select 1));
        if (_real > 0 && _custom > 0) then {
            _doorIdMap pushBack [_real, _custom];
        };
    };
} forEach (_doorIdMapText splitString ", ");

// Get all synchronized objects
private _syncedObjects = synchronizedObjects _logic;

// Laptops to link
private _laptops = _syncedObjects select {
    typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_PortableServer_01_black_F_AE3", "Land_PortableServer_01_olive_F_AE3", "Land_PortableServer_01_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

// Synced objects and/or objects in the module area and synced trigger areas, per the Register attribute
private _registerMode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_REGISTER", 1];
([_logic, _registerMode, _laptops] call FUNC(getModuleObjects)) params ["_synced", "_inArea"];

// Get laptop netIds for linking
private _linkedComputers = _laptops apply { netId _x };

// Device Access states how the registered buildings may be reached. The combo's fourth entry (3) is
// the linked-plus-future variant, which resolves to a linked device that later laptops also reach.
private _accessMode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_ACCESS", -1];
private _availableToFutureLaptops = false;

if (_accessMode == 3) then {
    _accessMode = ACCESS_MODE_LINKED;
    _availableToFutureLaptops = true;
};

if (_accessMode < 0) then {
    // Missions saved before Device Access existed carry only the legacy public checkbox, so map that
    // forward and leave their devices as reachable as they were.
    _accessMode = ACCESS_MODE_LINKED;
    if ((_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DOORS_PUBLIC", 1]) in [1, true]) then {
        if (_linkedComputers isEqualTo []) then {
            _accessMode = ACCESS_MODE_PUBLIC;
        } else {
            _availableToFutureLaptops = true;
        };
    };
};

// Keep only objects that expose door animations or door configs
private _allDevices = (_synced + _inArea) select { ([_x] call Root_fnc_detectBuildingDoors) isNotEqualTo [] };

if (_allDevices isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add Doors: No door-bearing objects synchronized or found in the module or trigger areas!");
    deleteVehicle _logic;
};

// Hand out sequential IDs from the requested start across the registered buildings; each building
// also receives the shared per-door override map.
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

    // Call the doors-specific main function
    // Parameters: _targetObject, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation, _requestedId, _doorIdMap, _accessMode, _startState
    [_device, _execUserId, _linkedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation, _assignId, _doorIdMap, _accessMode, _startState] call FUNC(addDoorsZeusMain);

} forEach _allDevices;

// Delete the logic module after execution
deleteVehicle _logic;
