#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns how long downloading a hackable file takes and its virtual size. A file given a
 *              virtual size downloads at the AE3 network transfer speed that applies to the downloading
 *              user/computer/wifi network (AE3_network_fnc_getTransferSpeed, mission setting by
 *              default); otherwise the legacy download time in seconds is used.
 *
 * Arguments:
 * 0: _database <OBJECT> - Object the hackable file is stored on
 * 1: _computer <OBJECT> (Optional) - Downloading computer (the operator's own inside SSH), default: objNull
 * 2: _user <STRING> (Optional) - Downloading account; "" = the computer's terminal/desktop user, default: ""
 *
 * Return Value:
 * <ARRAY> - [download time in seconds, virtual size in bytes or -1]
 *
 * Example:
 * ([_database] call Root_fnc_getDatabaseTransfer) params ["_seconds", "_bytes"];
 *
 * Public: Yes
 */

params [["_database", objNull, [objNull]], ["_computer", objNull, [objNull]], ["_user", "", [""]]];

if (isNull _database) exitWith { [0, -1] };

private _seconds = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_SIZE_EDIT", 0];
if !(_seconds isEqualType 0) then { _seconds = 0; };

private _bytes = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_VSIZE", -1];
if (_bytes >= 0 && {!isNil "AE3_armaos_fnc_shell_transferDuration"}) then {
    if (!isNull _computer && _user isEqualTo "") then {
        _user = (_computer getVariable ["AE3_terminal", createHashMap]) getOrDefault ["AE3_terminalLoginUser", ""];
        if (_user isEqualTo "") then { _user = _computer getVariable ["AE3_desktop_sessionUser", ""]; };
    };
    _seconds = ([_bytes, "network", _computer, _user] call AE3_armaos_fnc_shell_transferDuration) select 0;
};

[_seconds, _bytes]
