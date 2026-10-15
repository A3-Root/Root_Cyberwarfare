#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ZEN module that reads and rewrites the identifier a registered device answers to. What
 *              it shows depends on where it is dropped, because a curator wanting to look codes up
 *              and a curator wanting to change one are doing different jobs: on open ground it lists
 *              every registered device with its grid and its code, and on a device it offers that
 *              device's current code, a new one to replace it with, and whether everyone who has
 *              already used the old code should lose the device again. The codes live on the server,
 *              so this asks for them rather than reading them; Root_fnc_showIdentifierZeus opens the
 *              dialog when the answer arrives.
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
