#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Whether a device is reachable from one computer on its own: a private link filed under
 *              any identifier that computer answers to, or a public entry it is not excluded from.
 *              Unlike Root_fnc_isDeviceAccessible this asks about one machine only and ignores hacking
 *              tools, backdoor paths, identifier grants and sessions - it answers "whose device is
 *              this", which is what decides who pays for operating it.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The computer
 * 1: _deviceType <NUMBER> - Device type (1-8)
 * 2: _deviceId <NUMBER> - Device ID
 *
 * Return Value:
 * <BOOLEAN> - True when that computer owns a route to the device
 *
 * Example:
 * [_laptop, DEVICE_TYPE_DOOR, 1234] call Root_fnc_hasDeviceLink;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]]
];

if (isNull _computer) exitWith { false };
if !(VALIDATE_DEVICE_TYPE(_deviceType)) exitWith { false };

private _identifiers = [_computer] call FUNC(getComputerIdentifiers);

if (_identifiers isEqualTo []) exitWith { false };

// Public entries first, matching the order isDeviceAccessible uses
private _isPublic = false;

{
    _x params ["_pubDevType", "_pubDevId", ["_excludedIdentifiers", []]];

    if (_pubDevType == _deviceType && _pubDevId == _deviceId) exitWith {
        _isPublic = (_excludedIdentifiers isEqualTo []) || {(_identifiers findIf {_x in _excludedIdentifiers}) == -1};
    };
} forEach GET_PUBLIC_DEVICES;

if (_isPublic) exitWith { true };

private _linkCache = GET_LINK_CACHE;
private _allowedDevices = [];

{
    _allowedDevices append (_linkCache getOrDefault [_x, []]);
} forEach _identifiers;

(_allowedDevices findIf {
    _x params ["_type", "_id"];
    _type == _deviceType && _id == _deviceId
}) != -1
