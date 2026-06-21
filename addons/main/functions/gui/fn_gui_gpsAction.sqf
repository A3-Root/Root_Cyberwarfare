#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side GPS tracker action for the GUI GPS app. "track" marks the tracker as
 * tracked so its location is revealed on the map (the GUI's [Map] link); the position keeps
 * updating to the tracker's last pinged location. Runs on the server. (GPS #1/#2)
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the operator (reply target)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _gpsId <NUMBER> - Tracker id from the registry
 * 3: _action <STRING> - "track"
 * 4: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_gpsId", "_action", ["_commandPath", ""]];

private _computer = objectFromNetId _computerNetId;
private _reply = {
	params ["_owner", "_msg", "_ok"];
	["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_GPS_TRACKER, _msg, _ok], _owner] call CBA_fnc_ownerEvent;
};

if (isNull _computer) exitWith {};

if !([_computer, DEVICE_TYPE_GPS_TRACKER, _gpsId, _commandPath] call FUNC(isDeviceAccessible)) exitWith
{
	[_owner, format ["Access denied to tracker %1", _gpsId], false] call _reply;
};

private _trackers = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [DEVICE_TYPE_GPS_TRACKER, []];
private _idx = _trackers findIf { (_x select 0) == _gpsId };
if (_idx == -1) exitWith { [_owner, format ["Access denied to tracker %1", _gpsId], false] call _reply; };

private _tracker = objectFromNetId ((_trackers select _idx) select 1);
if (isNull _tracker) exitWith { [_owner, format ["Access denied to tracker %1", _gpsId], false] call _reply; };

_tracker setVariable ["ROOT_CYBERWARFARE_GPS_TRACKED", true, true];

["root_cyberwarfare_deviceStateChanged", [DEVICE_TYPE_GPS_TRACKER, _gpsId, "track"]] call CBA_fnc_serverEvent;
[_owner, "Tracking active - location revealed on the map.", true] call _reply;
