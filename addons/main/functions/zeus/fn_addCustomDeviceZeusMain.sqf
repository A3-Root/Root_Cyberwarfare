#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to register a custom device with activation/deactivation code
 *
 * Arguments:
 * 0: _targetObject <OBJECT> - The object to register as a custom device
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds to link, default: []
 * 3: _customName <STRING> (Optional) - Custom device name, default: "Custom Device"
 * 4: _activationCode <STRING> (Optional) - Code to execute on activation, default: ""
 * 5: _deactivationCode <STRING> (Optional) - Code to execute on deactivation, default: ""
 * 6: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Generator", "hint 'ON'", "hint 'OFF'", false] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
 *
 * Public: No
 */

params [
    ["_targetObject", objNull],
    ["_execUserId", 0],
    ["_linkedComputers", []],
    ["_customName", "Custom Device"],
    ["_activationCode", ""],
    ["_deactivationCode", ""],
    ["_availableToFutureLaptops", false]
];

if (isNull _targetObject) exitWith {
    LOG_ERROR("addCustomDeviceZeusMain: Invalid target object");
};

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

// Store activation/deactivation code on the object
_targetObject setVariable ["ROOT_CYBERWARFARE_ACTIVATIONCODE", _activationCode, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_DEACTIVATIONCODE", _deactivationCode, true];

// Generate unique device ID
private _deviceId = (round (random 8999)) + 1000;

// Get all devices
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allCustom = _allDevices select 4;

// Store device entry: [deviceId, objectNetId, deviceName, activationCode, deactivationCode, availableToFuture]
_allCustom pushBack [
    _deviceId,
    netId _targetObject,
    _customName,
    _activationCode,
    _deactivationCode,
    _availableToFutureLaptops
];

// Update device array
_allDevices set [4, _allCustom];
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
    private _computerNetId = _x;
    // Get computer object to verify it exists
    private _computer = objectFromNetId _computerNetId;
    if (!isNull _computer) then {
        private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
        _existingLinks pushBack [DEVICE_TYPE_CUSTOM, _deviceId];
        _linkCache set [_computerNetId, _existingLinks];

        // Remove from exclusion list if they were in it
        _allExistingComputers = _allExistingComputers - [_computerNetId];

        // Broadcast event
        ["root_cyberwarfare_deviceLinked", [_computerNetId, DEVICE_TYPE_CUSTOM, _deviceId]] call CBA_fnc_serverEvent;
    };
} forEach _linkedComputers;

// Update link cache
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];

// If available to future laptops, add to public devices with exclusion list
if (_availableToFutureLaptops) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];
    _publicDevices pushBack [DEVICE_TYPE_CUSTOM, _deviceId, _allExistingComputers];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};

// Sync variables
publicVariable "ROOT_CYBERWARFARE_ALL_DEVICES";
publicVariable "ROOT_CYBERWARFARE_LINK_CACHE";
if (_availableToFutureLaptops) then {
    publicVariable "ROOT_CYBERWARFARE_PUBLIC_DEVICES";
};

LOG_INFO_1("Custom Device added: %1",_customName);
