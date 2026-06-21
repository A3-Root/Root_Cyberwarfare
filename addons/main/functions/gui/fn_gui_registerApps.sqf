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
		private _obj = objectFromNetId (_x param [1, ""]);
		private _label = "";
		private _status = ""; // current device state shown next to the label in the GUI (#2/#3/#4...)
		switch (_type) do {
			case DEVICE_TYPE_DOOR: {
				private _doorIds = _x param [2, []];
				_label = format ["Building %1 (%2 doors)", _id, count _doorIds];
				if (!isNull _obj) then {
					private _locked = {(_obj getVariable [format ["bis_disabled_Door_%1", _x], 0]) == 1} count _doorIds;
					_status = format ["%1/%2 locked", _locked, count _doorIds];
				};
			};
			case DEVICE_TYPE_LIGHT:     { _label = format ["Light %1", _id]; };
			case DEVICE_TYPE_POWERGRID: {
				_label = format ["Power grid %1", _id];
				if (!isNull _obj) then { _status = _obj getVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF"]; };
			};
			case DEVICE_TYPE_DATABASE:  {
				// Label by the database's filename rather than its numeric id (#5).
				private _fn = "";
				if (!isNull _obj) then { _fn = _obj getVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", ""]; };
				_label = [format ["Database %1", _id], _fn + ".txt"] select (_fn isNotEqualTo "" && {_fn isEqualType ""});
			};
			case DEVICE_TYPE_DRONE: {
				_label = format ["Drone %1", _id];
				if (!isNull _obj) then { _status = str (side _obj); };
			};
			case DEVICE_TYPE_VEHICLE: {
				_label = [format ["Vehicle %1", _id], getText (configOf _obj >> "displayName")] select (!isNull _obj);
				if (!isNull _obj) then { _status = ["unlocked", "locked"] select ((locked _obj) > 0); };
			};
			case DEVICE_TYPE_GPS_TRACKER: { _label = format ["Tracker %1", _id]; };
			default                     { _label = format ["Device %1", _id]; };
		};
		_items pushBack createHashMapFromArray [["id", _id], ["label", _label], ["status", _status]];
	} forEach _list;
	_items
};

ROOT_CYBERWARFARE_LOG_DEBUG_2("gui_registerApps: hasWeb=%1 hasNative=%2",_hasWeb,_hasNative);

if (_hasWeb) then
{
	// Register each device type as a generic CEF device-list app. extra carries the device type
	// and the action buttons the generic app renders per device.
	private _act = { params ["_id", "_label"]; createHashMapFromArray [["id", _id], ["label", _label]] };

	{
		_x params ["_id", "_titleKey", "_glyph", "_icon", "_type", "_actions", "_menu"];
		[
			_id, localize _titleKey, _glyph, "deviceList",
			createHashMapFromArray [["type", _type], ["actions", _actions], ["icon", _icon], ["menu", _menu]]
		] call AE3_desktop_fnc_registerExtApp;
	} forEach [
		// _menu nests the app in the AE3 Applications menu under a Tools folder (#1/#10), keeping the
		// left dock clear. Action buttons let the operator drive each device from the GUI (#3-#9).
		["RootCW_Doors",     "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS",     "&#128682;", "door",     DEVICE_TYPE_DOOR,      [["lock", "Lock"] call _act, ["unlock", "Unlock"] call _act], "Tools/Hack"],
		["RootCW_Lights",    "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS",    "&#128161;", "light",    DEVICE_TYPE_LIGHT,     [["on", "On"] call _act, ["off", "Off"] call _act], "Tools/Hack"],
		["RootCW_Gps",       "STR_ROOT_CYBERWARFARE_GUI_APP_GPS",       "&#128205;", "gps",      DEVICE_TYPE_GPS_TRACKER, [], "Tools/Hack"],
		["RootCW_PowerGrid", "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID", "&#9889;",   "power",    DEVICE_TYPE_POWERGRID, [["on", "On"] call _act, ["off", "Off"] call _act, ["overload", "Overload"] call _act], "Tools/Devices"],
		["RootCW_Databases", "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES", "&#128451;", "database", DEVICE_TYPE_DATABASE,  [["access", "Download"] call _act], "Tools/Devices"],
		["RootCW_Drones",    "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES",    "&#128760;", "drone",    DEVICE_TYPE_DRONE,     [["west", "WEST"] call _act, ["east", "EAST"] call _act, ["guer", "GUER"] call _act, ["civ", "CIV"] call _act], "Tools/Devices"],
		["RootCW_Vehicles",  "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES",  "&#128663;", "vehicle",  DEVICE_TYPE_VEHICLE,   [["lock", "Lock"] call _act, ["unlock", "Unlock"] call _act, ["engineoff", "Engine Off"] call _act], "Tools/Devices"],
		["RootCW_Custom",    "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM",    "&#129513;", "device",   DEVICE_TYPE_CUSTOM,    [["activate", "Activate"] call _act, ["deactivate", "Deactivate"] call _act], "Tools/Devices"]
	];

	// dev_request: browser asks for a device type -> reuse the MP-safe request path.
	["dev_request", {
		params ["_computer", "_user", "_data"];
		private _reqType = _data getOrDefault ["type", 0];
		ROOT_CYBERWARFARE_LOG_DEBUG_1("gui dev_request type=%1",_reqType);
		if (isNull _computer) exitWith {};
		[_computer, _reqType] call Root_fnc_gui_requestDevices;
	}] call AE3_desktop_fnc_registerCmd;

	// dev_action: browser triggers an action on a device -> the matching server action event.
	["dev_action", {
		params ["_computer", "_user", "_data"];
		ROOT_CYBERWARFARE_LOG_DEBUG_1("gui dev_action data=%1",_data);
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
			case DEVICE_TYPE_DRONE:     { ["root_cyberwarfare_gui_droneAction",     [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_VEHICLE:   { ["root_cyberwarfare_gui_vehicleAction",   [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_CUSTOM:    { ["root_cyberwarfare_gui_customAction",    [_co, _nid, _id, _action, netId player, ""]] call CBA_fnc_serverEvent; };
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
	ROOT_CYBERWARFARE_LOG_DEBUG_2("gui devList type=%1 count=%2",_deviceType,count _list);

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
