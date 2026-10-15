#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Closes a computer's Hackerman SSH session, so it goes back to reaching only the devices
 *              linked to itself. Used by the operator, and by the session sweep when a session can no
 *              longer stand up.
 *
 * Arguments:
 * 0: _computerNetId <STRING> - Operator's computer
 * 1: _reasonKey <STRING> (Optional) - Stringtable key explaining why, for the operator's screen
 * 2: _owner <NUMBER> (Optional) - Machine to answer, 0 for none
 *
 * Return Value:
 * <BOOLEAN> - True when a session was closed
 *
 * Example:
 * [netId _laptop] call Root_fnc_hackSshDisconnectMain;
 *
 * Public: Yes
 */

params [
    ["_computerNetId", "", [""]],
    ["_reasonKey", "STR_ROOT_CYBERWARFARE_HACKSSH_DISCONNECTED", [""]],
    ["_owner", 0, [0]]
];

if (!isServer) exitWith {
    ["root_cyberwarfare_hackSshDisconnect", [_computerNetId, _reasonKey, clientOwner]] call CBA_fnc_serverEvent;
    false
};

private _sessions = GET_HACK_SESSIONS;
private _session = _sessions getOrDefault [_computerNetId, []];

private _computer = objectFromNetId _computerNetId;

if (!isNull _computer) then {
    _computer setVariable [VAR_HACK_SESSION, nil, true];
};

if (_session isEqualTo []) exitWith {
    if (_owner > 0) then {
        ["root_cyberwarfare_hackSshResult", [false, "STR_ROOT_CYBERWARFARE_HACKSSH_NO_SESSION", ""], _owner] call CBA_fnc_ownerEvent;
    };

    false
};

_sessions deleteAt _computerNetId;
missionNamespace setVariable [GVAR_HACK_SESSIONS, _sessions];

[] call FUNC(manageHackSweep);

ROOT_CYBERWARFARE_LOG_INFO_1("hackssh: session closed for %1",_computerNetId);

// The operator is told on whichever machine is driving that computer, so a session the sweep closed
// is noticed by whoever was using it
private _tell = _owner;

if (_tell <= 0 && {!isNull _computer}) then {
    _tell = [_computer] call AE3_armaos_fnc_computer_getLocality;
};

if (_tell > 0) then {
    ["root_cyberwarfare_hackSshResult", [true, _reasonKey, ""], _tell] call CBA_fnc_ownerEvent;
};

true
