#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Power Grid" app. Lists accessible power grids
 * and shows the selected grid's coverage area as a radius circle on a live map diagram, coloured by
 * state (green = on, grey = off, red = destroyed). The operator can turn the grid on/off or overload
 * it (two-click confirm, destructive). Grid radius is taken from the device registry (always set in
 * Zeus / Eden), so the diagram is always available.
 *
 * Arguments (AE3 app entry contract): 0:_winId 1:_ctrlGroup 2:_computer 3:_args
 * Return Value: App callbacks <HASHMAP>
 * Public: No
 */

params ["_winId", "_ctrlGroup", "_computer", "_args"];

private _session = uiNamespace getVariable ["AE3_desktop_session", createHashMap];
private _display = _session getOrDefault ["display", displayNull];
private _theme = _session getOrDefault ["theme", createHashMap];
(ctrlPosition _ctrlGroup) params ["", "", "_w", "_h"];

private _listW = _w * 0.42;

private _listCtrl = _display ctrlCreate ["RscListBox", -1, _ctrlGroup];
_listCtrl ctrlSetPosition [0.01, 0.045, _listW - 0.015, _h - 0.10];
_listCtrl ctrlCommit 0;

private _mapCtrl = _display ctrlCreate ["RscMapControl", -1, _ctrlGroup];
_mapCtrl ctrlSetPosition [_listW, 0.045, _w - _listW - 0.01, _h - 0.10];
_mapCtrl ctrlEnable true;
_mapCtrl ctrlCommit 0;

// Coverage circle + centre dot markers (local, removed on close).
private _circleName = format ["ROOT_pgrid_circle_%1", _winId];
private _dotName = format ["ROOT_pgrid_dot_%1", _winId];
createMarkerLocal [_circleName, [0, 0, 0]];
_circleName setMarkerShapeLocal "ELLIPSE";
_circleName setMarkerBrushLocal "FDiagonal";
_circleName setMarkerColorLocal "ColorGrey";
_circleName setMarkerAlphaLocal 0.5;
createMarkerLocal [_dotName, [0, 0, 0]];
_dotName setMarkerTypeLocal "loc_Power";

_listCtrl setVariable ["AE3_mapCtrl", _mapCtrl];
_listCtrl setVariable ["AE3_circle", _circleName];
_listCtrl setVariable ["AE3_dot", _dotName];

