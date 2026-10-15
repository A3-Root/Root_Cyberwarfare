#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Starts the Hackerman SSH session sweep when the first session opens and removes it when
 *              the last one closes, so a mission where nobody is connected runs none of it. Server only.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call Root_fnc_manageHackSweep;
 *
 * Public: No
 */

if (!isServer) exitWith {};

private _handle = missionNamespace getVariable [GVAR_HACK_SWEEP, -1];

if ((count GET_HACK_SESSIONS) > 0) exitWith {
    if (_handle >= 0) exitWith {};

    _handle = [{[] call Root_fnc_hackSessionSweep}, 10] call CBA_fnc_addPerFrameHandler;

    missionNamespace setVariable [GVAR_HACK_SWEEP, _handle];
};

if (_handle < 0) exitWith {};

[_handle] call CBA_fnc_removePerFrameHandler;

missionNamespace setVariable [GVAR_HACK_SWEEP, -1];
