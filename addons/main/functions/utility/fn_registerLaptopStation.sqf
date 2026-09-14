#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Records a laptop in the mission-wide roster of hacking stations, alongside the networked
 *              flag the laptop itself carries. The roster exists because the curator dialogs have to be
 *              able to list a station without finding it first: an object scan depends on the laptop
 *              sitting in the collection the scan asks for, and a laptop that a script moved into a
 *              container, or that has not finished initializing, can be absent from every one of them.
 *              The array is broadcast and JIP-persistent, so a client that joins later sees the same
 *              roster. Entries whose object no longer exists are dropped as the roster is written, which
 *              keeps a deleted laptop out of the dialogs without a separate cleanup pass.
 *
 * Arguments:
 * 0: _laptop <OBJECT> - Laptop to record as a hacking station
 *
 * Return Value:
 * None
 *
 * Example:
 * [_laptop] call Root_fnc_registerLaptopStation;
 *
 * Public: No
 */

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {};

private _registry = missionNamespace getVariable [GVAR_LAPTOP_REGISTRY, []];
_registry = _registry select {!isNull _x};

if (_laptop in _registry) exitWith {};

_registry pushBack _laptop;
missionNamespace setVariable [GVAR_LAPTOP_REGISTRY, _registry, true];

DEBUG_LOG_1("Laptop registered as a station, roster size: %1",count _registry);
