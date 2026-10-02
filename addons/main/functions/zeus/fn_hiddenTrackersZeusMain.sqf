#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server side of the Hidden Trackers module: assembles the roster of trackers that no
 * laptop lists - their identifiers, what they are attached to and what state they are in - and sends
 * it to the one curator who asked for it.
 *
 * The identifiers are the mission's secrets and live only on the server, so this is the only way they
 * ever leave it, and only to someone who currently holds a curator interface. Anyone else gets
 * nothing, with the refusal logged.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the curator asking
 * 1: _requester <OBJECT> - The curator's unit, checked for a curator interface
 *
 * Return Value:
 * None
 *
 * Example:
 * [clientOwner, player] remoteExec ["Root_fnc_hiddenTrackersZeusMain", 2];
 *
 * Public: No
 */

if (!isServer) exitWith {};

params [["_owner", 0, [0]], ["_requester", objNull, [objNull]]];

if (_owner <= 0) exitWith {};

// Only a curator may read the codes. A unit with no curator module assigned to it is not one.
if (isNull _requester || {isNull (getAssignedCuratorLogic _requester)}) exitWith {
    ROOT_CYBERWARFARE_LOG_INFO_1(format ["hiddenTrackersZeusMain: refused the hidden tracker roster to a non-curator (%1)",_requester]);
    ["root_cyberwarfare_zeusHiddenTrackers", [[]], _owner] call CBA_fnc_ownerEvent;
};

private _allTrackers = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]]) param [5, []];
private _identifiers = GET_GPS_IDENTIFIERS;
private _rows = [];

{
    private _identifier = _x;
    (_identifiers getOrDefault [_identifier, []]) params [["_deviceId", -1], ["_name", ""], ["_objectName", ""], ["_plantedByUid", ""], ["_hidden", false]];

    if (_hidden && _deviceId >= 0) then {
        private _index = _allTrackers findIf {(_x select 0) == _deviceId};

        // A tracker whose registry row has gone (cleared by the cleanup pass, or never registered)
        // is reported with what is still known of it rather than silently dropped.
        private _objectNetId = "";
        private _status = localize "STR_ROOT_CYBERWARFARE_GPS_STATUS_MISSING";
        if (_index > -1) then {
            private _row = _allTrackers select _index;
            _objectNetId = _row param [1, ""];
            _status = (_row param [8, ["Untracked"]]) param [0, "Untracked"];
        };

        _rows pushBack [_deviceId, _identifier, _name, _objectName, _objectNetId, _status];
    };
} forEach (keys _identifiers);

DEBUG_LOG_1("Sent %1 hidden tracker(s) to a curator",count _rows);

["root_cyberwarfare_zeusHiddenTrackers", [_rows], _owner] call CBA_fnc_ownerEvent;
