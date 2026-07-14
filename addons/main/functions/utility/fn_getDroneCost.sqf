#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Answers what a drone operation costs on a given drone. A drone registered with a cost of
 *              its own is worth what the mission maker said it is worth, and every other drone is worth
 *              what the mission's setting says. This is the one place the answer is worked out, so the
 *              terminal, the desktop and the confirmation prompt cannot quote a figure that differs from
 *              the one that is actually charged.
 *
 * Arguments:
 * 0: _drone <OBJECT> - The drone
 * 1: _operation <STRING> - "disable" or "side"
 *
 * Return Value:
 * Cost <NUMBER> - Energy in Wh for one operation on this drone
 *
 * Example:
 * private _cost = [_drone, "disable"] call Root_fnc_getDroneCost;
 *
 * Public: No
 */

params [["_drone", objNull, [objNull]], ["_operation", "disable", [""]]];

private _isDisable = _operation isEqualTo "disable";

private _setting = [SETTING_DRONE_SIDE_COST, SETTING_DRONE_HACK_COST] select _isDisable;
private _default = [20, 10] select _isDisable;
private _override = ["ROOT_CYBERWARFARE_DRONE_SIDE_COST", "ROOT_CYBERWARFARE_DRONE_DISABLE_COST"] select _isDisable;

private _cost = missionNamespace getVariable [_setting, _default];

// A cost of zero on the drone is the mission maker saying nothing about it, which leaves the setting to
// answer; anything above zero is theirs and stands whatever the setting is changed to.
if (!isNull _drone) then {
    private _perDrone = _drone getVariable [_override, 0];
    if (_perDrone isEqualType 0 && {_perDrone > 0}) then { _cost = _perDrone; };
};

_cost
