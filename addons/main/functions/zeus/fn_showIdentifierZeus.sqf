#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Opens the Device Identifier module's dialog on the server's answer: a list of every
 *              registered device with its grid and code, copied to the clipboard on confirm, or one
 *              device's code with a replacement box and a revoke option. Client only.
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

// Open ground: everything that answers to a code
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

// One object can hold several registrations - doors and lights in the same building - so the list
// is also the picker
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
		// Read-only: replacing a code is the box below
		["LIST", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_CURRENT", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_CURRENT_DESC"], [_values, _names, 0, 3 min (count _values)], true],
		["TOOLBOX:YESNO", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_REPLACE", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_REPLACE_DESC"], [false], true],
		// Cut to eight upper-case letters and digits on every key press
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

		if (_replace && {count _newCode != 8}) exitWith {
			[localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_BAD_CODE"] call zen_common_fnc_showMessage;
		};

		// Its own code goes back when no new one was asked for; a blank code would draw a random one
		[_deviceType, _deviceId, [_code, _newCode] select _replace, _grantsAccess, clientOwner] remoteExec ["Root_fnc_setDeviceIdentifier", 2];

		if (_revoke) then {
			[_deviceType, _deviceId] call Root_fnc_revokeIdentifierAccess;
		};
	},
	{},
	[_rows]
] call zen_dialog_fnc_create;
