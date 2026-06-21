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
	// Grid + world position for the shared map-link, gated by the per-device "Allow Location View"
	// flag (default on; GPS is gated on its tracked state instead). Returns [gridStr, [x,y]] or
	// ["", []] when hidden, so the GUI shows/hides the location and [Map] button accordingly (#0f).
	private _locOf = {
		params ["_o", ["_force", false]];
		if (isNull _o) exitWith { ["", []] };
		if (!_force && {!(_o getVariable ["ROOT_CYBERWARFARE_ALLOW_LOCATION", true])}) exitWith { ["", []] };
		private _p = getPosWorld _o;
		[mapGridPosition _o, [_p select 0, _p select 1]]
	};
	private _displayName = { params ["_o", "_fallback"]; if (isNull _o) exitWith {_fallback}; private _n = getText (configOf _o >> "displayName"); [_fallback, _n] select (_n isNotEqualTo "") };
	{
		private _id = _x param [0, _forEachIndex];
		private _obj = objectFromNetId (_x param [1, ""]);
		private _label = "";
		private _status = "";       // current device state next to the label (#2/#3/#4...)
		private _details = [];       // [[k,v],...] extra properties (vehicles #1)
		private _children = [];      // sub-items with own actions (per-door lock #2)
		private _downloadTime = 0;   // database download duration in seconds (#5)
		private _acts = [];          // per-device action override (vehicles gate by allow flags, #2)
		private _mkAct = { createHashMapFromArray [["id", _this select 0], ["label", _this select 1]] };
		// Confirm-action builder ([id,label,confirm]). MUST be local to DESCRIBE: it runs later in the
		// devList event-handler scope where the registration-time _actC is out of scope, so referencing
		// that one errored and the door items never built -> the Doors app showed empty (Doors #1).
		private _actC = { createHashMapFromArray [["id", _this select 0], ["label", _this select 1], ["confirm", _this select 2]] };
		// Slider-action builder ([id,label,min,max,value,step,unit]): the GUI opens a bounded slider and
		// sends the chosen numeric value, matching the CLI's fine-tuning (Vehicles #1).
		private _mkSlider = {
			_this params ["_sid", "_slabel", "_smin", "_smax", "_sval", ["_sstep", 1], ["_sunit", ""]];
			createHashMapFromArray [["id", _sid], ["label", _slabel], ["slider", true], ["min", _smin], ["max", _smax], ["value", _sval], ["step", _sstep], ["unit", _sunit]]
		};
		// _grid (grid square text) + _pos (world [x,y] for the [Map] link), gated by Allow Location.
		([_obj] call _locOf) params ["_grid", "_pos"];
		switch (_type) do {
			case DEVICE_TYPE_DOOR: {
				private _doorIds = _x param [2, []];
				_label = [_obj, format ["Building %1", _id]] call _displayName;
				if (!isNull _obj) then {
					private _locked = {(_obj getVariable [format ["bis_disabled_Door_%1", _x], 0]) == 1} count _doorIds;
					_status = format ["%1/%2 locked", _locked, count _doorIds];
					// Per-door sub-items so individual doors can be locked/unlocked (#2).
					{
						private _ds = ["unlocked", "locked"] select ((_obj getVariable [format ["bis_disabled_Door_%1", _x], 0]) == 1);
						_children pushBack createHashMapFromArray [
							["id", str _x], ["label", format ["Door %1", _x]], ["status", _ds],
							["actions", [
								["lock", "Lock", "Locking this door draws battery power. Continue?"] call _actC,
								["unlock", "Unlock", "Unlocking this door draws battery power. Continue?"] call _actC
							]]
						];
					} forEach _doorIds;
				};
			};
			case DEVICE_TYPE_LIGHT: {
				_label = [_obj, format ["Light %1", _id]] call _displayName;
				if (!isNull _obj) then {
					if (alive _obj) then { _status = ["Off", "On"] select (_obj getVariable ["ROOT_CYBERWARFARE_LIGHT_ON", true]); }
					else { _status = "Disabled"; };
				};
			};
			case DEVICE_TYPE_POWERGRID: {
				_label = [_obj, format ["Power grid %1", _id]] call _displayName;
				if (!isNull _obj) then {
					_status = _obj getVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF"];
					// "Lights affected" must match what the action actually toggles, so the number shown
					// equals the "N lights turned ON/OFF" report (Power Grid #1). The action (fn_gui_
					// powergridAction) targets every object within the grid's radius minus excluded
					// classes - so use the SAME query and the SAME radius/exclusions from the registry row
					// (_x = [id, netId, name, radius, allowOverload, explosionType, excludedClassnames]).
					private _rad = _x param [3, _obj getVariable ["ROOT_CYBERWARFARE_GENERATOR_RADIUS", 0]];
					private _excluded = _x param [6, []];
					private _affected = (9 allObjects 0) select { (_x distance _obj) <= _rad };
					if (_excluded isNotEqualTo []) then { _affected = _affected select { !(typeOf _x in _excluded) }; };
					_details = [["Radius", format ["%1m", round _rad]], ["Lights affected", count _affected]];
				};
			};
			case DEVICE_TYPE_DATABASE: {
				private _fn = "";
				if (!isNull _obj) then { _fn = _obj getVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", ""]; };
				_label = [format ["Database %1", _id], _fn + ".txt"] select (_fn isNotEqualTo "" && {_fn isEqualType ""});
				// Download time (seconds) so the GUI shows a real progress bar (#5).
				_grid = ""; _pos = [];
				_downloadTime = _obj getVariable ["ROOT_CYBERWARFARE_DATABASE_SIZE_EDIT", 0];
				_details = [["Download time", format ["%1s", _downloadTime]]];
			};
			case DEVICE_TYPE_DRONE: {
				_label = [_obj, format ["Drone %1", _id]] call _displayName;
				if (!isNull _obj) then { _status = [str (side _obj), "Disabled"] select (!alive _obj || {_obj getVariable ["ROOT_CYBERWARFARE_DRONE_DISABLED", false]}); };
			};
			case DEVICE_TYPE_VEHICLE: {
				_label = [_obj, format ["Vehicle %1", _id]] call _displayName;
				if (!isNull _obj) then {
					_status = ["unlocked", "locked"] select ((locked _obj) > 0);
					// Live vehicle properties (#1): fuel, engine, lock, damage.
					_details = [
						["Fuel", format ["%1%2", round ((fuel _obj) * 100), "%"]],
						["Engine", ["Off", "On"] select (isEngineOn _obj)],
						["Locked", ["No", "Yes"] select ((locked _obj) > 0)],
						["Damage", format ["%1%2", round ((damage _obj) * 100), "%"]]
					];
					// Controls gated by the per-vehicle allow flags (#2).
					_acts = [["lock", "Lock"] call _mkAct, ["unlock", "Unlock"] call _mkAct];
					if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_ENGINE", false]) then { _acts append [["engineon", "Engine On"] call _mkAct, ["engineoff", "Engine Off"] call _mkAct]; };
					if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_LIGHTS", false]) then { _acts append [["lightson", "Lights On"] call _mkAct, ["lightsoff", "Lights Off"] call _mkAct]; };
					if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_BRAKES", false]) then { _acts pushBack (["brakes", "Brake"] call _mkAct); };
					// Fuel / Speed / Alarm are sliders bounded by the per-vehicle limits, matching the CLI
					// (Vehicles #1). The old Refuel/Drain + Speed +/- buttons are replaced by these.
					if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_FUEL", false]) then {
						private _fmin = _obj getVariable ["ROOT_CYBERWARFARE_FUEL_MIN", 0];
						private _fmax = _obj getVariable ["ROOT_CYBERWARFARE_FUEL_MAX", 100];
						_acts pushBack (["setfuel", "Fuel", _fmin, _fmax, round ((fuel _obj) * 100), 1, "%"] call _mkSlider);
					};
					if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_SPEED", false]) then {
						private _smin = _obj getVariable ["ROOT_CYBERWARFARE_SPEED_MIN", -50];
						private _smax = _obj getVariable ["ROOT_CYBERWARFARE_SPEED_MAX", 50];
						_acts pushBack (["setspeed", "Speed", _smin, _smax, 0, 1, "km/h"] call _mkSlider);
					};
					if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_DOOR", false]) then {
						private _amin = _obj getVariable ["ROOT_CYBERWARFARE_ALARM_MIN", 1];
						private _amax = _obj getVariable ["ROOT_CYBERWARFARE_ALARM_MAX", 30];
						_acts pushBack (["setalarm", "Alarm", _amin, _amax, _amin, 1, "s"] call _mkSlider);
					};
				};
			};
			case DEVICE_TYPE_GPS_TRACKER: {
				_label = [_obj, format ["Tracker %1", _id]] call _displayName;
				// Location revealed only while/after tracking (#1/#2); otherwise hidden regardless.
				private _tracked = !isNull _obj && {_obj getVariable ["ROOT_CYBERWARFARE_GPS_TRACKED", false]};
				_status = ["Untracked", "Tracked"] select _tracked;
				if (_tracked) then { ([_obj, true] call _locOf) params ["_grid", "_pos"]; } else { _grid = ""; _pos = []; };
			};
			default { _label = [_obj, format ["Device %1", _id]] call _displayName; };
		};
		_items pushBack createHashMapFromArray [
			["id", _id], ["label", _label], ["status", _status],
			["grid", _grid], ["pos", _pos], ["details", _details], ["children", _children],
			["downloadTime", _downloadTime], ["actions", _acts]
		];
	} forEach _list;
	_items
};

