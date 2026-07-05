#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side handler for the GUI device-list request. Resolves the accessible devices
 * of the requested type for the computer and returns the lightweight registry entries to the
 * requesting client only (no global broadcast). Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the requesting client (target for the reply)
 * 1: _computerNetId <STRING> - netId of the laptop
 * 2: _deviceType <NUMBER> - DEVICE_TYPE_* constant
 * 3: _commandPath <STRING> - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", "_computerNetId", "_deviceType", ["_commandPath", ""]];

private _computer = objectFromNetId _computerNetId;
if (isNull _computer) exitWith {};

// The Network Scanner is not a hackable-device list: it enumerates AE3 laptops/routers on the same
// subnet, so it bypasses the device registry and builds its rows from the AE3 network model instead.
private _list = if (_deviceType == DEVICE_TYPE_NETSCAN) then {
    [_computer] call FUNC(scanNetwork)
} else {
    [_computer, _deviceType, _commandPath] call FUNC(getAccessibleDevices)
};

// Registry entries are already lightweight (ids + netIds). Reply to the requesting client only.
["root_cyberwarfare_gui_devList", [_deviceType, _list, _computerNetId], _owner] call CBA_fnc_ownerEvent;
