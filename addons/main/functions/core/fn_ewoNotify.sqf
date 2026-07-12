// File: fn_ewoNotify.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Shows a coloured EWO charging message to the local player. The server drives every
 *              charging job, so it calls this on the owning client to report job starts, completions
 *              and interruptions the player would otherwise have no way to observe.
 *
 * Arguments:
 * 0: _message <STRING> - Message body, already localized and formatted
 * 1: _color <STRING> - Hex colour of the message (default: info blue)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["Charging complete.", ROOT_CYBERWARFARE_COLOR_SUCCESS] call Root_fnc_ewoNotify;
 *
 * Public: No
 */

params [["_message", "", [""]], ["_color", ROOT_CYBERWARFARE_COLOR_INFO, [""]]];

if (!hasInterface || {_message isEqualTo ""}) exitWith {};

hintSilent parseText format ["<t color='%1'>%2</t>", _color, _message];
