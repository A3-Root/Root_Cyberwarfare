params ["_logic"];
private _entity = attachedTo _logic;

if !(hasInterface) exitWith {};

private _execUserId = clientOwner;

if (isNil "ROOT_customLaptopNameIndex") then { ROOT_customLaptopNameIndex = 1 };
ROOT_customLaptopName = format ["HackingPlatform_%1", ROOT_customLaptopNameIndex];

[
    "Hacking Tools Settings", [
	["EDIT", ["Tool Path", "Path for the Hacking Tool. Do not add trailing '/'. Always end with a letter. No special characters or spaces. Example: /rubberducky/tools"], ["/rubberducky/tools"]],
	["EDIT", ["Laptop Name", "Custom Name to be given to the laptop for easier management of devices. Only visible to curators when linking devices to specific laptops."], [ROOT_customLaptopName]]
	], {
		params ["_results", "_entity"];
		_results params ["_path", "_customName"];
		[_entity, _path, _execUserId, _customName] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
		ROOT_customLaptopNameIndex = ROOT_customLaptopNameIndex + 1;
		["Hacking Tool Added to the Device!"] call zen_common_fnc_showMessage;
	}, {
		["Aborted"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	}, _entity
] call zen_dialog_fnc_create;

deleteVehicle _logic;
