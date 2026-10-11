#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Looks up the device a code belongs to. Server only (codes are never broadcast).
 *
 * Arguments:
 * 0: _identifier <STRING> - Code as typed (case-insensitive)
 * 1: _deviceType <NUMBER> (Optional) - Only accept a device of this type, -1 = any, default: -1
 *
 * Return Value:
 * <ARRAY> - [deviceType, deviceId, grantsAccess], or [] if unknown
 *
 * Example:
 * ([_code, DEVICE_TYPE_DOOR] call Root_fnc_resolveDeviceIdentifier) params ["_type", "_id", "_grants"];
 *
 * Public: No
 */

if (!isServer) exitWith {[]};

params [["_identifier", "", [""]], ["_deviceType", -1, [0]]];

private _normalized = toUpperANSI ([_identifier] call CBA_fnc_trim);
if (_normalized isEqualTo "") exitWith {[]};

private _entry = GET_DEVICE_IDENTIFIERS getOrDefault [_normalized, []];
if (_entry isEqualTo []) exitWith {[]};
if (_deviceType != -1 && {(_entry select 0) != _deviceType}) exitWith {[]};

+_entry
