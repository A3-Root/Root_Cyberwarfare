#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the computer whose battery pays for operating one device. The computer the
 *              device is linked to is the one that pays, so a remote laptop reached through a session
 *              funds the work done on its own devices while the operator funds work on theirs. When
 *              both ends can reach the device the operator pays, and when neither owns a route - a
 *              backdoor path or a device identifier got the operator in - the operator pays as well.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Executing computer
 * 1: _deviceType <NUMBER> (Optional) - Device type (1-8), 0 for a cost that belongs to no device
 * 2: _deviceId <NUMBER> (Optional) - Device ID
 *
 * Return Value:
 * <OBJECT> - Computer to draw power from
 *
 * Example:
 * private _payer = [_computer, DEVICE_TYPE_DOOR, 1234] call Root_fnc_getDevicePowerComputer;
 *
 * Public: No
 */

params [
    ["_computer", objNull, [objNull]],
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]]
];

private _operator = [_computer] call FUNC(getPowerComputer);

if (isNull _operator) exitWith { _operator };

// A cost that is not about a particular device belongs to the operator
if !(VALIDATE_DEVICE_TYPE(_deviceType)) exitWith { _operator };

// The operator's own route wins, which also covers a device linked to both ends
if ([_operator, _deviceType, _deviceId] call FUNC(hasDeviceLink)) exitWith { _operator };

private _others = ([_computer] call FUNC(getSessionComputers)) select {_x isNotEqualTo _operator};
private _index = _others findIf {[_x, _deviceType, _deviceId] call FUNC(hasDeviceLink)};

if (_index < 0) exitWith { _operator };

_others select _index
