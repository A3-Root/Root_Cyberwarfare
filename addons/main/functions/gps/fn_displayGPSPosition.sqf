#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Starts tracking a GPS tracker and displays its position on the map. The tracker may be
 * named either by its device ID, which is what a laptop that lists the tracker shows, or by the
 * eight-character identifier the tracker answers to. An identifier is resolved by the server, because
 * the identifiers are the mission's secrets and are never sent to a client; the resolution also
 * carries the permission with it, which is what lets a code reach a tracker no laptop here is wired
 * to.
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _trackerId <STRING> - Tracker ID, or the identifier the tracker answers to
 * 4: _commandPath <STRING> - Function name for backdoor access checking
 * 5: _bypassAccess <BOOL> (Optional) - Set by the identifier path once the server has resolved a
 *                                      valid code, which is itself the permission, default: false
 *
 * Return Value:
 * None
 *
 * Example:
 * [123, _laptop, "var1", "1234", "/backdoor_gpstrack"] call Root_fnc_displayGPSPosition;
 * [123, _laptop, "var1", "D34FNDUM", "/backdoor_gpstrack"] call Root_fnc_displayGPSPosition;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_trackerId', '_commandPath', ['_bypassAccess', false, [false]]];

// Check for help request
if (_trackerId in ["-h", "help"]) exitWith {
    [_computer, [[["GPSTRACK COMMAND HELP", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Description:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Track GPS-enabled devices or targets in real-time on your map."]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Syntax:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["gpstrack <TrackerID|Identifier>"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Parameters:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["TrackerID", "#008DF8"], ["   - ID of a GPS tracker this terminal can see", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["Identifier", "#008DF8"], ["  - 8-character code issued when a tracker was planted", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Examples:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  gpstrack 1234       - Start tracking GPS device #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  gpstrack D34FNDUM   - Start tracking the tracker that code belongs to"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Note:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- A code works from any terminal with the toolset, whether or not this one lists the tracker"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- A code can only be entered on a terminal that is connected to a network"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Some trackers are hidden and appear in no listing; a code is the only way to reach them"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Creates a map marker showing target's position"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Updates at configured intervals"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Some trackers may have limited duration"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Tracking continues until duration expires or tracker is disabled"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Requires power confirmation"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Check if tracker allows re-tracking after completion"]]]] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

private _string = "";
private _trackerIdNum = parseNumber _trackerId;

// Which of the two ways of naming a tracker this is. A device id is four digits, so a token of
// identifier length is an identifier even when it happens to be all digits, and anything that is not
// a number at all is an identifier too - which is also how a typo gets a clear answer instead of a
// silent timeout. An identifier is handed to the server to resolve, and the reply re-enters this
// function with the resolved device id and the permission the code carries, so everything below -
// cost, battery prompt, status rules - happens exactly once and identically for both.
private _candidate = [_trackerId] call CBA_fnc_trim;
private _isIdentifier = _candidate isNotEqualTo "" && {
    (count _candidate) == GPS_IDENTIFIER_LENGTH || {!(_candidate regexMatch "^[0-9]+$")}
};

if (_isIdentifier) exitWith {
    [
        "root_cyberwarfare_gpsResolveIdentifier",
        [netId _computer, _trackerId, _owner, _commandPath, _nameOfVariable]
    ] call CBA_fnc_serverEvent;
};

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
            // Check if this specific tracker is accessible. A tracker named by its identifier skips
            // this: the code is the credential, and a laptop holding no link to the tracker is
            // exactly the case it exists for.
            if (_bypassAccess || {[_computer, 6, _storedTrackerId, _commandPath] call Root_fnc_isDeviceAccessible}) then {
                _foundTracker = true;

                // A tracker registered with a cost of its own is billed at that; every other tracker is
                // billed at the mission's GPS setting.
                if ((isNil "_powerCost") || (_powerCost < 1)) then {
                    _powerCost = _trackerObject getVariable [
                        "ROOT_CYBERWARFARE_GPS_TRACKER_COST",
                        missionNamespace getVariable [SETTING_GPS_COST, 10]
                    ];
                };

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

                            // local copy update only - the server applies and broadcasts the authoritative change

                            missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];

                            ["root_cyberwarfare_updateTrackerStatus", [_storedTrackerId, (_allGpsTrackers select _forEachIndex) select 8]] call CBA_fnc_serverEvent;
                        } else {
                            if !([_computer, _powerCost] call FUNC(checkPowerAvailable)) then {
                                _string = format ['Error! Insufficient Power!'];
                                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                                breakTo "exit";
                            };

                            if !([_computer, _powerCost] call FUNC(getUserConfirmation)) then {
                                missionNamespace setVariable [_nameOfVariable, true, true];
                                breakTo "exit";
                            };

                            [_computer, _powerCost] call FUNC(consumePower);

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

                            // local copy update only - the server applies and broadcasts the authoritative change

                            missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];

                            ["root_cyberwarfare_updateTrackerStatus", [_storedTrackerId, (_allGpsTrackers select _forEachIndex) select 8]] call CBA_fnc_serverEvent;
                            
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
