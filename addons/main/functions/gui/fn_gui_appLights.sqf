#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Lights" app. Lists accessible lights with their
 * current on/off state and lets the operator toggle the selected one. The device list is fetched
 * from the server via Root_fnc_gui_requestDevices (MP-safe).
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
_listCtrl ctrlSetPosition [0.01, 0.045, _w - 0.02, _h - 0.10];
_listCtrl ctrlCommit 0;

private _onBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_onBtn ctrlSetPosition [_w * 0.5, _h - 0.05, _w * 0.24 - 0.005, 0.04];
_onBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_TURN_ON");
_onBtn ctrlSetBackgroundColor [0.16, 0.5, 0.2, 1];
_onBtn ctrlSetTextColor [1, 1, 1, 1];
_onBtn ctrlCommit 0;

private _offBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_offBtn ctrlSetPosition [_w * 0.74, _h - 0.05, _w * 0.24 - 0.005, 0.04];
_offBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_TURN_OFF");
_offBtn ctrlSetBackgroundColor (_theme getOrDefault ["titlebar", [0.18, 0.2, 0.24, 1]]);
_offBtn ctrlSetTextColor (_theme getOrDefault ["text", [1, 1, 1, 1]]);
_offBtn ctrlCommit 0;

private _refreshBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_refreshBtn ctrlSetPosition [0.01, _h - 0.05, 0.12, 0.04];
_refreshBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_REFRESH");
_refreshBtn ctrlSetBackgroundColor (_theme getOrDefault ["titlebar", [0.18, 0.2, 0.24, 1]]);
_refreshBtn ctrlSetTextColor (_theme getOrDefault ["text", [1, 1, 1, 1]]);
_refreshBtn ctrlCommit 0;

private _populate = {
	params ["_listCtrl", "_list"];
	lbClear _listCtrl;
	{
		_x params ["_id", "_netId"];
		private _light = objectFromNetId _netId;
		private _on = !isNull _light && {(lightIsOn _light) isEqualTo "ON"};
		private _i = _listCtrl lbAdd format [localize "STR_ROOT_CYBERWARFARE_GUI_LIGHT_ENTRY", _id, localize (["STR_ROOT_CYBERWARFARE_GUI_STATE_OFF", "STR_ROOT_CYBERWARFARE_GUI_STATE_ON"] select _on)];
		_listCtrl lbSetData [_i, str _id];
		_listCtrl lbSetColor [_i, [[0.7, 0.7, 0.72, 1], [0.95, 0.85, 0.3, 1]] select _on];
	} forEach _list;
};

uiNamespace setVariable [format ["ROOT_gui_open_%1", DEVICE_TYPE_LIGHT], [_listCtrl, _populate, controlNull]];
[_computer, DEVICE_TYPE_LIGHT] call Root_fnc_gui_requestDevices;

private _doAction = {
	params ["_ctrl", "_state"];
	private _ctx = _ctrl getVariable "AE3_ctx";
	_ctx params ["_computer", "_listCtrl"];

	private _sel = lbCurSel _listCtrl;
	if (_sel < 0) exitWith {};
	private _lightId = parseNumber (_listCtrl lbData _sel);

	["root_cyberwarfare_gui_lightAction", [clientOwner, netId _computer, _lightId, _state, ""]] call CBA_fnc_serverEvent;
};

{
	_x setVariable ["AE3_ctx", [_computer, _listCtrl]];
} forEach [_onBtn, _offBtn];

_onBtn setVariable ["AE3_doAction", _doAction];
_onBtn ctrlAddEventHandler ["ButtonClick", { [_this select 0, "on"] call (_this select 0 getVariable "AE3_doAction"); }];
_offBtn setVariable ["AE3_doAction", _doAction];
_offBtn ctrlAddEventHandler ["ButtonClick", { [_this select 0, "off"] call (_this select 0 getVariable "AE3_doAction"); }];

_refreshBtn setVariable ["AE3_computer", _computer];
_refreshBtn ctrlAddEventHandler ["ButtonClick", {
	[_this select 0 getVariable "AE3_computer", DEVICE_TYPE_LIGHT] call Root_fnc_gui_requestDevices;
}];

createHashMapFromArray [["onClose", {
	uiNamespace setVariable [format ["ROOT_gui_open_%1", DEVICE_TYPE_LIGHT], nil];
}]]
