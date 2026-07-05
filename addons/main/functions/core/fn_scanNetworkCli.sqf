#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side driver for the terminal 'netscan' command. Builds the network snapshot on
 *              the server (where the AE3 registries are authoritative), streams the result to the
 *              requesting client's terminal, optionally exports it to a file in the laptop filesystem,
 *              and raises the completion flag the command waits on.
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID of the client that ran the command
 * 1: _computer <OBJECT> - The scanning laptop
 * 2: _nameOfVariable <STRING> - Completion flag variable name
 * 3: _exportPath <STRING> (Optional) - File path to export results to, default: "" (no export)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_owner", ["_computer", objNull, [objNull]], ["_nameOfVariable", "", [""]], ["_exportPath", "", [""]]];

if (isNull _computer) exitWith {
    if (_nameOfVariable isNotEqualTo "") then { missionNamespace setVariable [_nameOfVariable, true, true]; };
};

private _rows = [_computer] call FUNC(scanNetwork);

// Print on the client that owns the terminal.
[_computer, _rows] remoteExec [QFUNC(scanNetworkPrint), _owner];

// Optional export to the laptop's filesystem (server writes it so locality/sync is handled).
if (_exportPath isNotEqualTo "") then {
    private _nl = toString [10];
    private _text = "Network Scan Results" + _nl + "IP Address | Type | External SSH | Interface" + _nl;
    {
        _x params ["_ip", "_type", "_ssh", "_iface"];
        _text = _text + format ["%1 | %2 | %3 | %4", _ip, _type, _ssh, _iface] + _nl;
    } forEach _rows;
    [_computer, _exportPath, _text, false, "root", [[true, true, true], [true, false, true]]] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];
};

if (_nameOfVariable isNotEqualTo "") then {
    missionNamespace setVariable [_nameOfVariable, true, true];
};
