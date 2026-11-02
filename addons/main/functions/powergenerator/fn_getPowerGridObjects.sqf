#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Objects a power grid switches: every object within the radius of the grid object or inside the
 * effect area, minus the excluded classes. Any machine.
 *
 * Arguments:
 * 0: _gridObject <OBJECT> - The generator
 * 1: _radius <NUMBER|ARRAY> - Grid radius in metres, or effect area [centerASL, a, b, angle, isRectangle]
 * 2: _excludedClassnames <ARRAY> - (Optional, default: []) Class names left out
 *
 * Return Value:
 * Objects <ARRAY>
 *
 * Example:
 * private _lights = [_generator, 300, ["Land_LampHalogen_F"]] call Root_fnc_getPowerGridObjects;
 * private _lights = [_generator, [getPosASL _village, 300, 200, 45, true]] call Root_fnc_getPowerGridObjects;
 *
 * Public: Yes
 */

params [["_gridObject", objNull, [objNull]], ["_radius", 0, [0, []]], ["_excludedClassnames", [], [[]]]];

if (isNull _gridObject) exitWith { [] };

private _objects = if (_radius isEqualType []) then {
    _radius params ["_center", "_a", "_b", ["_angle", 0], ["_rect", false]];
    private _area = [ASLToAGL _center, _a, _b, _angle, _rect];
    (9 allObjects 0) select { _x inArea _area }
} else {
    (9 allObjects 0) select { (_x distance _gridObject) <= _radius }
};
if (_excludedClassnames isNotEqualTo []) then {
    _objects = _objects select { !(typeOf _x in _excludedClassnames) };
};

_objects
