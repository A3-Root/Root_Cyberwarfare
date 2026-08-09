#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Applies the chosen access mode to a device that has just been registered. This is the
 *              single place that writes device reachability, so every device type resolves the three
 *              modes identically:
 *              - ACCESS_MODE_UNASSIGNED: nothing is written. The device stays in the device registry
 *                only and no laptop can reach it until access is granted later.
 *              - ACCESS_MODE_LINKED: a private [type, id] link is added to each supplied computer.
 *                When the device is also marked available to future laptops it additionally enters the
 *                public list with every current non-linked laptop excluded, so only the linked laptops
 *                and laptops created afterwards can reach it.
 *              - ACCESS_MODE_PUBLIC: the device enters the public list with an empty exclusion list,
 *                making it reachable by every current and future laptop. Supplied computers still
 *                receive a private link so the device keeps working if it is unpublished later.
 *              Identifiers are laptop netIds in Simple mode and player UIDs in Experimental mode, to
 *              match the identifier that fn_isDeviceAccessible resolves at access time.
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - Device type constant (DEVICE_TYPE_*)
 * 1: _deviceId <NUMBER> - Registered device id
 * 2: _linkedComputers <ARRAY> - Persistent computer identifiers to link, may be empty
 * 3: _accessMode <NUMBER> (Optional) - ACCESS_MODE_* constant, default: ACCESS_MODE_UNASSIGNED
 * 4: _availableToFutureLaptops <BOOL> (Optional) - Extend linked access to later laptops, default: false
 *
 * Return Value:
 * <STRING> - Human readable availability summary for curator feedback
 *
 * Example:
 * private _text = [DEVICE_TYPE_DATABASE, 1003, [netId _laptop], ACCESS_MODE_LINKED, false] call Root_fnc_applyDeviceAccess;
 *
 * Public: No
 */

params [
    ["_deviceType", 0, [0]],
    ["_deviceId", 0, [0]],
    ["_linkedComputers", [], [[]]],
    ["_accessMode", ACCESS_MODE_UNASSIGNED, [0]],
    ["_availableToFutureLaptops", false, [false]]
];

if !(VALIDATE_DEVICE_TYPE(_deviceType)) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR_1("applyDeviceAccess: Invalid device type %1",_deviceType);
    ""
};

if !(VALIDATE_ACCESS_MODE(_accessMode)) then {
    ROOT_CYBERWARFARE_LOG_ERROR_1("applyDeviceAccess: Invalid access mode %1, falling back to unassigned",_accessMode);
    _accessMode = ACCESS_MODE_UNASSIGNED;
};

DEBUG_LOG_3("applyDeviceAccess - Type: %1, Id: %2, Mode: %3",_deviceType,_deviceId,_accessMode);
DEBUG_LOG_2("Device setup mode: %1, Future laptops: %2",GET_DEVICE_MODE,_availableToFutureLaptops);

if (_accessMode == ACCESS_MODE_UNASSIGNED) exitWith {
    DEBUG_LOG("Unassigned - no links and no public entry written");
    localize "STR_ROOT_CYBERWARFARE_ACCESS_UNASSIGNED"
};

// Private links are shared by both remaining modes: they survive a later change of public state.
if (_linkedComputers isNotEqualTo []) then {
    [_linkedComputers, _deviceType, _deviceId] call FUNC(addComputerDeviceLinks);
};

if (_accessMode == ACCESS_MODE_PUBLIC) exitWith {
    private _publicDevices = GET_PUBLIC_DEVICES;
    // An empty exclusion list is what fn_isDeviceAccessible reads as "reachable by everyone".
    _publicDevices pushBack [_deviceType, _deviceId, []];
    missionNamespace setVariable [GVAR_PUBLIC_DEVICES, _publicDevices];
    call FUNC(syncDeviceData);

    DEBUG_LOG("Public - registered with no exclusions");
    localize "STR_ROOT_CYBERWARFARE_ACCESS_PUBLIC"
};

// ACCESS_MODE_LINKED from here on.
if (!_availableToFutureLaptops) exitWith {
    if (_linkedComputers isEqualTo []) exitWith {
        // Nothing was selected, so the device ends up with the same reachability as unassigned.
        DEBUG_LOG("Linked mode with no computers selected - device left unreachable");
        localize "STR_ROOT_CYBERWARFARE_ACCESS_UNASSIGNED"
    };

    format [localize "STR_ROOT_CYBERWARFARE_ACCESS_LINKED", count _linkedComputers]
};

// Available to future laptops: publish the device but exclude every laptop that exists right now and
// is not one of the selected ones. New laptops are absent from the exclusion list and gain access.
private _excludedIdentifiers = [];

if (IS_EXPERIMENTAL_MODE) then {
    {
        private _nearLaptops = nearestObjects [_x, [], 3] select {
            [_x] call FUNC(isRegisteredLaptop)
        };
        if (_nearLaptops isNotEqualTo []) then {
            private _uid = getPlayerUID _x;
            if !(_uid in _linkedComputers) then {
                _excludedIdentifiers pushBackUnique _uid;
                DEBUG_LOG_2("Excluding player %1 (UID: %2)",name _x,_uid);
            };
        };
    } forEach allPlayers;
} else {
    {
        _x params ["_netId"];
        if !(_netId in _linkedComputers) then {
            _excludedIdentifiers pushBackUnique _netId;
            DEBUG_LOG_1("Excluding laptop netId: %1",_netId);
        };
    } forEach (call FUNC(getRegisteredLaptops));
};

private _publicDevices = GET_PUBLIC_DEVICES;
_publicDevices pushBack [_deviceType, _deviceId, _excludedIdentifiers];
missionNamespace setVariable [GVAR_PUBLIC_DEVICES, _publicDevices];
call FUNC(syncDeviceData);

DEBUG_LOG_1("Excluded identifiers: %1",_excludedIdentifiers);

if (_linkedComputers isEqualTo []) exitWith {
    localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE_ONLY"
};

format [localize "STR_ROOT_CYBERWARFARE_ACCESS_LINKED_FUTURE", count _linkedComputers]
