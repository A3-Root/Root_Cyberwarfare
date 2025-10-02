params ["_logic"];
deleteVehicle _logic;

if !(hasInterface) exitWith {};

[
    "Hacking Power Requirements", [
	["SLIDER", ["Cost to Lock/Unlock Doors", "Energy / Power (in Wh) required to lock/unlock doors"], [0, 20, 2, 1]],
    ["SLIDER", ["Cost to Switch Drone Sides", "Energy / Power (in Wh) required to change the side of a drone"], [0, 100, 20, 1]],
    ["SLIDER", ["Cost to Disable Drone", "Energy / Power (in Wh) required to disable a drone"], [0, 50, 10, 1]],
    ["SLIDER", ["Cost to Activate/Deactivate Custom Devices", "Energy / Power (in Wh) required to use a custom hacking tool"], [0, 100, 10, 1]]
	], {
		params ["_results"];
		_results params ["_doorCost", "_droneSideCost", "_droneDestructionCost", "_customCost"];
		missionNamespace setVariable ["ROOT-All-Costs", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];
		["Modified Hacking Power Cost!"] call zen_common_fnc_showMessage;
	}, {
		["Aborted"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	}, []
] call zen_dialog_fnc_create;


