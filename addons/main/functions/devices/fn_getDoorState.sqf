#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Position and lock state of one building door. Any machine.
 *
 * Arguments:
 * 0: _building <OBJECT> - Building
 * 1: _door <NUMBER> - Engine door number
 *
 * Return Value:
 * [isOpen <BOOL>, isLocked <BOOL>] <ARRAY>
 *
 * Example:
 * ([cursorObject, 1] call Root_fnc_getDoorState) params ["_isOpen", "_isLocked"];
 *
 * Public: Yes
 */

params [["_building", objNull, [objNull]], ["_door", 0, [0]]];

if (isNull _building) exitWith { [false, false] };

private _sources = (configOf _building) >> "AnimationSources";
private _source = [format ["Door_%1_sound_source", _door], format ["Door_%1_noSound_source", _door], format ["Door_%1_source", _door]] select { isClass (_sources >> _x) };

private _phase = if (_source isEqualTo []) then {
    _building animationPhase format ["Door_%1_rot", _door]
} else {
    _building animationSourcePhase (_source select 0)
};

[_phase > 0.5, (_building getVariable [format ["bis_disabled_Door_%1", _door], 0]) == 1]
