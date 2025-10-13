#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to register a power generator as a custom device that controls lights within radius
 *
 * Arguments:
 * 0: _targetObject <OBJECT> - The generator object
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _generatorName <STRING> (Optional) - Generator name, default: "Power Generator"
 * 4: _radius <NUMBER> (Optional) - Radius in meters to affect lights, default: 50
 * 5: _allowExplosionActivate <BOOLEAN> (Optional) - Create explosion on activation, default: false
 * 6: _allowExplosionDeactivate <BOOLEAN> (Optional) - Create explosion on deactivation, default: false
 * 7: _explosionType <STRING> (Optional) - Explosion ammo type, default: "G_40mm_HE"
 * 8: _excludedClassnames <ARRAY> (Optional) - Array of classnames to exclude, default: []
 * 9: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Generator", 100, true, false, "HelicopterExploSmall", ["Lamp_Street_small_F"], false] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
 *
 * Public: No
 */

params [
    ["_targetObject", objNull],
    ["_execUserId", 0],
    ["_linkedComputers", []],
    ["_generatorName", "Power Generator"],
    ["_radius", 50],
    ["_allowExplosionActivate", false],
    ["_allowExplosionDeactivate", false],
    ["_explosionType", "G_40mm_HE"],
    ["_excludedClassnames", []],
    ["_availableToFutureLaptops", false]
];

if (isNull _targetObject) exitWith {
    LOG_ERROR("addPowerGeneratorZeusMain: Invalid target object");
};

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

// Store generator configuration on the object
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_RADIUS", _radius, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_ACTIVATE", _allowExplosionActivate, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_DEACTIVATE", _allowExplosionDeactivate, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_TYPE", _explosionType, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_EXCLUDED", _excludedClassnames, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GENERATOR_STATE", false, true]; // false = off, true = on

private _netId = netId _targetObject;

// Create activation code
private _activationCode = "
params ['_computer'];
private _generatorNetId = _this getVariable ['ROOT_CYBERWARFARE_CUSTOM_NETID', ''];
private _generator = objectFromNetId _generatorNetId;

if (isNull _generator) exitWith {
    [_computer, 'Error: Generator object not found!'] remoteExec ['AE3_armaos_fnc_shell_stdout', _execUserId];
};

private _isDestroyed = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_DESTROYED', false];
if (_isDestroyed) exitWith {
    [_computer, 'Error: Generator was destroyed and cannot be reactivated!'] remoteExec ['AE3_armaos_fnc_shell_stdout', _execUserId];
};

private _radius = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_RADIUS', 50];
private _allowExplosion = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_ACTIVATE', false];
private _explosionType = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_TYPE', 'G_40mm_HE'];
private _excludedClassnames = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_EXCLUDED', []];

private _allObjects = 25 allObjects 0;
private _objectsInRadius = _allObjects select {(_x distance _generator) <= _radius};

private _lightsAffected = 0;
{
    private _light = _x;
    if (typeOf _light in _excludedClassnames) then { continue };
    if (_light isKindOf 'Lamps_base_F') then {
        _light switchLight 'ON';
        _lightsAffected = _lightsAffected + 1;
    };
} forEach _objectsInRadius;

[_computer, format ['Generator activated: %1 lights turned ON within %2m radius', _lightsAffected, _radius]] remoteExec ['AE3_armaos_fnc_shell_stdout', _execUserId];

_generator setVariable ['ROOT_CYBERWARFARE_GENERATOR_STATE', true, true];
";

// Create deactivation code
private _deactivationCode = "
params ['_computer'];
private _generatorNetId = _this getVariable ['ROOT_CYBERWARFARE_CUSTOM_NETID', ''];
private _generator = objectFromNetId _generatorNetId;

if (isNull _generator) exitWith {
    [_computer, 'Error: Generator object not found!'] remoteExec ['AE3_armaos_fnc_shell_stdout', _execUserId];
};

private _isDestroyed = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_DESTROYED', false];
if (_isDestroyed) exitWith {
    [_computer, 'Error: Generator was destroyed and cannot be reactivated!'] remoteExec ['AE3_armaos_fnc_shell_stdout', _execUserId];
};

private _radius = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_RADIUS', 50];
private _allowExplosion = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_DEACTIVATE', false];
private _explosionType = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_EXPLOSION_TYPE', 'G_40mm_HE'];
private _excludedClassnames = _generator getVariable ['ROOT_CYBERWARFARE_GENERATOR_EXCLUDED', []];

private _allObjects = 25 allObjects 0;
private _objectsInRadius = _allObjects select {(_x distance _generator) <= _radius};

private _lightsAffected = 0;
{
    private _light = _x;
    if (typeOf _light in _excludedClassnames) then { continue };
    if (_light isKindOf 'Lamps_base_F') then {
        _light switchLight 'OFF';
        _lightsAffected = _lightsAffected + 1;
    };
} forEach _objectsInRadius;

if (_allowExplosion) then {
    private _explosion = _explosionType createVehicle (getPos _generator);
    _generator setVariable ['ROOT_CYBERWARFARE_GENERATOR_DESTROYED', true, true];
    [_computer, format ['WARNING: Generator overloaded! All objects requiring electricity within %2m radius affected.', _lightsAffected, _radius]] remoteExec ['AE3_armaos_fnc_shell_stdout', _execUserId];
} else {
    [_computer, format ['Generator deactivated: %1 lights turned OFF within %2m radius', _lightsAffected, _radius]] remoteExec ['AE3_armaos_fnc_shell_stdout', _execUserId];
};

if (!_allowExplosion) then {
    _generator setVariable ['ROOT_CYBERWARFARE_GENERATOR_STATE', false, true];
};
";

// Store these codes on the object itself
_targetObject setVariable ["ROOT_CYBERWARFARE_ACTIVATIONCODE", _activationCode, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_DEACTIVATIONCODE", _deactivationCode, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_CUSTOM_NETID", _netId, true];

// Register as custom device using existing addDeviceZeusMain
[_targetObject, _execUserId, _linkedComputers, true, _generatorName, _activationCode, _deactivationCode, _availableToFutureLaptops] call FUNC(addDeviceZeusMain);

LOG_INFO_1("Power Generator added: %1",_generatorName);
