#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Opens a Hackerman SSH session from one computer to another, so the operator can drive
 *              every device linked to the target as if sitting at it. The session is held by the
 *              server, which is what lets both the terminal tools and the desktop apps work through
 *              it - the desktop builds its device lists and performs its actions server-side, where
 *              AE3's own terminal session is invisible.
 *
 *              The gates are AE3's, in AE3's order: a route has to resolve over the simulated network,
 *              the target has to be a powered computer with SSH enabled, and the credentials have to
 *              match the target's own account list and root policy. The operator's computer needs the
 *              hacking tools; the target does not. The target's terminal lock is deliberately left
 *              alone, so whoever is using that laptop is not thrown off it and never sees the intruder.
 *
 * Arguments:
 * 0: _computerNetId <STRING> - Operator's computer
 * 1: _targetIp <STRING> - Target address, "192.168.0.5"
 * 2: _user <STRING> - Account on the target
 * 3: _password <STRING> - Password for that account
 * 4: _owner <NUMBER> (Optional) - Machine to answer, 0 for none in multiplayer
 *
 * Return Value:
 * <BOOLEAN> - True when a session was opened
 *
 * Example:
 * [netId _laptop, "192.168.0.5", "admin", "pw", clientOwner] call Root_fnc_hackSshConnectMain;
 *
 * Public: Yes
 */

params [
    ["_computerNetId", "", [""]],
    ["_targetIp", "", [""]],
    ["_user", "", [""]],
    ["_password", "", [""]],
    ["_owner", 0, [0]]
];

if (!isServer) exitWith {
    ["root_cyberwarfare_hackSshConnect", [_computerNetId, _targetIp, _user, _password, clientOwner]] call CBA_fnc_serverEvent;
    false
};

// Only the stringtable key travels: a dedicated server may well run a different language than the
// player, so the client localizes it on arrival
private _fnc_fail = {
    params ["_key"];

    if (_owner > 0 || {!isMultiplayer}) then {
        ["root_cyberwarfare_hackSshResult", [false, _key, ""], _owner] call CBA_fnc_ownerEvent;
    };

    false
};

private _computer = objectFromNetId _computerNetId;

if (isNull _computer) exitWith { ["STR_ROOT_CYBERWARFARE_HACKSSH_NO_COMPUTER"] call _fnc_fail };

if !(missionNamespace getVariable [SETTING_HACK_SSH_ENABLED, true]) exitWith {
    ["STR_ROOT_CYBERWARFARE_HACKSSH_DISABLED"] call _fnc_fail
};

// The tools have to be on the operator's machine. The whole point is reaching a target that has none.
if !([_computer] call FUNC(hasHackingToolsAvailable)) exitWith {
    ["STR_ROOT_CYBERWARFARE_HACKSSH_NO_TOOLS"] call _fnc_fail
};

private _address = [_targetIp] call AE3_network_fnc_str2ip;

if (_address isEqualTo []) exitWith { ["STR_ROOT_CYBERWARFARE_HACKSSH_BAD_ADDRESS"] call _fnc_fail };

// AE3's router walk: it already accounts for power, wireless range and cross-subnet SSH policy
private _target = ([_computer, _address] call AE3_network_fnc_resolve) param [0, objNull];

if (isNull _target || (_target isEqualTo _computer)) exitWith {
    ["STR_ROOT_CYBERWARFARE_HACKSSH_NO_ROUTE"] call _fnc_fail
};

if !(_target getVariable ["AE3_cap_hasTerminal", false]) exitWith {
    ["STR_ROOT_CYBERWARFARE_HACKSSH_REFUSED"] call _fnc_fail
};

if !(_target getVariable ["AE3_ssh_enabled", true]) exitWith {
    ["STR_ROOT_CYBERWARFARE_HACKSSH_REFUSED"] call _fnc_fail
};

if ((_target getVariable ["AE3_power_powerState", 0]) != 1) exitWith {
    ["STR_ROOT_CYBERWARFARE_HACKSSH_OFFLINE"] call _fnc_fail
};

// Credentials are checked here because the server already holds the target's authoritative account
// list, so no password has to be pulled back to a client to compare it
private _users = _target getVariable ["AE3_Userlist", createHashMap];
private _rootBlocked = (_user isEqualTo "root") && {!([_target] call AE3_armaos_fnc_computer_allowsRootLogin)};
private _authOk = !_rootBlocked && {_user in _users} && {(_users get _user) isEqualTo _password};

// Attempts are logged on the target whether they succeed or not, so an intrusion can be found. The
// write is appended to the authoritative copy, so it survives whatever session that laptop has open.
private _logKey = ["STR_ROOT_CYBERWARFARE_HACKSSH_LOG_FAILED", "STR_ROOT_CYBERWARFARE_HACKSSH_LOG_OPENED"] select _authOk;
private _logLine = format ["%1 (hackssh %2)%3", localize _logKey, _user, endl];

[_target, "/var/log/auth.log", _logLine, true] call AE3_filesystem_fnc_device_writeFile;

if (!_authOk) exitWith { ["STR_ROOT_CYBERWARFARE_HACKSSH_AUTH_FAILED"] call _fnc_fail };

// Opening a connection costs the operator's own battery
private _cost = missionNamespace getVariable [SETTING_HACK_SSH_COST, 0];

if (_cost > 0 && {!([_computer, _cost] call FUNC(checkPowerAvailable))}) exitWith {
    ["STR_ROOT_CYBERWARFARE_HACKSSH_NO_POWER"] call _fnc_fail
};

private _sessions = GET_HACK_SESSIONS;

_sessions set [_computerNetId, [netId _target, _user, serverTime, serverTime]];
missionNamespace setVariable [GVAR_HACK_SESSIONS, _sessions];

// The published half carries no password: it is what the client's apps read to show the session
private _label = _target getVariable ["ace_cargo_customName", _targetIp];

_computer setVariable [VAR_HACK_SESSION, [netId _target, _label, _user], true];

[] call FUNC(manageHackSweep);

// Debited here rather than through consumePower, which belongs to the client that printed the cost
if (_cost > 0) then {
    ([_computer, _cost] call FUNC(getBatteryStatus)) params ["_hasBattery", "_battery", "_currentWh"];

    if (_hasBattery) then {
        [_computer, _battery, WH_TO_KWH(_currentWh - _cost)] call FUNC(removePower);
    };
};

ROOT_CYBERWARFARE_LOG_INFO_2("hackssh: session opened from %1 to %2",_computerNetId,netId _target);

if (_owner > 0 || {!isMultiplayer}) then {
    ["root_cyberwarfare_hackSshResult", [true, "STR_ROOT_CYBERWARFARE_HACKSSH_CONNECTED", _label, _user], _owner] call CBA_fnc_ownerEvent;
};

true
