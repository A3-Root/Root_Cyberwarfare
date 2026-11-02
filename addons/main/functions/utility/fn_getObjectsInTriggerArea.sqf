#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Unique objects within synchronized trigger areas.
 *
 * Arguments:
 * 0: _triggers <ARRAY> - Array of trigger objects
 *
 * Return Value:
 * _uniqueObjects <ARRAY> - Array of unique objects found in trigger areas
 *
 * Example:
 * private _objects = [_syncedTriggers] call Root_fnc_getObjectsInTriggerArea;
 *
 * Public: No
 */

params [
    ["_triggers", [], [[]]]
];

[_triggers apply {
    (triggerArea _x) params ["_a", "_b", "_angle", "_rect", ["_c", -1]];
    [getPosASL _x, _a, _b, _angle, _rect, _c]
}] call FUNC(getObjectsInArea)
