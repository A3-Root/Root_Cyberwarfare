/*
 * Author: Root
 * Description: ACE interaction callback to attach a GPS tracker to an object
 *              Creates a ZEN dialog for configuring tracker parameters, then consumes
 *              the GPS tracker item from player inventory and attaches tracker to target
 *
 * Arguments:
 * 0: _target <OBJECT> - The object to attach the GPS tracker to
 * 1: _player <OBJECT> - The player attaching the tracker
 *
 * Return Value:
 * None
 *
 * Example:
 * [_target, _player] call Root_fnc_aceAttachGPSTrackerObject;
 *
 * Public: No
 */

params ["_target", "_player"];

// Get GPS tracker item class from CBA settings
private _execUserId = clientOwner;

// Use existing GPS tracker functions with default parameters
private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", 1];
private _trackerName = format ["GPS_Tracker_%1", _index];

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
        private _netId = netId _x;
        _allComputers pushBack _netId;
    };
} forEach (24 allObjects 1); // 24 = EmptyDetector class number

// Create ZEN dialog for tracker configuration
["GPS Tracker Configuration", [
	["SLIDER", ["Tracking Time (seconds)", "Maximum time in seconds the tracking will stay active"], [1, 30000, 60, 0]],
    ["SLIDER", ["Update Frequency (seconds)", "Frequency in seconds between ping updates"], [1, 3000, 5, 0]]
	], {
		// On dialog accept
		params ["_results", "_args"];
        _args params ["_target", "_execUserId", "_allComputers", "_trackerName", "_index"];
        _results params ["_trackingTime", "_updateFrequency"];

        // Set default parameters
        private _lastPingTimer = 30;  // Seconds before last known position is shown
        private _powerCost = 2;        // Power cost per ping in Wh
        private _customMarker = "";    // No custom marker
        private _allowRetracking = true;  // Allow retracking same target
        private _availableToFutureLaptops = true;  // All laptops can access

        // Validate inputs
        if (_trackingTime < 1) then { _trackingTime = 1; };
        if (_updateFrequency < 1) then { _updateFrequency = 1; };

        // Call server-side function to register tracker
        [_target, _execUserId, _allComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, false] remoteExec ["Root_fnc_addGpsTrackerZeusMain", 2];

        // Remove GPS tracker item from player inventory
        // Check each container in priority order
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

        // Increment tracker index for next tracker
        missionNamespace setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", _index + 1, true];

        // Show success message
        [format ["GPS Tracker attached successfully to %1!", getText (configOf _target >> "displayName")], 2] call ACE_common_fnc_displayTextStructured;
	}, {
		// On dialog cancel
		["Aborted"] call zen_common_fnc_showMessage;
		playSound "FD_Start_F";
	},
    [_target, _execUserId, _allComputers, _trackerName, _index]
] call zen_dialog_fnc_create;
