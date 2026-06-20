#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Custom Devices" app. Lists accessible custom
 * devices and lets the operator activate/deactivate the selected one.
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
		_x params ["_id", "", ["_name", ""]];
		private _label = if (_name isEqualTo "") then { format [localize "STR_ROOT_CYBERWARFARE_GUI_CUSTOM_ENTRY", _id, _id] } else { format [localize "STR_ROOT_CYBERWARFARE_GUI_CUSTOM_ENTRY", _name, _id] };
		private _i = _listCtrl lbAdd _label;
		_listCtrl lbSetData [_i, str _id];
	} forEach _list;
};

// Custom device code runs server-side with the operating player object, so we send netId player.
private _mk = {
	params ["_state"];
	compile format ["params ['_computer', '_listCtrl']; private _sel = lbCurSel _listCtrl; if (_sel < 0) exitWith {}; ['root_cyberwarfare_gui_customAction', [clientOwner, netId _computer, parseNumber (_listCtrl lbData _sel), '%1', netId player, '']] call CBA_fnc_serverEvent;", _state];
};

private _buttons = [
	[localize "STR_ROOT_CYBERWARFARE_GUI_ACTIVATE", [0.16, 0.5, 0.2, 1], ["activate"] call _mk],
	[localize "STR_ROOT_CYBERWARFARE_GUI_DEACTIVATE", [0.55, 0.16, 0.16, 1], ["deactivate"] call _mk]
];

[_ctrlGroup, _computer, DEVICE_TYPE_CUSTOM, _populate, _buttons] call Root_fnc_gui_buildListApp
