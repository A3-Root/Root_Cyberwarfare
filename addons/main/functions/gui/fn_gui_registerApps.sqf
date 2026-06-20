#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Client-side setup for the RootCW desktop GUI. Registers the RootCW apps into the AE3
 * web desktop (CEF) as generic device-list apps and installs the client event handlers that
 * receive device lists / action results from the server and forward them to the browser. Falls
 * back to the legacy native registration if only the old native desktop is present. Call once per
 * client (postInit, hasInterface).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _hasWeb = !isNil "AE3_desktop_fnc_registerExtApp";
private _hasNative = !isNil "AE3_desktop_fnc_registerApp";

if (!_hasWeb && !_hasNative) exitWith
{
	ROOT_CYBERWARFARE_LOG_INFO("AE3 desktop not present - RootCW GUI apps not registered");
};

// Raw server list entries are [id, ...]; build {id, label} pairs for the browser. Global so the
// (later-running) device-list event handler can reuse it.
ROOT_CYBERWARFARE_GUI_DESCRIBE = {
	params ["_type", "_list"];
	private _items = [];
	{
		private _id = _x param [0, _forEachIndex];
		private _label = switch (_type) do {
			case DEVICE_TYPE_DOOR:      { format ["Building %1 (%2 doors)", _id, count (_x param [2, []])] };
			case DEVICE_TYPE_LIGHT:     { format ["Light %1", _id] };
			case DEVICE_TYPE_POWERGRID: { format ["Power grid %1", _id] };
			case DEVICE_TYPE_DATABASE:  { format ["Database %1", _id] };
			case DEVICE_TYPE_DRONE:     { format ["Drone %1", _id] };
			case DEVICE_TYPE_VEHICLE:   { format ["Vehicle %1", _id] };
			case DEVICE_TYPE_GPS_TRACKER: { format ["Tracker %1", _id] };
			default                     { format ["Device %1", _id] };
		};
		_items pushBack createHashMapFromArray [["id", _id], ["label", _label]];
	} forEach _list;
	_items
};

