#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Caches device links for a computer in the link cache hashmap
 *              Uses persistent identifier (netId in Simple mode, player UID in Experimental mode)
 *
 * Arguments:
 * 0: _computerIdentifier <STRING> - Persistent identifier for the computer (netId or player UID)
 * 1: _deviceArray <ARRAY> - Array of [deviceType, deviceId] pairs
 *
 * Return Value:
 * None
 *
 * Example:
 * [netId _laptop, [[1, 1234], [2, 5678]]] call Root_fnc_cacheDeviceLinks;
 * [getPlayerUID _player, [[1, 1234], [2, 5678]]] call Root_fnc_cacheDeviceLinks;
 *
 * Public: No
 */

params [
    ["_computerIdentifier", "", [""]],
    ["_deviceArray", [], [[]]]
];

DEBUG_LOG_2("cacheDeviceLinks called - Identifier: %1, Device count: %2",_computerIdentifier,count _deviceArray);

if (_computerIdentifier == "") exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("cacheDeviceLinks: Invalid computer identifier");
    DEBUG_LOG("Invalid computer identifier - cannot cache");
};

// Get or create link cache
private _linkCache = GET_LINK_CACHE;

// Store the device links in cache
_linkCache set [_computerIdentifier, _deviceArray];

// Update global variable
missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];

DEBUG_LOG_2("Successfully cached device links for identifier %1: %2 devices",_computerIdentifier,count _deviceArray);
ROOT_CYBERWARFARE_LOG_DEBUG_2("Cached device links for computer %1: %2 devices",_computerIdentifier,count _deviceArray);
