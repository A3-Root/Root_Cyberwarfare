#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Adds the configured default Rubberducky login (username/password) to a laptop the moment a
 * hacking-tools USB is plugged in, so the operator always has a known account to log into, and grants that
 * account superuser rights so it can read the files and home directories the laptop's other users own.
 * Gated by the ROOT_CYBERWARFARE_RUBBERDUCKY_CREDS_ENABLED CBA setting; the account name/password come
 * from ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_USER / _PASS (default "quack" / "quack"). An account that
 * already exists is left as it is, but is still raised to superuser. Server only.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop the Rubberducky was connected to
 *
 * Return Value:
 * <BOOL> - true if the account was created by this call, false if it already existed or nothing was done
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

// Don't clobber an existing account with the same name (also makes re-plugging a no-op). The superuser
// grant below still runs, because the account may have been created by another route - a mission script
// or an Eden attribute - that left it unprivileged.
private _userlist = _computer getVariable ["AE3_Userlist", createHashMap];
private _accountCreated = false;

if (_user in (keys _userlist)) then {
    DEBUG_LOG_1("seedRubberduckyCredentials: user '%1' already exists, skipping account creation",_user);
} else {
    [_computer, _user, _pass] call AE3_armaos_fnc_computer_addUser;
    _accountCreated = true;
    ROOT_CYBERWARFARE_LOG_INFO_1(format ["Rubberducky default credential '%1' added to connected laptop.",_user]);
};

// The toolset is only useful against a laptop's own secrets if it can read them, and those live under
// other accounts' home directories. The account is therefore added to /etc/sudoers, which is what AE3
// reads to decide whether a user may act as root over the filesystem.
if (isNil "AE3_armaos_fnc_computer_addSudoer") exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("seedRubberduckyCredentials: AE3 addSudoer command unavailable");
    _accountCreated
};

if !([_computer, _user] call AE3_armaos_fnc_computer_isSudoer) then {
    [_computer, _user] call AE3_armaos_fnc_computer_addSudoer;
    ROOT_CYBERWARFARE_LOG_INFO_1(format ["Rubberducky account '%1' granted superuser rights.",_user]);
};

_accountCreated
