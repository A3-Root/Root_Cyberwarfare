#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Extract all unique objects within synchronized trigger areas.
 * Supports both rectangular and elliptical triggers with rotation.
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

if (_triggers isEqualTo []) exitWith { [] };

private _allObjects = createHashMap;

{
    private _trigger = _x;
    private _pos = getPosATL _trigger;
    private _sizeX = triggerArea _trigger select 0;
    private _sizeY = triggerArea _trigger select 1;
    private _angle = triggerArea _trigger select 2;
    private _isRectangle = triggerArea _trigger select 3;

    private _objectsInTrigger = [];
    private _entitiesInTrigger = [];

    if (_isRectangle) then {
        // Rectangular/Elliptical trigger - use precise boundary checking
        _objectsInTrigger = nearestObjects [_pos, [], (_sizeX max _sizeY)];
        {
            if (_x inArea [_pos, _sizeX, _sizeY, _angle, _isRectangle]) then {
                _allObjects set [str _x, _x];
            };
        } forEach _objectsInTrigger;

        _entitiesInTrigger = _pos nearEntities (_sizeX max _sizeY);
        {
            if (_x inArea [_pos, _sizeX, _sizeY, _angle, _isRectangle]) then {
                _allObjects set [str _x, _x];
            };
        } forEach _entitiesInTrigger;
    } else {
        // Circular trigger - use radius-based collection
        _objectsInTrigger = nearestObjects [_pos, [], _sizeX];
        { _allObjects set [str _x, _x]; } forEach _objectsInTrigger;

        _entitiesInTrigger = _pos nearEntities (_sizeX max _sizeY);
        { _allObjects set [str _x, _x]; } forEach _entitiesInTrigger;
    };
} forEach _triggers;

// Return unique objects array
values _allObjects