ROOT_CYBERWARFARE_LOG_DEBUG_2("gui_registerApps: hasWeb=%1 hasNative=%2",_hasWeb,_hasNative);

if (_hasWeb) then
{
	// Register each device type as a generic CEF device-list app. extra carries the device type
	// and the action buttons the generic app renders per device.
	private _act = { params ["_id", "_label"]; createHashMapFromArray [["id", _id], ["label", _label]] };
	private _actC = { params ["_id", "_label", "_confirm"]; createHashMapFromArray [["id", _id], ["label", _label], ["confirm", _confirm]] };

	{
		_x params ["_id", "_titleKey", "_glyph", "_icon", "_type", "_actions", "_menu", ["_globals", []]];
		private _extra = createHashMapFromArray [["type", _type], ["actions", _actions], ["icon", _icon], ["menu", _menu]];
		if (_globals isNotEqualTo []) then { _extra set ["globalActions", _globals]; };
		[_id, localize _titleKey, _glyph, "deviceList", _extra] call AE3_desktop_fnc_registerExtApp;
	} forEach [
		// All RootCW apps go in a single "Hacking Tools" Applications-menu category (#6). Registration
		// order below = the display order within the category. Action buttons drive each device.
		["RootCW_Doors",     "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS",     "&#128682;", "door",     DEVICE_TYPE_DOOR,      [["lock", "Lock", "Locking the building's doors draws battery power. Continue?"] call _actC, ["unlock", "Unlock", "Unlocking the building's doors draws battery power. Continue?"] call _actC], "Hacking Tools"],
		// Lights: per-light On/Off plus whole-network All On / All Off (Lights #1).
		["RootCW_Lights",    "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS",    "&#128161;", "light",    DEVICE_TYPE_LIGHT,     [["on", "On"] call _act, ["off", "Off"] call _act], "Hacking Tools", [["allon", "All On"] call _act, ["alloff", "All Off"] call _act]],
		["RootCW_Databases", "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES", "&#128451;", "database", DEVICE_TYPE_DATABASE,  [createHashMapFromArray [["id", "access"], ["label", "Download"], ["flow", "download"]]], "Hacking Tools"],
		["RootCW_Gps",       "STR_ROOT_CYBERWARFARE_GUI_APP_GPS",       "&#128205;", "gps",      DEVICE_TYPE_GPS_TRACKER, [["track", "Track"] call _act], "Hacking Tools"],
		// Drones: Disable plus side-change buttons (Drones #1); the action handler supports west/east/guer/civ.
		["RootCW_Drones",    "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES",    "&#128760;", "drone",    DEVICE_TYPE_DRONE,     [["disable", "Disable"] call _act, ["west", "WEST"] call _act, ["east", "EAST"] call _act, ["guer", "GUER"] call _act, ["civ", "CIV"] call _act], "Hacking Tools"],
		// Vehicles: plain toggles; Fuel/Speed/Alarm are added as slider actions per-vehicle in DESCRIBE
		// (Vehicles #1). Refuel/Drain removed.
		["RootCW_Vehicles",  "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES",  "&#128663;", "vehicle",  DEVICE_TYPE_VEHICLE,   [["lock", "Lock"] call _act, ["unlock", "Unlock"] call _act, ["engineoff", "Engine Off"] call _act], "Hacking Tools"],
		["RootCW_PowerGrid", "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID", "&#9889;",   "power",    DEVICE_TYPE_POWERGRID, [["on", "On"] call _act, ["off", "Off"] call _act, ["overload", "Overload"] call _act], "Hacking Tools"],
		["RootCW_Custom",    "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM",    "&#129513;", "device",   DEVICE_TYPE_CUSTOM,    [["activate", "Activate"] call _act, ["deactivate", "Deactivate"] call _act], "Hacking Tools"]
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
		private _sub = _data getOrDefault ["sub", ""]; // individual door id, etc.
		private _value = _data getOrDefault ["value", 0]; // numeric slider value (vehicles #1)
		private _co = clientOwner;
		private _nid = netId _computer;
		switch (_type) do {
			// _sub carries an individual door id for per-door lock/unlock (Doors #2); "" = whole building.
			case DEVICE_TYPE_DOOR:      { ["root_cyberwarfare_gui_doorAction",      [_co, _nid, _id, _action, "", _sub]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_LIGHT:     { ["root_cyberwarfare_gui_lightAction",     [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_POWERGRID: { ["root_cyberwarfare_gui_powergridAction", [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_DATABASE:  { ["root_cyberwarfare_gui_databaseAction",  [_co, _nid, _id, netId player, "", _data getOrDefault ["savePath", ""]]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_DRONE:     { ["root_cyberwarfare_gui_droneAction",     [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_VEHICLE:   { ["root_cyberwarfare_gui_vehicleAction",   [_co, _nid, _id, _action, "", _value]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_GPS_TRACKER: { ["root_cyberwarfare_gui_gpsAction",     [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
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
	params ["_deviceType", "_msg", "_ok", ["_path", ""]];

	if (!isNil "AE3_desktop_fnc_jsSend") then {
		["dev_result", createHashMapFromArray [["type", _deviceType], ["msg", _msg], ["ok", _ok], ["path", _path]]] call AE3_desktop_fnc_jsSend;
	};

	private _open = uiNamespace getVariable [format ["ROOT_gui_open_%1", _deviceType], []];
	if (_open isEqualTo []) exitWith {};
	hintSilent parseText format ["<t color='%1'>%2</t>", [ROOT_CYBERWARFARE_COLOR_ERROR, ROOT_CYBERWARFARE_COLOR_SUCCESS] select _ok, _msg];
	private _listCtrl = _open select 0;
	if (isNull _listCtrl) exitWith {};
	private _computer = (uiNamespace getVariable ["AE3_desktop_session", createHashMap]) getOrDefault ["computer", objNull];
	if (!isNull _computer) then { [_computer, _deviceType] call Root_fnc_gui_requestDevices; };
}] call CBA_fnc_addEventHandler;
