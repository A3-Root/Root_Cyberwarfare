#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to register a power generator that controls lights within radius
 *
 * Arguments:
 * 0: _targetObject <OBJECT> - The generator object
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer objects, default: []
 * 3: _generatorName <STRING> (Optional) - Generator name, default: "Power Generator"
 * 4: _radius <NUMBER> (Optional) - Radius in meters to affect lights, default: 50
 * 5: _allowExplosionOverload <BOOLEAN> (Optional) - Create explosion on overload, default: false
 * 6: _explosionType <STRING> (Optional) - Explosion ammo type, default: "ClaymoreDirectionalMine_Remote_Ammo_Scripted"
 * 7: _excludedClassnames <ARRAY> (Optional) - Array of classnames to exclude, default: []
 * 8: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 9: _powerCost <NUMBER> (Optional) - Power cost in Wh per operation, default: 10
 * 10: _requestedId <NUMBER> (Optional) - Fixed device id, 0 = auto-assign, default: 0
 * 11: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Generator", 100, true, "HelicopterExploSmall", ["Lamp_Street_small_F"], false, 15, 0, ACCESS_MODE_PUBLIC] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
 *
 * Public: No
 */

params [
    ["_targetObject", objNull],
    ["_execUserId", 0],
    ["_linkedComputers", []],
    ["_generatorName", "Power Generator"],
    ["_radius", 50],
    ["_allowExplosionOverload", false],
    ["_explosionType", "ClaymoreDirectionalMine_Remote_Ammo_Scripted"],
    ["_excludedClassnames", []],
    ["_availableToFutureLaptops", false],
    ["_powerCost", 10],
    ["_requestedId", 0],
    ["_accessMode", ACCESS_MODE_UNASSIGNED, [0]]
];

if (isNull _targetObject) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("addPowerGeneratorZeusMain: Invalid target object");
};

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

// Store generator configuration on the object
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_RADIUS", _radius, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_OVERLOAD", _allowExplosionOverload, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_TYPE", _explosionType, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_EXCLUDED", _excludedClassnames, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "ON", true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_DESTROYED", false, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_POWERGRID_COST", _powerCost, true];

// Get all devices
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allPowerGrids = _allDevices select 7;

// Honour a caller-requested ID when free, otherwise draw a fresh unused one.
private _deviceId = [_requestedId, _allPowerGrids apply { _x select 0 }] call FUNC(resolveDeviceId);

// Store device entry: [gridId, objectNetId, gridName, radius, allowExplosionOverload, explosionType, excludedClassnames, availableToFutureLaptops, powerCost, linkedComputers]
_allPowerGrids pushBack [
    _deviceId,
    netId _targetObject,
    _generatorName,
    _radius,
    _allowExplosionOverload,
    _explosionType,
    _excludedClassnames,
    _availableToFutureLaptops,
    _powerCost,
    _linkedComputers
];

// Update device array
_allDevices set [7, _allPowerGrids];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;

// Drop placeholder identifiers, then apply the requested reachability: private links, public
// registration, or nothing at all.
private _validComputers = _linkedComputers select {_x != ""};
private _availabilityText = [DEVICE_TYPE_POWERGRID, _deviceId, _validComputers, _accessMode, _availableToFutureLaptops] call FUNC(applyDeviceAccess);

// Send feedback to Zeus user
[format ["Root Cyber Warfare: Power Grid added with ID: %1. %2", _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];

ROOT_CYBERWARFARE_LOG_INFO_1("Power Grid added: %1",_generatorName);
