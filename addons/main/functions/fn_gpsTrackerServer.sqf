params ["_trackerObject", "_markerName", "_trackingTime", "_updateFrequency", "_trackerId", "_computer", "_allowRetracking", "_trackerIdNum", "_trackerName", "_clientID", "_lastPingTimer"];

private _startTime = time;
private _endTime = _startTime + _trackingTime;
private _trackerPos = [];
private _computerNetId = netId _computer;

// Update tracker status to "Tracked" on server
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
            ["Tracked", time, _markerName],
            _x select 9
        ]];
        _allDevices set [5, _allGpsTrackers];
        missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
    };
} forEach _allGpsTrackers;

[_trackerObject, _markerName, _trackingTime, _updateFrequency, _trackerName, _lastPingTimer] remoteExec ["Root_fnc_gpsTrackerClient", _clientID];

waitUntil {time < (_endTime + 2)};

private _lastPosition = [0, 0, 0];
_lastPosition = getPos _trackerObject;

// Tracking completed - update status
private _newStatus = "Completed"; 
if !(_allowRetracking) then {
    _newStatus = "Untrackable";
};

// If tracker object was destroyed during tracking
if (isNull _trackerObject) then {
    _newStatus = "Dead";
};

// Update the global tracker status
_allDevices = missionNamespace getVariable ["ROOT-All-Devices", []];
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
            _x select 9
        ]];
        _allDevices set [5, _allGpsTrackers];
        missionNamespace setVariable ["ROOT-All-Devices", _allDevices, true];
    };
} forEach _allGpsTrackers;

// Send completion message to the original computer if it still exists
private _computerObj = objectFromNetId _computerNetId;
if (!isNull _computerObj) then {
    private _string = format ["Tracking for target '%1' (ID: %2) has ended.", _trackerName, _trackerIdNum];
    [_computerObj, _string] call AE3_armaos_fnc_shell_stdout;
    
    private _trackerGridPos = mapGridPosition _lastPosition;
    _string = format ["     Last pinged position: %1.", _trackerGridPos];
    [_computerObj, _string] call AE3_armaos_fnc_shell_stdout;
};
