#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the identifier (code) a device answers to in terminal commands. Works for every
 *              device type including GPS trackers. Server only, since codes are never broadcast.
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - DEVICE_TYPE_* constant (1 door, 2 light, 3 drone, 4 file, 5 custom,
 *                           6 GPS tracker, 7 vehicle, 8 power grid)
 * 1: _deviceId <NUMBER> - Registered device id
 *
 * Return Value:
 * <STRING> - Identifier, or "" if the device has none
 *
 * Example:
 * private _code = [1, 1004] call Root_fnc_getDeviceIdentifier;
 *
 * Public: Yes
 */

if (!isServer) exitWith {""};

params [["_deviceType", 0, [0]], ["_deviceId", 0, [0]]];

if (_deviceType == DEVICE_TYPE_GPS_TRACKER) exitWith {
    private _code = "";
    {
        if ((_y select 0) == _deviceId) exitWith { _code = _x; };
    } forEach GET_GPS_IDENTIFIERS;
    _code
};

GET_DEVICE_IDENTIFIER_INDEX getOrDefault [format ["%1:%2", _deviceType, _deviceId], ""]
