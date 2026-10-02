#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Switches a curator's private overlay for one GPS tracker on or off. The overlay is a
 * marker on the curator's own map that follows the tracked object, so a curator can confirm in the
 * field that a hidden tracker is on the thing it was meant to be on.
 *
 * It is a view and nothing more. The marker is created locally on the curator's machine, so no other
 * player sees it; the tracker's registered status, its battery cost, its tracking duration and its
 * one-shot rule are all untouched, and switching the overlay on is not tracking the device - an
 * operator still has to enter the identifier on a laptop for that.
 *
 * One frame handler serves every overlay this curator has open. It drops the overlay of an object
 * that no longer exists, and takes itself down once the last overlay is off.
 *
 * Arguments:
 * 0: _deviceId <NUMBER> - Tracker device id the overlay belongs to
 * 1: _objectNetId <STRING> - netId of the tracked object
 * 2: _label <STRING> - Marker label, normally the tracker name and its identifier
 * 3: _enabled <BOOL> - true shows the overlay, false removes it
 *
 * Return Value:
 * None
 *
 * Example:
 * [1004, "2:14", "Tracker_1 (D34FNDUM)", true] call Root_fnc_zeusTrackerMarker;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

params [
    ["_deviceId", 0, [0]],
    ["_objectNetId", "", [""]],
    ["_label", "", [""]],
    ["_enabled", false, [false]]
];

private _overlays = uiNamespace getVariable ["ROOT_CYBERWARFARE_ZEUS_TRACKER_OVERLAYS", createHashMap];
uiNamespace setVariable ["ROOT_CYBERWARFARE_ZEUS_TRACKER_OVERLAYS", _overlays];

private _key = str _deviceId;
private _markerName = format ["ROOT_ZEUS_TRACK_%1", _deviceId];

if (!_enabled) exitWith {
    if (_key in _overlays) then {
        deleteMarkerLocal _markerName;
        _overlays deleteAt _key;
        DEBUG_LOG_1("Curator tracker overlay removed for tracker %1",_deviceId);
    };
};

private _object = objectFromNetId _objectNetId;
if (isNull _object) exitWith {};

if !(_key in _overlays) then {
    private _marker = createMarkerLocal [_markerName, getPos _object];
    _marker setMarkerTypeLocal "mil_objective";
    _marker setMarkerColorLocal (missionNamespace getVariable [SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE, "ColorRed"]);
    _marker setMarkerTextLocal _label;
};

_overlays set [_key, [_objectNetId, _markerName]];

// The frame handler is shared, so it is started once and only while there is something to draw.
if (isNil {uiNamespace getVariable "ROOT_CYBERWARFARE_ZEUS_TRACKER_PFH"}) then {
    private _handle = [{
        private _overlays = uiNamespace getVariable ["ROOT_CYBERWARFARE_ZEUS_TRACKER_OVERLAYS", createHashMap];

        if ((keys _overlays) isEqualTo []) exitWith {
            [_this select 1] call CBA_fnc_removePerFrameHandler;
            uiNamespace setVariable ["ROOT_CYBERWARFARE_ZEUS_TRACKER_PFH", nil];
        };

        {
            (_overlays getOrDefault [_x, ["", ""]]) params ["_netId", "_marker"];
            private _object = objectFromNetId _netId;
            if (isNull _object) then {
                // Nothing left to follow, so the overlay goes rather than freezing on a stale position.
                deleteMarkerLocal _marker;
                _overlays deleteAt _x;
            } else {
                _marker setMarkerPosLocal (getPos _object);
            };
        } forEach (keys _overlays);
    }, 1, []] call CBA_fnc_addPerFrameHandler;

    uiNamespace setVariable ["ROOT_CYBERWARFARE_ZEUS_TRACKER_PFH", _handle];
};

DEBUG_LOG_1("Curator tracker overlay shown for tracker %1",_deviceId);
