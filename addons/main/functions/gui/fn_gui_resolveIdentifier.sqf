#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Resolves an identifier typed into a desktop app to a device id. A code that grants
 *              access also writes a grant for the laptop that typed it. Server only.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator, for the error reply
 * 1: _computer <OBJECT> - The laptop the code was typed on
 * 2: _deviceType <NUMBER> - DEVICE_TYPE_* constant the app works on
 * 3: _identifier <STRING> - Code as typed
 *
 * Return Value:
 * <ARRAY> - [deviceId] when the code is known, [] when it is not (the operator has been told)
 *
 * Example:
 * private _resolved = [_owner, _computer, DEVICE_TYPE_DOOR, "VAULTDR1"] call Root_fnc_gui_resolveIdentifier;
 *
 * Public: No
 */

if (!isServer) exitWith {[]};

params [["_owner", 0, [0]], ["_computer", objNull, [objNull]], ["_deviceType", 0, [0]], ["_identifier", "", [""]]];

private _reply = {
	params ["_owner", "_deviceType", "_msg"];
	["root_cyberwarfare_gui_actionResult", [_deviceType, _msg, false], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer || _identifier isEqualTo "") exitWith {[]};

if !(missionNamespace getVariable [SETTING_DEVICE_IDENTIFIERS, true]) exitWith {
	[_owner, _deviceType, localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_DISABLED"] call _reply;
	[]
};

private _entry = [_identifier, _deviceType] call FUNC(resolveDeviceIdentifier);

if (_entry isEqualTo []) exitWith {
	[_owner, _deviceType, format [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_UNKNOWN", _identifier]] call _reply;
	[]
};

_entry params ["", "_deviceId", "_grantsAccess"];

if (_grantsAccess) then {
	private _grants = missionNamespace getVariable [GVAR_IDENTIFIER_GRANTS, createHashMap];

	_grants set [format ["%1:%2:%3", netId _computer, _deviceType, _deviceId], diag_tickTime + IDENTIFIER_GRANT_DURATION];
	missionNamespace setVariable [GVAR_IDENTIFIER_GRANTS, _grants];
};

[_deviceId]
