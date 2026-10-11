#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ZEN module placed on a registered device (door building, light, drone, vehicle, file
 *              holder, custom device or power generator) that sets the identifier it answers to in
 *              terminal commands and whether that code grants access by itself.
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

private _targetObject = attachedObject _logic;
deleteVehicle _logic;

if !(hasInterface) exitWith {};

if (isNull _targetObject) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_PLACE_ON_DEVICE"] call zen_common_fnc_showMessage;
};

[
    localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_MODULE",
    [
        ["EDIT", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_CODE", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_CODE_DESC"], [""]],
        ["CHECKBOX", [localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_GRANTS", localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_GRANTS_DESC"], true]
    ],
    {
        params ["_results", "_targetObject"];
        _results params ["_identifier", "_grantsAccess"];
        [_targetObject, 0, _identifier, _grantsAccess, clientOwner] remoteExec ["Root_fnc_setDeviceIdentifier", 2];
    },
    {},
    _targetObject
] call zen_dialog_fnc_create;
