#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Removes the identifier of a device, so its code no longer resolves. Server only.
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - DEVICE_TYPE_* constant
 * 1: _deviceId <NUMBER> - Registered device id
 *
 * Return Value:
 * None
 *
 * Example:
 * [DEVICE_TYPE_DOOR, 1004] call Root_fnc_unregisterDeviceIdentifier;
 *
 * Public: No
 */

if (!isServer) exitWith {};

params [["_deviceType", 0, [0]], ["_deviceId", 0, [0]]];

private _index = GET_DEVICE_IDENTIFIER_INDEX;
private _key = format ["%1:%2", _deviceType, _deviceId];
private _current = _index getOrDefault [_key, ""];
if (_current isEqualTo "") exitWith {};

private _identifiers = GET_DEVICE_IDENTIFIERS;
_identifiers deleteAt _current;
_index deleteAt _key;
missionNamespace setVariable [GVAR_DEVICE_IDENTIFIERS, _identifiers];
missionNamespace setVariable [GVAR_DEVICE_IDENTIFIER_INDEX, _index];
