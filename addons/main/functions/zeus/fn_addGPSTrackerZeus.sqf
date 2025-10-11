/*
 * Author: Root
 * Zeus module to add a GPS tracker to an object
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addGPSTrackerZeus;
 *
 * Public: No
 */

params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

if (isNull _targetObject) exitWith {
    deleteVehicle _logic;
    ["Place the module on an object!"] call zen_common_fnc_showMessage;
};

if !(hasInterface) exitWith {};
private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", 1];
ROOT_CYBERWARFARE_GPS_TRACKER_NAME = format ["GPS_Tracker_%1", _index];

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        private _netId = netId _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

private _dialogControls = [
    ["EDIT", ["Tracker Name", "Name that will appear in the terminal and as the default marker in the map for this tracker"], [ROOT_CYBERWARFARE_GPS_TRACKER_NAME]],
    ["SLIDER", ["Tracking Time (seconds)", "Maximum time in seconds the tracking will stay active"], [1, 3000, 60, 0]],
    ["SLIDER", ["Update Frequency (seconds)", "Frequency in seconds between position updates"], [1, 3000, 5, 0]],
    ["SLIDER", ["Last Ping Duration", "Frequency in seconds for the last ping to be active for"], [1, 3000, 5, 0]],
    ["SLIDER", ["Power Cost to Track", "Energy / Power (in Wh) required to track this signal"], [1, 30, 10, 1]],
    ["EDIT", ["Custom Marker (optional)", "Custom name for the map marker to be used. Leave empty to use Tracker Name"], [""]],
    ["TOOLBOX:YESNO", ["Allow Retracking", "Allow tracking again after the initial tracking time ends?"], false],
    ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this tracker be available to laptops that are added later?"], false]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this tracker to %1", _computerName]], false];
} forEach _allComputers;

[
    format ["Add GPS Tracker - %1", getText (configOf _targetObject >> "displayName")], 
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_targetObject", "_execUserId", "_allComputers", "_index"];
        
        // First six results are the tracker configuration
        _results params ["_trackerName", "_trackingTime", "_updateFrequency", "_lastPingTimer", "_powerCost", "_customMarker", "_allowRetracking", "_availableToFutureLaptops"];
        
        // The rest are checkbox values for each computer
        private _selectedComputers = [];
        private _checkboxStartIndex = 8;
        
        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // If available to future laptops, keep the selected computers but mark for future availability
        // If not available to future laptops and no computers selected, use all current computers
        if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
            _selectedComputers = _allComputers apply { _x select 0 };
        };
        
        private _underFlow = [_trackingTime, _updateFrequency, _lastPingTimer, _powerCost];
        {
            if (_x < 1) then { _x = 1; };
        } forEach _underFlow;
        
        // Pass all parameters including the availability setting
        [_targetObject, _execUserId, _selectedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost] remoteExec ["Root_fnc_addGpsTrackerZeusMain", 2];
        ["GPS Tracker Added!"] call zen_common_fnc_showMessage;
        _index = _index + 1;
        missionNamespace setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", _index, true];
    }, 
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_targetObject, _execUserId, _allComputers, _index]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
