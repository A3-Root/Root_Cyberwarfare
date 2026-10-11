#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Lists the registrations an object has in the device registry (a building with doors,
 *              a lamp, a vehicle, a file holder, ...).
 *
 * Arguments:
 * 0: _object <OBJECT> - Registered object
 *
 * Return Value:
 * <ARRAY> - [[deviceType, deviceId], ...]
 *
 * Example:
 * private _registrations = [cursorObject] call Root_fnc_findDevicesByObject;
 *
 * Public: Yes
 */

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {[]};

private _netId = netId _object;
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _result = [];

{
    private _deviceType = _forEachIndex + 1;
    {
        if ((_x param [1, ""]) isEqualTo _netId) then {
            _result pushBack [_deviceType, _x select 0];
        };
    } forEach _x;
} forEach _allDevices;

_result
