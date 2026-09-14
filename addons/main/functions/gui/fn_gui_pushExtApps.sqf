#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Rebuilds the AE3 web desktop external-app list for the active computer.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Computer object bound to the open desktop
 * 1: _desktopOpened <BOOL> (Optional, default: false) - Call follows a desktop being opened rather than
 *    a volume or app-list refresh, which is what makes it eligible to play the loading intro
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]], ["_desktopOpened", false, [false]]];

if (isNull _computer || {isNil "AE3_desktop_fnc_jsSend"}) exitWith {};

if (isMultiplayer) then {
    [_computer, "AE3_USB_Interfaces_occupied"] call AE3_main_fnc_getRemoteVar;
    [_computer, "AE3_USB_Interfaces_mounted"] call AE3_main_fnc_getRemoteVar;
    [_computer, "ROOT_CYBERWARFARE_INTRO_PENDING"] call AE3_main_fnc_getRemoteVar;
};

private _available = [_computer] call FUNC(syncHackingToolAvailability);
[_computer, _available] call FUNC(gui_syncHackermanDesktop);

// Auto-play the loading intro. Two things make a laptop eligible: opening its desktop while the hacking
// tools are available, and the server flagging it because a tools drive was just plugged in. The first
// covers a laptop whose tools the mission installed directly - it never sees a drive at all - and the
// second still fires on a mount into a desktop that is already open.
if (_available && {!isNil "AE3_desktop_fnc_openFile"}) then {
    private _pending = _computer getVariable ["ROOT_CYBERWARFARE_INTRO_PENDING", false];

    // The pending flag is cleared whatever happens next, so a mission that switched the intro off does
    // not leave laptops carrying a flag that would fire the moment it is switched back on.
    if (_pending) then {
        ["root_cyberwarfare_clearIntroPending", [netId _computer]] call CBA_fnc_serverEvent;
    };

    // Rate-limit the intro on this client: reconnecting to the same laptop, or re-plugging its drive,
    // within the configured cooldown skips the video rather than replaying it back to back. A cooldown
    // of zero plays it on every connection. The timestamp stays client-local because the cooldown is
    // about what this viewer has just watched, not about the laptop's shared state.
    private _introEnabled = missionNamespace getVariable [SETTING_INTRO_VIDEO_ENABLED, true];
    private _cooldown = missionNamespace getVariable [SETTING_INTRO_VIDEO_COOLDOWN, ROOT_CYBERWARFARE_INTRO_COOLDOWN];
    private _lastPlayed = _computer getVariable ["ROOT_CYBERWARFARE_INTRO_LAST", -1e9];
    if (_introEnabled && {_desktopOpened || _pending} && {time - _lastPlayed >= _cooldown}) then {
        _computer setVariable ["ROOT_CYBERWARFARE_INTRO_LAST", time];
        [
            _computer,
            "Hackerman.exe",
            "AE3_MEDIA|video|mod|0|\z\root_cyberwarfare\addons\main\video\loading.ogv",
            [],
            createHashMapFromArray [["allowStop", false], ["volume", 0.05]]
        ] call AE3_desktop_fnc_openFile;
    };
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
