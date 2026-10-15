#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Takes back every access a device's identifier has handed out. A code that opens a
 *              device leaves the machine that typed it a grant for a while, so a curator changing a
 *              code is not enough on its own: whoever used the old one would keep working the device
 *              until their grant ran out. This drops those grants wherever they are held - on the
 *              server, which is where the desktop apps write them, and on every client, which is
 *              where a terminal command writes them - so the device has to be opened again.
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
