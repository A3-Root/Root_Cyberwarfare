#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop app entry for the RootCW "Vehicles" app. Lists accessible vehicles and
 * lets the operator lock/unlock or kill the engine of the selected one.
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
		private _veh = objectFromNetId _netId;
		private _storedName = _x param [2, ""];
		private _name = if (_storedName isEqualType "" && {_storedName isNotEqualTo ""}) then {
			_storedName
		} else {
			if (isNull _veh) then { "?" } else { getText (configOf _veh >> "displayName") }
		};
		private _i = _listCtrl lbAdd format [localize "STR_ROOT_CYBERWARFARE_GUI_VEHICLE_ENTRY", _id, _name];
		_listCtrl lbSetData [_i, str _id];
	} forEach _list;
};

private _mk = {
	params ["_act"];
	compile format ["params ['_computer', '_listCtrl']; private _sel = lbCurSel _listCtrl; if (_sel < 0) exitWith {}; ['root_cyberwarfare_gui_vehicleAction', [clientOwner, netId _computer, parseNumber (_listCtrl lbData _sel), '%1', '']] call CBA_fnc_serverEvent;", _act];
};

private _buttons = [
	[localize "STR_ROOT_CYBERWARFARE_GUI_LOCK", [0.55, 0.16, 0.16, 1], ["lock"] call _mk],
	[localize "STR_ROOT_CYBERWARFARE_GUI_UNLOCK", [0.16, 0.5, 0.2, 1], ["unlock"] call _mk],
	[localize "STR_ROOT_CYBERWARFARE_GUI_ENGINE_OFF", [0.4, 0.4, 0.16, 1], ["engineoff"] call _mk]
];

[_ctrlGroup, _computer, DEVICE_TYPE_VEHICLE, _populate, _buttons] call Root_fnc_gui_buildListApp
