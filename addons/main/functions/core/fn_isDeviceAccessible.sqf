#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Checks if a computer can access a specific device with optional backdoor bypass
 *              Supports both Simple mode (object-based) and Experimental mode (player UID-based)
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _deviceType <NUMBER> - Device type (1-8)
 * 2: _deviceId <NUMBER> - Device ID
 * 3: _commandPath <STRING> (Optional) - Command path for backdoor checking, default: ""
 *
 * Return Value:
 * <BOOLEAN> - True if device is accessible, false otherwise
 *
 * Example:
 * [_laptop, DEVICE_TYPE_DOOR, 1234] call Root_fnc_isDeviceAccessible;
 * [_laptop, DEVICE_TYPE_DOOR, 1234, "/backdoor/"] call Root_fnc_isDeviceAccessible;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]],
    ["_commandPath", "", [""]]
];

DEBUG_LOG_3("isDeviceAccessible called - Computer: %1, DeviceType: %2, DeviceId: %3",_computer,_deviceType,_deviceId);
DEBUG_LOG_1("Device setup mode: %1",GET_DEVICE_MODE);

if (isNull _computer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("isDeviceAccessible: Invalid computer object");
    DEBUG_LOG("Computer object is null - ACCESS DENIED");
    false
};

if !(VALIDATE_DEVICE_TYPE(_deviceType)) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR_1("isDeviceAccessible: Invalid device type %1",_deviceType);
    DEBUG_LOG_1("Invalid device type %1 - ACCESS DENIED",_deviceType);
    false
};

// Check if this command is running from a backdoor path
private _backdoorPaths = _computer getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", []];
DEBUG_LOG_2("Backdoor check - CommandPath: %1, BackdoorPaths: %2",_commandPath,_backdoorPaths);

if (_commandPath != "" && {_backdoorPaths isNotEqualTo []}) then {
    {
        if (_commandPath find _x == 0) exitWith {
            DEBUG_LOG_1("Backdoor access granted via path: %1",_x);
            true
        };
    } forEach _backdoorPaths;
};

// Check if hacking tools are installed
private _hasHackingTools = _computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false];
DEBUG_LOG_1("Hacking tools installed: %1",_hasHackingTools);

if !(_hasHackingTools) exitWith {
    ROOT_CYBERWARFARE_LOG_DEBUG("isDeviceAccessible: Hacking tools not installed");
    DEBUG_LOG("Hacking tools not installed - ACCESS DENIED");
    false
};

// Get persistent identifier for this computer
private _computerIdentifier = [_computer] call FUNC(getComputerIdentifier);
DEBUG_LOG_1("Computer identifier: %1",_computerIdentifier);

if (_computerIdentifier == "") exitWith {
    DEBUG_LOG("Unable to determine computer identifier - ACCESS DENIED");
    false
};

// Check if this device is in the public list FIRST
private _publicDevices = GET_PUBLIC_DEVICES;
private _isPublic = false;
DEBUG_LOG_1("Checking public devices (count: %1)",count _publicDevices);

{
    _x params ["_pubDevType", "_pubDevId", ["_excludedIdentifiers", []]];

    if (_pubDevType == _deviceType && {_pubDevId == _deviceId}) exitWith {
        DEBUG_LOG_2("Found matching public device - DeviceType: %1, DeviceId: %2",_pubDevType,_pubDevId);
        DEBUG_LOG_1("Exclusion list: %1",_excludedIdentifiers);

        // If no exclusion list, fully public
        if (_excludedIdentifiers isEqualTo []) exitWith {
            _isPublic = true;
            DEBUG_LOG("No exclusion list - device is fully public");
        };

        // Check if computer identifier is NOT excluded
        _isPublic = !(_computerIdentifier in _excludedIdentifiers);
        DEBUG_LOG_2("Identifier %1 in exclusion list: %2",_computerIdentifier,!_isPublic);
    };
} forEach _publicDevices;

// If device is public and accessible, return true
if (_isPublic) exitWith {
    DEBUG_LOG("Public device access granted - ACCESS GRANTED");
    true
};

DEBUG_LOG("Device not public or excluded - checking private links");

// Check private device links using hashmap cache
private _linkCache = GET_LINK_CACHE;

// Get this computer's device links from cache
private _allowedDevices = _linkCache getOrDefault [_computerIdentifier, []];
DEBUG_LOG_2("Private device links for identifier %1: %2 devices",_computerIdentifier,count _allowedDevices);

if (_allowedDevices isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_DEBUG_1("isDeviceAccessible: No device links for computer %1",_computerIdentifier);
    DEBUG_LOG("No private device links found - ACCESS DENIED");
    false
};

// Check if device is in allowed list
private _isAllowed = _allowedDevices findIf {
    _x params ["_type", "_id"];
    _type == _deviceType && {_id == _deviceId}
} != -1;

DEBUG_LOG_3("Private link check result - Identifier: %1, Device: %2, Allowed: %3",_computerIdentifier,_deviceId,_isAllowed);
ROOT_CYBERWARFARE_LOG_DEBUG_3("isDeviceAccessible: Computer %1, Device %2 = %3",_computerIdentifier,_deviceId,_isAllowed);

if (_isAllowed) then {
    DEBUG_LOG("Private link found - ACCESS GRANTED");
} else {
    DEBUG_LOG("Device not in private links - ACCESS DENIED");
};

_isAllowed
