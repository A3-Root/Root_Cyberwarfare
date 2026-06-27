#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side database download for the GUI Databases app. Writes the database file to
 * the laptop filesystem and runs any execution code, mirroring Root_fnc_downloadDatabase without the
 * terminal progress bar. Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (reply target)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _databaseId <NUMBER> - Database id from the registry
 * 3: _playerNetId <STRING> - netId of the operating player (for execution code)
 * 4: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_databaseId", "_playerNetId", ["_commandPath", ""], ["_savePath", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok", ["_path", ""]];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_DATABASE, _msg, _ok, _path], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};

if !([_computer, DEVICE_TYPE_DATABASE, _databaseId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_NO_ACCESSIBLE_DATABASES", false] call _reply;
};

private _databases = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [3, []];
private _idx = _databases findIf { (_x select 0) == _databaseId };
if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DATABASE", _databaseId], false] call _reply; };

private _database = objectFromNetId ((_databases select _idx) select 1);
if (isNull _database) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_DATABASE", _databaseId], false] call _reply; };

private _databaseName = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", "database"];
private _databaseContent = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_DATA_EDIT", ""];
private _executionCode = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_EXECUTIONCODE", ""];

private _fileName = (_databaseName splitString " ") joinString "_";
if (_savePath isEqualTo "") then { _savePath = format ["/root/%1.txt", _fileName]; };
if ((_savePath select [(count _savePath) - 1, 1]) isEqualTo "/") then {
	_savePath = _savePath + format ["%1.txt", _fileName];
};
private _pathParts = _savePath splitString "/";
private _leafName = _pathParts param [(count _pathParts) - 1, ""];
if ((_leafName find ".") == -1) then {
	_savePath = _savePath + ".txt";
};

[_computer, _savePath, _databaseContent, false, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExecCall ["AE3_filesystem_fnc_device_addFile", 2];

if (_executionCode != "") then { [_computer, objectFromNetId _playerNetId, _owner] spawn (compile _executionCode); };

// Report the exact path so the GUI can open it (caesar-1 encrypted - read via the Crypto app, key 1).
private _msg = (format [localize "STR_ROOT_CYBERWARFARE_GUI_DOWNLOADED", _databaseName]) + format [" -> %1 (caesar key 1)", _savePath];
[_owner, _msg, true, _savePath] call _reply;
