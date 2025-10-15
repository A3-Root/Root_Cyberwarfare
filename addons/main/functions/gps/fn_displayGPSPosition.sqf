#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Starts tracking a GPS tracker and displays its position on the map
 *
 * Arguments:
 * 0: _owner <ANY> - Owner parameter (legacy compatibility)
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _trackerId <STRING> - Tracker ID to display
 * 4: _commandPath <STRING> - Function name for backdoor access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [nil, _laptop, "var1", "1234", "/backdoor_gpstrack"] call Root_fnc_displayGPSPosition;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_trackerId', '_commandPath'];

private _string = "";
private _trackerIdNum = parseNumber _trackerId;

if (_trackerIdNum != 0) then {
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allGpsTrackers = _allDevices param [5, []];

    if (_allGpsTrackers isEqualTo []) then {
        _string = "Error! No GPS trackers found.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _foundTracker = false;
    
    {
        // [_deviceId, _netId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _linkedComputers, _availableToFutureLaptops, ["Untracked", 0, ""], _allowRetracking, _lastPingTimer, _powerCost, _ownersSelection];

        _x params ["_storedTrackerId", "_trackerNetId", "_trackerName", "_trackingTime", "_updateFrequency", "_customMarker", "_linkedComputers", "_availableToFutureLaptops", "_currentStatus", "_allowRetracking", "_lastPingTimer", "_powerCost", ["_ownersSelection", [[], [], []]]];
        private _trackerObject = objectFromNetId _trackerNetId;
        
        if (_trackerIdNum == _storedTrackerId) then {
            // Check if this specific tracker is accessible
            if ([_computer, 6, _storedTrackerId, _commandPath] call Root_fnc_isDeviceAccessible) then {
                _foundTracker = true;

                if ((isNil "_powerCost") || (_powerCost < 1)) then { _powerCost = _trackerObject getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_COST", 10] };
                private _battery = uiNamespace getVariable "AE3_Battery";
                private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";
                
                // Check if already being tracked by this computer
                if ((_currentStatus select 0) == "Tracking") then {
                    _string = format ["Tracker '%1' (ID: %2) is already being tracked.", _trackerName, _trackerIdNum];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                } else {
                    // Check if retracking is allowed for completed trackers
                   if ((((_currentStatus select 0) in ["Completed", "Tracked"]) && !(_allowRetracking)) || ((_currentStatus select 0) in ["Untrackable", "Disabled"])) then {
                        _string = format ["Tracker '%1' (ID: %2) cannot be tracked again.", _trackerName, _trackerIdNum];
                        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    } else {
                        // Check if object still exists
                        if (isNull _trackerObject) then {
                            _string = format ["Tracker '%1' (ID: %2) - no longer exists.", _trackerName, _trackerIdNum];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            
                            // Update status to Dead
                            _allGpsTrackers set [_forEachIndex, [
                                _storedTrackerId, 
                                _trackerNetId, 
                                _trackerName, 
                                _trackingTime, 
                                _updateFrequency, 
                                _customMarker, 
                                _linkedComputers, 
                                _availableToFutureLaptops, 
                                ["Dead", 0, ""],
                                _allowRetracking,
                                _lastPingTimer,
                                _powerCost
                            ]];
                            _allDevices set [5, _allGpsTrackers];
                            missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
                        } else {
                            _string = format ['Are you sure? (Y/N): '];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            while{true} do {
                                private _areYouSure = [_computer] call AE3_armaos_fnc_shell_stdin;
                                if((_areYouSure isEqualTo "y") || (_areYouSure isEqualTo "Y")) then {
                                    break;
                                };
                                if((_areYouSure isEqualTo "n") || (_areYouSure isEqualTo "N")) then {
                                    missionNamespace setVariable [_nameOfVariable, true, true];
                                    breakTo "exit";
                                };
                            };
                            if(_batteryLevel < ((_powerCost)/1000)) then {
                                _string = format ['Error! Insufficient Power!'];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                                breakTo "exit";
                            };
                            
                            private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";
                            private _changeWh = _powerCost;
                            private _newLevel = _batteryLevel - (_changeWh/1000);
                            [_computer, _battery, _newLevel] remoteExec ["Root_fnc_removePower", 2];
                            _string = format ['Power Cost: %1Wh', _changeWh];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            _string = format ['New Power Level: %1Wh', _newLevel*1000];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                            // Start tracking
                            private _markerName = if (_customMarker != "") then { _customMarker } else { format ["ROOT_GpsTracker_%1_%2", _trackerIdNum, round(random 10000)] };
                            
                            // If there's an existing marker from a previous track, delete it first
                            if ((_currentStatus select 2) != "") then {
                                deleteMarkerLocal (_currentStatus select 2);
                            };                           
                            // Update tracker status
                            _allGpsTrackers set [_forEachIndex, [
                                _storedTrackerId, 
                                _trackerNetId, 
                                _trackerName, 
                                _trackingTime, 
                                _updateFrequency, 
                                _customMarker, 
                                _linkedComputers, 
                                _availableToFutureLaptops, 
                                ["Tracking", time, _markerName],
                                _allowRetracking,
                                _lastPingTimer,
                                _powerCost
                            ]];
                            _allDevices set [5, _allGpsTrackers];
                            missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
                            
                            _string = format ["Tracking '%1' (ID: %2) for %3 seconds.", _trackerName, _trackerIdNum, _trackingTime];
                            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                            
                            // Start tracking loop
                            private _clientID = clientOwner;
                            [_trackerObject, _markerName, _trackingTime, _updateFrequency, _storedTrackerId, _computer, _allowRetracking, _trackerIdNum, _trackerName, _clientID, _lastPingTimer, _ownersSelection] remoteExec ["Root_fnc_gpsTrackerServer", 2];
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
