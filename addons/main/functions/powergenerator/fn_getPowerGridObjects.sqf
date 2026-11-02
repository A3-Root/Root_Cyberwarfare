#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Objects a power grid switches: every object within the radius of the grid object, minus the
 * excluded classes. Any machine.
 *
 * Arguments:
 * 0: _gridObject <OBJECT> - The generator
 * 1: _radius <NUMBER> - Grid radius in metres
 * 2: _excludedClassnames <ARRAY> - (Optional, default: []) Class names left out
 *
 * Return Value:
 * Objects <ARRAY>
 *
 * Example:
 * private _lights = [_generator, 300, ["Land_LampHalogen_F"]] call Root_fnc_getPowerGridObjects;
 *
 * Public: Yes
 */

params [["_gridObject", objNull, [objNull]], ["_radius", 0, [0]], ["_excludedClassnames", [], [[]]]];

if (isNull _gridObject) exitWith { [] };

private _objects = (9 allObjects 0) select { (_x distance _gridObject) <= _radius };
if (_excludedClassnames isNotEqualTo []) then {
    _objects = _objects select { !(typeOf _x in _excludedClassnames) };
};

_objects
