#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Gives a registered GPS tracker the identifier it will answer to, and records what that
 * identifier belongs to: the tracker's name, the object it was first attached to, and the player who
 * planted it. This is the only function that writes the identifier map, so every identifier in a
 * mission is minted and recorded in one place.
 *
 * A tracker marked hidden is additionally added to the list of ids no listing may show. That list is
 * the only part of this that reaches clients - the identifiers themselves stay on the server, because
 * a client that held them could read every code in the mission. Resolving a code is therefore
 * something a client asks the server to do.
 *
 * Arguments:
 * 0: _deviceId <NUMBER> - The registered tracker's device id
 * 1: _trackerName <STRING> - The tracker's display name
 * 2: _object <OBJECT> - The object the tracker was attached to
 * 3: _plantedByUid <STRING> (Optional) - UID of the player who planted it, default: ""
 * 4: _hidden <BOOL> (Optional) - Keep the tracker out of every listing, default: false
 * 5: _requestedIdentifier <STRING> (Optional) - A mission-chosen code; a blank or already-used one is
 *                                               replaced by a fresh draw, default: ""
 *
 * Return Value:
 * <STRING> - The identifier the tracker now answers to, or "" if none could be assigned
 *
 * Example:
 * private _code = [1004, "Tracker_1", _car, getPlayerUID _player, true, ""] call Root_fnc_registerGpsIdentifier;
 *
 * Public: No
 */

if (!isServer) exitWith {""};

params [
    ["_deviceId", 0, [0]],
    ["_trackerName", "", [""]],
    ["_object", objNull, [objNull]],
    ["_plantedByUid", "", [""]],
    ["_hidden", false, [false]],
    ["_requestedIdentifier", "", [""]]
];

private _identifiers = GET_GPS_IDENTIFIERS;

// A code the mission asked for is honoured when it is free, so an Eden-placed tracker can carry a
// code the briefing already names. Anything else is drawn fresh.
private _identifier = toUpperANSI _requestedIdentifier;
if (_identifier isEqualTo "" || {_identifier in (keys _identifiers)}) then {
    if (_identifier isNotEqualTo "") then {
        ROOT_CYBERWARFARE_LOG_INFO_1(format ["registerGpsIdentifier: identifier %1 is already in use, drawing a fresh one",_identifier]);
    };
    _identifier = call FUNC(generateGpsIdentifier);
};

if (_identifier isEqualTo "") exitWith {""};

private _objectName = "";
if (!isNull _object) then {
    _objectName = getText (configOf _object >> "displayName");
};

_identifiers set [_identifier, [_deviceId, _trackerName, _objectName, _plantedByUid, _hidden]];
missionNamespace setVariable [GVAR_GPS_IDENTIFIERS, _identifiers];

if (_hidden) then {
    private _hiddenIds = GET_GPS_HIDDEN_IDS;
    _hiddenIds pushBackUnique _deviceId;
    missionNamespace setVariable [GVAR_GPS_HIDDEN_IDS, _hiddenIds];
    call FUNC(syncDeviceData);
};

ROOT_CYBERWARFARE_LOG_INFO_3(format ["GPS tracker '%1' (ID: %2) answers to identifier %3",_trackerName,_deviceId,_identifier]);

_identifier
