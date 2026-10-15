#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Handles the "by identifier" action of a desktop app: resolves the code, then sends the
 *              app's device list again with the device it names in it. Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _deviceType <NUMBER> - DEVICE_TYPE_* constant of the app that asked
 * 3: _identifier <STRING> - Code as typed
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_owner", 0, [0]], ["_computerNetId", "", [""]], ["_deviceType", 0, [0]], ["_identifier", "", [""]]];

private _computer = objectFromNetId _computerNetId;

if (isNull _computer) exitWith {};

if (([_owner, _computer, _deviceType, _identifier] call Root_fnc_gui_resolveIdentifier) isEqualTo []) exitWith {};

["root_cyberwarfare_gui_actionResult", [_deviceType, format [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_ADDED", toUpperANSI _identifier], true], _owner] call CBA_fnc_ownerEvent;

[_owner, _computerNetId, _deviceType] call Root_fnc_gui_sendDeviceList;
