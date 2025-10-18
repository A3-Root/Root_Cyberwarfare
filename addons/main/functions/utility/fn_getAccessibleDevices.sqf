#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Gets all accessible devices of a specific type for a computer
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop/computer object
 * 1: _deviceType <NUMBER> - Device type (1-7)
 * 2: _commandPath <STRING> (Optional) - Command path for backdoor checking, default: ""
 *
 * Return Value:
 * <ARRAY> - Array of accessible devices
 *
 * Example:
 * [_laptop, DEVICE_TYPE_DOOR] call Root_fnc_getAccessibleDevices;
 * [_laptop, DEVICE_TYPE_DOOR, "/backdoor/"] call Root_fnc_getAccessibleDevices;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_deviceType", 0, [0]],
    ["_commandPath", "", [""]]
];

if (isNull _computer) exitWith {
    LOG_ERROR("getAccessibleDevices: Invalid computer object");
    []
};

if !(VALIDATE_DEVICE_TYPE(_deviceType)) exitWith {
    LOG_ERROR_1("getAccessibleDevices: Invalid device type %1",_deviceType);
    []
};

// Get devices from legacy array (devices are stored here by Zeus registration functions)
private _allDevicesArray = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];

// Determine array index based on device type
// Array structure: [doors, lights, drones, databases, custom, gpsTrackers, vehicles, powerGrids]
private _arrayIndex = switch (_deviceType) do {
    case DEVICE_TYPE_DOOR: { 0 };
    case DEVICE_TYPE_LIGHT: { 1 };
    case DEVICE_TYPE_DRONE: { 2 };
    case DEVICE_TYPE_DATABASE: { 3 };
    case DEVICE_TYPE_CUSTOM: { 4 };
    case DEVICE_TYPE_GPS_TRACKER: { 5 };
    case DEVICE_TYPE_VEHICLE: { 6 };
    case DEVICE_TYPE_POWERGRID: { 7 };
    default { -1 };
};

if (_arrayIndex == -1) exitWith {
    LOG_ERROR_1("getAccessibleDevices: Failed to get array index for type %1",_deviceType);
    []
};

// Get all devices of this type
private _allDevices = _allDevicesArray select _arrayIndex;

// Filter to only accessible devices
private _accessibleDevices = _allDevices select {
    [_computer, _deviceType, _x select 0, _commandPath] call FUNC(isDeviceAccessible)
};

_accessibleDevices
