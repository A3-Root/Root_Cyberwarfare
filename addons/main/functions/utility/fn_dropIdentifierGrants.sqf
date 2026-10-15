#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Drops this machine's grants for one device. A terminal files a grant under the device
 *              alone and the server files it under the laptop as well, so both shapes of key are
 *              matched here and the one function serves every machine the revoke reaches.
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - DEVICE_TYPE_* constant
 * 1: _deviceId <NUMBER> - Device id
 *
 * Return Value:
 * None
 *
 * Example:
 * [DEVICE_TYPE_DOOR, 1004] call Root_fnc_dropIdentifierGrants;
 *
 * Public: No
 */

params [["_deviceType", 0, [0]], ["_deviceId", 0, [0]]];

private _grants = missionNamespace getVariable [GVAR_IDENTIFIER_GRANTS, createHashMap];
private _plain = format ["%1:%2", _deviceType, _deviceId];
private _suffix = ":" + _plain;

{
	if (_x isEqualTo _plain || {(_x select [(count _x) - (count _suffix)]) isEqualTo _suffix}) then {
		_grants deleteAt _x;
	};
} forEach (keys _grants);

missionNamespace setVariable [GVAR_IDENTIFIER_GRANTS, _grants];
