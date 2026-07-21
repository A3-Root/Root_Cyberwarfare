#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Resolves an approximate world position for each detected door of a building so the
 * curator can be shown which physical door maps to which door number. Door numbers come from
 * Root_fnc_detectBuildingDoors; positions are taken from the matching model selection when one can
 * be found, otherwise the labels are stacked above the building so they stay discoverable.
 *
 * Arguments:
 * 0: _building <OBJECT> - The building to inspect
 *
 * Return Value:
 * <ARRAY> - Array of [doorNumber <NUMBER>, worldPos <ARRAY>]
 *
 * Example:
 * private _labels = [_building] call Root_fnc_getDoorPositions;
 *
 * Public: No
 */

params [["_building", objNull, [objNull]]];

if (isNull _building) exitWith { [] };

private _doorNums = [_building] call FUNC(detectBuildingDoors);

// Map each door number to a model selection name (e.g. "Door_1" -> 1), ignoring handles/locks.
private _selForNum = createHashMap;
{
    private _low = toLower _x;
    if (_low find "door" >= 0 && {_low find "handle" < 0} && {_low find "doorlock" < 0}) then {
        private _finds = _low regexFind ["([0-9]+)"];
        if (_finds isNotEqualTo []) then {
            private _n = parseNumber (((_finds select 0) select 1) select 0);
            if !(_n in _selForNum) then { _selForNum set [_n, _x]; };
        };
    };
} forEach (selectionNames _building);

private _result = [];
{
    private _num = _x;
    private _pos = [];
    private _sel = _selForNum getOrDefault [_num, ""];
    if (_sel isNotEqualTo "") then {
        private _mp = _building selectionPosition _sel;
        if (_mp isNotEqualTo [0, 0, 0]) then {
            _pos = _building modelToWorldVisual _mp;
            _pos set [2, (_pos select 2) + 1];
        };
    };
    if (_pos isEqualTo []) then {
        // No usable selection: stack the label above the building centre so it is still readable.
        _pos = _building modelToWorldVisual [0, 0, 3 + _forEachIndex * 0.5];
    };
    _result pushBack [_num, _pos];
} forEach _doorNums;

_result
