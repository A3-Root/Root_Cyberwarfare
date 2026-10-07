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
	params ["_type", "_list", ["_computerNetId", ""]];
	private _items = [];
	private _computer = objectFromNetId _computerNetId;
	private _doorCost = missionNamespace getVariable [SETTING_DOOR_COST, 2];
	private _powerConfirm = {
		params ["_label", "_costWh"];
		private _batteryStatus = [_computer, _costWh] call FUNC(getBatteryStatus);
		_batteryStatus params ["_hasBattery", "_battery", "_currentWh", "_currentPercent", "_capacityWh", "_remainingWh", "_remainingPercent"];
		if (!_hasBattery) exitWith {
			format [(localize "STR_ROOT_CYBERWARFARE_UI_1_DRAWS_2_WH_BR_CURRENT_BATTERY_UNAVAILABLE"), _label, round _costWh]
		};
		format [
			(localize "STR_ROOT_CYBERWARFARE_UI_1_DRAWS_2_WH_BR_CURRENT_BATTERY_3_WH_4_5_BR"),
			_label,
			round _costWh,
			round _currentWh,
			round _currentPercent,
			"%",
			round _remainingWh,
			round _remainingPercent
		]
	};
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
	// Prefer the mission-maker's custom device name (stored in the registry row) over the object's
	// class displayName, so both Zeus and 3DEN modules show the name they were given on the desktop.
	private _labelOr = { params ["_o", "_stored", "_fallback"]; if (_stored isEqualType "" && _stored isNotEqualTo "") exitWith {_stored}; [_o, _fallback] call _displayName };
	{
		private _id = _x param [0, _forEachIndex];
		private _obj = objectFromNetId (_x param [1, ""]);
		private _label = "";
		private _status = "";       // current device state next to the label (#2/#3/#4...)
		private _details = [];       // [[k,v],...] extra properties (vehicles #1)
		private _children = [];      // sub-items with own actions (per-door lock #2)
			private _downloadTime = 0;   // database download duration in seconds (#5)
			private _mapLabel = nil;     // optional map marker label override
			private _mapMarker = nil;    // optional focused map marker toggle
			private _acts = [];          // per-device action override (vehicles gate by allow flags, #2)
		// Confirm-action builder ([id,label,confirm]). MUST be local to DESCRIBE: it runs later in the
		// devList event-handler scope where the registration-time _actC is out of scope, so referencing
		// that one errored and the door items never built -> the Doors app showed empty (Doors #1).
		private _actC = { createHashMapFromArray [["id", _this select 0], ["label", _this select 1], ["confirm", _this select 2]] };
		// Slider-action builder ([id,label,min,max,value,step,unit]): the GUI opens a bounded slider and
		// sends the chosen numeric value, matching the CLI's fine-tuning (Vehicles #1).
			private _mkSlider = {
				_this params ["_sid", "_slabel", "_smin", "_smax", "_sval", ["_sstep", 1], ["_sunit", ""], ["_options", createHashMap], ["_confirm", ""]];
				createHashMapFromArray [["id", _sid], ["label", _slabel], ["slider", true], ["min", _smin], ["max", _smax], ["value", _sval], ["step", _sstep], ["unit", _sunit], ["options", _options], ["confirm", _confirm]]
			};
		// _grid (grid square text) + _pos (world [x,y] for the [Map] link), gated by Allow Location.
		([_obj] call _locOf) params ["_grid", "_pos"];
		switch (_type) do {
			case DEVICE_TYPE_DOOR: {
				private _doorIds = _x param [2, []];
				// Per-door custom IDs assigned by the mission maker; the id sent back for a per-door
				// action is the custom one, resolved to the engine number server-side.
				private _doorIdMap = _x param [5, []];
				_label = [_obj, format [(localize "STR_ROOT_CYBERWARFARE_UI_BUILDING_1"), _id]] call _displayName;
				if (!isNull _obj) then {
					private _locked = {(_obj getVariable [format ["bis_disabled_Door_%1", _x], 0]) == 1} count _doorIds;
					_status = format [(localize "STR_ROOT_CYBERWARFARE_UI_1_2_LOCKED"), _locked, count _doorIds];
					private _lockCost = ((count _doorIds) - _locked) * _doorCost;
					private _unlockCost = _locked * _doorCost;
					_acts = [
						["lock", (localize "STR_ROOT_CYBERWARFARE_GUI_LOCK"), [(localize "STR_ROOT_CYBERWARFARE_UI_LOCKING_ALL_DOORS"), _lockCost] call _powerConfirm] call _actC,
						["unlock", (localize "STR_ROOT_CYBERWARFARE_GUI_UNLOCK"), [(localize "STR_ROOT_CYBERWARFARE_UI_UNLOCKING_ALL_DOORS"), _unlockCost] call _powerConfirm] call _actC
					];
					{
						private _realDoor = _x;
						private _customDoor = _realDoor;
						{
							if ((_x select 1) == _realDoor) exitWith { _customDoor = _x select 0; };
						} forEach _doorIdMap;
						private _isLocked = (_obj getVariable [format ["bis_disabled_Door_%1", _realDoor], 0]) == 1;
						private _ds = [(localize "STR_ROOT_CYBERWARFARE_UI_UNLOCKED"), (localize "STR_ROOT_CYBERWARFARE_UI_LOCKED")] select _isLocked;
						private _singleLockCost = ([1, 0] select _isLocked) * _doorCost;
						private _singleUnlockCost = ([0, 1] select _isLocked) * _doorCost;
						_children pushBack createHashMapFromArray [
							["id", str _customDoor], ["label", format [(localize "STR_ROOT_CYBERWARFARE_UI_DOOR_1_2"), _customDoor]], ["status", _ds],
							["actions", [
								["lock", (localize "STR_ROOT_CYBERWARFARE_GUI_LOCK"), [(localize "STR_ROOT_CYBERWARFARE_UI_LOCKING_THIS_DOOR"), _singleLockCost] call _powerConfirm] call _actC,
								["unlock", (localize "STR_ROOT_CYBERWARFARE_GUI_UNLOCK"), [(localize "STR_ROOT_CYBERWARFARE_UI_UNLOCKING_THIS_DOOR"), _singleUnlockCost] call _powerConfirm] call _actC
							]]
						];
					} forEach _doorIds;
				};
			};
			case DEVICE_TYPE_LIGHT: {
				_label = [_obj, format [(localize "STR_ROOT_CYBERWARFARE_UI_LIGHT_1"), _id]] call _displayName;
				if (!isNull _obj) then {
					if (alive _obj) then { _status = [(localize "STR_ROOT_CYBERWARFARE_UI_OFF"), (localize "STR_ROOT_CYBERWARFARE_UI_ON")] select (_obj getVariable ["ROOT_CYBERWARFARE_LIGHT_ON", true]); }
					else { _status = (localize "STR_ROOT_CYBERWARFARE_UI_DISABLED"); };
				};
			};
			case DEVICE_TYPE_POWERGRID: {
				_label = [_obj, _x param [2, ""], format [(localize "STR_ROOT_CYBERWARFARE_UI_POWER_GRID_1"), _id]] call _labelOr;
					if (!isNull _obj) then {
						_status = [_obj getVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF"]] call FUNC(localizeDeviceState);
						private _cost = missionNamespace getVariable [SETTING_POWERGRID_COST, 15];
						_acts = [
							["on", (localize "STR_ROOT_CYBERWARFARE_UI_ON"), [(localize "STR_ROOT_CYBERWARFARE_UI_ACTIVATING_THE_POWER_GRID"), _cost] call _powerConfirm] call _actC,
							["off", (localize "STR_ROOT_CYBERWARFARE_UI_OFF"), [(localize "STR_ROOT_CYBERWARFARE_UI_DEACTIVATING_THE_POWER_GRID"), _cost] call _powerConfirm] call _actC,
							["overload", (localize "STR_ROOT_CYBERWARFARE_GUI_OVERLOAD"), [(localize "STR_ROOT_CYBERWARFARE_UI_OVERLOADING_THE_POWER_GRID"), _cost] call _powerConfirm] call _actC
						];
					// "Lights affected" must match what the action actually toggles, so the number shown
					// equals the "N lights turned ON/OFF" report (Power Grid #1). The action (fn_gui_
					// powergridAction) targets every object within the grid's radius minus excluded
					// classes - so use the SAME query and the SAME radius/exclusions from the registry row
					// (_x = [id, netId, name, radius, allowOverload, explosionType, excludedClassnames]).
					private _rad = _x param [3, _obj getVariable ["ROOT_CYBERWARFARE_GENERATOR_RADIUS", 0]];
					private _excluded = _x param [6, []];
					private _affected = (9 allObjects 0) select { (_x distance _obj) <= _rad };
					if (_excluded isNotEqualTo []) then { _affected = _affected select { !(typeOf _x in _excluded) }; };
					_details = [[(localize "STR_ROOT_CYBERWARFARE_UI_RADIUS"), format ["%1m", round _rad]], [(localize "STR_ROOT_CYBERWARFARE_UI_LIGHTS_AFFECTED"), count _affected]];
				};
			};
			case DEVICE_TYPE_DATABASE: {
				private _fn = "";
				if (!isNull _obj) then { _fn = _obj getVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", ""]; };
				_label = [format [(localize "STR_ROOT_CYBERWARFARE_UI_DATABASE_1"), _id], _fn + ".txt"] select (_fn isNotEqualTo "" && _fn isEqualType "");
				// Download time (seconds) so the GUI shows a real progress bar (#5).
				_grid = ""; _pos = [];
				_downloadTime = _obj getVariable ["ROOT_CYBERWARFARE_DATABASE_SIZE_EDIT", 0];
				_details = [[(localize "STR_ROOT_CYBERWARFARE_UI_DOWNLOAD_TIME"), format ["%1s", _downloadTime]]];
			};
				case DEVICE_TYPE_DRONE: {
					// Prefer the mission-maker's custom drone name (registry row index 2) over the class displayName.
					_label = [_obj, _x param [2, ""], format [(localize "STR_ROOT_CYBERWARFARE_UI_DRONE_1"), _id]] call _labelOr;
					if (!isNull _obj) then {
						_status = [[str (side _obj)] call FUNC(localizeDeviceState), (localize "STR_ROOT_CYBERWARFARE_UI_DISABLED")] select (!alive _obj || {_obj getVariable ["ROOT_CYBERWARFARE_DRONE_DISABLED", false]});
						// The figure the confirmation quotes is the one the server will charge: a drone
						// registered with a cost of its own is billed at that, everything else at the setting.
						private _disableCost = [_obj, "disable"] call FUNC(getDroneCost);
						private _sideCost = [_obj, "side"] call FUNC(getDroneCost);
						_acts = [
							["disable", (localize "STR_ROOT_CYBERWARFARE_UI_DISABLE"), [(localize "STR_ROOT_CYBERWARFARE_UI_DISABLING_THIS_DRONE"), _disableCost] call _powerConfirm] call _actC,
							createHashMapFromArray [["id", "side"], ["label", (localize "STR_ROOT_CYBERWARFARE_UI_CHANGE_SIDE")], ["submenu", [
								["west", (localize "STR_ROOT_CYBERWARFARE_UI_WEST_BLUFOR"), [(localize "STR_ROOT_CYBERWARFARE_UI_CHANGING_THIS_DRONE_SIDE"), _sideCost] call _powerConfirm] call _actC,
								["east", (localize "STR_ROOT_CYBERWARFARE_UI_EAST_OPFOR"), [(localize "STR_ROOT_CYBERWARFARE_UI_CHANGING_THIS_DRONE_SIDE"), _sideCost] call _powerConfirm] call _actC,
								["guer", (localize "STR_ROOT_CYBERWARFARE_UI_GUER_INDFOR"), [(localize "STR_ROOT_CYBERWARFARE_UI_CHANGING_THIS_DRONE_SIDE"), _sideCost] call _powerConfirm] call _actC,
								["civ", (localize "STR_ROOT_CYBERWARFARE_UI_CIVILIAN"), [(localize "STR_ROOT_CYBERWARFARE_UI_CHANGING_THIS_DRONE_SIDE"), _sideCost] call _powerConfirm] call _actC
							]]]
						];
					};
				};
			case DEVICE_TYPE_VEHICLE: {
				_label = [_obj, _x param [2, ""], format [(localize "STR_ROOT_CYBERWARFARE_UI_VEHICLE_1"), _id]] call _labelOr;
				if (!isNull _obj) then {
					_status = [(localize "STR_ROOT_CYBERWARFARE_UI_UNLOCKED"), (localize "STR_ROOT_CYBERWARFARE_UI_LOCKED")] select ((locked _obj) > 0);
					// Live vehicle properties shown beside each available vehicle.
					_details = [
						[(localize "STR_ROOT_CYBERWARFARE_UI_FUEL"), format ["%1%2", round ((fuel _obj) * 100), "%"]],
						[(localize "STR_ROOT_CYBERWARFARE_UI_FUEL_CONTROL"), (localize "STR_ROOT_CYBERWARFARE_UI_REDUCE_ONLY")],
						[(localize "STR_ROOT_CYBERWARFARE_UI_ENGINE"), [(localize "STR_ROOT_CYBERWARFARE_UI_OFF"), (localize "STR_ROOT_CYBERWARFARE_UI_ON")] select (isEngineOn _obj)],
						[(localize "STR_ROOT_CYBERWARFARE_UI_LOCKED_2"), [(localize "STR_ROOT_CYBERWARFARE_UI_NO"), (localize "STR_ROOT_CYBERWARFARE_UI_YES")] select ((locked _obj) > 0)],
						[(localize "STR_ROOT_CYBERWARFARE_UI_DAMAGE"), format ["%1%2", round ((damage _obj) * 100), "%"]]
						];
						private _cost = _obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_COST", 2];
						private _accessActions = [
							["lock", (localize "STR_ROOT_CYBERWARFARE_GUI_LOCK"), [(localize "STR_ROOT_CYBERWARFARE_UI_LOCKING_THIS_VEHICLE"), _cost] call _powerConfirm] call _actC,
							["unlock", (localize "STR_ROOT_CYBERWARFARE_GUI_UNLOCK"), [(localize "STR_ROOT_CYBERWARFARE_UI_UNLOCKING_THIS_VEHICLE"), _cost] call _powerConfirm] call _actC
						];
						private _systemActions = [];
						private _movementActions = [];
						if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_ENGINE", false]) then { _systemActions append [
							["engineon", (localize "STR_ROOT_CYBERWARFARE_UI_ENGINE_ON"), [(localize "STR_ROOT_CYBERWARFARE_UI_STARTING_THIS_VEHICLE_ENGINE"), _cost] call _powerConfirm] call _actC,
							["engineoff", (localize "STR_ROOT_CYBERWARFARE_GUI_ENGINE_OFF"), [(localize "STR_ROOT_CYBERWARFARE_UI_STOPPING_THIS_VEHICLE_ENGINE"), _cost] call _powerConfirm] call _actC
						]; };
						if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_LIGHTS", false]) then { _systemActions append [
							["lightson", (localize "STR_ROOT_CYBERWARFARE_UI_LIGHTS_ON"), [(localize "STR_ROOT_CYBERWARFARE_UI_TURNING_THIS_VEHICLE_LIGHTS_ON"), _cost] call _powerConfirm] call _actC,
							["lightsoff", (localize "STR_ROOT_CYBERWARFARE_UI_LIGHTS_OFF"), [(localize "STR_ROOT_CYBERWARFARE_UI_TURNING_THIS_VEHICLE_LIGHTS_OFF"), _cost] call _powerConfirm] call _actC
						]; };
						if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_BRAKES", false]) then {
							private _bmin = _obj getVariable ["ROOT_CYBERWARFARE_BRAKES_MIN", 1];
							private _bmax = _obj getVariable ["ROOT_CYBERWARFARE_BRAKES_MAX", 10];
							_movementActions pushBack (["brakes", (localize "STR_ROOT_CYBERWARFARE_UI_BRAKE_RATE"), _bmin, _bmax, _bmax, 1, "m/s2", createHashMap, [(localize "STR_ROOT_CYBERWARFARE_UI_APPLYING_THIS_VEHICLE_BRAKE_CONTROL"), _cost] call _powerConfirm] call _mkSlider);
						};
						if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_FUEL", false]) then {
							private _fmin = _obj getVariable ["ROOT_CYBERWARFARE_FUEL_MIN", 0];
							private _fmax = _obj getVariable ["ROOT_CYBERWARFARE_FUEL_MAX", 100];
							private _currentFuel = round ((fuel _obj) * 100);
							private _fuelCeiling = _currentFuel min _fmax;
							private _fuelFloor = _fmin min _fuelCeiling;
							_systemActions pushBack (["setfuel", (localize "STR_ROOT_CYBERWARFARE_UI_FUEL"), _fuelFloor, _fuelCeiling, _fuelCeiling, 1, "%", createHashMap, [(localize "STR_ROOT_CYBERWARFARE_UI_CHANGING_THIS_VEHICLE_FUEL"), _cost] call _powerConfirm] call _mkSlider);
						};
						if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_SPEED", false]) then {
							private _smin = _obj getVariable ["ROOT_CYBERWARFARE_SPEED_MIN", -50];
							private _smax = _obj getVariable ["ROOT_CYBERWARFARE_SPEED_MAX", 50];
							private _speedOptions = createHashMapFromArray [["checkboxLabel", (localize "STR_ROOT_CYBERWARFARE_UI_LOCK_VEHICLE_TO_THIS_SPEED")], ["returnObject", true]];
							_movementActions pushBack (["setspeed", (localize "STR_ROOT_CYBERWARFARE_UI_SPEED"), _smin, _smax, round (speed _obj), 1, "km/h", _speedOptions, [(localize "STR_ROOT_CYBERWARFARE_UI_CHANGING_THIS_VEHICLE_SPEED"), _cost] call _powerConfirm] call _mkSlider);
						};
						if (_obj getVariable ["ROOT_CYBERWARFARE_VEHICLE_DOOR", false]) then {
							private _amin = _obj getVariable ["ROOT_CYBERWARFARE_ALARM_MIN", 1];
							private _amax = _obj getVariable ["ROOT_CYBERWARFARE_ALARM_MAX", 30];
							_systemActions pushBack (["setalarm", (localize "STR_ROOT_CYBERWARFARE_UI_ALARM"), _amin, _amax, _amin, 1, "s", createHashMap, [(localize "STR_ROOT_CYBERWARFARE_UI_TRIGGERING_THIS_VEHICLE_ALARM"), _cost] call _powerConfirm] call _mkSlider);
						};
					_acts = [createHashMapFromArray [["id", "access"], ["label", (localize "STR_ROOT_CYBERWARFARE_UI_ACCESS")], ["submenu", _accessActions]]];
					if (_systemActions isNotEqualTo []) then { _acts pushBack createHashMapFromArray [["id", "systems"], ["label", (localize "STR_ROOT_CYBERWARFARE_UI_SYSTEMS")], ["submenu", _systemActions]]; };
					if (_movementActions isNotEqualTo []) then { _acts pushBack createHashMapFromArray [["id", "movement"], ["label", (localize "STR_ROOT_CYBERWARFARE_UI_MOVEMENT")], ["submenu", _movementActions]]; };
				};
			};
				case DEVICE_TYPE_GPS_TRACKER: {
					_label = [_obj, _x param [2, ""], format [(localize "STR_ROOT_CYBERWARFARE_UI_TRACKER_1"), _id]] call _labelOr;
				private _trackingTime = _x param [3, 0];
				private _updateFrequency = _x param [4, 0];
				private _currentStatus = _x param [8, ["Untracked", 0, ""]];
				private _statusName = if (_currentStatus isEqualType []) then { _currentStatus param [0, "Untracked"] } else { str _currentStatus };
				private _statusStart = if (_currentStatus isEqualType []) then { _currentStatus param [1, 0] } else { 0 };
				_status = [_statusName] call FUNC(localizeDeviceState);
				if (_statusName isEqualTo "Tracking") then {
					private _elapsed = (time - _statusStart) max 0;
					private _remaining = (_trackingTime - _elapsed) max 0;
					_details = [[(localize "STR_ROOT_CYBERWARFARE_UI_STATUS"), _status], [(localize "STR_ROOT_CYBERWARFARE_UI_ELAPSED"), format ["%1s", round _elapsed]], [(localize "STR_ROOT_CYBERWARFARE_UI_REMAINING"), format ["%1s", round _remaining]], [(localize "STR_ROOT_CYBERWARFARE_UI_DURATION"), format ["%1s", round _trackingTime]], [(localize "STR_ROOT_CYBERWARFARE_GUI_REFRESH"), format ["%1s", round _updateFrequency]]];
				} else {
					_details = [[(localize "STR_ROOT_CYBERWARFARE_UI_STATUS"), _status], [(localize "STR_ROOT_CYBERWARFARE_UI_DURATION"), format ["%1s", round _trackingTime]], [(localize "STR_ROOT_CYBERWARFARE_GUI_REFRESH"), format ["%1s", round _updateFrequency]]];
				};
					private _tracked = !isNull _obj && {_statusName in ["Tracking", "Tracked", "Completed", "Untrackable"]};
					if (_tracked) then { ([_obj, true] call _locOf) params ["_grid", "_pos"]; } else { _grid = ""; _pos = []; };
					_mapLabel = "";
					_mapMarker = false;
					private _cost = _x param [11, _obj getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_COST", 10]];
					_acts = [["track", (localize "STR_ROOT_CYBERWARFARE_GUI_TRACK"), [(localize "STR_ROOT_CYBERWARFARE_UI_TRACKING_THIS_GPS_SIGNAL"), _cost] call _powerConfirm] call _actC];
				};
				case DEVICE_TYPE_CUSTOM: {
					_label = [_obj, _x param [2, ""], format [(localize "STR_ROOT_CYBERWARFARE_UI_CUSTOM_DEVICE_1"), _id]] call _labelOr;
					private _cost = missionNamespace getVariable [SETTING_CUSTOM_COST, 5];
					_acts = [
						["activate", (localize "STR_ROOT_CYBERWARFARE_GUI_ACTIVATE"), [(localize "STR_ROOT_CYBERWARFARE_UI_ACTIVATING_THIS_CUSTOM_DEVICE"), _cost] call _powerConfirm] call _actC,
						["deactivate", (localize "STR_ROOT_CYBERWARFARE_GUI_DEACTIVATE"), [(localize "STR_ROOT_CYBERWARFARE_UI_DEACTIVATING_THIS_CUSTOM_DEVICE"), _cost] call _powerConfirm] call _actC
					];
				};
				case DEVICE_TYPE_NETSCAN: {
					// Rows arrive from Root_fnc_scanNetwork as [ip, type, ssh, interface, deviceBreakdown];
					// present each as a read-only entry with no actions or location. A single
					// "__SCANNING__" marker row is sent first to show the in-progress scan state.
					_x params [["_scanIp", ""], ["_scanType", ""], ["_scanSsh", ""], ["_scanIface", ""], ["_scanBreakdown", []]];
					_grid = ""; _pos = [];
					if (_scanIp isEqualTo "__SCANNING__") then {
						_id = 0;
						_label = (localize "STR_ROOT_CYBERWARFARE_UI_SCANNING_NETWORK");
						_status = (localize "STR_ROOT_CYBERWARFARE_UI_IN_PROGRESS");
					} else {
						_id = _forEachIndex;
						_label = _scanIp;
						_status = [(localize "STR_ROOT_CYBERWARFARE_UI_LAPTOP"), (localize "STR_ROOT_CYBERWARFARE_UI_ROUTER")] select (_scanType isEqualTo "Router");
						_details = [[(localize "STR_ROOT_CYBERWARFARE_UI_EXTERNAL_SSH"), [(localize "STR_ROOT_CYBERWARFARE_UI_NO"), (localize "STR_ROOT_CYBERWARFARE_UI_YES")] select (_scanSsh isEqualTo "Yes")], [(localize "STR_ROOT_CYBERWARFARE_UI_INTERFACE"), switch (_scanIface) do {
							case "CLI only": { (localize "STR_ROOT_CYBERWARFARE_UI_CLI_ONLY") };
							case "GUI only": { (localize "STR_ROOT_CYBERWARFARE_UI_GUI_ONLY") };
							case "CLI + GUI": { (localize "STR_ROOT_CYBERWARFARE_UI_CLI_GUI") };
							case "N/A": { (localize "STR_ROOT_CYBERWARFARE_UI_N_A") };
							default { _scanIface };
						}]];
						if (_scanBreakdown isNotEqualTo [] && _scanType isEqualTo "Laptop") then {
							private _breakdownStr = (_scanBreakdown apply { format ["%1 %2", _x select 1, switch (_x select 0) do { case "Doors": { (localize "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS") }; case "Lights": { (localize "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS") }; case "Drones": { (localize "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES") }; case "Databases": { (localize "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES") }; case "Custom Devices": { (localize "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM") }; case "GPS Trackers": { (localize "STR_ROOT_CYBERWARFARE_UI_GPS_TRACKERS") }; case "Vehicles": { (localize "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES") }; case "Power Grids": { (localize "STR_ROOT_CYBERWARFARE_UI_POWER_GRIDS") }; default { _x select 0 }; }] }) joinString ", ";
							_details pushBack [(localize "STR_ROOT_CYBERWARFARE_UI_HACKABLE_DEVICES"), _breakdownStr];
						};
					};
				};
			default { _label = [_obj, format [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_1"), _id]] call _displayName; };
		};
		// Default the map-link label/marker for every device type that has a position (doors, lights,
		// vehicles, drones, custom devices, power grids), so the same [Map] link GPS already gets also
		// shows up for them - GPS sets its own mapLabel/mapMarker above and is left untouched here.
		if (isNil "_mapLabel" && {_pos isNotEqualTo []}) then { _mapLabel = _label; _mapMarker = true; };
		private _item = createHashMapFromArray [
			["id", _id], ["label", _label], ["status", _status],
			["grid", _grid], ["pos", _pos], ["details", _details], ["children", _children],
			["distance", if (isNull _obj) then {-1} else {round (_obj distance player)}],
			["downloadTime", _downloadTime], ["actions", _acts]
		];
		if (!isNil "_mapLabel") then { _item set ["mapLabel", _mapLabel]; };
		if (!isNil "_mapMarker") then { _item set ["mapMarker", _mapMarker]; };
		_items pushBack _item;
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
		_x params ["_id", "_titleKey", "_glyph", "_icon", "_type", "_actions", "_menu", ["_globals", []]];
		private _extra = createHashMapFromArray [["type", _type], ["actions", _actions], ["icon", _icon], ["menu", (localize "STR_ROOT_CYBERWARFARE_UI_HACKING_TOOLS")]];
		if (_menu isEqualTo "Hacking Tools") then { _extra set ["requiresFunction", "Root_fnc_hasHackingToolsAvailable"]; };
		if (_menu isEqualTo "Hacking Tools") then { _extra set ["filters", true]; };
		if (_globals isNotEqualTo []) then { _extra set ["globalActions", _globals]; };
		[_id, localize _titleKey, _glyph, "deviceList", _extra] call AE3_desktop_fnc_registerExtApp;
	} forEach [
		// All RootCW apps go in a single "Hacking Tools" Applications-menu category (#6). Registration
		// order below = the display order within the category. Action buttons drive each device.
		// Network Scanner: read-only list of AE3 laptops/routers on the subnet; the Export global
		// action writes the scan to a file in the laptop's filesystem.
		["RootCW_NetScan",   "STR_ROOT_CYBERWARFARE_GUI_APP_NETSCAN",   "&#128225;", "network",  DEVICE_TYPE_NETSCAN,   [], "Hacking Tools", [createHashMapFromArray [["id", "export"], ["label", (localize "STR_ROOT_CYBERWARFARE_UI_EXPORT_TO_FILE")], ["flow", "download"]]]],
		["RootCW_Doors",     "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS",     "&#128682;", "door",     DEVICE_TYPE_DOOR,      [], "Hacking Tools"],
		// Lights: per-light On/Off plus whole-network All On / All Off (Lights #1).
		["RootCW_Lights",    "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS",    "&#128161;", "light",    DEVICE_TYPE_LIGHT,     [["on", (localize "STR_ROOT_CYBERWARFARE_UI_ON")] call _act, ["off", (localize "STR_ROOT_CYBERWARFARE_UI_OFF")] call _act], "Hacking Tools", [["allon", (localize "STR_ROOT_CYBERWARFARE_UI_ALL_ON")] call _act, ["alloff", (localize "STR_ROOT_CYBERWARFARE_UI_ALL_OFF")] call _act]],
		["RootCW_Databases", "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES", "&#128451;", "database", DEVICE_TYPE_DATABASE,  [createHashMapFromArray [["id", "access"], ["label", (localize "STR_ROOT_CYBERWARFARE_GUI_DOWNLOAD")], ["flow", "download"]]], "Hacking Tools"],
		// GPS: per-tracker Track, plus a whole-app entry for typing in the identifier of a tracker this
		// laptop does not list - the only way to reach a hidden one.
		["RootCW_Gps",       "STR_ROOT_CYBERWARFARE_GUI_APP_GPS",       "&#128205;", "gps",      DEVICE_TYPE_GPS_TRACKER, [["track", (localize "STR_ROOT_CYBERWARFARE_GUI_TRACK")] call _act], "Hacking Tools", [createHashMapFromArray [["id", "trackid"], ["label", localize "STR_ROOT_CYBERWARFARE_GUI_GPS_TRACK_BY_ID"], ["flow", "prompt"], ["promptTitle", localize "STR_ROOT_CYBERWARFARE_GUI_GPS_TRACK_BY_ID_PROMPT"]]]],
		// Drones: Disable plus side-change buttons (Drones #1); the action handler supports west/east/guer/civ.
		["RootCW_Drones",    "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES",    "&#128760;", "drone",    DEVICE_TYPE_DRONE,     [["disable", (localize "STR_ROOT_CYBERWARFARE_UI_DISABLE")] call _act, createHashMapFromArray [["id", "side"], ["label", (localize "STR_ROOT_CYBERWARFARE_UI_CHANGE_SIDE")], ["submenu", [["west", (localize "STR_ROOT_CYBERWARFARE_UI_WEST_BLUFOR")] call _act, ["east", (localize "STR_ROOT_CYBERWARFARE_UI_EAST_OPFOR")] call _act, ["guer", (localize "STR_ROOT_CYBERWARFARE_UI_GUER_INDFOR")] call _act, ["civ", (localize "STR_ROOT_CYBERWARFARE_UI_CIVILIAN")] call _act]]]], "Hacking Tools"],
		// Vehicles: plain toggles; Fuel/Speed/Alarm are added as slider actions per-vehicle in DESCRIBE
		// (Vehicles #1). Refuel/Drain removed.
		["RootCW_Vehicles",  "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES",  "&#128663;", "vehicle",  DEVICE_TYPE_VEHICLE,   [], "Hacking Tools"],
		["RootCW_PowerGrid", "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID", "&#9889;",   "power",    DEVICE_TYPE_POWERGRID, [["on", (localize "STR_ROOT_CYBERWARFARE_UI_ON")] call _act, ["off", (localize "STR_ROOT_CYBERWARFARE_UI_OFF")] call _act, ["overload", (localize "STR_ROOT_CYBERWARFARE_GUI_OVERLOAD")] call _act], "Hacking Tools"],
		["RootCW_Custom",    "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM",    "&#129513;", "device",   DEVICE_TYPE_CUSTOM,    [["activate", (localize "STR_ROOT_CYBERWARFARE_GUI_ACTIVATE")] call _act, ["deactivate", (localize "STR_ROOT_CYBERWARFARE_GUI_DEACTIVATE")] call _act], "Hacking Tools"]
	];

	private _hackermanExtra = createHashMapFromArray [
		["menu", (localize "STR_ROOT_CYBERWARFARE_UI_HACKING_TOOLS")],
		["icon", "terminal"],
		// Point at the base64 sidecar (PNG bytes): the CEF loader reads .b64 paths directly and skips the
		// engine texture sampler entirely, which both renders the icon and avoids the "Unknown sampler
		// texture type" warning the packed .paa produced. Replace hackerman.paa.b64 with your own art by
		// base64-encoding a PNG to that file.
		["iconPath", "\z\root_cyberwarfare\addons\main\images\hackerman.paa.b64"],
		["showOnDesktop", true],
		["showInDock", true],
		["showInMenu", false],
		["requiresFunction", "Root_fnc_hasHackingToolsAvailable"],
		["openCommand", "rootcw_hackerman_open"],
		["width", 320],
		["height", 630],
		["subtitle", (localize "STR_ROOT_CYBERWARFARE_UI_HACKING_TOOLS")],
		["launchApps", [
			["RootCW_NetScan", localize "STR_ROOT_CYBERWARFARE_GUI_APP_NETSCAN"],
			["RootCW_Doors", localize "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS"],
			["RootCW_Lights", localize "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS"],
			["RootCW_Databases", localize "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES"],
			["RootCW_Gps", localize "STR_ROOT_CYBERWARFARE_GUI_APP_GPS"],
			["RootCW_Drones", localize "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES"],
			["RootCW_Vehicles", localize "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES"],
			["RootCW_PowerGrid", localize "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID"],
			["RootCW_Custom", localize "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM"],
			["RootCW_Cryptography", (localize "STR_ROOT_CYBERWARFARE_UI_CRYPTOGRAPHY")]
		]]
	];
	["RootCW_Hackerman", "Hackerman.exe", "H", "launcher", _hackermanExtra] call AE3_desktop_fnc_registerExtApp;

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
		private _value = _data getOrDefault ["value", 0];
		private _lock = _data getOrDefault ["lock", false];
		// The ids the app has on screen when a whole-app action is pressed. The filter never leaves the
		// browser, so the visible rows have to travel with the action for it to mean "all of these".
		private _ids = _data getOrDefault ["ids", []];
		private _co = clientOwner;
		private _nid = netId _computer;
		switch (_type) do {
			// _sub carries an individual door id for per-door lock/unlock (Doors #2); "" = whole building.
			case DEVICE_TYPE_NETSCAN:   { ["root_cyberwarfare_gui_netscanExport",   [_co, _nid, _data getOrDefault ["savePath", ""]]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_DOOR:      { ["root_cyberwarfare_gui_doorAction",      [_co, _nid, _id, _action, "", _sub]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_LIGHT:     { ["root_cyberwarfare_gui_lightAction",     [_co, _nid, _id, _action, "", _ids]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_POWERGRID: { ["root_cyberwarfare_gui_powergridAction", [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_DATABASE:  { ["root_cyberwarfare_gui_databaseAction",  [_co, _nid, _id, netId player, "", _data getOrDefault ["savePath", ""]]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_DRONE:     { ["root_cyberwarfare_gui_droneAction",     [_co, _nid, _id, _action, ""]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_VEHICLE:   { ["root_cyberwarfare_gui_vehicleAction",   [_co, _nid, _id, _action, "", _value, _lock]] call CBA_fnc_serverEvent; };
			// The typed identifier travels with the action: the app has no row for a hidden tracker,
			// so the code is the only thing naming what to track.
			case DEVICE_TYPE_GPS_TRACKER: { ["root_cyberwarfare_gui_gpsAction",     [_co, _nid, _id, _action, "", _data getOrDefault ["promptValue", ""]]] call CBA_fnc_serverEvent; };
			case DEVICE_TYPE_CUSTOM:    { ["root_cyberwarfare_gui_customAction",    [_co, _nid, _id, _action, netId player, ""]] call CBA_fnc_serverEvent; };
			default {};
		};
	}] call AE3_desktop_fnc_registerCmd;

	["rootcw_hackerman_open", {
		params ["_computer", "_user", "_data", "_rid", "_command"];
		private _result = createHashMapFromArray [["ok", true]];
		if (isNull _computer || {!([_computer] call Root_fnc_hasHackingToolsAvailable)}) exitWith {
			_result set ["ok", false];
			[_command, _rid, _result] call AE3_desktop_fnc_jsReply;
		};

		// The intro video no longer plays from the launcher; it auto-plays once per USB mount when the
		// desktop is (re)opened with a hacking-tools drive connected - see gui_pushExtApps.
		[_command, _rid, _result] call AE3_desktop_fnc_jsReply;
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
	["RootCW_GpsMap", (localize "STR_ROOT_CYBERWARFARE_UI_GPS_MAP"), "Root_fnc_gui_appGpsMap", [0.6, 0.7], false, false] call AE3_desktop_fnc_registerApp;
};

// Server reply: device list for an open app. Feed the native control (if any) AND the browser.
["root_cyberwarfare_gui_devList", {
	params ["_deviceType", "_list", ["_computerNetId", ""]];
	ROOT_CYBERWARFARE_LOG_DEBUG_2("gui devList type=%1 count=%2",_deviceType,count _list);

	private _open = uiNamespace getVariable [format ["ROOT_gui_open_%1", _deviceType], []];
	if (_open isNotEqualTo []) then {
		_open params ["_listCtrl", "_populate"];
		if (!isNull _listCtrl) then {
			_listCtrl setVariable ["ROOT_gui_rows", _list];
			[_listCtrl, _list] call _populate;
		};
	};

	if (!isNil "AE3_desktop_fnc_jsSend") then {
		private _items = [_deviceType, _list, _computerNetId] call ROOT_CYBERWARFARE_GUI_DESCRIBE;
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

// Runs mission-provided custom device code on the operator client after the server validates access.
["root_cyberwarfare_gui_customExec", {
	params ["_computerNetId", "_deviceNetId", "_playerNetId", "_owner", "_code"];
	private _computer = objectFromNetId _computerNetId;
	private _deviceObject = objectFromNetId _deviceNetId;
	private _playerObject = objectFromNetId _playerNetId;
	if (_code isEqualType "" && _code isNotEqualTo "") then {
		[_computer, _deviceObject, _playerObject, _owner] spawn (compile _code);
	};
}] call CBA_fnc_addEventHandler;
