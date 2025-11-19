#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the persistent identifier for a computer based on the current device setup mode
 *              Simple mode: Returns laptop netId (object-based)
 *              Experimental mode: Returns player UID (player-based, survives laptop pickup/deploy)
 *
 * Arguments:
 * 0: _computer <OBJECT> - Laptop/computer object
 *
 * Return Value:
 * <STRING> - Persistent identifier (netId in Simple mode, player UID in Experimental mode)
 *
 * Example:
 * private _identifier = [_laptop] call Root_fnc_getComputerIdentifier;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

DEBUG_LOG_1("getComputerIdentifier called with computer: %1",_computer);

if (isNull _computer) exitWith {
    DEBUG_LOG("Computer is null,returning empty string");
    ""
};

if (IS_EXPERIMENTAL_MODE) exitWith {
    DEBUG_LOG("Experimental mode detected - looking for player");

    // Find player using this laptop
    private _player = [_computer] call FUNC(getPlayerFromComputer);

    if (isNull _player) exitWith {
        DEBUG_LOG("No player found for computer in experimental mode");
        ""
    };

    private _uid = getPlayerUID _player;
    DEBUG_LOG_2("Experimental mode - Player: %1, UID: %2",name _player,_uid);
    _uid
};

// Simple mode - use netId
private _netId = netId _computer;
DEBUG_LOG_1("Simple mode - netId: %1",_netId);
_netId
