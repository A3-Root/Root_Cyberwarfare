#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Searches a target object for GPS trackers with probability-based detection
 *
 * Arguments:
 * 0: _target <OBJECT> - The object to search
 * 1: _player <OBJECT> - The player performing the search
 *
 * Return Value:
 * None
 *
 * Example:
 * [_target, player] call Root_fnc_searchForGPSTracker;
 *
 * Public: No
 */

params ["_target", "_player"];

if (isNull _target || {_target == _player}) exitWith {
    ["Cannot search this target!", true, 1.5, 2] call ace_common_fnc_displayText;
};

private _isBeingSearched = missionNamespace getVariable ["ROOT_CYBERWARFARE_ACTIVE_SEARCH", false];
if (_isBeingSearched) exitWith {
    ["Search already underway by another person!", true, 1.5, 2] call ace_common_fnc_displayText;
};
missionNamespace setVariable ["ROOT_CYBERWARFARE_ACTIVE_SEARCH", true, true];

// Check if player has spectrum device
private _hasSpectrumDevice = false;

private _spectrumDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_SPECTRUM_DEVICE", ["hgun_esd_01_antenna_01_F", "hgun_esd_01_antenna_02_F", "hgun_esd_01_antenna_03_F", "hgun_esd_01_base_F", "hgun_esd_01_dummy_F", "hgun_esd_01_F"]];
private _detectTool = missionNamespace getVariable ["ROOT_CYBERWARFARE_SPECTRUM_DETTOOL", 0.8];
private _detectNormal = missionNamespace getVariable ["ROOT_CYBERWARFARE_SPECTRUM_DETNORM", 0.2];

{
    if (_x in (weapons _player)) exitWith {
        _hasSpectrumDevice = true;
    };
} forEach _spectrumDevices;

// Calculate detection chance
private _detectionChance = [_detectNormal, _detectTool] select (_hasSpectrumDevice);

// Check if target actually has a GPS tracker
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
private _allGpsTrackers = _allDevices select 5;

private _targetNetId = netId _target;
private _hasTracker = false;
private _trackerData = [];

{
    private _trackerNetId = _x select 1;
    if (_trackerNetId == _targetNetId) exitWith {
        _hasTracker = true;
        _trackerData = _x;
    };
} forEach _allGpsTrackers;

// Random check for detection
private _detected = (random 1) < _detectionChance;

if ((!_hasTracker) || (!_detected)) exitWith {
    ["Search complete. No GPS tracker detected.", true, 1.5, 2] call ace_common_fnc_displayText;
};

// GPS tracker found!
_trackerData params ["_trackerId", "_trackerNetId", "_trackerName", "_trackingTime", "_updateFrequency", "_customMarker", "_linkedComputers", "_availableToFutureLaptops", "_currentStatus", "_allowRetracking", "_lastPingTimer", "_powerCost"];

[format ["GPS Tracker detected: %1", _trackerName], true, 1.5, 2] call ace_common_fnc_displayText;

// Show different options based on equipment
if (_hasSpectrumDevice) then {
    ["GPS Tracker(s) Detected Over Broadspectrum", [
        ["TOOLBOX:YESNO", ["Disable GPS Tracker?", "Disables this GPS Tracker. WARNING: Will alert active connected devices about the abrupt failure of this tracker."], false],
        ["TOOLBOX:YESNO", ["Reverse Trace Connections", "Attempts to reverse trace the pings sent and received by this tracker."], false]
        ], {
            params ["_results", "_args"];
            _args params ["_target", "_player", "_trackerData", "_linkedComputers"];
            _results params ["_trackerDisable", "_reverseLookup"];

            if (_trackerDisable) then {
                [_target, _trackerData, _player] call Root_fnc_disableGPSTracker;
                ["GPS Tracker disabled!", true, 1.5, 2] call ace_common_fnc_displayText;
            };
            if (_reverseLookup) then {
                [_linkedComputers, _player, false] call Root_fnc_revealLaptopLocations;
                ["Laptop locations revealed on map!", true, 1.5, 2] call ace_common_fnc_displayText;
            };
        }, {
            ["Aborted"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        },
        [_target, _player, _trackerData, _linkedComputers]
    ] call zen_dialog_fnc_create;
} else {
    ["GPS Tracker(s) Device Detected", [
        ["TOOLBOX:YESNO", ["Disable GPS Tracker?", "Disables this GPS Tracker. WARNING: Will alert active connected devices about the abrupt failure of this tracker."], false]
        ], {
            params ["_results", "_args"];
            _args params ["_target", "_player", "_trackerData"];
            _results params ["_trackerDisable"];

            if (_trackerDisable) then {
                [_target, _trackerData, _player] call Root_fnc_disableGPSTracker;
                ["GPS Tracker disabled!", true, 1.5, 2] call ace_common_fnc_displayText;
            };

        }, {
            ["Aborted"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        },
        [_target, _player, _trackerData]
    ] call zen_dialog_fnc_create;
};
missionNamespace setVariable ["ROOT_CYBERWARFARE_ACTIVE_SEARCH", false, true];
