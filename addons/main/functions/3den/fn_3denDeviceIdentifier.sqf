#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: 3DEN Editor module that sets the identifier synchronized devices answer to in terminal
 *              commands, and whether the code grants access by itself. Synchronize it to objects that
 *              another module registers as devices (building, light, vehicle, file holder, custom
 *              device, power generator). The requested code goes to the first object; any further
 *              object receives a random code with the same access rule.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denDeviceIdentifier;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

private _identifier = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_IDENTIFIER_CODE", ""];
// 3DEN BOOL attributes load as numbers (1/0); coerce to a real boolean.
private _grantsAccess = (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_IDENTIFIER_GRANTS", 1]) in [1, true];
private _objects = synchronizedObjects _logic select { !(_x isKindOf "Logic") };

if (_objects isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("3DEN Device Identifier: no objects synchronized to this module!");
};

{
    // setDeviceIdentifier waits for the object to be registered by its add module.
    [_x, 0, [_identifier, ""] select (_forEachIndex > 0), _grantsAccess] call FUNC(setDeviceIdentifier);
} forEach _objects;
