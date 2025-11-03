#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to register custom device(s) with activation/deactivation code
 *
 * Arguments:
 * DIRECT MODE (single object):
 * 0: _targetObject <OBJECT> - The object to register as a custom device
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds to link, default: []
 * 3: _customName <STRING> (Optional) - Custom device name, default: "Custom Device"
 * 4: _activationCode <STRING> (Optional) - Code to execute on activation, default: ""
 * 5: _deactivationCode <STRING> (Optional) - Code to execute on deactivation, default: ""
 * 6: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * RADIUS MODE (multiple objects):
 * 0: _centerPosition <ARRAY> - Position array [x, y, z] for search center
 * 1: _radius <NUMBER> - Search radius in meters
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _linkedComputers <ARRAY> (Optional) - Array of computer netIds to link, default: []
 * 4: _customName <STRING> (Optional) - Custom device name, default: "Custom Device"
 * 5: _activationCode <STRING> (Optional) - Code to execute on activation, default: ""
 * 6: _deactivationCode <STRING> (Optional) - Code to execute on deactivation, default: ""
 * 7: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Generator", "hint 'ON'", "hint 'OFF'", false] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
 * [[100, 200, 0], 500, 0, [], "GenSet", "hint 'ON'", "hint 'OFF'", true] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2]; // Radius mode with position
 *
 * Public: No
 */

// Detect mode based on first parameter type
private _radiusMode = false;
private _centerPos = [];
private _targetObject = objNull;
private _radius = 0;
private _execUserId = 0;
private _linkedComputers = [];
private _customName = "Custom Device";
private _activationCode = "";
private _deactivationCode = "";
private _availableToFutureLaptops = false;

private _firstParam = _this select 0;

// Check if first parameter is an array (position array for radius mode) or object (direct mode)
if (typeName _firstParam == "ARRAY") then {
    // Radius mode: position array passed
    _radiusMode = true;
    _centerPos = _firstParam;
    _radius = param [1, 1000, [0]];
    _execUserId = param [2, 0, [0]];
    _linkedComputers = param [3, [], [[]]];
    _customName = param [4, "Custom Device", [""]];
    _activationCode = param [5, "", [""]];
    _deactivationCode = param [6, "", [""]];
    _availableToFutureLaptops = param [7, false, [false]];
} else {
    // Direct mode: object passed
    _radiusMode = false;
    _targetObject = _firstParam;
    _execUserId = param [1, 0, [0]];
    _linkedComputers = param [2, [], [[]]];
    _customName = param [3, "Custom Device", [""]];
    _activationCode = param [4, "", [""]];
    _deactivationCode = param [5, "", [""]];
    _availableToFutureLaptops = param [6, false, [false]];
};

// Validate object in direct mode
if (!_radiusMode && isNull _targetObject) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("addCustomDeviceZeusMain: Invalid target object");
};

if (!_radiusMode && _execUserId == 0) then {
    _execUserId = owner _targetObject;
};

// Handle radius mode
if (_radiusMode) exitWith {
    private _registeredCount = 0;

    // Find all objects in radius (no type filter - any object can be custom device)
    private _allObjects = nearestObjects [_centerPos, [], _radius];

    // Register each object
    {
        private _obj = _x;
        // Register each object (skip logic modules)
        if (typeOf _obj find "Logic" < 0) then {
            [_obj, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] call FUNC(addCustomDeviceZeusMain);
            _registeredCount = _registeredCount + 1;
        };
    } forEach _allObjects;

    // Send feedback to user
    [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_SUCCESS", _registeredCount]] remoteExec ["zen_common_fnc_showMessage", _execUserId];
    [format ["Root Cyber Warfare: Registered %1 custom device(s) in %2m radius", _registeredCount, _radius]] remoteExec ["systemChat", _execUserId];
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

ROOT_CYBERWARFARE_LOG_INFO_1("Custom Device added: %1",_customName);
