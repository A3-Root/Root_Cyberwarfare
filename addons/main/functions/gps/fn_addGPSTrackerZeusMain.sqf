#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Server-side function to add a GPS tracker to the network
 *
 * Arguments:
 * 0: _targetObject <OBJECT> - The object to track
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _trackerName <STRING> (Optional) - Tracker display name, default: ""
 * 4: _trackingTime <NUMBER> (Optional) - Tracking duration in seconds, default: 60
 * 5: _updateFrequency <NUMBER> (Optional) - Update frequency in seconds, default: 5
 * 6: _customMarker <STRING> (Optional) - Custom marker name, default: ""
 * 7: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 8: _allowRetracking <BOOLEAN> (Optional) - Allow retracking, default: false
 * 9: _lastPingTimer <NUMBER> - Last ping marker duration
 * 10: _powerCost <NUMBER> - Power cost per ping
 * 11: _sysChat <BOOLEAN> (Optional) - Show system chat message, default: true
 * 12: _ownersSelection <ARRAY> (Optional) - Additional sides, groups, or players, to get GPS Pings marked on map, default: [[], [], []]
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Tracker1", 60, 5, "", false, true, 30, 2, true, [[], [], []]] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
 *
 * Public: No
 */

params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], ["_trackerName", ""], ["_trackingTime", 60], ["_updateFrequency", 5], ["_customMarker", ""], ["_availableToFutureLaptops", false], ["_allowRetracking", false], "_lastPingTimer", "_powerCost", ["_sysChat", true], ["_ownersSelection", [[], [], []]]];

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allGpsTrackers = _allDevices select 5;

private _netId = netId _targetObject;

private _deviceId = (round (random 8999)) + 1000;
if (count _allGpsTrackers > 0) then {
    while {true} do {
        _deviceId = (round (random 8999)) + 1000;
        private _trackerIsNew = true;
        {
            if (_x select 0 == _deviceId) then {
                _trackerIsNew = false;
            };
        } forEach _allGpsTrackers;
        if (_trackerIsNew) then { break };
    };
};

// Store the tracker with initial status "Untracked" and owners selection
_allGpsTrackers pushBack [_deviceId, _netId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _linkedComputers, _availableToFutureLaptops, ["Untracked", 0, ""], _allowRetracking, _lastPingTimer, _powerCost, _ownersSelection];

// Update the allDevices array with the new GPS trackers category
_allDevices set [5, _allGpsTrackers];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];


// Store variables on the target object
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_ID", _deviceId, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_NAME", _trackerName, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_TIME", _trackingTime, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_FREQUENCY", _updateFrequency, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_MARKER", _customMarker, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_RETRACK", _allowRetracking, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_PING", _lastPingTimer, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_COST", _powerCost, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_OWNERS", _ownersSelection, true];

private _availabilityText = "";

// Store device linking information (for selected computers)
if (_linkedComputers isNotEqualTo []) then {
    // Update new hashmap-based link cache
    private _linkCache = GET_LINK_CACHE;

    {
        private _computerNetId = _x;
        private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
        _existingLinks pushBack [6, _deviceId]; // 6 = GPS tracker type
        _linkCache set [_computerNetId, _existingLinks];
    } forEach _linkedComputers;

    missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];
    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
};

private _excludedIdentifiers = [];
// Handle public device access
if (_availableToFutureLaptops || count _linkedComputers == 0) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

    DEBUG_LOG_2("Device setup mode: %1, Future laptops: %2",GET_DEVICE_MODE,_availableToFutureLaptops);

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario: Available to future + some linked
            // Exclude current laptops that are NOT linked
            DEBUG_LOG("Scenario 4: Excluding current non-linked computers");

            if (IS_EXPERIMENTAL_MODE) then {
                {
                    private _nearLaptops = nearestObjects [_x, [], 3] select {
                        _x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]
                    };
                    if (_nearLaptops isNotEqualTo []) then {
                        private _uid = getPlayerUID _x;
                        if !(_uid in _linkedComputers) then {
                            _excludedIdentifiers pushBack _uid;
                            DEBUG_LOG_2("Excluding player %1 (UID: %2)",name _x,_uid);
                        };
                    };
                } forEach allPlayers;
            } else {
                {
                    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                        private _netId = netId _x;
                        if !(_netId in _linkedComputers) then {
                            _excludedIdentifiers pushBack _netId;
                            DEBUG_LOG_1("Excluding laptop netId: %1",_netId);
                        };
                    };
                } forEach (24 allObjects 1);
            };

            _availabilityText = _availabilityText + format [" and all future computers."];
        } else {
            // Scenario: Available to future + no linked
            // Exclude ALL current laptops
            DEBUG_LOG("Scenario 3: Excluding all current computers");

            if (IS_EXPERIMENTAL_MODE) then {
                {
                    private _nearLaptops = nearestObjects [_x, [], 3] select {
                        _x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]
                    };
                    if (_nearLaptops isNotEqualTo []) then {
                        _excludedIdentifiers pushBack (getPlayerUID _x);
                        DEBUG_LOG_2("Excluding player %1 (UID: %2)",name _x,getPlayerUID _x);
                    };
                } forEach allPlayers;
            } else {
                {
                    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                        _excludedIdentifiers pushBack (netId _x);
                        DEBUG_LOG_1("Excluding laptop netId: %1",netId _x);
                    };
                } forEach (24 allObjects 1);
            };

            _availabilityText = "Available to future computers only";
        };
    } else {
        // Scenario: Not available to future + no linked
        // No exclusions - all current laptops get access
        DEBUG_LOG("Scenario 1: All current computers get access");
        _availabilityText = format ["Available to all current computers."];
    };

    DEBUG_LOG_1("Excluded identifiers: %1",_excludedIdentifiers);
    // Only add to public devices if we have exclusions or it's available to future
    if (_availableToFutureLaptops || _excludedIdentifiers isNotEqualTo []) then {
        _publicDevices pushBack [6, _deviceId, _excludedIdentifiers]; // 6 = GPS tracker type
        missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
    };
};

if (_sysChat) then {
    [format ["Root Cyber Warfare: GPS Tracker '%1' added (ID: %2). %3", _trackerName, _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];
};
