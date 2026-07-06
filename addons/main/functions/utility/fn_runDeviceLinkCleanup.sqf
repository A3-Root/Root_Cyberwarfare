#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Runs a single pass of device-link cleanup on the server: drops link-cache entries and
 * device-registry rows whose backing object no longer exists. Shared by the optional periodic loop
 * (Root_fnc_cleanupDeviceLinks) and the on-demand manual clear (Root_fnc_clearBrokenDeviceLinks / the
 * "Clear Broken Device Links" ZEN module), so both paths use identical validation rules.
 *
 * Validation rule (both modes): a resolved (non-null) laptop/device object is ALWAYS kept - its
 * presence proves it still exists. The ROOT_CYBERWARFARE_HACKABLE_LAPTOP networked flag is not trusted
 * as a deletion signal (it can read false for a pass or two after a player joins, before it replicates).
 * Only an object whose netId is unresolvable while players are present is a removal candidate.
 *
 * Grace vs immediate: with _useGrace the candidate must fail CLEANUP_STRIKE_LIMIT consecutive calls
 * before it is dropped (strike counters persist in missionNamespace across calls), absorbing transient
 * lookup misses; without it a candidate is dropped on the spot. The periodic loop passes the admin's
 * ROOT_CYBERWARFARE_CLEANUP_STRIKE_GRACE setting; the manual clear passes false (act now).
 *
 * Arguments:
 * 0: _useGrace <BOOL> (Optional, default true) - true = strike grace, false = remove candidates immediately
 *
 * Return Value:
 * <NUMBER> - Total entries removed this pass (legacy links + link-cache identifiers + device rows)
 *
 * Example:
 * [false] call Root_fnc_runDeviceLinkCleanup;
 *
 * Public: No
 */

if (!isServer) exitWith {0};

params [["_useGrace", true, [true]]];

private _strikeLimit = CLEANUP_STRIKE_LIMIT;

// Strike counters persist across passes so grace survives between calls (the loop and repeated manual
// clears share them). Only consulted when _useGrace is true.
private _legacyStrikes = missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_STRIKES_LEGACY", createHashMap];
private _linkStrikes = missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_STRIKES_LINK", createHashMap];
private _deviceStrikes = missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_STRIKES_DEV", createHashMap];
missionNamespace setVariable ["ROOT_CYBERWARFARE_CLEANUP_STRIKES_LEGACY", _legacyStrikes];
missionNamespace setVariable ["ROOT_CYBERWARFARE_CLEANUP_STRIKES_LINK", _linkStrikes];
missionNamespace setVariable ["ROOT_CYBERWARFARE_CLEANUP_STRIKES_DEV", _deviceStrikes];

// Decides whether a removal candidate is dropped now: immediately in non-grace mode, otherwise only
// after _strikeLimit consecutive strikes. Returns true to remove. Clears the strike on a valid entry.
private _strikeAndCheck = {
    params ["_map", "_key", "_isValid"];
    if (_isValid) exitWith { _map deleteAt _key; false };
    if (!_useGrace) exitWith { _map deleteAt _key; true };
    private _strikes = (_map getOrDefault [_key, 0]) + 1;
    if (_strikes >= _strikeLimit) exitWith { _map deleteAt _key; true };
    _map set [_key, _strikes];
    DEBUG_LOG_2("Cleanup: %1 invalid (strike %2), kept pending confirmation",_key,_strikes);
    false
};

private _totalRemoved = 0;

// ---- Legacy device-links array (computer netId -> devices) ----
private _deviceLinks = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", []];
private _cleanLinks = [];
private _removedCount = 0;

DEBUG_LOG_1("Cleanup: Checking %1 legacy device links",count _deviceLinks);

{
    private _computerNetId = _x select 0;
    private _computer = objectFromNetId _computerNetId;
    private _isValid = !isNull _computer || {allPlayers isEqualTo []};
    if ([_legacyStrikes, _computerNetId, _isValid] call _strikeAndCheck) then {
        _removedCount = _removedCount + 1;
        ROOT_CYBERWARFARE_LOG_INFO_1(format ["Cleanup: Removed device links for deleted computer: %1",_computerNetId]);
    } else {
        _cleanLinks pushBack _x;
    };
} forEach _deviceLinks;

missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", _cleanLinks];
if (_removedCount > 0) then {
    _totalRemoved = _totalRemoved + _removedCount;
    call Root_fnc_syncDeviceData;
    ROOT_CYBERWARFARE_LOG_INFO_2(format ["Cleanup removed %1 computer links. %2 links active in the server.",_removedCount,count _cleanLinks]);
};

// ---- Link cache (identifier -> [[type,id],...]) ----
private _linkCache = GET_LINK_CACHE;
private _identifiersToRemove = [];

DEBUG_LOG_2("Cleanup: Checking %1 link cache entries (Mode: %2)",count keys _linkCache,GET_DEVICE_MODE);

{
    private _identifier = _x;
    private _isValid = false;

    if (IS_EXPERIMENTAL_MODE) then {
        // Experimental mode: identifier is a player UID - valid while that player is connected.
        _isValid = (allPlayers findIf {getPlayerUID _x == _identifier}) != -1;
    } else {
        // Simple mode: identifier is a laptop netId - a resolved object is valid; an unresolvable netId
        // is a candidate only while players are present (a null before that just means "not networked yet").
        private _computer = objectFromNetId _identifier;
        _isValid = !isNull _computer || {allPlayers isEqualTo []};
    };

    if ([_linkStrikes, _identifier, _isValid] call _strikeAndCheck) then {
        _identifiersToRemove pushBack _identifier;
    };
} forEach (keys _linkCache);

{
    _linkCache deleteAt _x;
    ROOT_CYBERWARFARE_LOG_INFO_1(format ["Cleanup: Removed link cache for invalid identifier: %1",_x]);
} forEach _identifiersToRemove;

if (_identifiersToRemove isNotEqualTo []) then {
    _totalRemoved = _totalRemoved + (count _identifiersToRemove);
    missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache];
    call Root_fnc_syncDeviceData;
    ROOT_CYBERWARFARE_LOG_INFO_2(format ["Cleanup removed %1 link cache entries. %2 entries remain.",count _identifiersToRemove,count keys _linkCache]);
};

// ---- Device registry (per-type arrays of [id, netId, ...]) ----
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _cleanedDevices = [[], [], [], [], [], [], [], []];
private _devicesRemoved = 0;

{
    private _deviceList = _x;
    private _typeIndex = _forEachIndex;
    private _cleanedList = [];
    {
        private _deviceNetId = _x select 1;
        private _strikeKey = format ["%1:%2", _typeIndex, _deviceNetId];
        private _isValid = !isNull (objectFromNetId _deviceNetId) || {allPlayers isEqualTo []};
        if ([_deviceStrikes, _strikeKey, _isValid] call _strikeAndCheck) then {
            _devicesRemoved = _devicesRemoved + 1;
            ROOT_CYBERWARFARE_LOG_INFO_2(format ["Cleanup: Removing deleted device: Type %1, NetId %2",_typeIndex,_deviceNetId]);
        } else {
            _cleanedList pushBack _x;
        };
    } forEach _deviceList;
    _cleanedDevices set [_typeIndex, _cleanedList];
} forEach _allDevices;

missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _cleanedDevices];
if (_devicesRemoved > 0) then {
    _totalRemoved = _totalRemoved + _devicesRemoved;
    call Root_fnc_syncDeviceData;
};

_totalRemoved
