#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side custom device activate/deactivate for the GUI Custom app. Mirrors the core
 * of Root_fnc_customDevice without terminal I/O. Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (reply target)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _customId <NUMBER> - Custom device id from the registry
 * 3: _state <STRING> - "activate" / "deactivate"
 * 4: _playerNetId <STRING> - netId of the operating player (passed to the device code)
 * 5: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_customId", "_state", "_playerNetId", ["_commandPath", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_CUSTOM, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};
_state = toLower _state;
if !(_state in ["activate", "deactivate"]) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_INVALID_CUSTOM_DEVICE_STATE", _state], false] call _reply; };

if !([_computer, DEVICE_TYPE_CUSTOM, _customId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_CUSTOM_DEVICE_NOT_FOUND", _customId], false] call _reply;
};

private _custom = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [4, []];
private _idx = _custom findIf { (_x select 0) == _customId };
if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_CUSTOM_DEVICE_NOT_FOUND", _customId], false] call _reply; };

(_custom select _idx) params ["", "_deviceNetId", "_customName", "_activationCode", "_deactivationCode"];

private _cost = missionNamespace getVariable [SETTING_CUSTOM_COST, 5];
if !([_computer, _cost] call FUNC(checkPowerAvailable)) exitWith { [_owner, localize "STR_ROOT_CYBERWARFARE_ERROR_INSUFFICIENT_POWER", false] call _reply; };
[_computer, _cost] call FUNC(consumePower);

private _code = [_deactivationCode, _activationCode] select (_state isEqualTo "activate");
if (_code isEqualType "" && {_code != ""}) then {
	["root_cyberwarfare_gui_customExec", [_computerNetId, _deviceNetId, _playerNetId, _owner, _code], _owner] call CBA_fnc_ownerEvent;
};

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_CUSTOM, _customId, _state]] call CBA_fnc_serverEvent;

private _msg = format [localize ([
	"STR_ROOT_CYBERWARFARE_CUSTOM_DEVICE_DEACTIVATED",
	"STR_ROOT_CYBERWARFARE_CUSTOM_DEVICE_ACTIVATED"
] select (_state isEqualTo "activate")), _customName, _customId];
[_owner, _msg, true] call _reply;
