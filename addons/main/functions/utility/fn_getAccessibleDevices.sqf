#include "../../script_component.hpp"
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

// Get device cache
private _deviceCache = GET_DEVICE_CACHE;

// Determine cache key based on device type
private _cacheKey = switch (_deviceType) do {
    case DEVICE_TYPE_DOOR: { CACHE_KEY_DOORS };
    case DEVICE_TYPE_LIGHT: { CACHE_KEY_LIGHTS };
    case DEVICE_TYPE_DRONE: { CACHE_KEY_DRONES };
    case DEVICE_TYPE_DATABASE: { CACHE_KEY_DATABASES };
    case DEVICE_TYPE_CUSTOM: { CACHE_KEY_CUSTOM };
    case DEVICE_TYPE_GPS_TRACKER: { CACHE_KEY_GPS_TRACKERS };
    case DEVICE_TYPE_VEHICLE: { CACHE_KEY_VEHICLES };
    default { "" };
};

if (_cacheKey == "") exitWith {
    LOG_ERROR_1("getAccessibleDevices: Failed to get cache key for type %1",_deviceType);
    []
};

// Get all devices of this type
private _allDevices = _deviceCache getOrDefault [_cacheKey, []];

// Filter to only accessible devices
private _accessibleDevices = _allDevices select {
    [_computer, _deviceType, _x select 0, _commandPath] call FUNC(isDeviceAccessible)
};

_accessibleDevices
