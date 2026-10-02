#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Writes a planted tracker into the player's own briefing diary, under a Cyber Warfare
 * subject created the first time one is needed. An identifier is the only way back to a hidden
 * tracker, so the person who planted it keeps a written record of it: what the tracker is called,
 * the code it answers to, what it was attached to and where that was at the time. Runs on the
 * planter's machine only - a diary is local to the player it belongs to, which is also what keeps the
 * code from reaching anybody else.
 *
 * Arguments:
 * 0: _trackerName <STRING> - The tracker's display name
 * 1: _identifier <STRING> - The identifier the tracker answers to
 * 2: _objectName <STRING> - Display name of the object it was attached to
 * 3: _grid <STRING> (Optional) - Map grid the tracker was planted at, default: ""
 *
 * Return Value:
 * None
 *
 * Example:
 * ["Tracker_1", "D34FNDUM", "Offroad", "053041"] call Root_fnc_logTrackerToDiary;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

params [
    ["_trackerName", "", [""]],
    ["_identifier", "", [""]],
    ["_objectName", "", [""]],
    ["_grid", "", [""]]
];

if (_identifier isEqualTo "") exitWith {};

// One subject for every record this mission writes, created on first use.
if !(missionNamespace getVariable ["ROOT_CYBERWARFARE_DIARY_SUBJECT_READY", false]) then {
    player createDiarySubject ["ROOT_CYBERWARFARE", localize "STR_ROOT_CYBERWARFARE_DIARY_SUBJECT"];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DIARY_SUBJECT_READY", true];
};

private _lines = [
    format [localize "STR_ROOT_CYBERWARFARE_DIARY_TRACKER_NAME", _trackerName],
    format [localize "STR_ROOT_CYBERWARFARE_DIARY_TRACKER_IDENTIFIER", _identifier],
    format [localize "STR_ROOT_CYBERWARFARE_DIARY_TRACKER_OBJECT", _objectName]
];

if (_grid isNotEqualTo "") then {
    _lines pushBack format [localize "STR_ROOT_CYBERWARFARE_DIARY_TRACKER_GRID", _grid];
};

_lines pushBack localize "STR_ROOT_CYBERWARFARE_DIARY_TRACKER_HINT";

player createDiaryRecord [
    "ROOT_CYBERWARFARE",
    [
        format [localize "STR_ROOT_CYBERWARFARE_DIARY_TRACKER_TITLE", _identifier],
        _lines joinString "<br/>"
    ]
];
