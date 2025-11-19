#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Finds the player currently using a computer terminal
 *              Used in experimental mode to map laptop objects to player UIDs
 *
 * Arguments:
 * 0: _computer <OBJECT> - Laptop/computer object
 *
 * Return Value:
 * <OBJECT> - Player object currently using the computer, or objNull if none found
 *
 * Example:
 * private _player = [_laptop] call Root_fnc_getPlayerFromComputer;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

DEBUG_LOG_1("getPlayerFromComputer called with: %1",_computer);

if (isNull _computer) exitWith {
    DEBUG_LOG("Computer is null");
    objNull
};

// Check all players for proximity or interaction with the laptop
private _player = objNull;
{
    // Player is in vehicle (laptop) or within interaction range (3m)
    if (vehicle _x == _computer || {_x distance _computer < 3}) exitWith {
        _player = _x;
        DEBUG_LOG_2("Found player %1 near computer %2",name _player,_computer);
    };
} forEach allPlayers;

if (isNull _player) then {
    DEBUG_LOG("No player found near computer");
};

_player
