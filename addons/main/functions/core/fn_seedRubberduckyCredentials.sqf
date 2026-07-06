#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Adds the configured default Rubberducky login (username/password) to a laptop the moment a
 * hacking-tools USB is plugged in, so the operator always has a known account to log into. Gated by the
 * ROOT_CYBERWARFARE_RUBBERDUCKY_CREDS_ENABLED CBA setting; the account name/password come from
 * ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_USER / _PASS (default "quack" / "quack"). Does nothing if the
 * feature is off or an account with that username already exists on the laptop. Server only.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop the Rubberducky was connected to
 *
 * Return Value:
 * <BOOL> - true if a credential was added, false otherwise
 *
 * Example:
 * [_laptop] call Root_fnc_seedRubberduckyCredentials;
 *
 * Public: Yes
 */

if (!isServer) exitWith {false};

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith {false};

// Feature toggle (default on) - admins can disable via CBA settings or Root_fnc_setRubberduckyCredentials.
if !(missionNamespace getVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CREDS_ENABLED", true]) exitWith {false};

// AE3 credential command must exist to add the account.
if (isNil "AE3_armaos_fnc_computer_addUser") exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("seedRubberduckyCredentials: AE3 addUser command unavailable");
    false
};

private _user = missionNamespace getVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_USER", "quack"];
private _pass = missionNamespace getVariable ["ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_PASS", "quack"];

if !(_user isEqualType "" && {_user isNotEqualTo ""}) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("seedRubberduckyCredentials: empty/invalid username configured");
    false
};

// Don't clobber an existing account with the same name (also makes re-plugging a no-op).
private _userlist = _computer getVariable ["AE3_Userlist", createHashMap];
if (_user in (keys _userlist)) exitWith {
    DEBUG_LOG_1("seedRubberduckyCredentials: user '%1' already exists, skipping",_user);
    false
};

[_computer, _user, _pass] call AE3_armaos_fnc_computer_addUser;
ROOT_CYBERWARFARE_LOG_INFO_1(format ["Rubberducky default credential '%1' added to connected laptop.",_user]);
true
