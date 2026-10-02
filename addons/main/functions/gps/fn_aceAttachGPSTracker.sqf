#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ACE interaction to attach a GPS tracker to a target (object, vehicle, or self). The
 *              dialog asks only what a soldier in the field can answer - how long the tracker should
 *              report for, and how often - and the progress bar then plants it.
 *
 *              A tracker planted by hand is covert: it appears in no laptop's device list, and the
 *              only way to follow it is to enter the eight-character identifier the plant produces on
 *              a laptop that is connected to a network. The identifier reaches the attacher as a hint
 *              and as a record in their own briefing diary, and whoever they pass it to can follow
 *              the tracker from any laptop, which is the point: the code is the thing worth guarding.
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

[
    localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TITLE",
    [
        ["SLIDER", [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME", localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME_DESC"], [1, 30000, 60, 0]],
        ["SLIDER", [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_FREQ", localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_FREQ_DESC"], [1, 3000, 5, 0]]
    ],
    {
        // On dialog accept - show progress bar and attach tracker
        params ["_results", "_args"];
        _args params ["_target", "_player", "_itemClass", "_execUserId", "_trackerName", "_index"];
        _results params ["_trackingTime", "_updateFrequency"];

        // Validate inputs
        if (_trackingTime < 1) then { _trackingTime = 1; };
        if (_updateFrequency < 1) then { _updateFrequency = 1; };

        // Set default parameters
        private _lastPingTimer = 30;  // Seconds before last known position is shown
        private _powerCost = 2;        // Power cost per ping in Wh
        private _customMarker = "";    // No custom marker
        private _allowRetracking = false;  // One time tracking only
        private _availableToFutureLaptops = false;  // Reached by its identifier, not by laptop access

        // Now show ACE progress bar AFTER configuration
        [
            5,  // Duration in seconds
            [_target, _player, _itemClass, _execUserId, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, _index],
            {
                // On progress bar completion
                params ["_args"];
                _args params ["_target", "_player", "_itemClass", "_execUserId", "_trackerName", "_trackingTime", "_updateFrequency", "_customMarker", "_availableToFutureLaptops", "_allowRetracking", "_lastPingTimer", "_powerCost", "_index"];

                // Registered as hidden, with no laptop named: the identifier the server mints is what
                // grants access to it, so there is nothing here to wire.
                [_target, _execUserId, [], _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost, false, [[], [], []], 0, ACCESS_MODE_UNASSIGNED, true, "", getPlayerUID _player] remoteExec ["Root_fnc_addGpsTrackerZeusMain", 2];

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

                // Show success message. The identifier arrives from the server a moment later, as a
                // hint of its own and as the diary record.
                [format [localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_SUCCESS", getText (configOf _target >> "displayName")], 2] call ACE_common_fnc_displayTextStructured;
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
    [_target, _player, _itemClass, _execUserId, _trackerName, _index]
] call zen_dialog_fnc_create;
