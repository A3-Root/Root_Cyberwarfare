#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ZEN module for device identifiers. Dropped on open ground it lists every registered
 *              device with its grid and code; dropped on a device it sets that device's code and can
 *              revoke the access the old one granted. The codes are server-side, so this requests
 *              them and Root_fnc_showIdentifierZeus opens the dialog on the answer.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_deviceIdentifierZeus;
 *
 * Public: No
 */

params ["_logic"];

private _targetObject = attachedTo _logic;
deleteVehicle _logic;

if !(hasInterface) exitWith {};

["root_cyberwarfare_identifierOverviewReq", [clientOwner, [netId _targetObject, ""] select (isNull _targetObject)]] call CBA_fnc_serverEvent;
