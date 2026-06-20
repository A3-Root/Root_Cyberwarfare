#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Shared builder for the RootCW list-style GUI apps (doors-like layout: a device list
 * plus a row of action buttons). Requests the device list from the server, registers the open-app
 * reference so the reply can populate it, and wires each action button. Action button code is called
 * as [_computer, _listCtrl] call _code (the code reads the selected row itself).
 *
 * Arguments:
 * 0: _ctrlGroup <CONTROL> - The window content group
 * 1: _computer <OBJECT> - The laptop
 * 2: _deviceType <NUMBER> - DEVICE_TYPE_* constant
 * 3: _populate <CODE> - [_listCtrl, _list] code that fills the list box
 * 4: _buttons <ARRAY> - Array of [label <STRING>, bgColor <ARRAY>, code <CODE>]
 *
 * Return Value:
 * App callbacks <HASHMAP>
 *
 * Public: No
 */

params ["_ctrlGroup", "_computer", "_deviceType", "_populate", "_buttons"];

private _session = uiNamespace getVariable ["AE3_desktop_session", createHashMap];
private _display = _session getOrDefault ["display", displayNull];
private _theme = _session getOrDefault ["theme", createHashMap];
(ctrlPosition _ctrlGroup) params ["", "", "_w", "_h"];

private _listCtrl = _display ctrlCreate ["RscListBox", -1, _ctrlGroup];
_listCtrl ctrlSetPosition [0.01, 0.045, _w - 0.02, _h - 0.10];
_listCtrl ctrlCommit 0;

private _refreshBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_refreshBtn ctrlSetPosition [0.01, _h - 0.05, 0.12, 0.04];
_refreshBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_REFRESH");
_refreshBtn ctrlSetBackgroundColor (_theme getOrDefault ["titlebar", [0.18, 0.2, 0.24, 1]]);
_refreshBtn ctrlSetTextColor (_theme getOrDefault ["text", [1, 1, 1, 1]]);
_refreshBtn ctrlCommit 0;
_refreshBtn setVariable ["AE3_ctx", [_computer, _deviceType]];
_refreshBtn ctrlAddEventHandler ["ButtonClick", {
	(_this select 0 getVariable "AE3_ctx") params ["_computer", "_deviceType"];
	[_computer, _deviceType] call Root_fnc_gui_requestDevices;
}];

private _n = count _buttons;
private _slot = (_w - 0.15) / (_n max 1);
{
	_x params ["_label", "_bg", "_code"];
	private _btn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
	_btn ctrlSetPosition [0.14 + _slot * _forEachIndex, _h - 0.05, _slot - 0.006, 0.04];
	_btn ctrlSetText _label;
	_btn ctrlSetBackgroundColor _bg;
	_btn ctrlSetTextColor [1, 1, 1, 1];
	_btn ctrlCommit 0;
	_btn setVariable ["AE3_ctx", [_computer, _listCtrl]];
	_btn setVariable ["AE3_code", _code];
	_btn ctrlAddEventHandler ["ButtonClick", {
		(_this select 0 getVariable "AE3_ctx") call (_this select 0 getVariable "AE3_code");
	}];
} forEach _buttons;

uiNamespace setVariable [format ["ROOT_gui_open_%1", _deviceType], [_listCtrl, _populate]];
[_computer, _deviceType] call Root_fnc_gui_requestDevices;

createHashMapFromArray [["onClose", compile format ["uiNamespace setVariable ['ROOT_gui_open_%1', nil];", _deviceType]]]
