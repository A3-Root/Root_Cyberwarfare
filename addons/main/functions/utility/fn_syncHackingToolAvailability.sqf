#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Publishes the current effective hacking-tool availability on a computer object.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Computer object to update
 *
 * Return Value:
 * Hacking tools availability <BOOL>
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith {false};

private _available = [_computer] call FUNC(hasHackingToolsAvailable);
_computer setVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_AVAILABLE", _available, true];

_available
