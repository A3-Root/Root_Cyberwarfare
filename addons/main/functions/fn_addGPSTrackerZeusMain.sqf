params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], ["_trackerName", ""], ["_trackingTime", 60], ["_updateFrequency", 5], ["_customMarker", ""], ["_availableToFutureLaptops", false], ["_allowRetracking", false], "_lastPingTimer", "_powerCost"];

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", [[], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;
private _allLamps = _allDevices select 1;
private _allDrones = _allDevices select 2;
private _allDatabases = _allDevices select 3;
private _allCustom = _allDevices select 4;
private _allGpsTrackers = _allDevices select 5;
private _allVehicles = _allDevices select 6;

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
missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];


// Store variables on the target object
_targetObject setVariable ["ROOT_GpsTrackerId", _deviceId, true];
_targetObject setVariable ["ROOT_GpsTrackerName", _trackerName, true];
_targetObject setVariable ["ROOT_GpsTrackerTrackingTime", _trackingTime, true];
_targetObject setVariable ["ROOT_GpsTrackerUpdateFrequency", _updateFrequency, true];
_targetObject setVariable ["ROOT_GpsTrackerCustomMarker", _customMarker, true];
_targetObject setVariable ["ROOT_AvailableToFutureLaptops", _availableToFutureLaptops, true];
_targetObject setVariable ["ROOT_GpsTrackerAllowRetracking", _allowRetracking, true];
_targetObject setVariable ["ROOT_GpsTrackerLastPingTimer", _lastPingTimer, true];
_targetObject setVariable ["ROOT_GpsTrackerPowerCost", _powerCost, true];

private _availabilityText = "";

// Store device linking information (for selected computers)
if (_linkedComputers isNotEqualTo []) then {
    private _deviceLinks = missionNamespace getVariable ["ROOT-Device-Links", []];
    
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
    missionNamespace setVariable ["ROOT-Device-Links", _deviceLinks, true];
};

private _excludedNetIds = [];
// Handle public device access
if (_availableToFutureLaptops || count _linkedComputers == 0) then {
    private _publicDevices = missionNamespace getVariable ["ROOT-Public-Devices", []];

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario: Available to future + some linked
            // Exclude current laptops that are NOT linked
            {
                if (_x getVariable ["ROOT_HackingTools", false]) then {
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
                if (_x getVariable ["ROOT_HackingTools", false]) then {
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
        missionNamespace setVariable ["ROOT-Public-Devices", _publicDevices, true];
    };
};


[format ["Root Cyber Warfare: GPS Tracker '%1' added (ID: %2). %3", _trackerName, _deviceId, _availabilityText]] remoteExec ["systemChat", _execUserId];
