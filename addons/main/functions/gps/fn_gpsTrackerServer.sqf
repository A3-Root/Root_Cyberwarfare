params ["_trackerObject", "_markerName", "_trackingTime", "_updateFrequency", "_trackerId", "_computer", "_allowRetracking", "_trackerIdNum", "_trackerName", "_clientID", "_lastPingTimer"];

private _computerNetId = netId _computer;

// Update tracker status to "Tracking" on server
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
private _allGpsTrackers = _allDevices param [5, []];

{
    if ((_x select 0) == _trackerId) then {
        // [_deviceId, _netId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _linkedComputers, _availableToFutureLaptops, ["Untracked", 0, ""], _allowRetracking, _lastPingTimer, _powerCost];
        _allGpsTrackers set [_forEachIndex, [
            _x select 0, 
            _x select 1, 
            _x select 2, 
            _x select 3, 
            _x select 4, 
            _x select 5, 
            _x select 6, 
            _x select 7, 
            ["Tracking", time, _markerName],
            _x select 9,
            _x select 10,
            _x select 11
        ]];
        _allDevices set [5, _allGpsTrackers];
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
    };
} forEach _allGpsTrackers;

[_trackerObject, _markerName, _trackingTime, _updateFrequency, _trackerName, _lastPingTimer] remoteExec ["Root_fnc_gpsTrackerClient", _clientID];

uiSleep (_trackingTime + 0.5);
// waitUntil {time > _endTime};

private _lastPosition = [0, 0, 0];
_lastPosition = getPos _trackerObject;

// Tracking completed - update status
private _newStatus = "Completed"; 
if !(_allowRetracking) then {
    _newStatus = "Untrackable";
};

// Update the global tracker status
_allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
_allGpsTrackers = _allDevices param [5, []];

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
            _x select 9,
            _x select 10,
            _x select 11
        ]];
        _allDevices set [5, _allGpsTrackers];
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
    };
} forEach _allGpsTrackers;

// Send completion message to the original computer if it still exists
private _trackerComputer = objectFromNetId _computerNetId;
if (!isNull _trackerComputer) then {
    private _trackerGridPos = mapGridPosition _lastPosition;
    private _string = format ["Tracking for target '%1' (ID: %2) has ended at last position: %3.", _trackerName, _trackerIdNum, _trackerGridPos];
    [_trackerComputer, _string] call AE3_armaos_fnc_shell_stdout;
    [_trackerComputer, _string] remoteExec ["AE3_armaos_fnc_shell_stdout", _clientID];
    _string = format ["     Last pinged position: %1.", _trackerGridPos];
    [_trackerComputer, _string] call AE3_armaos_fnc_shell_stdout;
    [_trackerComputer, _string] remoteExec ["AE3_armaos_fnc_shell_stdout", _clientID];
};

scopeName "exit";