// Draw the selected grid's coverage circle and centre the map on it.
private _drawSel = {
	params ["_listCtrl"];
	private _grids = _listCtrl getVariable ["AE3_grids", []];
	private _sel = lbCurSel _listCtrl;
	if (_sel < 0 || {_sel >= count _grids}) exitWith {};

	(_grids select _sel) params ["", "_netId", "", ["_radius", 100]];
	private _grid = objectFromNetId _netId;
	if (isNull _grid) exitWith {};

	private _pos = getPosWorld _grid;
	private _state = toUpper (_grid getVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF"]);
	private _col = switch (_state) do { case "ON": {"ColorGreen"}; case "DESTROYED": {"ColorRed"}; default {"ColorGrey"} };

	private _circle = _listCtrl getVariable "AE3_circle";
	private _dot = _listCtrl getVariable "AE3_dot";
	_circle setMarkerPosLocal _pos;
	_circle setMarkerSizeLocal [_radius, _radius];
	_circle setMarkerColorLocal _col;
	_dot setMarkerPosLocal _pos;

	private _map = _listCtrl getVariable "AE3_mapCtrl";
	_map ctrlMapAnimAdd [0.3, (0.05 max (_radius / 3000) min 1), _pos];
	ctrlMapAnimCommit _map;
};
_listCtrl setVariable ["AE3_drawSel", _drawSel];

private _populate = {
	params ["_listCtrl", "_list"];
	lbClear _listCtrl;
	_listCtrl setVariable ["AE3_grids", _list];
	{
		_x params ["_id", "_netId", ["_name", ""]];
		private _grid = objectFromNetId _netId;
		private _state = if (isNull _grid) then { "?" } else { _grid getVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF"] };
		private _i = _listCtrl lbAdd format [localize "STR_ROOT_CYBERWARFARE_GUI_GRID_ENTRY", _name, _id, _state];
		_listCtrl lbSetData [_i, str _id];
		_listCtrl lbSetColor [_i, switch (toUpper _state) do { case "ON": {[0.3, 0.8, 0.3, 1]}; case "DESTROYED": {[0.8, 0.2, 0.2, 1]}; default {[0.7, 0.7, 0.72, 1]} }];
	} forEach _list;
	// Redraw the coverage circle for the (still) selected grid after a refresh.
	[_listCtrl] call (_listCtrl getVariable ["AE3_drawSel", {}]);
};

_listCtrl ctrlAddEventHandler ["LBSelChanged", {
	[_this select 0] call ((_this select 0) getVariable ["AE3_drawSel", {}]);
}];

uiNamespace setVariable [format ["ROOT_gui_open_%1", DEVICE_TYPE_POWERGRID], [_listCtrl, _populate]];
[_computer, DEVICE_TYPE_POWERGRID] call Root_fnc_gui_requestDevices;

/* ---------------------------------------- buttons ---------------------------------------- */

private _send = {
	params ["_ctrl", "_action"];
	(_ctrl getVariable "AE3_ctx") params ["_computer", "_listCtrl"];
	private _sel = lbCurSel _listCtrl;
	if (_sel < 0) exitWith {};
	["root_cyberwarfare_gui_powergridAction", [clientOwner, netId _computer, parseNumber (_listCtrl lbData _sel), _action, ""]] call CBA_fnc_serverEvent;
};

private _refreshBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_refreshBtn ctrlSetPosition [0.01, _h - 0.05, 0.10, 0.04];
_refreshBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_REFRESH");
_refreshBtn ctrlSetBackgroundColor (_theme getOrDefault ["titlebar", [0.18, 0.2, 0.24, 1]]);
_refreshBtn ctrlSetTextColor (_theme getOrDefault ["text", [1, 1, 1, 1]]);
_refreshBtn ctrlCommit 0;
_refreshBtn setVariable ["AE3_computer", _computer];
_refreshBtn ctrlAddEventHandler ["ButtonClick", {
	[_this select 0 getVariable "AE3_computer", DEVICE_TYPE_POWERGRID] call Root_fnc_gui_requestDevices;
}];

private _onBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_onBtn ctrlSetPosition [_listW, _h - 0.05, (_w - _listW) / 3 - 0.006, 0.04];
_onBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_TURN_ON");
_onBtn ctrlSetBackgroundColor [0.16, 0.5, 0.2, 1];
_onBtn ctrlSetTextColor [1, 1, 1, 1];
_onBtn ctrlCommit 0;
_onBtn setVariable ["AE3_ctx", [_computer, _listCtrl]];
_onBtn ctrlAddEventHandler ["ButtonClick", { [_this select 0, "on"] call ((_this select 0) getVariable "AE3_send"); }];
_onBtn setVariable ["AE3_send", _send];

private _offBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_offBtn ctrlSetPosition [_listW + (_w - _listW) / 3, _h - 0.05, (_w - _listW) / 3 - 0.006, 0.04];
_offBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_TURN_OFF");
_offBtn ctrlSetBackgroundColor [0.4, 0.4, 0.16, 1];
_offBtn ctrlSetTextColor [1, 1, 1, 1];
_offBtn ctrlCommit 0;
_offBtn setVariable ["AE3_ctx", [_computer, _listCtrl]];
_offBtn setVariable ["AE3_send", _send];
_offBtn ctrlAddEventHandler ["ButtonClick", { [_this select 0, "off"] call ((_this select 0) getVariable "AE3_send"); }];

private _overloadBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_overloadBtn ctrlSetPosition [_listW + 2 * (_w - _listW) / 3, _h - 0.05, (_w - _listW) / 3 - 0.006, 0.04];
_overloadBtn ctrlSetText (localize "STR_ROOT_CYBERWARFARE_GUI_OVERLOAD");
_overloadBtn ctrlSetBackgroundColor [0.7, 0.16, 0.16, 1];
_overloadBtn ctrlSetTextColor [1, 1, 1, 1];
_overloadBtn ctrlCommit 0;
_overloadBtn setVariable ["AE3_ctx", [_computer, _listCtrl]];
_overloadBtn ctrlAddEventHandler ["ButtonClick", {
	(_this select 0 getVariable "AE3_ctx") params ["_computer", "_listCtrl"];
	private _sel = lbCurSel _listCtrl;
	if (_sel < 0) exitWith {};
	private _id = parseNumber (_listCtrl lbData _sel);
	if ((uiNamespace getVariable ["ROOT_gui_overloadArmed", -1]) isEqualTo _id) then
	{
		uiNamespace setVariable ["ROOT_gui_overloadArmed", -1];
		["root_cyberwarfare_gui_powergridAction", [clientOwner, netId _computer, _id, "overload", ""]] call CBA_fnc_serverEvent;
	}
	else
	{
		uiNamespace setVariable ["ROOT_gui_overloadArmed", _id];
		hintSilent (localize "STR_ROOT_CYBERWARFARE_GUI_OVERLOAD_CONFIRM");
		[{ uiNamespace setVariable ["ROOT_gui_overloadArmed", -1]; }, 3] call CBA_fnc_waitAndExecute;
	};
}];

createHashMapFromArray [["onClose", compile format [
	"deleteMarkerLocal 'ROOT_pgrid_circle_%1'; deleteMarkerLocal 'ROOT_pgrid_dot_%1'; uiNamespace setVariable ['ROOT_gui_open_%2', nil];",
	_winId, DEVICE_TYPE_POWERGRID
]]]
