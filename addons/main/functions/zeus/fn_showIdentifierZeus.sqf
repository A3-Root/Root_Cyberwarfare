#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Opens the Device Identifier module's dialog once the server has answered with what the
 *              module is standing on. Dropped on open ground that is a list of every registered
 *              device, its grid and its code, and the entry picked on closing is copied to the
 *              clipboard, since a code is only useful once it is written into a mission's intel.
 *              Dropped on a device it is that device's code, a box for the code to replace it with -
 *              eight letters and digits, enforced as it is typed - and the question of whether the
 *              laptops that already used the old code should lose the device until they are let in
 *              again. Client only.
 *
 * Arguments:
 * 0: _kind <STRING> - "all", "device" or "none"
 * 1: _rows <ARRAY> - [deviceType, deviceId, label, grid, code, grantsAccess] per device
 *
 * Return Value:
 * None
 *
 * Example:
 * ["device", [[1, 1004, "Doors 1004 - Vault", "043112", "VAULTDR1", true]]] call Root_fnc_showIdentifierZeus;
 *
 * Public: No
 */

params [["_kind", "", [""]], ["_rows", [], [[]]]];

if (!hasInterface) exitWith {};

if (isNil "zen_dialog_fnc_create") exitWith {
	{
		systemChat format ["%1   %2   %3", _x select 2, _x select 3, _x select 4];
	} forEach _rows;
};

if (_kind isEqualTo "none") exitWith {
	[localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_PLACE_ON_DEVICE"] call zen_common_fnc_showMessage;
};

/* ---------------------------------------------------------------------------------------------- */

// Open ground: everything that answers to a code, in one list
if (_kind isEqualTo "all") exitWith {
	if (_rows isEqualTo []) exitWith {
		[localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NONE_REGISTERED"] call zen_common_fnc_showMessage;
	};

	private _values = _rows apply {_x select 4};
	private _names = _rows apply {
		_x params ["", "", "_label", "_grid", "_code"];

		private _gridText = [_grid, localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NO_GRID"] select (_grid isEqualTo "");
		private _codeText = [_code, localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NO_CODE"] select (_code isEqualTo "");

		[format ["%1   %2   %3", _label, _gridText, _codeText]]
	};

	[
		localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_LIST_TITLE",
		[
			["LIST", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_LIST_LABEL", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_LIST_DESC"], [_values, _names, 0, 12]]
		],
		{
			params ["_results"];

			_results params ["_code"];

			if (_code isEqualTo "") exitWith {};

			copyToClipboard _code;
			systemChat format [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_COPIED", _code];
		},
		{},
		[]
	] call zen_dialog_fnc_create;
};

/* ---------------------------------------------------------------------------------------------- */

// On a device: its code as it stands, and what to do about it. One object can be registered more
// than once - a building with doors and lights is two devices standing in the same place - so the
// list is what settles which of them this is about, and it carries the code of each.
private _values = [];
private _names = [];

{
	_x params ["", "", "_rowLabel", "", "_rowCode"];

	_values pushBack _forEachIndex;
	_names pushBack [format ["%1   %2", _rowLabel, [_rowCode, localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NO_CODE"] select (_rowCode isEqualTo "")]];
} forEach _rows;

(_rows select 0) params ["", "", "_label", "", "_code"];

private _current = [_code, localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NO_CODE"] select (_code isEqualTo "");
private _grants = ((_rows select 0) param [5, true]) isEqualTo true;

[
	format [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_DEVICE_TITLE", _label, _current],
	[
		// The codes are shown here, not offered for editing: rewriting one is the box below, so there
		// is no way to type this into something the device does not answer to
		["LIST", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_CURRENT", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_CURRENT_DESC"], [_values, _names, 0, 3 min (count _values)], true],
		["TOOLBOX:YESNO", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_REPLACE", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_REPLACE_DESC"], [false], true],
		// Eight letters and digits, cut to shape on every key press, so a code that cannot exist can
		// never be confirmed
		["EDIT", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NEW", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_NEW_DESC"], ["", {
			private _clean = (toUpperANSI _this) regexReplace ["[^A-Z0-9]", ""];

			_clean select [0, 8]
		}], true],
		["TOOLBOX:YESNO", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_GRANTS", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_GRANTS_DESC"], [_grants], true],
		["TOOLBOX:YESNO", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_REVOKE", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_REVOKE_DESC"], [false], true]
	],
	{
		params ["_results", "_arguments"];

		_results params ["_pick", "_replace", "_newCode", "_grantsAccess", "_revoke"];
		_arguments params ["_rows"];

		(_rows param [_pick, _rows select 0]) params ["_deviceType", "_deviceId", "", "", "_code"];

		// A replacement that is not eight characters long is no replacement at all, and saying so
		// beats quietly writing a code the mission maker did not mean
		if (_replace && {count _newCode != 8}) exitWith {
			[localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_BAD_CODE"] call zen_common_fnc_showMessage;
		};

		// Its own code is sent back when no new one was asked for: a blank code means "draw a random
		// one", which would change what the device answers to without anyone asking. The credential
		// flag is written either way, since it belongs to whichever code the device ends up with.
		[_deviceType, _deviceId, [_code, _newCode] select _replace, _grantsAccess, clientOwner] remoteExec ["Root_fnc_setDeviceIdentifier", 2];

		if (_revoke) then {
			[_deviceType, _deviceId] call Root_fnc_revokeIdentifierAccess;
		};
	},
	{},
	[_rows]
] call zen_dialog_fnc_create;
