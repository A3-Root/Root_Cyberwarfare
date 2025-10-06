params['_owner', '_computer', '_nameOfVariable', '_trackerId', '_commandPath'];

private _string = "";
private _trackerIdNum = parseNumber _trackerId;

if (_trackerIdNum != 0) then {
    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", [[], [], [], [], []]];
    private _allGpsTrackers = _allDevices select 5;

    // Filter trackers that are accessible by this computer
    private _accessibleTrackers = _allGpsTrackers select { 
        [_computer, 6, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
    };

    if (_accessibleTrackers isEqualTo []) then {
        _string = "Error! No accessible GPS trackers found or access denied.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _foundTracker = false;
    
    {
        private _storedTrackerId = _x select 0;
        private _trackerNetId = _x select 1;
        
        if (_trackerIdNum == _storedTrackerId) then {
            _foundTracker = true;
            private _trackerObject = objectFromNetId _trackerNetId;
            private _trackerName = _x select 2;
            private _trackingTime = _x select 3;
            private _updateFrequency = _x select 4;
            private _customMarker = _x select 5;
            private _currentStatus = _x select 8; // [isTracking, startTime, markerName]
            
            // Check if object still exists
            if ((isNull _trackerObject) || !(alive _trackerObject)) then {
                _string = format ["Tracker '%1' (ID: %2) - Target object no longer exists/alive.", _trackerName, _trackerIdNum];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                
                // Update status to Dead
                _allGpsTrackers set [_forEachIndex, [_storedTrackerId, _trackerNetId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _x select 6, _x select 7, ["Dead", 0, ""]]];
                missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
            } else {
                // Start tracking
                private _markerName = if (_customMarker != "") then { _customMarker } else { format ["ROOT_GpsTracker_%1_%2", _trackerIdNum, netId _computer] };
                
                // Create marker
                private _marker = createMarkerLocal [_markerName, getPos _trackerObject];
                _marker setMarkerTypeLocal "mil_dot";
                _marker setMarkerTextLocal _trackerName;
                _marker setMarkerColorLocal "ColorRed";
                
                // Update tracker status
                _allGpsTrackers set [_forEachIndex, [_storedTrackerId, _trackerNetId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _x select 6, _x select 7, ["Tracked", time, _markerName]]];
                missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
                
                _string = format ["Tracking target '%1' (ID: %2) for %3 seconds. Marker: %4", _trackerName, _trackerIdNum, _trackingTime, _markerName];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                
                // Start tracking loop
                [_trackerObject, _markerName, _trackingTime, _updateFrequency, _storedTrackerId, _computer] spawn {
                    params ["_trackerObject", "_markerName", "_trackingTime", "_updateFrequency", "_trackerId", "_computer"];
                    
                    private _startTime = time;
                    private _endTime = _startTime + _trackingTime;
                    
                    while {time < _endTime && !isNull _trackerObject} do {
                        _markerName setMarkerPosLocal (getPos _trackerObject);
                        sleep _updateFrequency;
                    };
                    
                    // Clean up after tracking time expires
                    deleteMarkerLocal _markerName;
                    
                    // Update status to Untracked
                    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
                    private _allGpsTrackers = _allDevices param [6, []];
                    
                    {
                        if ((_x select 0) == _trackerId) then {
                            _allGpsTrackers set [_forEachIndex, [_x select 0, _x select 1, _x select 2, _x select 3, _x select 4, _x select 5, _x select 6, _x select 7, ["Untracked", 0, ""]]];
                            missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
                        };
                    } forEach _allGpsTrackers;
                };
            };
        };
    } forEach _accessibleTrackers;
    
    if (!_foundTracker) then {
        _string = format ["Error! GPS Tracker ID %1 not found or access denied.", _trackerIdNum];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
};

if (_trackerIdNum == 0) then {
    _string = format ["Error! Invalid TrackerID - %1.", _trackerId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
