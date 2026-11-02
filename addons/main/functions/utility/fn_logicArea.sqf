#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Area of a module logic: the 3DEN area if set, otherwise the fallback size at the logic's direction.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic
 * 1: _fallback <ARRAY> (Optional) - Half sizes [a, b], default: [50, 50]
 *
 * Return Value:
 * Area [centerASL, a, b, angle, isRectangle, c] usable with inArea <ARRAY>
 *
 * Example:
 * private _area = [_logic] call Root_fnc_logicArea;
 *
 * Public: No
 */

params [["_logic", objNull, [objNull]], ["_fallback", [50, 50], [[]], 2]];

private _area = _logic getVariable ["objectArea", [_fallback select 0, _fallback select 1, getDir _logic, false, -1]];
_area params [["_a", 50], ["_b", 50], ["_angle", 0], ["_rect", false], ["_c", -1]];

[getPosASL _logic, _a, _b, _angle, _rect, _c]
