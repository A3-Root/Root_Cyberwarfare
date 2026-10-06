#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Zeus module to modify global power cost settings
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_modifyPowerZeus;
 *
 * Public: No
 */

params ["_logic"];
deleteVehicle _logic;

if !(hasInterface) exitWith {};

// Every slider opens on the cost that is actually in force, so a curator reads the mission's current
// figures rather than the module's own defaults, and what they leave alone stays as it was.
[
    (localize "STR_ROOT_CYBERWARFARE_UI_HACKING_POWER_REQUIREMENTS"), [
	["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_COST_TO_LOCK_UNLOCK_DOORS"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_LOCK_UNLOCK_DOORS")], [1, 20, missionNamespace getVariable [SETTING_DOOR_COST, 2], 1]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_COST_TO_SWITCH_DRONE_SIDES"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_CHANGE_THE_SIDE_OF_A_DRONE")], [1, 100, missionNamespace getVariable [SETTING_DRONE_SIDE_COST, 20], 1]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_COST_TO_DISABLE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_DISABLE_A_DRONE_WITHOUT_A_MISSION")], [1, 100, missionNamespace getVariable [SETTING_DRONE_HACK_COST, 10], 1]],
	["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_COST_TO_HACK_VEHICLES"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_CONTROL_A_VEHICLE_WITHOUT_A_MISSION")], [1, 100, missionNamespace getVariable [SETTING_VEHICLE_COST, 2], 1]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_COST_TO_ACTIVATE_DEACTIVATE_CUSTOM_DEVICES"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_USE_A_CUSTOM_HACKING_TOOL")], [1, 100, missionNamespace getVariable [SETTING_CUSTOM_COST, 10], 1]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_COST_TO_PING_GPS_TRACKERS"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_TRACK_A_GPS_TRACKER_WITHOUT_A")], [1, 100, missionNamespace getVariable [SETTING_GPS_COST, 10], 1]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_COST_TO_CONTROL_POWER_GRID"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_CONTROL_POWER_GRIDS_ON_OFF_OVERLOAD")], [1, 100, missionNamespace getVariable [SETTING_POWERGRID_COST, 15], 1]]
	], {
		params ["_results"];
		_results params ["_doorCost", "_droneSideCost", "_droneDestructionCost", "_vehicleCost", "_customCost", "_gpsCost", "_powerGridCost"];
		// The settings are what every hacking operation reads, so they are what the module writes; the
		// legacy cost array is kept in step behind them for scripts that still read it.
		missionNamespace setVariable [SETTING_DOOR_COST, _doorCost, true];
		missionNamespace setVariable [SETTING_DRONE_SIDE_COST, _droneSideCost, true];
		missionNamespace setVariable [SETTING_DRONE_HACK_COST, _droneDestructionCost, true];
		missionNamespace setVariable [SETTING_VEHICLE_COST, _vehicleCost, true];
		missionNamespace setVariable [SETTING_CUSTOM_COST, _customCost, true];
		missionNamespace setVariable [SETTING_GPS_COST, _gpsCost, true];
		missionNamespace setVariable [SETTING_POWERGRID_COST, _powerGridCost, true];
		missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];
		[localize "STR_ROOT_CYBERWARFARE_ZEUS_POWER_MODIFIED"] call zen_common_fnc_showMessage;
	}, {
		[localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	}, []
] call zen_dialog_fnc_create;


