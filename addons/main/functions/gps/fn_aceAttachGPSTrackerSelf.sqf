params ["_player"];
private _execUserId = clientOwner;

// Get the target object (player's vehicle if in vehicle, otherwise player)
private _target = vehicle _player;

// Use existing GPS tracker functions with default parameters
private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", 1];
private _trackerName = format ["GPS_Tracker_%1", _index];

// Get all existing laptops
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
        private _netId = netId _x;
        _allComputers pushBack _netId;
    };
} forEach (24 allObjects 1);

["GPS Tracker Configuration", [
	["SLIDER", ["Tracking Time (seconds)", "Maximum time in seconds the tracking will stay active"], [1, 30000, 60, 0]],
    ["SLIDER", ["Update Frequency (seconds)", "Frequency in seconds between ping updates"], [1, 3000, 5, 0]]
	], {
		params ["_results", "_args"];
        _args params ["_target", "_execUserId", "_allComputers", "_trackerName", "_index"];
        _results params ["_trackingTime", "_updateFrequency"];

        if (_trackingTime < 1) then { _trackingTime = 1; };
        if (_updateFrequency < 1) then { _updateFrequency = 1; };

        private _lastPingTimer = 30;
        private _powerCost = 2;
        private _customMarker = "";
        private _allowRetracking = true;
        private _availableToFutureLaptops = true;

        [_target, _execUserId, _allComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, false] remoteExec ["Root_fnc_addGpsTrackerZeusMain", 2];

        if (uniformItems _player find _itemClass >= 0) then {
            _player removeItemFromUniform _itemClass;
        } else {
            if (vestItems _player find _itemClass >= 0) then {
                _player removeItemFromVest _itemClass;
            } else {
                if (backpackItems _player find _itemClass >= 0) then {
                    _player removeItemFromBackpack _itemClass;
                } else {
                    if (items _player find _itemClass >= 0) then {
                        _player removeItem _itemClass;
                    };
                };
            };
        };

        missionNamespace setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", _index + 1, true];

        [format ["GPS Tracker attached successfully to %1!", getText (configOf _target >> "displayName")], 2] call ACE_common_fnc_displayTextStructured;
	}, {
		["Aborted"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	},
    [_target, _execUserId, _allComputers, _trackerName, _index]
] call zen_dialog_fnc_create;
