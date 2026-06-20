#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Client-side helper that asks the server for the list of devices of a given type that
 * the given computer can access. The server replies (to this client only) with event
 * "root_cyberwarfare_gui_devList". Used by the RootCW desktop GUI apps so clients never read the
 * server-authoritative device registry directly.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop the operator is using
 * 1: _deviceType <NUMBER> - DEVICE_TYPE_* constant
 * 2: _commandPath <STRING> (Optional, default: "") - Backdoor command path
 *
 * Return Value:
 * None
 *
 * Example:
 * [_laptop, DEVICE_TYPE_DOOR] call Root_fnc_gui_requestDevices;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]], ["_deviceType", 0, [0]], ["_commandPath", "", [""]]];
if (isNull _computer) exitWith {};

["root_cyberwarfare_gui_reqDevices", [clientOwner, netId _computer, _deviceType, _commandPath]] call CBA_fnc_serverEvent;
