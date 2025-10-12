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

[
    "Hacking Power Requirements", [
	["SLIDER", ["Cost to Lock/Unlock Doors", "Energy / Power (in Wh) required to lock/unlock doors"], [1, 20, 2, 1]],
    ["SLIDER", ["Cost to Switch Drone Sides", "Energy / Power (in Wh) required to change the side of a drone"], [1, 100, 20, 1]],
    ["SLIDER", ["Cost to Disable Drone", "Energy / Power (in Wh) required to disable a drone"], [1, 50, 10, 1]],
    ["SLIDER", ["Cost to Activate/Deactivate Custom Devices", "Energy / Power (in Wh) required to use a custom hacking tool"], [1, 100, 10, 1]]
	], {
		params ["_results"];
		_results params ["_doorCost", "_droneSideCost", "_droneDestructionCost", "_customCost"];
		missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];
		["Modified Hacking Power Cost!"] call zen_common_fnc_showMessage;
	}, {
		["Aborted"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	}, []
] call zen_dialog_fnc_create;


