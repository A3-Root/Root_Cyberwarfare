#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add hacking tools to computers/laptops
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddHackingTools;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Get synchronized laptops early for the condition check
private _syncedObjects = synchronizedObjects _logic;
private _laptops = _syncedObjects select {
	typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

// Wait for mission time AND all laptops to have AE3 initialized before executing
[
	{
		params ["_laptops"];
		CBA_missionTime >= 10
		&& {_laptops findIf {isNil {_x getVariable "AE3_filesystem"}} == -1}
	},
	{
		params ["_laptops", "_logic"];

		// Early exit if no laptops
		if (_laptops isEqualTo []) exitWith {
			ROOT_CYBERWARFARE_LOG_ERROR("3DEN Add Hacking Tools: No AE3 Laptop objects synchronized to this module!");
		};

		// Get module attributes
		private _toolPath = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_HACK_TOOL_PATH", "/rubberducky/tools"];
		private _backdoorPrefix = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_HACK_TOOL_BACKDOOR", ""];

		// Generate custom laptop name
		private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", 1];

		{
			private _laptop = _x;
			private _customName = format ["HackTool_%1", _index];
			private _execUserId = owner _laptop;

			// Call the existing Zeus main function
			[_laptop, _toolPath, _execUserId, _customName, _backdoorPrefix] call FUNC(addHackingToolsZeusMain);

			_index = _index + 1;
		} forEach _laptops;

		missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _index, true];

		// Notify admins of success
		if (serverCommandAvailable "#kick") then {
			systemChat "[ROOT Cyberwarfare] Add Hacking Tools module initialized successfully";
		};

		// Delete the logic module after execution
		deleteVehicle _logic;
	},
	[_laptops, _logic]
] call CBA_fnc_waitUntilAndExecute;
