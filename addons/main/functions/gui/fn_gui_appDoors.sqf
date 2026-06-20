#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Doors" app. Lists the buildings the laptop can
 * access and lets the operator lock/unlock all doors of the selected building with a click. A
 * coloured indicator shows the last action (green = unlocked, red = locked). The device list is
 * fetched from the server via Root_fnc_gui_requestDevices (MP-safe).
 *
 * Arguments (AE3 app entry contract):
 * 0: _winId <NUMBER>
 * 1: _ctrlGroup <CONTROL>
 * 2: _computer <OBJECT>
 * 3: _args <ANY>
 *
 * Return Value:
 * App callbacks <HASHMAP>
 *
 * Public: No
 */

params ["_winId", "_ctrlGroup", "_computer", "_args"];

private _session = uiNamespace getVariable ["AE3_desktop_session", createHashMap];
private _display = _session getOrDefault ["display", displayNull];
private _theme = _session getOrDefault ["theme", createHashMap];
(ctrlPosition _ctrlGroup) params ["", "", "_w", "_h"];

private _listCtrl = _display ctrlCreate ["RscListBox", -1, _ctrlGroup];
_listCtrl ctrlSetPosition [0.01, 0.045, _w * 0.5 - 0.015, _h - 0.10];
_listCtrl ctrlCommit 0;

private _statusCtrl = _display ctrlCreate ["RscStructuredText", -1, _ctrlGroup];
_statusCtrl ctrlSetPosition [_w * 0.5, 0.045, _w * 0.5 - 0.01, 0.10];
_statusCtrl ctrlSetStructuredText (parseText (localize "STR_ROOT_CYBERWARFARE_GUI_DOORS_HINT"));
_statusCtrl ctrlCommit 0;

// Coloured door indicator (green = unlocked, red = locked).
private _doorPanel = _display ctrlCreate ["RscText", -1, _ctrlGroup];
_doorPanel ctrlSetPosition [_w * 0.5 + 0.06, 0.17, 0.14, 0.18];
_doorPanel ctrlSetBackgroundColor [0.3, 0.3, 0.33, 1];
_doorPanel ctrlSetTextColor [1, 1, 1, 1];
_doorPanel ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_DOOR");
_doorPanel ctrlCommit 0;

private _lockBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_lockBtn ctrlSetPosition [_w * 0.5, _h - 0.05, _w * 0.24 - 0.005, 0.04];
_lockBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_LOCK");
_lockBtn ctrlSetBackgroundColor [0.55, 0.16, 0.16, 1];
_lockBtn ctrlSetTextColor [1, 1, 1, 1];
_lockBtn ctrlCommit 0;

private _unlockBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_unlockBtn ctrlSetPosition [_w * 0.74, _h - 0.05, _w * 0.24 - 0.005, 0.04];
_unlockBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_UNLOCK");
_unlockBtn ctrlSetBackgroundColor [0.16, 0.5, 0.2, 1];
_unlockBtn ctrlSetTextColor [1, 1, 1, 1];
_unlockBtn ctrlCommit 0;

private _refreshBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_refreshBtn ctrlSetPosition [0.01, _h - 0.05, 0.12, 0.04];
_refreshBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_REFRESH");
_refreshBtn ctrlSetBackgroundColor (_theme getOrDefault ["titlebar", [0.18, 0.2, 0.24, 1]]);
_refreshBtn ctrlSetTextColor (_theme getOrDefault ["text", [1, 1, 1, 1]]);
_refreshBtn ctrlCommit 0;

// Populate code shared with the device-list reply handler.
private _populate = {
	params ["_listCtrl", "_list"];
	lbClear _listCtrl;
	{
		_x params ["_bId", "", "_doorIds"];
		private _i = _listCtrl lbAdd format [localize "STR_ROOT_CYBERWARFARE_GUI_BUILDING_ENTRY", _bId, count _doorIds];
		_listCtrl lbSetData [_i, str _bId];
	} forEach _list;
};

uiNamespace setVariable [format ["ROOT_gui_open_%1", DEVICE_TYPE_DOOR], [_listCtrl, _populate, _doorPanel]];
[_computer, DEVICE_TYPE_DOOR] call Root_fnc_gui_requestDevices;

private _doAction = {
	params ["_ctrl", "_state"];
	private _ctx = _ctrl getVariable "AE3_ctx";
	_ctx params ["_computer", "_listCtrl", "_doorPanel"];

	private _sel = lbCurSel _listCtrl;
	if (_sel < 0) exitWith {};
	private _buildingId = parseNumber (_listCtrl lbData _sel);

	// Optimistic indicator: green when unlocking, red when locking.
	_doorPanel ctrlSetBackgroundColor ([[0.16, 0.5, 0.2, 1], [0.7, 0.16, 0.16, 1]] select (_state isEqualTo "lock"));

	["root_cyberwarfare_gui_doorAction", [clientOwner, netId _computer, _buildingId, _state, ""]] call CBA_fnc_serverEvent;
};

{
	_x setVariable ["AE3_ctx", [_computer, _listCtrl, _doorPanel]];
} forEach [_lockBtn, _unlockBtn];

_lockBtn setVariable ["AE3_doAction", _doAction];
_lockBtn ctrlAddEventHandler ["ButtonClick", { [_this select 0, "lock"] call (_this select 0 getVariable "AE3_doAction"); }];
_unlockBtn setVariable ["AE3_doAction", _doAction];
_unlockBtn ctrlAddEventHandler ["ButtonClick", { [_this select 0, "unlock"] call (_this select 0 getVariable "AE3_doAction"); }];

_refreshBtn setVariable ["AE3_computer", _computer];
_refreshBtn ctrlAddEventHandler ["ButtonClick", {
	[_this select 0 getVariable "AE3_computer", DEVICE_TYPE_DOOR] call Root_fnc_gui_requestDevices;
}];

createHashMapFromArray [["onClose", {
	uiNamespace setVariable [format ["ROOT_gui_open_%1", DEVICE_TYPE_DOOR], nil];
}]]
