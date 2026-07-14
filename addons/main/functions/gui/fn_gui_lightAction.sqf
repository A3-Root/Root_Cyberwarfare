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
 * 3: _state <STRING> - "on", "off", "allon" or "alloff"
 * 4: _commandPath <STRING> - Backdoor command path
 * 5: _ids <ARRAY> - (Optional, default: []) Light ids the app had on screen when a whole-app action was
 *                   pressed; [] means every light the laptop can reach
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_lightId", "_state", ["_commandPath", ""], ["_ids", [], [[]]]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_LIGHT, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};

// All On / All Off: switch every light the operator is looking at. The app sends the ids its filter has
// left on screen, so a filtered list switches only what it shows; an unfiltered one sends every row and
// the action reaches the whole network. An empty list is the app asking for everything the laptop can
// reach, which is what a caller without a filter to speak of means.
if (_state in ["allon", "alloff"]) exitWith {
	private _want = _state isEqualTo "allon";
	private _lights = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [1, []];
	// Ids arrive from the browser and may come across as text.
	private _wanted = _ids apply {if (_x isEqualType "") then {parseNumber _x} else {_x}};
	private _n = 0;
	private _total = 0;
	{
		_x params ["_lid", "_lnetId"];
		if ((_wanted isEqualTo [] || {_lid in _wanted}) && {[_computer, DEVICE_TYPE_LIGHT, _lid, _commandPath] call FUNC(isDeviceAccessible)}) then {
			_total = _total + 1;
			private _light = objectFromNetId _lnetId;
			if (!isNull _light) then {
				[_light, [toUpper "off", toUpper "on"] select _want] remoteExec ["switchLight", 0, format ["rcw_light_%1", netId _light]];
				_light setVariable ["ROOT_CYBERWARFARE_LIGHT_ON", _want, true];
				["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_LIGHT, _lid, ["off", "on"] select _want]] call CBA_fnc_serverEvent;
				_n = _n + 1;
			};
		};
	} forEach _lights;
	[_owner, format ["%1 of %2 lights switched %3", _n, _total, ["off", "on"] select _want], true] call _reply;
};

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
_light setVariable ["ROOT_CYBERWARFARE_LIGHT_ON", (_state isEqualTo "on"), true]; // for GUI status (#3)

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_LIGHT, _lightId, _state]] call CBA_fnc_serverEvent;

private _msg = [localize "STR_ROOT_CYBERWARFARE_LIGHT_TURNED_OFF", localize "STR_ROOT_CYBERWARFARE_LIGHT_TURNED_ON"] select (_state isEqualTo "on");
[_owner, _msg, true] call _reply;
