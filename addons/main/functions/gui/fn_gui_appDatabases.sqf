#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Databases" app. Lists accessible databases and
 * downloads the selected one to the laptop's /Files directory.
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
		_x params ["_id", "_netId"];
		private _db = objectFromNetId _netId;
		private _name = if (isNull _db) then { "" } else { _db getVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", ""] };
		private _label = if (_name isEqualTo "") then { format [localize "STR_ROOT_CYBERWARFARE_GUI_DATABASE_ENTRY", _id, _id] } else { format [localize "STR_ROOT_CYBERWARFARE_GUI_DATABASE_ENTRY", _name, _id] };
		private _i = _listCtrl lbAdd _label;
		_listCtrl lbSetData [_i, str _id];
	} forEach _list;
};

private _download = {
	params ["_computer", "_listCtrl"];
	private _sel = lbCurSel _listCtrl;
	if (_sel < 0) exitWith {};
	["root_cyberwarfare_gui_databaseAction", [clientOwner, netId _computer, parseNumber (_listCtrl lbData _sel), netId player, ""]] call CBA_fnc_serverEvent;
};

private _buttons = [[localize "STR_ROOT_CYBERWARFARE_GUI_DOWNLOAD", [0.16, 0.4, 0.6, 1], _download]];

[_ctrlGroup, _computer, DEVICE_TYPE_DATABASE, _populate, _buttons] call Root_fnc_gui_buildListApp
