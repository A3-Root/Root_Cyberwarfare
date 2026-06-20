#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: AE3 desktop map window that follows a GPS tracker. Opens a map control centred on the
 * tracked object with a blinking marker that updates in real time (throttled per-frame handler). The
 * window manager removes the returned "pfh" on close; onClose deletes the local marker.
 *
 * Arguments (AE3 app entry contract): 0:_winId 1:_ctrlGroup 2:_computer 3:_args=[trackerNetId, label]
 * Return Value: App callbacks <HASHMAP>
 * Public: No
 */

params ["_winId", "_ctrlGroup", "_computer", "_args"];
_args params [["_trackerNetId", ""], ["_label", "GPS"]];

private _session = uiNamespace getVariable ["AE3_desktop_session", createHashMap];
private _display = _session getOrDefault ["display", displayNull];
(ctrlPosition _ctrlGroup) params ["", "", "_w", "_h"];

private _target = objectFromNetId _trackerNetId;

private _mapCtrl = _display ctrlCreate ["RscMapControl", -1, _ctrlGroup];
_mapCtrl ctrlSetPosition [0.01, 0.045, _w - 0.02, _h - 0.055];
_mapCtrl ctrlEnable true;
_mapCtrl ctrlCommit 0;

private _markerName = format ["ROOT_gpsmap_%1_%2", _winId, round (random 99999)];
private _startPos = if (isNull _target) then { [0, 0, 0] } else { getPosWorld _target };
createMarkerLocal [_markerName, _startPos];
_markerName setMarkerTypeLocal "hd_dot";
_markerName setMarkerColorLocal "ColorRed";
_markerName setMarkerTextLocal _label;

_mapCtrl ctrlMapAnimAdd [0, 0.18, _startPos];
ctrlMapAnimCommit _mapCtrl;

// Remember the marker so onClose can remove it.
uiNamespace setVariable [format ["ROOT_gpsmap_marker_%1", _winId], _markerName];

// Throttled follow + blink. Keeps the tracker centred (movie-style) and pulses the marker.
private _pfh = [
	{
		params ["_args", "_handle"];
		_args params ["_mapCtrl", "_markerName", "_target"];
		if (isNull _mapCtrl) exitWith {};
		if (isNull _target) exitWith { _markerName setMarkerColorLocal "ColorBlack"; };

		private _pos = getPosWorld _target;
		_markerName setMarkerPosLocal _pos;
		// Blink between full and dim alpha.
		private _blink = uiNamespace getVariable ["ROOT_gpsmap_blink", true];
		_markerName setMarkerAlphaLocal ([0.35, 1] select _blink);
		uiNamespace setVariable ["ROOT_gpsmap_blink", !_blink];
		// Follow the target.
		_mapCtrl ctrlMapAnimAdd [0.4, 0.18, _pos];
		ctrlMapAnimCommit _mapCtrl;
	},
	0.5,
	[_mapCtrl, _markerName, _target]
] call CBA_fnc_addPerFrameHandler;

createHashMapFromArray [
	["pfh", _pfh],
	["onClose", compile format ["deleteMarkerLocal (uiNamespace getVariable ['ROOT_gpsmap_marker_%1', '']); uiNamespace setVariable ['ROOT_gpsmap_marker_%1', nil];", _winId]]
]
