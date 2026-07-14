#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to adjust power cost settings for hacking operations
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAdjustPowerCost;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Check if this is the first placed module of this type
private _existingModules = allMissionObjects "ROOT_Module3DEN_AdjustPowerCost";
private _firstModule = _existingModules select 0;

if (_logic != _firstModule) exitWith {
	ROOT_CYBERWARFARE_LOG_INFO("3DEN Adjust Power Cost: Multiple power cost modules detected. Using the first placed module only.");
	deleteVehicle _logic;
};

// Get module attributes
private _doorCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_DOOR", 2];
private _droneSideCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_DRONE_SIDE", 20];
private _droneDisableCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_DRONE_DISABLE", 10];
private _customCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_CUSTOM", 10];
private _gpsCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_GPS", 10];
private _powerGridCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_POWERGRID", 15];

// The settings are what every hacking operation reads its cost from, so they are what the module writes.
// The legacy cost variables are kept in step behind them for scripts that still read those.
missionNamespace setVariable [SETTING_DOOR_COST, _doorCost, true];
missionNamespace setVariable [SETTING_DRONE_SIDE_COST, _droneSideCost, true];
missionNamespace setVariable [SETTING_DRONE_HACK_COST, _droneDisableCost, true];
missionNamespace setVariable [SETTING_CUSTOM_COST, _customCost, true];
missionNamespace setVariable [SETTING_GPS_COST, _gpsCost, true];
missionNamespace setVariable [SETTING_POWERGRID_COST, _powerGridCost, true];

missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DOOR_EDIT", _doorCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT", _droneSideCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT", _droneDisableCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_CUSTOM_EDIT", _customCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_POWERGRID_COST", _powerGridCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [_doorCost, _droneSideCost, _droneDisableCost, _customCost], true];

private _msg = format ["3DEN Adjust Power Cost: Power costs configured - Door: %1Wh, Drone Side: %2Wh, Drone Disable: %3Wh, Custom: %4Wh, GPS: %5Wh, Power Grid: %6Wh", _doorCost, _droneSideCost, _droneDisableCost, _customCost, _gpsCost, _powerGridCost];
ROOT_CYBERWARFARE_LOG_INFO(_msg);

// Delete the logic module after execution
deleteVehicle _logic;
