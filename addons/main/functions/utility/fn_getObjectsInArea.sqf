#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Unique objects and entities inside one or more areas.
 *
 * Arguments:
 * 0: _areas <ARRAY> - Areas [centerASL, a, b, angle, isRectangle, c]
 *
 * Return Value:
 * Objects <ARRAY>
 *
 * Example:
 * private _objects = [[[_logic] call Root_fnc_logicArea]] call Root_fnc_getObjectsInArea;
 *
 * Public: No
 */

params [["_areas", [], [[]]]];

private _allObjects = createHashMap;

{
    _x params ["_center", "_a", "_b", ["_angle", 0], ["_rect", false], ["_c", -1]];
    private _area = [ASLToAGL _center, _a, _b, _angle, _rect, _c];
    private _reach = if (_rect) then { sqrt (_a ^ 2 + _b ^ 2) } else { _a max _b };
    private _pos = ASLToAGL _center;
    {
        if (_x inArea _area) then { _allObjects set [str _x, _x]; };
    } forEach ((nearestObjects [_pos, [], _reach]) + (_pos nearEntities _reach));
} forEach _areas;

values _allObjects
