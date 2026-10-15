#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Drops every grant a device's identifier has handed out, on the server and on every
 *              client, so the device has to be opened with a code again.
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - DEVICE_TYPE_* constant
 * 1: _deviceId <NUMBER> - Device id
 *
 * Return Value:
 * None
 *
 * Example:
 * [DEVICE_TYPE_DOOR, 1004] call Root_fnc_revokeIdentifierAccess;
 *
 * Public: Yes
 */

params [["_deviceType", 0, [0]], ["_deviceId", 0, [0]]];

if (!isServer) exitWith {
	["root_cyberwarfare_revokeIdentifier", [_deviceType, _deviceId]] call CBA_fnc_serverEvent;
};

["root_cyberwarfare_identifierRevoked", [_deviceType, _deviceId]] call CBA_fnc_globalEvent;
