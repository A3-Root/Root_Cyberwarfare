#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Moves and/or locks building doors. Doors already in the requested state are skipped.
 * No power cost. Server.
 *
 * States:
 * "open" / "close" - move the door, lock unchanged
 * "lock" / "unlock" - change the lock, position unchanged
 * "lockopen" / "lockclosed" - move the door and lock it
 *
 * Arguments:
 * 0: _building <OBJECT> - Building
 * 1: _doors <ARRAY> - Engine door numbers, [] = all detected doors
 * 2: _state <STRING> - State, see above
 * 3: _dryRun <BOOL> (Optional) - Only return the doors that would change, default: false
 *
 * Return Value:
 * Changed door numbers <ARRAY>
 *
 * Example:
 * [cursorObject, [], "lockopen"] remoteExec ["Root_fnc_setDoorState", 2];
 *
 * Public: Yes
 */

params [["_building", objNull, [objNull]], ["_doors", [], [[]]], ["_state", "", [""]], ["_dryRun", false, [false]]];

_state = toLower _state;
if (isNull _building || {!(_state in DOOR_STATES)}) exitWith { [] };

if (_doors isEqualTo []) then {
    _doors = [_building] call FUNC(detectBuildingDoors);
};

// Target position and lock; nil keeps the current value.
private _wantOpen = switch (_state) do {
    case "open";
    case "lockopen": { true };
    case "close";
    case "lockclosed": { false };
    default { nil };
};
private _wantLock = switch (_state) do {
    case "lock";
    case "lockopen";
    case "lockclosed": { true };
    case "unlock": { false };
    default { nil };
};

private _sourcesCfg = (configOf _building) >> "AnimationSources";
private _changed = [];

{
    private _door = _x;
    ([_building, _door] call FUNC(getDoorState)) params ["_isOpen", "_isLocked"];
    private _moveDoor = !isNil "_wantOpen" && {_wantOpen isNotEqualTo _isOpen};
    private _setLock = !isNil "_wantLock" && {_wantLock isNotEqualTo _isLocked};

    if (_moveDoor || _setLock) then {
        _changed pushBack _door;
        if (_dryRun) then { continue };

        if (_setLock) then {
            _building setVariable [format ["bis_disabled_Door_%1", _door], parseNumber _wantLock, true];
            _building setVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _door], [nil, true] select _wantLock, true];
        };

        if (_moveDoor) then {
            private _phase = parseNumber _wantOpen;
            private _sources = [format ["Door_%1_sound_source", _door], format ["Door_%1_noSound_source", _door], format ["Door_%1_source", _door]] select { isClass (_sourcesCfg >> _x) };
            if (_sources isEqualTo []) then {
                _building animate [format ["Door_%1_rot", _door], _phase];
            } else {
                { _building animateSource [_x, _phase]; } forEach _sources;
            };
        };
    };
} forEach _doors;

_changed
