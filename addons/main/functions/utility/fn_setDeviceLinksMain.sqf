#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function that changes which computers can reach devices that are already
 *              registered. It is the counterpart to fn_applyDeviceAccess, which only runs at
 *              registration time, and the only place a device can be taken back out of the public
 *              list. Supported actions:
 *              - ACCESS_ACTION_LINK: add a private [type, id] link on every supplied computer
 *              - ACCESS_ACTION_UNLINK: drop that link again, leaving other computers untouched
 *              - ACCESS_ACTION_PUBLIC: publish the device so every current and future computer
 *                reaches it, replacing any earlier public entry for it
 *              - ACCESS_ACTION_UNASSIGN: remove the public entry and every private link, so the
 *                device stays registered but nobody can reach it
 *              Entries naming a device id that is not in the registry are skipped, so a stale
 *              dialog or a mistyped Eden attribute cannot create links to devices that do not exist.
 *
 * Arguments:
 * 0: _computerIds <ARRAY> - Computer netIds, or persistent identifiers already resolved by the caller
 * 1: _deviceEntries <ARRAY> - Devices to act on, as [[deviceType, deviceId], ...]
 * 2: _action <NUMBER> (Optional) - ACCESS_ACTION_* constant, default: ACCESS_ACTION_LINK
 * 3: _execUserId <NUMBER> (Optional) - Owner id to report the result to, 0 = no feedback, default: 0
 *
 * Return Value:
 * <NUMBER> - How many device entries were changed
 *
 * Example:
 * [[netId _laptop], [[DEVICE_TYPE_DATABASE, 1003]], ACCESS_ACTION_LINK, clientOwner] remoteExec ["Root_fnc_setDeviceLinksMain", 2];
 *
 * Public: No
 */

params [
    ["_computerIds", [], [[]]],
    ["_deviceEntries", [], [[]]],
    ["_action", ACCESS_ACTION_LINK, [0]],
    ["_execUserId", 0, [0]]
];

if (!isServer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("setDeviceLinksMain: Must run on the server");
    0
};

// Callers hand over netIds because that is what a Zeus dialog or an Eden attribute can name. Resolve
// each one to the identifier the link cache is actually keyed by, which is the netId in Simple mode
// and the operating player's UID in Experimental mode. Identifiers that resolve to no object are
// passed through unchanged, so a caller that already did the lookup still works.
private _identifiers = [];
{
    private _computer = objectFromNetId _x;
    private _identifier = if (isNull _computer) then { _x } else { [_computer] call FUNC(getComputerIdentifier) };
    if (_identifier != "") then {
        _identifiers pushBackUnique _identifier;
    };
} forEach _computerIds;

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];

// Keep only entries that name a device type in range and an id the registry actually holds.
private _validEntries = _deviceEntries select {
    _x params [["_deviceType", 0, [0]], ["_deviceId", 0, [0]]];

    if (VALIDATE_DEVICE_TYPE(_deviceType)) then {
        private _devicesOfType = _allDevices param [_deviceType - 1, []];
        (_devicesOfType findIf {(_x select 0) == _deviceId}) > -1
    } else {
        false
    };
};

if (_validEntries isEqualTo []) exitWith {
    DEBUG_LOG("setDeviceLinksMain: No valid device entries supplied");
    if (_execUserId > 0) then {
        [localize "STR_ROOT_CYBERWARFARE_LINKS_NO_DEVICES"] remoteExec ["systemChat", _execUserId];
    };
    0
};

private _linkCache = GET_LINK_CACHE;
private _publicDevices = GET_PUBLIC_DEVICES;
private _changed = 0;

switch (_action) do {
    case ACCESS_ACTION_LINK: {
        {
            _x params ["_deviceType", "_deviceId"];
            [_identifiers, _deviceType, _deviceId] call FUNC(addComputerDeviceLinks);
            _changed = _changed + 1;
        } forEach _validEntries;
    };

    case ACCESS_ACTION_UNLINK: {
        {
            _x params ["_deviceType", "_deviceId"];
            {
                private _identifier = _x;
                private _links = _linkCache getOrDefault [_identifier, []];
                private _linkIndex = _links findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}};
                if (_linkIndex > -1) then {
                    _links deleteAt _linkIndex;
                    _linkCache set [_identifier, _links];
                    ["root_cyberwarfare_deviceUnlinked", [_identifier, _deviceType, _deviceId]] call CBA_fnc_serverEvent;
                };
            } forEach _identifiers;
            _changed = _changed + 1;
        } forEach _validEntries;
    };

    case ACCESS_ACTION_PUBLIC: {
        {
            _x params ["_deviceType", "_deviceId"];
            // Replace any earlier public entry so an exclusion list from an older registration cannot
            // keep a computer locked out of a device that is now meant to be fully public.
            private _index = _publicDevices findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}};
            if (_index > -1) then {
                _publicDevices deleteAt _index;
            };
            _publicDevices pushBack [_deviceType, _deviceId, []];
            _changed = _changed + 1;
        } forEach _validEntries;
    };

    case ACCESS_ACTION_UNASSIGN: {
        {
            _x params ["_deviceType", "_deviceId"];

            private _index = _publicDevices findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}};
            if (_index > -1) then {
                _publicDevices deleteAt _index;
            };

            // Every computer loses the link, not just the ones the caller happened to select, so the
            // device really is unreachable afterwards.
            {
                private _identifier = _x;
                private _links = _linkCache getOrDefault [_identifier, []];
                private _linkIndex = _links findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}};
                if (_linkIndex > -1) then {
                    _links deleteAt _linkIndex;
                    _linkCache set [_identifier, _links];
                    ["root_cyberwarfare_deviceUnlinked", [_identifier, _deviceType, _deviceId]] call CBA_fnc_serverEvent;
                };
            } forEach (keys _linkCache);

            _changed = _changed + 1;
        } forEach _validEntries;
    };

    default {
        ROOT_CYBERWARFARE_LOG_ERROR_1("setDeviceLinksMain: Unknown action %1",_action);
    };
};

missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache];
missionNamespace setVariable [GVAR_PUBLIC_DEVICES, _publicDevices];
call FUNC(syncDeviceData);

DEBUG_LOG_2("setDeviceLinksMain: action %1 applied to %2 device(s)",_action,_changed);

if (_execUserId > 0) then {
    [format [localize "STR_ROOT_CYBERWARFARE_LINKS_UPDATED", _changed]] remoteExec ["systemChat", _execUserId];
};

_changed
