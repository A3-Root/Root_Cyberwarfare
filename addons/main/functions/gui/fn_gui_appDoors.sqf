#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Doors" app. Lists the buildings the laptop can
 * access and applies Open, Close, Lock, Unlock, Lock Open or Lock Closed to all doors of the selected
 * building. A status line shows open/closed and locked/unlocked counts of the selected building. The
 * device list is fetched from the server via Root_fnc_gui_requestDevices.
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

// Open/closed and locked/unlocked counts of the selected building, refreshed twice a second.
private _doorPanel = _display ctrlCreate ["RscStructuredText", -1, _ctrlGroup];
_doorPanel ctrlSetPosition [_w * 0.5, 0.17, _w * 0.5 - 0.01, 0.10];
_doorPanel ctrlCommit 0;

// Action buttons, two rows of three: [state, label, colour]
private _btnW = (_w * 0.5 - 0.01) / 3;
private _buttons = [];
{
	_x params ["_state", "_label", "_color"];
	private _btn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
	_btn ctrlSetPosition [_w * 0.5 + (_forEachIndex % 3) * _btnW, _h - 0.10 + (floor (_forEachIndex / 3)) * 0.05, _btnW - 0.005, 0.04];
	_btn ctrlSetText (localize _label);
	_btn ctrlSetBackgroundColor _color;
	_btn ctrlSetTextColor [1, 1, 1, 1];
	_btn ctrlCommit 0;
	_btn setVariable ["AE3_state", _state];
	_buttons pushBack _btn;
} forEach [
	["open", "STR_ROOT_CYBERWARFARE_GUI_OPEN", [0.16, 0.5, 0.2, 1]],
	["close", "STR_ROOT_CYBERWARFARE_GUI_CLOSE", [0.3, 0.3, 0.33, 1]],
	["unlock", "STR_ROOT_CYBERWARFARE_GUI_UNLOCK", [0.16, 0.5, 0.2, 1]],
	["lock", "STR_ROOT_CYBERWARFARE_GUI_LOCK", [0.55, 0.16, 0.16, 1]],
	["lockopen", "STR_ROOT_CYBERWARFARE_GUI_LOCKOPEN", [0.55, 0.16, 0.16, 1]],
	["lockclosed", "STR_ROOT_CYBERWARFARE_GUI_LOCKCLOSED", [0.55, 0.16, 0.16, 1]]
];

private _refreshBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_refreshBtn ctrlSetPosition [0.01, _h - 0.05, 0.12, 0.04];
_refreshBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_REFRESH");
_refreshBtn ctrlSetBackgroundColor (_theme getOrDefault ["titlebar", [0.18, 0.2, 0.24, 1]]);
_refreshBtn ctrlSetTextColor (_theme getOrDefault ["text", [1, 1, 1, 1]]);
_refreshBtn ctrlCommit 0;

// Populate code shared with the device-list reply handler.
private _populate = {
	params ["_listCtrl", "_list"];
	private _prev = if (lbCurSel _listCtrl < 0) then {""} else {_listCtrl lbData (lbCurSel _listCtrl)};
	lbClear _listCtrl;
	{
		_x params ["_bId", "", "_doorIds"];
		private _i = _listCtrl lbAdd format [localize "STR_ROOT_CYBERWARFARE_GUI_BUILDING_ENTRY", _bId, count _doorIds];
		_listCtrl lbSetData [_i, str _bId];
		if (str _bId isEqualTo _prev) then { _listCtrl lbSetCurSel _i; };
	} forEach _list;
};

uiNamespace setVariable [format ["ROOT_gui_open_%1", DEVICE_TYPE_DOOR], [_listCtrl, _populate, _doorPanel]];
[_computer, DEVICE_TYPE_DOOR] call Root_fnc_gui_requestDevices;

private _doAction = {
	params ["_ctrl"];
	private _ctx = _ctrl getVariable "AE3_ctx";
	_ctx params ["_computer", "_listCtrl"];

	// A code in the identifier box names the device instead of the list selection
	private _code = [DEVICE_TYPE_DOOR] call Root_fnc_gui_identifierText;
	private _sel = lbCurSel _listCtrl;
	if (_sel < 0 && _code isEqualTo "") exitWith {};
	private _buildingId = if (_code isEqualTo "") then {parseNumber (_listCtrl lbData _sel)} else {0};

	["root_cyberwarfare_gui_doorAction", [clientOwner, netId _computer, _buildingId, _ctrl getVariable "AE3_state", "", "", _code]] call CBA_fnc_serverEvent;
};

{
	_x setVariable ["AE3_ctx", [_computer, _listCtrl]];
	_x setVariable ["AE3_doAction", _doAction];
	_x ctrlAddEventHandler ["ButtonClick", { [_this select 0] call (_this select 0 getVariable "AE3_doAction"); }];
} forEach _buttons;

[{
	params ["_args", "_pfhId"];
	_args params ["_listCtrl", "_doorPanel"];
	if (isNull _listCtrl || {isNull _doorPanel}) exitWith { [_pfhId] call CBA_fnc_removePerFrameHandler; };
	private _sel = lbCurSel _listCtrl;
	if (_sel < 0) exitWith { _doorPanel ctrlSetStructuredText parseText ""; };
	private _bId = parseNumber (_listCtrl lbData _sel);
	private _rows = _listCtrl getVariable ["ROOT_gui_rows", []];
	private _idx = _rows findIf { (_x select 0) == _bId };
	if (_idx < 0) exitWith { _doorPanel ctrlSetStructuredText parseText ""; };
	(_rows select _idx) params ["", "_bNetId", "_doorIds"];
	private _building = objectFromNetId _bNetId;
	if (isNull _building) exitWith { _doorPanel ctrlSetStructuredText parseText ""; };
	private _states = _doorIds apply { [_building, _x] call Root_fnc_getDoorState };
	private _open = { _x select 0 } count _states;
	private _locked = { _x select 1 } count _states;
	_doorPanel ctrlSetStructuredText parseText format [localize "STR_ROOT_CYBERWARFARE_DOOR_STATUS", _open, count _states - _open, _locked, count _states - _locked];
}, 0.5, [_listCtrl, _doorPanel]] call CBA_fnc_addPerFrameHandler;

_refreshBtn setVariable ["AE3_computer", _computer];
_refreshBtn ctrlAddEventHandler ["ButtonClick", {
	[_this select 0 getVariable "AE3_computer", DEVICE_TYPE_DOOR] call Root_fnc_gui_requestDevices;
}];

createHashMapFromArray [["onClose", {
	uiNamespace setVariable [format ["ROOT_gui_open_%1", DEVICE_TYPE_DOOR], nil];
}]]
