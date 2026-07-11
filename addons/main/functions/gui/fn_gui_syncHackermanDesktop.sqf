#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Requests a Hackerman.exe launcher sync for a computer. The filesystem itself is only
 *              ever mutated on the server (see FUNC(syncHackermanFs)) because the update is a
 *              read-modify-write of a single object variable - performing it on each client let two
 *              desktops race and leave the ~/Desktop entries inconsistent.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Computer object whose filesystem is updated
 * 1: _available <BOOL> - Whether the launcher should exist
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]], ["_available", false, [false]]];

if (isNull _computer) exitWith {};

if (isServer) exitWith {
    [_computer, _available] call FUNC(syncHackermanFs);
};

["root_cyberwarfare_syncHackermanFs", [netId _computer, _available]] call CBA_fnc_serverEvent;
