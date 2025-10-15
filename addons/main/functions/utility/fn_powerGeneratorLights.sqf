/*
 * Author: Root
 * Description: Global remoteExec lightstate of objects
 *
 * Arguments:
 * 0: _lightState <STRING> - Light state ("on" or "off")
 * 1: _objects <ARRAY> - Array of objects to change light state
 *
 * Return Value:
 * None
 *
 * Example:
 * ["on", _objects] remoteExec ["Root_fnc_powerGeneratorLights", 0, true];
 *
 * Public: No
 */

#include "\z\root_cyberwarfare\addons\main\script_component.hpp"

params [
    ["_lightState", "on"],
    ["_objects", []]
];

if !(_lightState in ["on", "off", "ON", "OFF"]) exitWith {
    private _string = format ["powerGeneratorLights: Invalid light state '%1'", _lightState];
    LOG_ERROR(_string);
};

{
    _x switchLight _lightState;
} forEach _objects;

private _string = format ["powerGeneratorLights: Set light state to '%1' on %2 objects", _lightState, count _objects];
LOG_INFO(_string);
