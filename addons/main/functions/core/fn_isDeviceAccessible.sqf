#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Checks if a computer can access a specific device with optional backdoor bypass
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _deviceType <NUMBER> - Device type (1-7)
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

if (isNull _computer) exitWith {
    LOG_ERROR("isDeviceAccessible: Invalid computer object");
    false
};

if !(VALIDATE_DEVICE_TYPE(_deviceType)) exitWith {
    LOG_ERROR_1("isDeviceAccessible: Invalid device type %1",_deviceType);
    false
};

// Check if this command is running from a backdoor path
private _backdoorPaths = _computer getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", []];
if (_commandPath != "" && {_backdoorPaths isNotEqualTo []}) then {
    {
        if (_commandPath find _x == 0) exitWith { true };
    } forEach _backdoorPaths;
};

// Check if hacking tools are installed
if !(_computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) exitWith {
    LOG_DEBUG("isDeviceAccessible: Hacking tools not installed");
    false
};

// Check if this device is in the public list FIRST
private _publicDevices = GET_PUBLIC_DEVICES;
{
    _x params ["_pubDevType", "_pubDevId", ["_excludedNetIds", []]];

    if (_pubDevType == _deviceType && {_pubDevId == _deviceId}) exitWith {
        // If no exclusion list, fully public
        if (_excludedNetIds isEqualTo []) exitWith { true };

        // Check if computer is excluded
        private _computerNetId = netId _computer;
        !(_computerNetId in _excludedNetIds)
    };
} forEach _publicDevices;

// Check private device links using hashmap cache
private _computerNetId = netId _computer;
private _linkCache = GET_LINK_CACHE;

// Get this computer's device links from cache
private _allowedDevices = _linkCache getOrDefault [_computerNetId, []];
if (_allowedDevices isEqualTo []) exitWith {
    LOG_DEBUG_1("isDeviceAccessible: No device links for computer %1",_computerNetId);
    false
};

// Check if device is in allowed list
private _isAllowed = _allowedDevices findIf {
    _x params ["_type", "_id"];
    _type == _deviceType && {_id == _deviceId}
} != -1;

LOG_DEBUG_3("isDeviceAccessible: Computer %1, Device %2 = %3",_computerNetId,_deviceId,_isAllowed);

_isAllowed
