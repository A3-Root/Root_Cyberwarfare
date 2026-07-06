#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Public API to configure the Rubberducky default-credential feature at runtime, mirroring
 * the CBA settings. Sets whether the feature is enabled and which username/password gets injected into a
 * laptop when a hacking-tools USB is connected. Any argument left as nil keeps its current value.
 * Broadcasts globally so servers and clients agree. Run on the server (or remoteExec to 2).
 *
 * Arguments:
 * 0: _enabled <BOOL> (Optional) - Enable/disable auto-injecting the default credential. nil = unchanged.
 * 1: _username <STRING> (Optional) - Default account username. nil = unchanged.
 * 2: _password <STRING> (Optional) - Default account password. nil = unchanged.
 *
 * Return Value:
 * None
 *
 * Example:
 * [true, "quack", "quack"] call Root_fnc_setRubberduckyCredentials;
 * [false] call Root_fnc_setRubberduckyCredentials; // disable, keep user/pass
 *
 * Public: Yes
 */

if (!isServer) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("setRubberduckyCredentials must run on the server - use remoteExec to 2.");
};

params ["_enabled", "_username", "_password"];

if (_enabled isEqualType false) then {
    missionNamespace setVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CREDS_ENABLED", _enabled, true];
};
if (_username isEqualType "" && {_username isNotEqualTo ""}) then {
    missionNamespace setVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_USER", _username, true];
};
if (_password isEqualType "") then {
    missionNamespace setVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_PASS", _password, true];
};

private _curEnabled = missionNamespace getVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CREDS_ENABLED", true];
private _curUser = missionNamespace getVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_USER", "quack"];
ROOT_CYBERWARFARE_LOG_INFO_2("Rubberducky credentials updated: enabled=%1 user=%2",_curEnabled,_curUser);
