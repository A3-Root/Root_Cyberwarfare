#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: 3DEN Editor module that registers every synchronized AE3 laptop as a hackable station.
 *              Assigns the station role and a link-dialog name only; it does not install the toolset.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denRegisterHackableLaptop;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

// Only AE3 laptops can act as hacking stations; USB drives are not stations, so they are excluded.
private _syncedObjects = synchronizedObjects _logic;
private _laptops = _syncedObjects select {
    typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"]
};

// Wait for mission time and for the laptops' AE3 layer to be initialized before registering.
[
    {
        params ["_laptops"];
        CBA_missionTime >= 10
        && {_laptops findIf {isNil {_x getVariable "AE3_filesystem"}} == -1}
    },
    {
        params ["_laptops", "_logic"];

        if (_laptops isEqualTo []) exitWith {
            ROOT_CYBERWARFARE_LOG_ERROR("3DEN Register Hackable Laptop: No AE3 Laptop objects synchronized to this module!");
        };

        private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", 1];
        // 3DEN BOOL attributes load as numbers (1/0); coerce to a real boolean before it reaches the
        // boolean-typed parameter of the registration function.
        private _addCredentials = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_REGISTER_LAPTOP_CREDENTIALS", 1]) in [1, true];

        {
            private _laptop = _x;
            private _customName = format ["HackTool_%1", _index];
            private _execUserId = owner _laptop;

            [_laptop, _execUserId, _customName, _addCredentials] call FUNC(registerHackableLaptopZeusMain);

            _index = _index + 1;
        } forEach _laptops;

        missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _index, true];

        if (serverCommandAvailable "#kick") then {
            systemChat "[ROOT Cyberwarfare] Register Hackable Laptop module initialized successfully";
        };

        deleteVehicle _logic;
    },
    [_laptops, _logic]
] call CBA_fnc_waitUntilAndExecute;
