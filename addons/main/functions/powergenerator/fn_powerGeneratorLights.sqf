#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Change lightstate of objects
 *
 * Arguments:
 * 0: _lightState <STRING> - Light state ("on" or "off")
 * 1: _objects <ARRAY> - Array of objects to change light state
 *
 * Return Value:
 * None
 *
 * Example:
 * ["ON", _objects] remoteExec ["Root_fnc_powerGeneratorLights", 0, true];
 *
 * Public: No
 */

params [
    ["_lightState", "ON"],
    ["_objects", []]
];

if !(_lightState in ["on", "off", "ON", "OFF"]) exitWith {
    private _string = format ["powerGeneratorLights: Invalid light state '%1'", _lightState];
    ROOT_CYBERWARFARE_LOG_ERROR(_string);
};

if (_lightState in ["on", "ON"]) then {
    {
        _x switchLight "ON";
    } forEach _objects;
} else {
    {
        _x switchLight "OFF";
    } forEach _objects;
};



private _string = format ["powerGeneratorLights: Set light state to '%1' on %2 objects", _lightState, count _objects];
ROOT_CYBERWARFARE_LOG_INFO(_string);