if (_hasWeb) then
{
	// Register each device type as a generic CEF device-list app. extra carries the device type
	// and the action buttons the generic app renders per device.
	private _act = { params ["_id", "_label"]; createHashMapFromArray [["id", _id], ["label", _label]] };

	{
		_x params ["_id", "_titleKey", "_glyph", "_icon", "_type", "_actions"];
		[
			_id, localize _titleKey, _glyph, "deviceList",
			createHashMapFromArray [["type", _type], ["actions", _actions], ["icon", _icon]]
		] call AE3_desktop_fnc_registerExtApp;
	} forEach [
		["RootCW_Doors",     "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS",     "&#128682;", "door",     DEVICE_TYPE_DOOR,      [["lock", "Lock"] call _act, ["unlock", "Unlock"] call _act]],
		["RootCW_Lights",    "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS",    "&#128161;", "light",    DEVICE_TYPE_LIGHT,     [["on", "On"] call _act, ["off", "Off"] call _act]],
		["RootCW_PowerGrid", "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID", "&#9889;",   "power",    DEVICE_TYPE_POWERGRID, [["overload", "Overload"] call _act]],
		["RootCW_Databases", "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES", "&#128451;", "database", DEVICE_TYPE_DATABASE,  [["access", "Access"] call _act]],
		["RootCW_Drones",    "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES",    "&#128760;", "drone",    DEVICE_TYPE_DRONE,     []],
		["RootCW_Vehicles",  "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES",  "&#128663;", "vehicle",  DEVICE_TYPE_VEHICLE,   []],
		["RootCW_Custom",    "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM",    "&#129513;", "device",   DEVICE_TYPE_CUSTOM,    []],
		["RootCW_Gps",       "STR_ROOT_CYBERWARFARE_GUI_APP_GPS",       "&#128205;", "gps",      DEVICE_TYPE_GPS_TRACKER, []]
	];

	// dev_request: browser asks for a device type -> reuse the MP-safe request path.
	["dev_request", {
		params ["_computer", "_user", "_data"];
		if (isNull _computer) exitWith {};
		[_computer, _data getOrDefault ["type", 0]] call Root_fnc_gui_requestDevices;
	}] call AE3_desktop_fnc_registerCmd;

	// dev_action: browser triggers an action on a device -> the matching server action event.
	["dev_action", {
		params ["_computer", "_user", "_data"];
		if (isNull _computer) exitWith {};
		private _type = _data getOrDefault ["type", 0];
		private _id = _data getOrDefault ["id", 0];
		private _action = _data getOrDefault ["action", ""];
		private _co = clientOwner;
		private _nid = netId _computer;
		switch (_type) do {
			case DEVICE_TYPE_DOOR:      { ["root_cyberwarfare_gui_doorAction",      [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_LIGHT:     { ["root_cyberwarfare_gui_lightAction",     [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_POWERGRID: { ["root_cyberwarfare_gui_powergridAction", [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_DATABASE:  { ["root_cyberwarfare_gui_databaseAction",  [_co, _nid, _id, netId player, ""]] call CBA_fnc_serverEvent; };
			default {};
		};
	}] call AE3_desktop_fnc_registerCmd;
}
else
{
	// Legacy native desktop fallback (no CEF): keep the classic windowed apps.
	["RootCW_Doors", localize "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS", "Root_fnc_gui_appDoors", [0.55, 0.5]] call AE3_desktop_fnc_registerApp;
	["RootCW_Lights", localize "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS", "Root_fnc_gui_appLights", [0.5, 0.55]] call AE3_desktop_fnc_registerApp;
	["RootCW_Drones", localize "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES", "Root_fnc_gui_appDrones", [0.55, 0.55]] call AE3_desktop_fnc_registerApp;
	["RootCW_PowerGrid", localize "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID", "Root_fnc_gui_appPowergrid", [0.55, 0.55]] call AE3_desktop_fnc_registerApp;
	["RootCW_Databases", localize "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES", "Root_fnc_gui_appDatabases", [0.5, 0.55]] call AE3_desktop_fnc_registerApp;
	["RootCW_Custom", localize "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM", "Root_fnc_gui_appCustom", [0.5, 0.55]] call AE3_desktop_fnc_registerApp;
	["RootCW_Vehicles", localize "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES", "Root_fnc_gui_appVehicles", [0.55, 0.55]] call AE3_desktop_fnc_registerApp;
	["RootCW_Gps", localize "STR_ROOT_CYBERWARFARE_GUI_APP_GPS", "Root_fnc_gui_appGps", [0.5, 0.55]] call AE3_desktop_fnc_registerApp;
	["RootCW_GpsMap", "GPS Map", "Root_fnc_gui_appGpsMap", [0.6, 0.7], false, false] call AE3_desktop_fnc_registerApp;
};

// Server reply: device list for an open app. Feed the native control (if any) AND the browser.
["root_cyberwarfare_gui_devList", {
	params ["_deviceType", "_list"];

	private _open = uiNamespace getVariable [format ["ROOT_gui_open_%1", _deviceType], []];
	if (_open isNotEqualTo []) then {
		_open params ["_listCtrl", "_populate"];
		if (!isNull _listCtrl) then { [_listCtrl, _list] call _populate; };
	};

	if (!isNil "AE3_desktop_fnc_jsSend") then {
		private _items = [_deviceType, _list] call ROOT_CYBERWARFARE_GUI_DESCRIBE;
		["dev_list", createHashMapFromArray [["type", _deviceType], ["items", _items]]] call AE3_desktop_fnc_jsSend;
	};
}] call CBA_fnc_addEventHandler;

// Server reply: result of an action. Notify the native hint AND the browser, then refresh.
["root_cyberwarfare_gui_actionResult", {
	params ["_deviceType", "_msg", "_ok"];

	if (!isNil "AE3_desktop_fnc_jsSend") then {
		["dev_result", createHashMapFromArray [["type", _deviceType], ["msg", _msg], ["ok", _ok]]] call AE3_desktop_fnc_jsSend;
	};

	private _open = uiNamespace getVariable [format ["ROOT_gui_open_%1", _deviceType], []];
	if (_open isEqualTo []) exitWith {};
	hintSilent parseText format ["<t color='%1'>%2</t>", [ROOT_CYBERWARFARE_COLOR_ERROR, ROOT_CYBERWARFARE_COLOR_SUCCESS] select _ok, _msg];
	private _listCtrl = _open select 0;
	if (isNull _listCtrl) exitWith {};
	private _computer = (uiNamespace getVariable ["AE3_desktop_session", createHashMap]) getOrDefault ["computer", objNull];
	if (!isNull _computer) then { [_computer, _deviceType] call Root_fnc_gui_requestDevices; };
}] call CBA_fnc_addEventHandler;
