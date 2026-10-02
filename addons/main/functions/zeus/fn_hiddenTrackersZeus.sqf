#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ZEN module that shows the curator every GPS tracker no laptop lists. The roster is held
 *              by the server, because the identifiers in it are the mission's secrets, so this asks
 *              for it and the reply opens the dialog (Root_fnc_hiddenTrackersDialog).
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_hiddenTrackersZeus;
 *
 * Public: No
 */

params ["_logic"];

deleteVehicle _logic;

if !(hasInterface) exitWith {};

[clientOwner, player] remoteExec ["Root_fnc_hiddenTrackersZeusMain", 2];
