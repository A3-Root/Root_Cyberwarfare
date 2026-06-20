#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Drones" app. Lists accessible drones with their
 * current side and lets the operator switch the selected drone's faction.
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
		private _drone = objectFromNetId _netId;
		private _sideStr = if (isNull _drone) then { "?" } else { str side _drone };
		private _i = _listCtrl lbAdd format [localize "STR_ROOT_CYBERWARFARE_GUI_DRONE_ENTRY", _id, _sideStr];
		_listCtrl lbSetData [_i, str _id];
	} forEach _list;
};

// One action button per faction; the faction literal is baked into each button's handler.
private _mk = {
	params ["_fac"];
	compile format ["params ['_computer', '_listCtrl']; private _sel = lbCurSel _listCtrl; if (_sel < 0) exitWith {}; ['root_cyberwarfare_gui_droneAction', [clientOwner, netId _computer, parseNumber (_listCtrl lbData _sel), '%1', '']] call CBA_fnc_serverEvent;", _fac];
};

private _buttons = [
	[localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_WEST", [0.10, 0.35, 0.62, 1], ["west"] call _mk],
	[localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_EAST", [0.62, 0.20, 0.20, 1], ["east"] call _mk],
	[localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_GUER", [0.25, 0.5, 0.16, 1], ["guer"] call _mk],
	[localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_CIV", [0.6, 0.5, 0.16, 1], ["civ"] call _mk]
];

[_ctrlGroup, _computer, DEVICE_TYPE_DRONE, _populate, _buttons] call Root_fnc_gui_buildListApp
