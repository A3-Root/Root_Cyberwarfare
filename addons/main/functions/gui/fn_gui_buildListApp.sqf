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
_listCtrl ctrlSetPosition [0.01, 0.09, _w - 0.02, _h - 0.145];
_listCtrl ctrlCommit 0;

private _gridEdit = _display ctrlCreate ["RscEdit", -1, _ctrlGroup];
_gridEdit ctrlSetPosition [0.01, 0.01, _w * 0.28, 0.03];
_gridEdit ctrlSetText "Grid";
_gridEdit ctrlCommit 0;

private _distanceEdit = _display ctrlCreate ["RscEdit", -1, _ctrlGroup];
_distanceEdit ctrlSetPosition [_w * 0.30, 0.01, _w * 0.18, 0.03];
_distanceEdit ctrlSetText "Distance m";
_distanceEdit ctrlCommit 0;

private _filterBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_filterBtn ctrlSetPosition [_w * 0.50, 0.01, _w * 0.12, 0.03];
_filterBtn ctrlSetText "Filters";
_filterBtn ctrlCommit 0;

private _pinBtn = _display ctrlCreate ["RscButton", -1, _ctrlGroup];
_pinBtn ctrlSetPosition [_w * 0.63, 0.01, _w * 0.14, 0.03];
_pinBtn ctrlSetText "Pin Selected";
_pinBtn ctrlCommit 0;

private _applyFilter = {
    params ["_listCtrl", "_populate", "_computer", "_gridEdit", "_distanceEdit"];
    private _rows = _listCtrl getVariable ["ROOT_gui_rows", []];
    private _pins = uiNamespace getVariable ["ROOT_gui_pins", []];
    private _grid = toLower (ctrlText _gridEdit);
    if (_grid isEqualTo "grid") then {_grid = "";};
    private _distance = parseNumber (ctrlText _distanceEdit);
    private _filtered = [];
    {
        private _obj = objectFromNetId (_x param [1, ""]);
        private _matchesGrid = true;
        private _matchesDistance = true;
        if (_grid isNotEqualTo "") then {
            _matchesGrid = !isNull _obj && {(toLower (mapGridPosition _obj)) find _grid == 0};
        };
        if (_distance > 0) then {
            _matchesDistance = !isNull _obj && {_obj distance _computer <= _distance};
        };
        if (_matchesGrid && _matchesDistance) then {_filtered pushBack _x;};
    } forEach _rows;
    private _pinned = _filtered select {(str (_x param [0, ""])) in _pins};
    private _others = _filtered select {!((str (_x param [0, ""])) in _pins)};
    [_listCtrl, _pinned + _others] call _populate;
};

_filterBtn setVariable ["ROOT_gui_filter", [_listCtrl, _populate, _computer, _gridEdit, _distanceEdit, _applyFilter]];
_filterBtn ctrlAddEventHandler ["ButtonClick", {
    (_this select 0 getVariable "ROOT_gui_filter") params ["_listCtrl", "_populate", "_computer", "_gridEdit", "_distanceEdit", "_applyFilter"];
    [_listCtrl, _populate, _computer, _gridEdit, _distanceEdit] call _applyFilter;
}];

_pinBtn setVariable ["ROOT_gui_pin", [_listCtrl, _populate, _computer, _gridEdit, _distanceEdit, _applyFilter]];
_pinBtn ctrlAddEventHandler ["ButtonClick", {
    (_this select 0 getVariable "ROOT_gui_pin") params ["_listCtrl", "_populate", "_computer", "_gridEdit", "_distanceEdit", "_applyFilter"];
    private _selected = lbCurSel _listCtrl;
    if (_selected < 0) exitWith {};
    private _id = _listCtrl lbData _selected;
    private _pins = uiNamespace getVariable ["ROOT_gui_pins", []];
    if (_id in _pins) then {_pins = _pins - [_id];} else {_pins pushBack _id;};
    uiNamespace setVariable ["ROOT_gui_pins", _pins];
    [_listCtrl, _populate, _computer, _gridEdit, _distanceEdit] call _applyFilter;
}];

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
