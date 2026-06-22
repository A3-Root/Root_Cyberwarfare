#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "GPS" app. Lists accessible GPS trackers; the
 * Track button opens a map window centred on the selected tracker (see Root_fnc_gui_appGpsMap).
 *
 * Arguments (AE3 app entry contract): 0:_winId 1:_ctrlGroup 2:_computer 3:_args
 * Return Value: App callbacks <HASHMAP>
 * Public: No
 */

params ["_winId", "_ctrlGroup", "_computer", "_args"];

private _populate = {
	params ["_listCtrl", "_list"];
	lbClear _listCtrl;
	{
		_x params ["_id", "_netId", ["_name", ""], "", "", "", "", "", ["_status", ["Untracked"]]];
		private _statusStr = if (_status isEqualType []) then { _status param [0, "Untracked"] } else { str _status };
		private _i = _listCtrl lbAdd format [localize "STR_ROOT_CYBERWARFARE_GUI_GPS_ENTRY", _name, _id, _statusStr];
		// Store the tracker object netId so the map window can follow it.
		_listCtrl lbSetData [_i, _netId];
		_listCtrl lbSetValue [_i, _id];
	} forEach _list;
};

private _track = {
	params ["_computer", "_listCtrl"];
	private _sel = lbCurSel _listCtrl;
	if (_sel < 0) exitWith {};
	private _netId = _listCtrl lbData _sel;
	if (_netId isEqualTo "") exitWith {};
	private _id = _listCtrl lbValue _sel;
	["root_cyberwarfare_gui_gpsAction", [clientOwner, netId _computer, _id, "track", ""]] call CBA_fnc_serverEvent;
	["RootCW_GpsMap", [_netId, _listCtrl lbText _sel]] call AE3_desktop_fnc_wm_createWindow;
};

private _buttons = [[localize "STR_ROOT_CYBERWARFARE_GUI_TRACK", [0.16, 0.4, 0.6, 1], _track]];

[_ctrlGroup, _computer, DEVICE_TYPE_GPS_TRACKER, _populate, _buttons] call Root_fnc_gui_buildListApp
