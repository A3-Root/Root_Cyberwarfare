#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Gives a registered device the 8-character identifier it answers to in terminal
 *              commands (in place of its numeric id). A device that already has one keeps it unless a
 *              different code is requested. GPS trackers use their own identifier registry and are
 *              ignored here. Server only.
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - DEVICE_TYPE_* constant
 * 1: _deviceId <NUMBER> - Registered device id
 * 2: _requestedIdentifier <STRING> (Optional) - Wanted code; blank or taken = random, default: ""
 * 3: _grantsAccess <BOOL> (Optional) - Knowing the code grants access without a link, default: true
 *
 * Return Value:
 * <STRING> - Identifier now assigned, or ""
 *
 * Example:
 * private _code = [DEVICE_TYPE_DOOR, 1004, "VAULTDR1", true] call Root_fnc_registerDeviceIdentifier;
 *
 * Public: No
 */

if (!isServer) exitWith {""};

params [
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]],
    ["_requestedIdentifier", "", [""]],
    ["_grantsAccess", true, [true]]
];

if (_deviceType == DEVICE_TYPE_GPS_TRACKER || {!VALIDATE_DEVICE_TYPE(_deviceType)}) exitWith {""};

private _identifiers = GET_DEVICE_IDENTIFIERS;
private _index = GET_DEVICE_IDENTIFIER_INDEX;
private _key = format ["%1:%2", _deviceType, _deviceId];
private _current = _index getOrDefault [_key, ""];
private _requested = toUpperANSI ([_requestedIdentifier] call CBA_fnc_trim);

// Keep the current code when nothing different was asked for; only refresh whether it grants access.
if (_current isNotEqualTo "" && {_requested isEqualTo "" || _requested isEqualTo _current}) exitWith {
    _identifiers set [_current, [_deviceType, _deviceId, _grantsAccess]];
    _current
};

private _identifier = _requested;
if (_identifier isEqualTo "" || {_identifier in _identifiers} || {_identifier in GET_GPS_IDENTIFIERS}) then {
    if (_identifier isNotEqualTo "") then {
        ROOT_CYBERWARFARE_LOG_INFO_1(format ["registerDeviceIdentifier: identifier %1 is already in use, drawing a fresh one",_identifier]);
    };
    _identifier = call FUNC(generateGpsIdentifier);
};

if (_identifier isEqualTo "") exitWith {""};

if (_current isNotEqualTo "") then { _identifiers deleteAt _current; };
_identifiers set [_identifier, [_deviceType, _deviceId, _grantsAccess]];
_index set [_key, _identifier];
missionNamespace setVariable [GVAR_DEVICE_IDENTIFIERS, _identifiers];
missionNamespace setVariable [GVAR_DEVICE_IDENTIFIER_INDEX, _index];

ROOT_CYBERWARFARE_LOG_INFO_3(format ["Device type %1 id %2 answers to identifier %3",_deviceType,_deviceId,_identifier]);

_identifier
