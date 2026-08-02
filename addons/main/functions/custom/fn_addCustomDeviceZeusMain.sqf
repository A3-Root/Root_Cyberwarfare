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
 * 7: _allowLocation <BOOLEAN> (Optional) - Show grid location on the laptop, default: true
 * 8: _requestedId <NUMBER> (Optional) - Desired device ID (0 = auto-assign), default: 0
 * 9: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
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
 * 8: _allowLocation <BOOLEAN> (Optional) - Show grid location on the laptop, default: true
 * 9: _startId <NUMBER> (Optional) - First device ID handed out across the area (0 = auto), default: 0
 * 10: _endId <NUMBER> (Optional) - Last device ID handed out across the area (0 = auto), default: 0
 * 11: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Generator", "hint 'ON'", "hint 'OFF'", false, true, 0, ACCESS_MODE_PUBLIC] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
 * [[100, 200, 0], 500, 0, [], "GenSet", "hint 'ON'", "hint 'OFF'", true, true, 0, 0, ACCESS_MODE_LINKED] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2]; // Radius mode with position
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
private _allowLocation = true; // "Allow Location View" (General #3); default on
private _requestedId = 0;      // Desired device ID for direct mode (0 = auto)
private _startId = 0;          // First ID handed out across a radius sweep
private _endId = 0;            // Last ID handed out across a radius sweep
private _accessMode = ACCESS_MODE_UNASSIGNED; // How the registered devices may be reached

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
    _allowLocation = param [8, true, [false]];
    _startId = param [9, 0, [0]];
    _endId = param [10, 0, [0]];
    _accessMode = param [11, ACCESS_MODE_UNASSIGNED, [0]];
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
    _allowLocation = param [7, true, [false]];
    _requestedId = param [8, 0, [0]];
    _accessMode = param [9, ACCESS_MODE_UNASSIGNED, [0]];
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

    // Hand out sequential IDs from the requested start across the found objects; once the range is
    // exhausted (or none was given) the remaining devices fall back to auto-assignment.
    private _nextId = _startId;

    // Register each object
    {
        private _obj = _x;
        // Register each object (skip logic modules)
        if (typeOf _obj find "Logic" < 0) then {
            private _assignId = 0;
            if (_nextId >= 1000 && _nextId <= 9999 && {_endId <= 0 || _nextId <= _endId}) then {
                _assignId = _nextId;
                _nextId = _nextId + 1;
            };
            [_obj, _execUserId, _linkedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops, _allowLocation, _assignId, _accessMode] call FUNC(addCustomDeviceZeusMain);
            _registeredCount = _registeredCount + 1;
        };
    } forEach _allObjects;

    // Send feedback to user
    [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_SUCCESS", _registeredCount]] remoteExec ["zen_common_fnc_showMessage", _execUserId];
    [format ["Root Cyber Warfare: Registered %1 custom device(s) in %2m radius", _registeredCount, _radius]] remoteExec ["systemChat", _execUserId];
};

// Store activation/deactivation code on the object
_targetObject setVariable ["ROOT_CYBERWARFARE_ALLOW_LOCATION", _allowLocation, true]; // General #3
_targetObject setVariable ["ROOT_CYBERWARFARE_ACTIVATIONCODE", _activationCode, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_DEACTIVATIONCODE", _deactivationCode, true];

// Get all devices
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allCustom = _allDevices select 4;

// Honour a caller-requested ID when free, otherwise draw a fresh unused one.
private _deviceId = [_requestedId, _allCustom apply { _x select 0 }] call FUNC(resolveDeviceId);

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
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
call Root_fnc_syncDeviceData;

// Only link computers whose object still exists, then apply the requested reachability: private
// links, public registration, or nothing at all.
private _validComputers = _linkedComputers select {!isNull (objectFromNetId _x)};
[DEVICE_TYPE_CUSTOM, _deviceId, _validComputers, _accessMode, _availableToFutureLaptops] call FUNC(applyDeviceAccess);

ROOT_CYBERWARFARE_LOG_INFO_1("Custom Device added: %1",_customName);
