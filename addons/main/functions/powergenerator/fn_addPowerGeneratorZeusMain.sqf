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
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Generator", 100, true, "HelicopterExploSmall", ["Lamp_Street_small_F"], false, 15] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
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
    ["_powerCost", 10]
];

if (isNull _targetObject) exitWith {
    LOG_ERROR("addPowerGeneratorZeusMain: Invalid target object");
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

// Generate unique device ID
private _deviceId = (round (random 8999)) + 1000;

// Get all devices
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allPowerGrids = _allDevices select 7;

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
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];

// Handle device linking
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];

// Get all existing computers for exclusion if availableToFuture is enabled
private _allExistingComputers = [];
if (_availableToFutureLaptops) then {
    {
        private _computerNetId = _x;
        _allExistingComputers pushBack _computerNetId;
    } forEach (keys _linkCache);
};

// Link to specified computers
{
    if (_x != "") then {
        private _computerNetId = _x;
        private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
        _existingLinks pushBack [DEVICE_TYPE_POWERGRID, _deviceId];
        _linkCache set [_computerNetId, _existingLinks];

        // Remove from exclusion list if they were in it
        _allExistingComputers = _allExistingComputers - [_computerNetId];

        // Broadcast event
        ["root_cyberwarfare_deviceLinked", [_computerNetId, DEVICE_TYPE_POWERGRID, _deviceId]] call CBA_fnc_serverEvent;
    };
} forEach _linkedComputers;

// Update link cache
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];

// If available to future laptops, add to public devices with exclusion list
if (_availableToFutureLaptops) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];
    _publicDevices pushBack [DEVICE_TYPE_POWERGRID, _deviceId, _allExistingComputers];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};

// Sync variables
publicVariable "ROOT_CYBERWARFARE_ALL_DEVICES";
publicVariable "ROOT_CYBERWARFARE_LINK_CACHE";
if (_availableToFutureLaptops) then {
    publicVariable "ROOT_CYBERWARFARE_PUBLIC_DEVICES";
};

// Build availability text
private _availabilityText = "";
private _linkedComputerCount = count _linkedComputers;
if (_availableToFutureLaptops) then {
    if (_linkedComputerCount > 0) then {
        _availabilityText = format ["Accessible by %1 linked computer(s) and all future computers", _linkedComputerCount];
    } else {
        _availabilityText = "Accessible by all future computers";
    };
} else {
    if (_linkedComputerCount > 0) then {
        _availabilityText = format ["Accessible by %1 linked computer(s)", _linkedComputerCount];
    } else {
        _availabilityText = "Not accessible by any computers (add links manually)";
    };
};

// Send feedback to Zeus user
[format ["Root Cyber Warfare: Power Grid added with ID: %1. %2", _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];

LOG_INFO_1("Power Grid added: %1",_generatorName);
