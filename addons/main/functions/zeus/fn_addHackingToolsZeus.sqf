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
ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME = format ["HackingPlatform_%1", _index];

[
    "Hacking Tools Settings", [
	["EDIT", ["Tool Path", "Path for the Hacking Tool. Do not add trailing '/'. Always end with a letter. No special characters or spaces except '/' and '_'. Example: /rubberducky/tools"], ["/rubberducky/tools"]],
	["EDIT", ["Laptop Name", "Custom Name to be given to the laptop for easier management of devices. Only visible to curators when linking devices to specific laptops."], [ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME]]
	], {
		params ["_results", "_args"];
		_args params ["_entity", "_index"];
		_results params ["_path", "_customName"];
		private _execUserId = owner _entity;
		[_entity, _path, _execUserId, _customName] remoteExec [QFUNC(addHackingToolsZeusMain), 2];
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
