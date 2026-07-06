#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Adds a single [deviceType, deviceId] private link to one or more computers in the
 *              shared link-cache hashmap. Fetches each computer's link list live by reference from
 *              the current cache and appends in place (deduplicated), so an entry is never rebuilt
 *              from a stale snapshot and concurrent/deferred device registrations cannot clobber each
 *              other's links. Runs as a single synchronous burst (no suspension) and broadcasts once.
 *
 * Arguments:
 * 0: _computerIds <ARRAY> - Persistent computer identifiers (netIds in Simple mode, player UIDs in Experimental)
 * 1: _deviceType <NUMBER> - Device type constant (DEVICE_TYPE_*)
 * 2: _deviceId <NUMBER> - Device id to link
 *
 * Return Value:
 * None
 *
 * Example:
 * [[netId _laptop], DEVICE_TYPE_GPS_TRACKER, _deviceId] call Root_fnc_addComputerDeviceLinks;
 *
 * Public: No
 */

params [
    ["_computerIds", [], [[]]],
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]]
];

if (_computerIds isEqualTo [] || {_deviceType == 0}) exitWith {};

// Mutate the live cache entries in place so no stale copy is ever written back over another
// registration's additions.
private _linkCache = GET_LINK_CACHE;
{
    private _existingLinks = _linkCache getOrDefault [_x, [], true];
    _existingLinks pushBackUnique [_deviceType, _deviceId];
    _linkCache set [_x, _existingLinks];
} forEach _computerIds;

missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache];
call Root_fnc_syncDeviceData;
