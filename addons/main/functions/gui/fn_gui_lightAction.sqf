#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side light on/off for the GUI Lights app. Switches an accessible light,
 * mirroring the core behaviour of Root_fnc_changeLightState without the terminal I/O. Runs on the
 * server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (for the result reply)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _lightId <NUMBER> - Light id from the device registry
 * 3: _state <STRING> - "on" or "off"
 * 4: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_lightId", "_state", ["_commandPath", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_LIGHT, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};
if !(_state in ["on", "off"]) exitWith {};

if !([_computer, DEVICE_TYPE_LIGHT, _lightId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_LIGHT", _lightId], false] call _reply;
};

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _lights = _allDevices param [1, []];
private _idx = _lights findIf { (_x select 0) == _lightId };
if (_idx == -1) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_LIGHT", _lightId], false] call _reply; };

private _light = objectFromNetId ((_lights select _idx) select 1);
if (isNull _light) exitWith { [_owner, format [localize "STR_ROOT_CYBERWARFARE_ERROR_ACCESS_DENIED_LIGHT", _lightId], false] call _reply; };

private _target = toUpper _state; // "ON" / "OFF"
[_light, _target] remoteExec ["switchLight", 0, format ["rcw_light_%1", netId _light]];

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_LIGHT, _lightId, _state]] call CBA_fnc_serverEvent;

private _msg = [localize "STR_ROOT_CYBERWARFARE_LIGHT_TURNED_OFF", localize "STR_ROOT_CYBERWARFARE_LIGHT_TURNED_ON"] select (_state isEqualTo "on");
[_owner, _msg, true] call _reply;
