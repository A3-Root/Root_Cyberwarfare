#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
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

// If no attached object (Zeus-placed), try to find terrain object at logic position
if (isNull _targetObject) then {
    private _logicPos = getPosATL _logic;
    private _nearObjects = nearestObjects [_logicPos, [], 5];

    // Find the closest object that isn't the logic itself
    {
        if (_x != _logic && !(_x isKindOf "Logic")) exitWith {
            _targetObject = _x;
        };
    } forEach _nearObjects;

    // If still no object found, show error
    if (isNull _targetObject) exitWith {
        deleteVehicle _logic;
        [(localize "STR_ROOT_CYBERWARFARE_UI_PLACE_THE_MODULE_ON_AN_OBJECT")] call zen_common_fnc_showMessage;
    };
};

if !(hasInterface) exitWith {};
private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", 1];
ROOT_CYBERWARFARE_GPS_TRACKER_NAME = format ["GPS_Tracker_%1", _index];

// Every laptop the tracker can be linked to. Without one the dialog still works, but only the Unassigned
// and Public access modes can do anything, so the curator is told before spending time on the form.
private _allComputers = call FUNC(getRegisteredLaptops);
if (_allComputers isEqualTo []) then {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS_WARN"] call zen_common_fnc_showMessage;
};

private _dialogControls = [
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_TRACKER_NAME"), (localize "STR_ROOT_CYBERWARFARE_UI_NAME_THAT_WILL_APPEAR_IN_THE_TERMINAL_AND_AS_THE_DEFAULT_MARKER_2")], [ROOT_CYBERWARFARE_GPS_TRACKER_NAME]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME"), (localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME_DESC")], [1, 3000, 60, 0]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_FREQ"), (localize "STR_ROOT_CYBERWARFARE_UI_FREQUENCY_IN_SECONDS_BETWEEN_POSITION_UPDATES")], [1, 3000, 5, 0]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_LAST_PING_DURATION"), (localize "STR_ROOT_CYBERWARFARE_UI_FREQUENCY_IN_SECONDS_FOR_THE_LAST_PING_TO_BE_ACTIVE_FOR")], [1, 3000, 5, 0]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_POWER_COST_TO_TRACK"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_TRACK_THIS_SIGNAL")], [1, 30, 10, 1]],
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_CUSTOM_MARKER_OPTIONAL"), (localize "STR_ROOT_CYBERWARFARE_UI_CUSTOM_NAME_FOR_THE_MAP_MARKER_TO_BE_USED_LEAVE_EMPTY_TO")], [""]],
    ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_RETRACKING"), (localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_TRACKING_AGAIN_AFTER_THE_INITIAL_TRACKING_TIME_ENDS_2")], false],
    ["OWNERS", [(localize "STR_ROOT_CYBERWARFARE_UI_ADDITIONAL_GPS_TRACKING_VISIBILITY"), (localize "STR_ROOT_CYBERWARFARE_UI_ADDITIONAL_APART_FROM_THE_PLAYER_WHO_INITIATED_THE_TRACK_SIDES_GROUPS_OR")], [[], [], [], 0]],
    ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
        [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
        [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"],
        0
    ]],
    ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE"), (localize "STR_ROOT_CYBERWARFARE_UI_ONLY_APPLIES_TO_LINKED_COMPUTERS_ONLY_THE_LINKED_COMPUTERS_KEEP_ACCESS_AND")], false],
    ["TOOLBOX:YESNO", [localize "STR_ROOT_CYBERWARFARE_GPS_HIDDEN", localize "STR_ROOT_CYBERWARFARE_GPS_HIDDEN_DESC"], false],
    ["EDIT", [localize "STR_ROOT_CYBERWARFARE_GPS_IDENTIFIER_FIELD", localize "STR_ROOT_CYBERWARFARE_GPS_IDENTIFIER_FIELD_DESC"], [""]],
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIXED_ID_FOR_THIS_TRACKER_0_AUTO_ASSIGN_A_FREE_ID")], ["0"]]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_THIS_TRACKER_TO_1"), _computerName]], false];
} forEach _allComputers;

[
    format [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_GPS_TRACKER_1"), getText (configOf _targetObject >> "displayName")],
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_targetObject", "_execUserId", "_allComputers", "_index"];

        // First results are the tracker configuration
        _results params ["_trackerName", "_trackingTime", "_updateFrequency", "_lastPingTimer", "_powerCost", "_customMarker", "_allowRetracking", "_ownersSelection", "_accessMode", "_availableToFutureLaptops", "_hidden", "_requestedIdentifier", "_requestedIdText"];
        private _requestedId = parseNumber _requestedIdText;

        // The rest are checkbox values for each computer
        private _selectedComputers = [];
        private _checkboxStartIndex = 13;

        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;


        private _underFlow = [_trackingTime, _updateFrequency, _lastPingTimer, _powerCost];
        {
            if (_x < 1) then { _x = 1; };
        } forEach _underFlow;
        
        // Pass all parameters including the availability setting and owners selection
        [_targetObject, _execUserId, _selectedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, true, _ownersSelection, _requestedId, _accessMode, _hidden, _requestedIdentifier, getPlayerUID player] remoteExec ["Root_fnc_addGpsTrackerZeusMain", 2];
        [(localize "STR_ROOT_CYBERWARFARE_UI_GPS_TRACKER_ADDED")] call zen_common_fnc_showMessage;

        // A hidden tracker is reached by its identifier rather than by laptop access, so the usual
        // "no laptop can reach this" warning would be telling the curator off for the normal case.
        if (!_hidden) then {
            // Linked access with nothing ticked registers a device no laptop can reach, which the
            // success message above does not convey on its own.
            [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
        };
        _index = _index + 1;
        missionNamespace setVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", _index, true];
    }, 
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_targetObject, _execUserId, _allComputers, _index]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
