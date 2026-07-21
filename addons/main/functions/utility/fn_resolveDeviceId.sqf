#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Resolves the final numeric ID for a device being registered.
 * If a caller-requested ID is a valid 4-digit value (1000-9999) and is not
 * already used by another device of the same type, that ID is honoured.
 * Otherwise a fresh random 4-digit ID that is free within the supplied list
 * is generated and returned.
 *
 * Arguments:
 * 0: _requestedId <NUMBER> - Desired ID, 0 (or out of range) means auto-assign
 * 1: _existingIds <ARRAY> - IDs already in use for this device type
 *
 * Return Value:
 * _deviceId <NUMBER> - A 4-digit ID guaranteed free within _existingIds
 *
 * Example:
 * [5000, _usedIds] call Root_fnc_resolveDeviceId;
 *
 * Public: No
 */

params [
    ["_requestedId", 0, [0]],
    ["_existingIds", [], [[]]]
];

// Honour a valid, unused caller-requested ID
if (_requestedId >= 1000 && _requestedId <= 9999 && {!(_requestedId in _existingIds)}) exitWith {
    _requestedId
};

// Auto-assign: keep drawing until a free ID is found
private _deviceId = (round (random 8999)) + 1000;
if (_existingIds isNotEqualTo []) then {
    while {_deviceId in _existingIds} do {
        _deviceId = (round (random 8999)) + 1000;
    };
};

_deviceId
