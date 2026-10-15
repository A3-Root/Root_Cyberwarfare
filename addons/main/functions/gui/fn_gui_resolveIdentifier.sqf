#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Turns an identifier typed into one of the desktop apps into the device id that app
 *              works on, under the same rules the terminal commands follow: an unknown code, or one
 *              belonging to a device of another type, is refused, and a code that grants access hands
 *              the laptop that typed it a short-lived grant so the device it names is reachable from
 *              that laptop alone. The grant is what makes the rest of an app's work unchanged - the
 *              device simply turns up in Root_fnc_getAccessibleDevices from then on. Server only; the
 *              identifier table is never broadcast.
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

// A code that is only a name for a device the laptop already reaches grants nothing; one that is the
// way in writes the grant the access check reads back.
if (_grantsAccess) then {
	private _grants = missionNamespace getVariable [GVAR_IDENTIFIER_GRANTS, createHashMap];

	_grants set [format ["%1:%2:%3", netId _computer, _deviceType, _deviceId], diag_tickTime + IDENTIFIER_GRANT_DURATION];
	missionNamespace setVariable [GVAR_IDENTIFIER_GRANTS, _grants];
};

[_deviceId]
