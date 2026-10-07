#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Zeus module to add hacking tools to a computer/laptop via ZEN dialog
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addHackingToolsZeus;
 *
 * Public: No
 */

params ["_logic"];
private _entity = attachedTo _logic;

if !(hasInterface) exitWith {};

private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", 1];
ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME = format ["HackTool_%1", _index];

[
    (localize "STR_ROOT_CYBERWARFARE_UI_HACKING_TOOLS_SETTINGS"), [
	["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_TOOL_PATH"), (localize "STR_ROOT_CYBERWARFARE_UI_PATH_FOR_THE_HACKING_TOOL_DO_NOT_ADD_TRAILING_ALWAYS_END_WITH")], ["/rubberducky/tools"]],
	["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_LAPTOP_NAME"), (localize "STR_ROOT_CYBERWARFARE_UI_CUSTOM_NAME_USED_BY_CURATOR_DEVICE_LINKING_TOOLS")], [ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME]],
    ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_DEFAULT_CREDENTIALS"), (localize "STR_ROOT_CYBERWARFARE_UI_ADDS_THE_CONFIGURED_RUBBERDUCKY_LOGIN_ACCOUNT_TO_THE_TARGET_LAPTOP")], true]
	], {
		params ["_results", "_args"];
		_args params ["_entity", "_index"];
		_results params ["_path", "_customName", "_addCredentials"];
		private _execUserId = owner _entity;
		[_entity, _path, _execUserId, _customName, "", false, _addCredentials] remoteExec [QFUNC(addHackingToolsZeusMain), 2];
		_index = _index + 1;
		missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _index, true];
		[localize "STR_ROOT_CYBERWARFARE_ZEUS_HACKING_TOOLS_SUCCESS"] call zen_common_fnc_showMessage;
	}, {
		[localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	},
	[_entity, _index]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
