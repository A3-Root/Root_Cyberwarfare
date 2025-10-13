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
	LOG_INFO("3DEN Adjust Power Cost: Multiple power cost modules detected. Using the first placed module only.");
	deleteVehicle _logic;
};

// Get module attributes
private _doorCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_DOOR", 2];
private _droneSideCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_DRONE_SIDE", 20];
private _droneDisableCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_DRONE_DISABLE", 10];
private _customCost = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_COST_CUSTOM", 10];

// Store power costs globally
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DOOR_EDIT", _doorCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT", _droneSideCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT", _droneDisableCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_CUSTOM_EDIT", _customCost, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [_doorCost, _droneSideCost, _droneDisableCost, _customCost], true];

private _msg = format ["3DEN Adjust Power Cost: Power costs configured - Door: %1Wh, Drone Side: %2Wh, Drone Disable: %3Wh, Custom: %4Wh", _doorCost, _droneSideCost, _droneDisableCost, _customCost];
LOG_INFO(_msg);

// Delete the logic module after execution
deleteVehicle _logic;
