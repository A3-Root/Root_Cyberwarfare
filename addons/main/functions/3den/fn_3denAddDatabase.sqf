#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module to add hackable files/databases
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denAddDatabase;
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

		// Get module attributes
		private _fileName = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_NAME", "Secret Database"];
		private _fileSize = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_SIZE", 10];
		private _fileContent = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_CONTENT", "This is a secret file downloaded from the network."];
		private _executionCode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_EXEC", ""];
		private _addToPublic = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_PUBLIC", true];

		// Get laptop netIds for linking
		private _linkedComputers = _laptops apply { netId _x };

		// Determine availability setting
		private _availableToFutureLaptops = false;
		if (_addToPublic) then {
			if (_linkedComputers isEqualTo []) then {
				// Public + no linked = all current laptops only
				_availableToFutureLaptops = false;
			} else {
				// Public + some linked = linked laptops + all future
				_availableToFutureLaptops = true;
			};
		};

		// Use the logic object itself to store the file data
		private _fileObject = _logic;
		private _execUserId = 2; // Server

		// Call the existing Zeus main function
		// Parameters: _fileObject, _filename, _filesize, _filecontent, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops
		[_fileObject, _fileName, _fileSize, _fileContent, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops] call FUNC(addDatabaseZeusMain);

		// Notify admins of success
		if (serverCommandAvailable "#kick") then {
			systemChat "[ROOT Cyberwarfare] Add Hackable File module initialized successfully";
		};

		// Note: Don't delete the logic module - it's used to store the file data
	},
	[_laptops, _logic]
] call CBA_fnc_waitUntilAndExecute;
