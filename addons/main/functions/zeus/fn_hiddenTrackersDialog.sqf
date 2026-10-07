#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Opens the Hidden Trackers dialog from the roster the server sent back. Each row names a
 *              tracker, the identifier it answers to, what it is attached to and the state it is in -
 *              this is the one place a curator can read the codes - and its tick switches that
 *              tracker's private map overlay on or off.
 *
 *              The overlay is a view and nothing else: the marker exists on this curator's machine
 *              only, no other player sees it, and the tracker's registered state, its battery cost and
 *              its one-shot rule are left alone. A tick is not tracking the device; an operator still
 *              has to enter the identifier on a laptop for that.
 *
 * Arguments:
 * 0: _rows <ARRAY> - [[deviceId, identifier, name, objectName, objectNetId, status], ...]
 *
 * Return Value:
 * None
 *
 * Example:
 * [_rows] call Root_fnc_hiddenTrackersDialog;
 *
 * Public: No
 */

if !(hasInterface) exitWith {};

params [["_rows", [], [[]]]];

if (_rows isEqualTo []) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_HIDDEN_NONE"] call zen_common_fnc_showMessage;
};

private _overlays = uiNamespace getVariable ["ROOT_CYBERWARFARE_ZEUS_TRACKER_OVERLAYS", createHashMap];

private _dialogControls = [];
{
    _x params ["_deviceId", "_identifier", "_name", "_objectName", "", "_status"];
    private _label = format [localize "STR_ROOT_CYBERWARFARE_ZEUS_HIDDEN_ENTRY", _name, _identifier, _objectName, [_status] call FUNC(localizeDeviceState)];
    // The tick starts as whatever this curator currently has on their map, so the dialog reads as the
    // state of the overlays rather than as a blank form each time it is opened. It is forced, because
    // ZEN would otherwise restore what the dialog was last confirmed with.
    _dialogControls pushBack ["CHECKBOX", [_label, localize "STR_ROOT_CYBERWARFARE_ZEUS_HIDDEN_ENTRY_DESC"], (str _deviceId) in _overlays, true];
} forEach _rows;

[
    localize "STR_ROOT_CYBERWARFARE_ZEUS_HIDDEN_TITLE",
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_rows"];

        private _shown = 0;
        {
            _x params ["_deviceId", "_identifier", "_name", "", "_objectNetId"];
            private _enabled = _results select _forEachIndex;
            [_deviceId, _objectNetId, format ["%1 (%2)", _name, _identifier], _enabled] call FUNC(zeusTrackerMarker);
            if (_enabled) then { _shown = _shown + 1; };
        } forEach _rows;

        [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_HIDDEN_APPLIED", _shown]] call zen_common_fnc_showMessage;
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_rows]
] call zen_dialog_fnc_create;
