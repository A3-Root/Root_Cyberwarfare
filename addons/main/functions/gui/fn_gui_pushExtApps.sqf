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

if (isMultiplayer) then {
    [_computer, "AE3_USB_Interfaces_occupied"] call AE3_main_fnc_getRemoteVar;
    [_computer, "AE3_USB_Interfaces_mounted"] call AE3_main_fnc_getRemoteVar;
    [_computer, "ROOT_CYBERWARFARE_INTRO_PENDING"] call AE3_main_fnc_getRemoteVar;
};

private _available = [_computer] call FUNC(syncHackingToolAvailability);
[_computer, _available] call FUNC(gui_syncHackermanDesktop);

// Auto-play the loading intro once per USB mount: when a hacking-tools drive was just connected the
// server flags the laptop; the first desktop refresh that sees tools available plays the video and
// clears the flag globally so it shows once per mount (a re-plug sets it again).
if (_available && {_computer getVariable ["ROOT_CYBERWARFARE_INTRO_PENDING", false]} && {!isNil "AE3_desktop_fnc_openFile"}) then {
    ["root_cyberwarfare_clearIntroPending", [netId _computer]] call CBA_fnc_serverEvent;
    [
        _computer,
        "Hackerman.exe",
        "AE3_MEDIA|video|mod|0|\z\root_cyberwarfare\addons\main\video\loading.ogv",
        [],
        createHashMapFromArray [["allowStop", false], ["volume", 0.05]]
    ] call AE3_desktop_fnc_openFile;
};

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
