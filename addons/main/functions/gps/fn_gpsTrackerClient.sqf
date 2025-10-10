params ["_trackerObject", "_markerName", "_trackingTime", "_updateFrequency", "_trackerName", "_lastPingTimer"];

private _startTime = time;
private _endTime = _startTime + _trackingTime;

private _trackerPos = [];
_trackerPos = getPos _trackerObject;

private _marker = createMarkerLocal [_markerName, _trackerPos];
_marker setMarkerTypeLocal "mil_dot";
_marker setMarkerTextLocal _trackerName;
_marker setMarkerColorLocal "ColorRed";

while {time < _endTime && !isNull _trackerObject} do {
    _trackerPos = getPos _trackerObject;
    _markerName setMarkerPosLocal _trackerPos;
    uiSleep _updateFrequency;
};

private _completed = format ["%1 (Last Ping)", _trackerName];
_marker setMarkerTextLocal _completed;
_marker setMarkerColorLocal "ColorCIV";

[_marker, _lastPingTimer] spawn {
    params ["_marker", "_lastPingTimer"];
    uiSleep _lastPingTimer;
    deleteMarkerLocal _marker;
};
