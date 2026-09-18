#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Checks if a computer can access a specific device with optional backdoor bypass.
 *              Access is matched against every identifier the computer answers to rather than a single
 *              key, so a link stored under the laptop's netId and one stored under the persistent
 *              identity Experimental mode uses both grant the access they were written for.
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

private _hasHackingTools = [_computer] call FUNC(syncHackingToolAvailability);
DEBUG_LOG_1("Hacking tools available: %1",_hasHackingTools);

if !(_hasHackingTools) exitWith {
    ROOT_CYBERWARFARE_LOG_DEBUG("isDeviceAccessible: Hacking tools not available");
    DEBUG_LOG("Hacking tools not available - ACCESS DENIED");
    false
};

// Every identifier this computer's access may be filed under, so a link written by an older build or
// by a script naming the laptop's netId still resolves.
private _computerIdentifiers = [_computer] call FUNC(getComputerIdentifiers);
DEBUG_LOG_1("Computer identifiers: %1",_computerIdentifiers);

if (_computerIdentifiers isEqualTo []) exitWith {
    DEBUG_LOG("Unable to determine computer identifier - ACCESS DENIED");
    false
};

// Check if this device is in the public list FIRST
private _publicDevices = GET_PUBLIC_DEVICES;
private _isPublic = false;
DEBUG_LOG_1("Checking public devices (count: %1)",count _publicDevices);

{
    _x params ["_pubDevType", "_pubDevId", ["_excludedIdentifiers", []]];

    if (_pubDevType == _deviceType && _pubDevId == _deviceId) exitWith {
        DEBUG_LOG_2("Found matching public device - DeviceType: %1, DeviceId: %2",_pubDevType,_pubDevId);
        DEBUG_LOG_1("Exclusion list: %1",_excludedIdentifiers);

        // If no exclusion list, fully public
        if (_excludedIdentifiers isEqualTo []) exitWith {
            _isPublic = true;
            DEBUG_LOG("No exclusion list - device is fully public");
        };

        // Excluding a computer means excluding every name it answers to, so a single hit locks it out.
        _isPublic = (_computerIdentifiers findIf {_x in _excludedIdentifiers}) == -1;
        DEBUG_LOG_2("Identifiers %1 in exclusion list: %2",_computerIdentifiers,!_isPublic);
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

// Gather the links filed under every name this computer answers to, so access granted under any one
// of them counts.
private _allowedDevices = [];
{
    _allowedDevices append (_linkCache getOrDefault [_x, []]);
} forEach _computerIdentifiers;

DEBUG_LOG_2("Private device links for identifiers %1: %2 devices",_computerIdentifiers,count _allowedDevices);
if (_deviceType == DEVICE_TYPE_GPS_TRACKER) then {
    DEBUG_LOG_3("[GPS DEBUG] identifiers=%1 deviceId=%2 allowedDevices=%3",_computerIdentifiers,_deviceId,_allowedDevices);
};

if (_allowedDevices isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_DEBUG_1("isDeviceAccessible: No device links for computer %1",_computerIdentifiers);
    DEBUG_LOG("No private device links found - ACCESS DENIED");
    false
};

// Check if device is in allowed list
private _isAllowed = _allowedDevices findIf {
    _x params ["_type", "_id"];
    _type == _deviceType && _id == _deviceId
} != -1;

DEBUG_LOG_3("Private link check result - Identifiers: %1, Device: %2, Allowed: %3",_computerIdentifiers,_deviceId,_isAllowed);
ROOT_CYBERWARFARE_LOG_DEBUG_3("isDeviceAccessible: Computer %1, Device %2 = %3",_computerIdentifiers,_deviceId,_isAllowed);

if (_isAllowed) then {
    DEBUG_LOG("Private link found - ACCESS GRANTED");
} else {
    DEBUG_LOG("Device not in private links - ACCESS DENIED");
};

_isAllowed
