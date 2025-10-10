params ["_logic"];
private _entity = attachedTo _logic;

if !(hasInterface) exitWith {};

private _execUserId = clientOwner;

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
		[_entity, _path, _execUserId, _customName] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
		_index = _index + 1;
		missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _index, true];
		["Hacking Tool Added to the Device!"] call zen_common_fnc_showMessage;
	}, {
		["Aborted"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	}, 
	[_entity, _index]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
