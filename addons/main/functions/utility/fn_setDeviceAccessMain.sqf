#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function that rewrites one registered device's reachability to exactly the
 *              state described by its arguments. Where fn_setDeviceLinksMain applies one action to a
 *              set of computers and leaves everything else alone, this replaces the whole picture for a
 *              single device: computers that are not listed lose their link, and any earlier public
 *              entry is dropped before the new one is written. That makes it the runtime counterpart to
 *              fn_applyDeviceAccess, which encodes the same three modes at registration time, and it
 *              round-trips that encoding - a device published with an exclusion list is the "linked
 *              plus future laptops" state, and is written back the same way.
 *              - ACCESS_MODE_UNASSIGNED: no public entry and no links, whatever was listed
 *              - ACCESS_MODE_LINKED: exactly the listed computers, optionally published with every
 *                other current laptop excluded so laptops created later gain access too
 *              - ACCESS_MODE_PUBLIC: published with no exclusions; the listed computers also keep a
 *                private link, so the device stays reachable for them if it is unpublished later
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - Device type constant (DEVICE_TYPE_*)
 * 1: _deviceId <NUMBER> - Registered device id
 * 2: _computerIds <ARRAY> - Computer netIds that should reach the device, may be empty
 * 3: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 * 4: _availableToFutureLaptops <BOOL> (Optional) - Extend linked access to later laptops, default: false
 * 5: _execUserId <NUMBER> (Optional) - Owner id to report the result to, 0 = no feedback, default: 0
 *
 * Return Value:
 * <BOOL> - true when the device was found and its access rewritten
 *
 * Example:
 * [DEVICE_TYPE_DOOR, 1042, [netId _laptop], ACCESS_MODE_LINKED, false, clientOwner] remoteExec ["Root_fnc_setDeviceAccessMain", 2];
 *
 * Public: Yes
 */

params [
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]],
    ["_computerIds", [], [[]]],
    ["_accessMode", ACCESS_MODE_UNASSIGNED, [0]],
    ["_availableToFutureLaptops", false, [false]],
    ["_execUserId", 0, [0]]
];

if (!isServer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("setDeviceAccessMain: Must run on the server");
    false
};

if !(VALIDATE_DEVICE_TYPE(_deviceType)) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR_1("setDeviceAccessMain: Invalid device type %1",_deviceType);
    false
};

if !(VALIDATE_ACCESS_MODE(_accessMode)) then {
    ROOT_CYBERWARFARE_LOG_ERROR_1("setDeviceAccessMain: Invalid access mode %1, falling back to unassigned",_accessMode);
    _accessMode = ACCESS_MODE_UNASSIGNED;
};

// A device id the registry does not hold would create links to something that cannot be reached, so a
// stale dialog left open while the device was deleted changes nothing.
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _devicesOfType = _allDevices param [_deviceType - 1, []];
if ((_devicesOfType findIf {(_x select 0) == _deviceId}) < 0) exitWith {
    DEBUG_LOG_2("setDeviceAccessMain: device %1/%2 is not registered",_deviceType,_deviceId);
    if (_execUserId > 0) then {
        [localize "STR_ROOT_CYBERWARFARE_LINKS_NO_DEVICES"] remoteExec ["systemChat", _execUserId];
    };
    false
};

// Callers name laptops by netId because that is what a curator dialog can carry. Resolve each to the
// identifier the link cache is keyed by, which is the netId in Simple mode and the operating player's
// UID in Experimental mode.
private _identifiers = [];
{
    private _computer = objectFromNetId _x;
    private _identifier = if (isNull _computer) then { _x } else { [_computer] call FUNC(getComputerIdentifier) };
    if (_identifier isNotEqualTo "") then {
        _identifiers pushBackUnique _identifier;
    };
} forEach _computerIds;

private _linkCache = GET_LINK_CACHE;
private _publicDevices = GET_PUBLIC_DEVICES;

// Unassigned grants nothing, so nothing is kept even when computers were listed.
if (_accessMode == ACCESS_MODE_UNASSIGNED) then {
    _identifiers = [];
};

// Start from a clean slate: drop the public entry and every link this device holds, then write back
// only what the requested state calls for. Doing it in that order is what makes the result exact
// rather than additive, and it is the only way a device can leave the public list.
private _publicIndex = _publicDevices findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}};
if (_publicIndex > -1) then {
    _publicDevices deleteAt _publicIndex;
};

{
    private _identifier = _x;
    if !(_identifier in _identifiers) then {
        private _links = _linkCache getOrDefault [_identifier, []];
        private _linkIndex = _links findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}};
        if (_linkIndex > -1) then {
            _links deleteAt _linkIndex;
            _linkCache set [_identifier, _links];
            ["root_cyberwarfare_deviceUnlinked", [_identifier, _deviceType, _deviceId]] call CBA_fnc_serverEvent;
        };
    };
} forEach (keys _linkCache);

missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache];
missionNamespace setVariable [GVAR_PUBLIC_DEVICES, _publicDevices];

if (_identifiers isNotEqualTo []) then {
    [_identifiers, _deviceType, _deviceId] call FUNC(addComputerDeviceLinks);
};

// Re-read the public list: addComputerDeviceLinks syncs on its own, and the entry written below has to
// land on top of whatever that left behind.
_publicDevices = GET_PUBLIC_DEVICES;

switch (true) do {
    case (_accessMode == ACCESS_MODE_PUBLIC): {
        // An empty exclusion list is what fn_isDeviceAccessible reads as "reachable by everyone".
        _publicDevices pushBack [_deviceType, _deviceId, []];
    };

    case (_accessMode == ACCESS_MODE_LINKED && _availableToFutureLaptops): {
        // Publish, but exclude every laptop that exists right now and was not selected. Laptops created
        // afterwards are absent from the exclusion list and therefore gain access.
        private _excludedIdentifiers = [];
        {
            private _laptop = objectFromNetId (_x select 0);
            private _identifier = if (isNull _laptop) then { _x select 0 } else { [_laptop] call FUNC(getComputerIdentifier) };
            if (_identifier isNotEqualTo "" && {!(_identifier in _identifiers)}) then {
                _excludedIdentifiers pushBackUnique _identifier;
            };
        } forEach (call FUNC(getRegisteredLaptops));

        _publicDevices pushBack [_deviceType, _deviceId, _excludedIdentifiers];
    };

    default {};
};

missionNamespace setVariable [GVAR_PUBLIC_DEVICES, _publicDevices];
call FUNC(syncDeviceData);

DEBUG_LOG_3("setDeviceAccessMain: device %1/%2 set to mode %3",_deviceType,_deviceId,_accessMode);

if (_execUserId > 0) then {
    [format [localize "STR_ROOT_CYBERWARFARE_ACCESS_DEVICE_UPDATED", _deviceId, count _identifiers]] remoteExec ["systemChat", _execUserId];
};

true
