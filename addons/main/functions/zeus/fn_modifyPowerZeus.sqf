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
    "Hacking Power Requirements", [
	["SLIDER", ["Cost to Lock/Unlock Doors", "Energy / Power (in Wh) required to lock/unlock doors"], [1, 20, missionNamespace getVariable [SETTING_DOOR_COST, 2], 1]],
    ["SLIDER", ["Cost to Switch Drone Sides", "Energy / Power (in Wh) required to change the side of a drone without a mission-specific cost"], [1, 100, missionNamespace getVariable [SETTING_DRONE_SIDE_COST, 20], 1]],
    ["SLIDER", ["Cost to Disable", "Energy / Power (in Wh) required to disable a drone without a mission-specific cost"], [1, 100, missionNamespace getVariable [SETTING_DRONE_HACK_COST, 10], 1]],
	["SLIDER", ["Cost to Hack Vehicles", "Energy / Power (in Wh) required to control a vehicle without a mission-specific cost"], [1, 100, missionNamespace getVariable [SETTING_VEHICLE_COST, 2], 1]],
    ["SLIDER", ["Cost to Activate/Deactivate Custom Devices", "Energy / Power (in Wh) required to use a custom hacking tool"], [1, 100, missionNamespace getVariable [SETTING_CUSTOM_COST, 10], 1]],
    ["SLIDER", ["Cost to Ping GPS Trackers", "Energy / Power (in Wh) required to track a GPS tracker without a mission-specific cost"], [1, 100, missionNamespace getVariable [SETTING_GPS_COST, 10], 1]],
    ["SLIDER", ["Cost to Control Power Grid", "Energy / Power (in Wh) required to control power grids (on/off/overload)"], [1, 100, missionNamespace getVariable [SETTING_POWERGRID_COST, 15], 1]]
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


