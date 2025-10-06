params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

if (isNull _targetObject) exitWith {
    deleteVehicle _logic;
    ["Place the module on an object!"] call zen_common_fnc_showMessage;
};

if !(hasInterface) exitWith {};

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_HackingTools", false]) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CustomName", _displayName];
        private _netId = netId _x;
        private _position = getPosATL _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

private _dialogControls = [
    ["EDIT", ["Tracker Name", "Name that will appear in the terminal for this tracker"], ["High Value Target"]],
    ["SLIDER", ["Tracking Time (seconds)", "Maximum time in seconds the tracking will stay active"], [0, 300, 60, 0]],
    ["SLIDER", ["Update Frequency (seconds)", "Frequency in seconds between position updates"], [0, 30, 5, 0]],
    ["EDIT", ["Custom Marker (optional)", "Custom marker name to use (leave empty for default)"], [""]],
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
        _args params ["_targetObject", "_execUserId", "_allComputers"];
        
        // First five results are the tracker configuration
        _results params ["_trackerName", "_trackingTime", "_updateFrequency", "_customMarker", "_availableToFutureLaptops"];
        
        // The rest are checkbox values for each computer
        private _selectedComputers = [];
        private _checkboxStartIndex = 5;
        
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
        
        // Pass all parameters including the availability setting
        [_targetObject, _execUserId, _selectedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops] remoteExec ["Root_fnc_addGPSTrackerZeusMain", 2];
        ["GPS Tracker Added!"] call zen_common_fnc_showMessage;
    }, 
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_targetObject, _execUserId, _allComputers]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
