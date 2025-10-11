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
 *
 * Return Value:
 * None
 *
 * Example:
 * [_obj, 0, [], "Tracker1", 60, 5, "", false, true, 30, 2, true] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
 *
 * Public: No
 */

params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], ["_trackerName", ""], ["_trackingTime", 60], ["_updateFrequency", 5], ["_customMarker", ""], ["_availableToFutureLaptops", false], ["_allowRetracking", false], "_lastPingTimer", "_powerCost", ["_sysChat", true]];

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
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

// Store the tracker with initial status "Untracked"
_allGpsTrackers pushBack [_deviceId, _netId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _linkedComputers, _availableToFutureLaptops, ["Untracked", 0, ""], _allowRetracking, _lastPingTimer, _powerCost];

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

private _availabilityText = "";

// Store device linking information (for selected computers)
if (_linkedComputers isNotEqualTo []) then {
    private _deviceLinks = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", []];
    
    {
        private _computerNetId = _x;
        private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
        
        if (_existingLinks isEqualTo []) then {
            _deviceLinks pushBack [_computerNetId, [[6, _deviceId]]]; // 6 = GPS tracker type
        } else {
            private _index = _deviceLinks find (_existingLinks select 0);
            private _devices = (_deviceLinks select _index) select 1;
            _devices pushBack [6, _deviceId];
            _deviceLinks set [_index, [_computerNetId, _devices]];
        };
    } forEach _linkedComputers;

    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", _deviceLinks, true];
};

private _excludedNetIds = [];
// Handle public device access
if (_availableToFutureLaptops || count _linkedComputers == 0) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario: Available to future + some linked
            // Exclude current laptops that are NOT linked
            {
                if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                    private _netId = netId _x;
                    if !(_netId in _linkedComputers) then {
                        _excludedNetIds pushBack _netId;
                    };
                };
            } forEach (24 allObjects 1);
            
            _availabilityText = _availabilityText + format [" and all future computers."];
        } else {
            // Scenario: Available to future + no linked
            // Exclude ALL current laptops
            {
                if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                    _excludedNetIds pushBack (netId _x);
                };
            } forEach (24 allObjects 1);
            _availabilityText = "Available to future computers only";
        };
    } else {
        // Scenario: Not available to future + no linked
        // No exclusions - all current laptops get access
        _availabilityText = format ["Available to all current computers."];
    };

    // Only add to public devices if we have exclusions or it's available to future
    if (_availableToFutureLaptops || _excludedNetIds isNotEqualTo []) then {
        _publicDevices pushBack [6, _deviceId, _excludedNetIds]; // 6 = GPS tracker type
        missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
    };
};

if (_sysChat) then {
    [format ["Root Cyber Warfare: GPS Tracker '%1' added (ID: %2). %3", _trackerName, _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];
};
