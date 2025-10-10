#include "../../script_component.hpp"
/*
 * Author: Root
 * Description: Caches device links for a computer in the link cache hashmap
 *
 * Arguments:
 * 0: _computerNetId <STRING> - Network ID of the computer
 * 1: _deviceArray <ARRAY> - Array of [deviceType, deviceId] pairs
 *
 * Return Value:
 * None
 *
 * Example:
 * [netId _laptop, [[1, 1234], [2, 5678]]] call Root_fnc_cacheDeviceLinks;
 *
 * Public: No
 */

params [
    ["_computerNetId", "", [""]],
    ["_deviceArray", [], [[]]]
];

if (_computerNetId == "") exitWith {
    LOG_ERROR("cacheDeviceLinks: Invalid computer netId");
};

// Get or create link cache
private _linkCache = GET_LINK_CACHE;

// Store the device links in cache
_linkCache set [_computerNetId, _deviceArray];

// Update global variable
missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];

LOG_DEBUG_2("Cached device links for computer %1: %2 devices",_computerNetId,count _deviceArray);
