// root_cyberwarfare\functions\fn_gpstrack.sqf
params['_owner', '_computer', '_nameOfVariable', '_trackerId', '_commandPath'];

private _string = "";
private _trackerIdNum = parseNumber _trackerId;

if (_trackerIdNum != 0) then {
    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
    private _allGpsTrackers = _allDevices param [5, []];

    if (_allGpsTrackers isEqualTo []) then {
        _string = "Error! No GPS trackers found.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _foundTracker = false;
    
    {
        private _storedTrackerId = _x select 0;
        private _trackerNetId = _x select 1;
        
        if (_trackerIdNum == _storedTrackerId) then {
            // Check if this specific tracker is accessible
            if ([_computer, 6, _storedTrackerId, _commandPath] call Root_fnc_isDeviceAccessible) then {
                _foundTracker = true;
                private _trackerObject = objectFromNetId _trackerNetId;
                private _trackerName = _x select 2;
                private _trackingTime = _x select 3;
                private _updateFrequency = _x select 4;
                private _customMarker = _x select 5;
                private _currentStatus = _x select 8;
                private _allowRetracking = _x select 9;
                
                // Check if already being tracked by this computer
                if ((_currentStatus select 0) == "Tracked") then {
                    _string = format ["Tracker '%1' (ID: %2) is already being tracked.", _trackerName, _trackerIdNum];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                } else {
                    // Check if retracking is allowed for completed trackers
                    if (((_currentStatus select 0) == "Completed") && !(_allowRetracking)) then {
                        _string = format ["Tracker '%1' (ID: %2) cannot be tracked again.", _trackerName, _trackerIdNum];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    } else {
                        // Check if object still exists
                        if (isNull _trackerObject) then {
                            _string = format ["Tracker '%1' (ID: %2) - Target object no longer exists.", _trackerName, _trackerIdNum];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            
                            // Update status to Dead
                            _allGpsTrackers set [_forEachIndex, [
                                _storedTrackerId, 
                                _trackerNetId, 
                                _trackerName, 
                                _trackingTime, 
                                _updateFrequency, 
                                _customMarker, 
                                _x select 6, 
                                _x select 7, 
                                ["Dead", 0, ""],
                                _allowRetracking
                            ]];
                            _allDevices set [5, _allGpsTrackers];
                            missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
                        } else {
                            // Start tracking
                            private _markerName = if (_customMarker != "") then { _customMarker } else { format ["ROOT_GpsTracker_%1_%2", _trackerIdNum, round(random 10000)] };
                            
                            // If there's an existing marker from a previous track, delete it first
                            if ((_currentStatus select 2) != "") then {
                                deleteMarkerLocal (_currentStatus select 2);
                            };
                            
                            // Create marker
                            private _marker = createMarkerLocal [_markerName, getPos _trackerObject];
                            _marker setMarkerTypeLocal "mil_dot";
                            _marker setMarkerTextLocal _trackerName;
                            _marker setMarkerColorLocal "ColorRed";
                            
                            // Update tracker status
                            _allGpsTrackers set [_forEachIndex, [
                                _storedTrackerId, 
                                _trackerNetId, 
                                _trackerName, 
                                _trackingTime, 
                                _updateFrequency, 
                                _customMarker, 
                                _x select 6, 
                                _x select 7, 
                                ["Tracked", time, _markerName],
                                _allowRetracking
                            ]];
                            _allDevices set [5, _allGpsTrackers];
                            missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
                            
                            _string = format ["Tracking target '%1' (ID: %2) for %3 seconds.", _trackerName, _trackerIdNum, _trackingTime];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            
                            // Start tracking loop
                            [_trackerObject, _markerName, _trackingTime, _updateFrequency, _storedTrackerId, _computer, _allowRetracking, _trackerIdNum] spawn {
                                params ["_trackerObject", "_markerName", "_trackingTime", "_updateFrequency", "_trackerId", "_computer", "_allowRetracking", "_trackerIdNum"];
                                
                                private _startTime = time;
                                private _endTime = _startTime + _trackingTime;
                                
                                while {time < _endTime && !isNull _trackerObject} do {
                                    _markerName setMarkerPosLocal (getPos _trackerObject);
                                    uiSleep _updateFrequency;
                                };
                                
                                // After tracking time, change marker color to indicate it's no longer updating
                                _markerName setMarkerColorLocal "ColorCIV";
                                
                                // Update status based on retracking permission
                                private _newStatus = "Trackable"; 
                                if !(_allowRetracking) then {
                                    private _newStatus = "Untrackable" ;
                                };
    
                                private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
                                private _allGpsTrackers = _allDevices param [5, []];
                                
                                {
                                    if ((_x select 0) == _trackerId) then {
                                        _allGpsTrackers set [_forEachIndex, [
                                            _x select 0, 
                                            _x select 1, 
                                            _x select 2, 
                                            _x select 3, 
                                            _x select 4, 
                                            _x select 5, 
                                            _x select 6, 
                                            _x select 7, 
                                            [_newStatus, time, _markerName],
                                            _x select 9
                                        ]];
                                        _allDevices set [5, _allGpsTrackers];
                                        missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
                                    };
                                } forEach _allGpsTrackers;
                                
                                // Notify user that tracking ended
                                private _endString = format ["Tracking for target ID %1 has ended. Marker remains at last known position.", _trackerIdNum];
                                [_computer, _endString] call AE3_armaos_fnc_shell_stdout;
                            };
                        };
                    };
                };
            } else {
                _string = format ["Access denied to GPS Tracker ID %1.", _trackerIdNum];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                _foundTracker = true; // We found it but access is denied
            };
        };
    } forEach _allGpsTrackers;
    
    if (!_foundTracker) then {
        _string = format ["Error! GPS Tracker ID %1 not found.", _trackerIdNum];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
} else {
    _string = format ["Error! Invalid TrackerID - %1.", _trackerId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
