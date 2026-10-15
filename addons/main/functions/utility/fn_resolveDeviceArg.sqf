#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Turns the device argument of a terminal command into a numeric device id. Numeric ids,
 *              "a" (all) and help flags pass through unchanged. Anything else is treated as a device
 *              identifier and resolved by the server; a code that grants access also hands this
 *              machine a short-lived access grant for that device (Root_fnc_isDeviceAccessible honours
 *              it, Root_fnc_clearIdentifierGrants drops it). Must run scheduled (it waits for the
 *              server's answer). Errors are printed to the terminal.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Executing computer
 * 1: _deviceType <NUMBER> - DEVICE_TYPE_* constant the command works on
 * 2: _argument <STRING> - Argument as typed
 *
 * Return Value:
 * <ARRAY> - [deviceIdString] on success, [] when the code could not be resolved
 *
 * Example:
 * private _resolved = [_computer, DEVICE_TYPE_DOOR, "VAULTDR1"] call Root_fnc_resolveDeviceArg;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]], ["_deviceType", 0, [0]], ["_argument", "", [""]]];

private _trimmed = [_argument] call CBA_fnc_trim;

// Plain ids, "all" and help requests are not identifiers.
if (
    !(missionNamespace getVariable [SETTING_DEVICE_IDENTIFIERS, true])
    || {_trimmed in ["", "a", "A", "-h", "--help", "help"]}
    || {_trimmed regexMatch "^[0-9]+$"}
) exitWith { [_argument] };

private _requestKey = format ["%1_%2_%3", clientOwner, diag_tickTime, floor random 100000];
private _resultVar = "ROOT_CYBERWARFARE_IDRES_" + _requestKey;
missionNamespace setVariable [_resultVar, nil];

["root_cyberwarfare_resolveIdentifier", [netId _computer, _trimmed, _deviceType, clientOwner, _requestKey]] call CBA_fnc_serverEvent;

private _deadline = diag_tickTime + 10;
waitUntil { !isNil {missionNamespace getVariable _resultVar} || {diag_tickTime > _deadline} };

private _reply = missionNamespace getVariable [_resultVar, []];
missionNamespace setVariable [_resultVar, nil];

if (_reply isEqualTo []) exitWith {
    [_computer, format ["<t color='%1'>%2</t>", ROOT_CYBERWARFARE_COLOR_ERROR, localize "STR_ROOT_CYBERWARFARE_IDENTIFIER_TIMEOUT"]] call AE3_armaos_fnc_shell_stdout;
    []
};

_reply params ["_deviceId", "_error", "_grantsAccess"];

if (_error isNotEqualTo "") exitWith {
    [_computer, format ["<t color='%1'>%2</t>", ROOT_CYBERWARFARE_COLOR_ERROR, _error]] call AE3_armaos_fnc_shell_stdout;
    []
};

if (_grantsAccess) then {
    private _grants = missionNamespace getVariable [GVAR_IDENTIFIER_GRANTS, createHashMap];
    _grants set [format ["%1:%2", _deviceType, _deviceId], diag_tickTime + IDENTIFIER_GRANT_DURATION];
    missionNamespace setVariable [GVAR_IDENTIFIER_GRANTS, _grants];
};

[str _deviceId]
