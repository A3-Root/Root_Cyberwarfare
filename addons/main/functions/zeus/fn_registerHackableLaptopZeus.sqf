#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Zeus module to register a laptop as a hackable station via a ZEN dialog. Only assigns
 *              the station role and a link-dialog name; it does not install the hacking toolset.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_registerHackableLaptopZeus;
 *
 * Public: No
 */

params ["_logic"];
private _entity = attachedTo _logic;

if !(hasInterface) exitWith {};

if (isNull _entity) exitWith {
    deleteVehicle _logic;
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_INVALID_TARGET"] call zen_common_fnc_showMessage;
};

private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", 1];
ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME = format ["HackTool_%1", _index];

[
    (localize "STR_ROOT_CYBERWARFARE_UI_REGISTER_HACKABLE_LAPTOP"), [
        ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_LAPTOP_NAME"), (localize "STR_ROOT_CYBERWARFARE_UI_CUSTOM_NAME_GIVEN_TO_THE_LAPTOP_FOR_EASIER_MANAGEMENT_OF_DEVICES_ONLY")], [ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME]],
        ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_DEFAULT_CREDENTIALS"), (localize "STR_ROOT_CYBERWARFARE_UI_ADDS_THE_CONFIGURED_RUBBERDUCKY_LOGIN_ACCOUNT_TO_THE_TARGET_LAPTOP")], true]
    ], {
        params ["_results", "_args"];
        _args params ["_entity", "_index"];
        _results params ["_customName", "_addCredentials"];
        private _execUserId = owner _entity;
        [_entity, _execUserId, _customName, _addCredentials] remoteExec [QFUNC(registerHackableLaptopZeusMain), 2];
        _index = _index + 1;
        missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _index, true];
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_REGISTER_LAPTOP_SUCCESS"] call zen_common_fnc_showMessage;
    }, {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_entity, _index]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
