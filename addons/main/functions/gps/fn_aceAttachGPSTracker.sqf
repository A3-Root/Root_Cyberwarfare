#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ACE interaction to attach a GPS tracker to a target (object, vehicle, or self).
 *              Opens a configuration dialog first, then runs the ACE progress bar, then registers the
 *              tracker on the server. The dialog carries the tracking timings and, like every device
 *              module, the device's reachability: an access mode plus a tick per registered laptop, so
 *              the operator says which stations the tracker reports to instead of the tracker being
 *              registered with nobody able to read it. Every ticked laptop is resolved server-side to
 *              the identifier the link cache is keyed by, so the choice holds in both device setup
 *              modes.
 *
 * Arguments:
 * 0: _target <OBJECT> - The object to attach the GPS tracker to
 * 1: _player <OBJECT> - The player attaching the tracker
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, player] call Root_fnc_aceAttachGPSTracker;
 * [vehicle player, player] call Root_fnc_aceAttachGPSTracker;
 *
 * Public: No
 */

params ["_target", "_player"];

// Get GPS tracker item class from CBA settings
private _itemClass = missionNamespace getVariable [SETTING_GPS_TRACKER_DEVICE, "ACE_Banana"];
private _execUserId = clientOwner;

// Use existing GPS tracker functions with default parameters
private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", 1];
private _trackerName = format ["GPS_Tracker_%1", _index];

// Every laptop the tracker can be linked to, kept as [netId, name] rows so each tick can be labelled
// with the station's name. Without one the dialog still works, but only the Unassigned and Public
// access modes can do anything, so the operator is told before spending time on the form.
private _allComputers = call FUNC(getRegisteredLaptops);
if (_allComputers isEqualTo []) then {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS_WARN"] call zen_common_fnc_showMessage;
};

private _dialogControls = [
    ["SLIDER", [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME", localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME_DESC"], [1, 30000, 60, 0]],
    ["SLIDER", [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_FREQ", localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_FREQ_DESC"], [1, 3000, 5, 0]],
    ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
        [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
        [
            localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED",
            localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED",
            localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"
        ],
        1
    ]]
];

// One tick per station, pre-ticked: a tracker an operator plants in the field is normally meant to
// report to every station that exists, and unticking is how that is narrowed down.
{
    _x params ["", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_LAPTOP_DESC", _computerName]], true];
} forEach _allComputers;

[
    localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TITLE",
    _dialogControls,
    {
        // On dialog accept - show progress bar and attach tracker
        params ["_results", "_args"];
        _args params ["_target", "_player", "_itemClass", "_execUserId", "_allComputers", "_trackerName", "_index"];
        _results params ["_trackingTime", "_updateFrequency", "_accessMode"];

        // Validate inputs
        if (_trackingTime < 1) then { _trackingTime = 1; };
        if (_updateFrequency < 1) then { _updateFrequency = 1; };

        // The ticks sit after the three fixed controls, in the order the laptops were offered.
        private _checkboxStartIndex = 3;
        private _selectedComputers = [];
        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // Set default parameters
        private _lastPingTimer = 30;  // Seconds before last known position is shown
        private _powerCost = 2;        // Power cost per ping in Wh
        private _customMarker = "";    // No custom marker
        private _allowRetracking = false;  // One time tracking only
        private _availableToFutureLaptops = true;  // Laptops registered later reach it too

        // Now show ACE progress bar AFTER configuration
        [
            5,  // Duration in seconds
            [_target, _player, _itemClass, _execUserId, _selectedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _index, _accessMode],
            {
                // On progress bar completion
                params ["_args"];
                _args params ["_target", "_player", "_itemClass", "_execUserId", "_selectedComputers", "_trackerName", "_trackingTime", "_updateFrequency", "_customMarker", "_availableToFutureLaptops", "_allowRetracking", "_lastPingTimer", "_powerCost", "_index", "_accessMode"];

                // Call server-side function to register tracker. The chosen access mode is what decides
                // whether the ticked laptops are written as private links, published, or left for later.
                [_target, _execUserId, _selectedComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, false, [[], [], []], 0, _accessMode] remoteExec ["Root_fnc_addGpsTrackerZeusMain", 2];

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
                [format [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_SUCCESS", getText (configOf _target >> "displayName")], 2] call ACE_common_fnc_displayTextStructured;

                // Linked access with nothing ticked registers a tracker no laptop can reach, which the
                // dialog does not convey on its own.
                [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
            },
            {
                // On progress bar failure/cancellation
                params ["_args"];
                _args params ["_target", "_player"];
                [format [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_FAILED", getText (configOf _target >> "displayName")], true, 1.5, 2] call ace_common_fnc_displayText;
            },
            format [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACHING_OBJECT", getText (configOf _target >> "displayName")],
            {
                // Condition to continue - target and player must be valid
                params ["_args"];
                _args params ["_target", "_player"];
                !isNull _target && {alive _player}
            },
            ["isNotInside"]  // Exceptions
        ] call ace_common_fnc_progressBar;

    },
    {
        // On dialog cancel
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_target, _player, _itemClass, _execUserId, _allComputers, _trackerName, _index]
] call zen_dialog_fnc_create;
