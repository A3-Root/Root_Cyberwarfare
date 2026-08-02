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
		// 3DEN BOOL attributes load as numbers (1/0); coerce so the boolean checks downstream do not throw.
			private _isEncrypted = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT", 0]) in [1, true];
		private _encryptionAlgorithm = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_ALGORITHM", "morse"];
		private _encryptionKey = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_KEY", ""];
		private _encryptionOptions = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_OPTIONS", ""];
		// Optional fixed ID for this file (0 = auto-assign).
		private _requestedId = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_ID_START", 0]);

		// Get laptop netIds for linking
		private _linkedComputers = _laptops apply { netId _x };

		// Device Access states how the registered devices may be reached. The combo's fourth entry (3) is
		// the linked-plus-future variant, which resolves to a linked device that later laptops also reach.
		private _accessMode = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_ACCESS", -1];
		private _availableToFutureLaptops = false;

		if (_accessMode == 3) then {
		    _accessMode = ACCESS_MODE_LINKED;
		    _availableToFutureLaptops = true;
		};

		if (_accessMode < 0) then {
		    // Missions saved before Device Access existed carry only the legacy public checkbox, so map
		    // that forward and leave their devices as reachable as they were.
		    _accessMode = ACCESS_MODE_LINKED;
		    if ((_logic getVariable ["ROOT_CYBERWARFARE_3DEN_DATABASE_PUBLIC", 1]) in [1, true]) then {
		        if (_linkedComputers isEqualTo []) then {
		            _accessMode = ACCESS_MODE_PUBLIC;
		        } else {
		            _availableToFutureLaptops = true;
		        };
		    };
		};

		// Use the logic object itself to store the file data
		private _fileObject = _logic;
		private _execUserId = 2; // Server

		[_fileObject, _fileName, _fileSize, _fileContent, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops, _isEncrypted, _encryptionAlgorithm, _encryptionKey, _encryptionOptions, _requestedId, _accessMode] call FUNC(addDatabaseZeusMain);

		// Notify admins of success
		if (serverCommandAvailable "#kick") then {
			systemChat "[ROOT Cyberwarfare] Add Hackable File module initialized successfully";
		};

		// Note: Don't delete the logic module - it's used to store the file data
	},
	[_laptops, _logic]
] call CBA_fnc_waitUntilAndExecute;
