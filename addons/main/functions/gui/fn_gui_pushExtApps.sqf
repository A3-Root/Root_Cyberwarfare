#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Rebuilds the AE3 web desktop external-app list for the active computer.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Computer object bound to the open desktop
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer || {isNil "AE3_desktop_fnc_jsSend"}) exitWith {};

[_computer] call FUNC(syncHackingToolAvailability);

private _extApps = missionNamespace getVariable ["AE3_desktop_extApps", []];
private _filtered = _extApps select {
    private _extra = _x getOrDefault ["extra", createHashMap];
    private _requires = _extra getOrDefault ["requiresVar", []];
    private _varOk = (_requires isEqualTo []) || {
        _requires params [["_varName", ""], ["_expected", true]];
        _varName isNotEqualTo "" && {(_computer getVariable [_varName, "__AE3_missing__"]) isEqualTo _expected}
    };

    private _requiresFunction = _extra getOrDefault ["requiresFunction", ""];
    private _fnOk = (_requiresFunction isEqualTo "") || {
        private _fn = missionNamespace getVariable [_requiresFunction, {}];
        (_fn isEqualType {}) && {[_computer] call _fn}
    };

    _varOk && _fnOk
};

["ext_apps", _filtered] call AE3_desktop_fnc_jsSend;
