#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Candidate objects of a 3DEN Add module: synced objects and/or objects in the module area,
 * plus objects in synced trigger areas. Laptops, logics and triggers are left out. Server.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic
 * 1: _registerMode <NUMBER> - 0 synced objects, 1 module area, 2 both
 * 2: _laptops <ARRAY> - Synced laptops to leave out
 *
 * Return Value:
 * [synced objects, objects in module and trigger areas] <ARRAY>
 *
 * Example:
 * ([_logic, 1, _laptops] call Root_fnc_getModuleObjects) params ["_synced", "_inArea"];
 *
 * Public: No
 */

params [["_logic", objNull, [objNull]], ["_registerMode", 1, [0]], ["_laptops", [], [[]]]];

// Modules saved without an area register synced objects only
if (isNil {_logic getVariable "objectArea"}) then { _registerMode = 0; };

private _synced = synchronizedObjects _logic;
private _triggers = _synced select { _x isKindOf "EmptyDetector" };

private _keep = { !(_x in _laptops) && {!(_x isKindOf "Logic")} && {!(_x isKindOf "EmptyDetector")} };

private _direct = [];
if (_registerMode in [0, 2]) then {
    _direct = _synced select _keep;
};

private _inArea = [_triggers] call FUNC(getObjectsInTriggerArea);
if (_registerMode in [1, 2]) then {
    _inArea append ([[[_logic] call FUNC(logicArea)]] call FUNC(getObjectsInArea));
};
_inArea = (_inArea arrayIntersect _inArea) select _keep;

[_direct, _inArea - _direct]
