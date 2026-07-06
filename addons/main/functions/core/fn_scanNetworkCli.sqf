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

// Optional export to the laptop's filesystem. Write through the filesystem (ensureFile + writeToFile),
// overwriting any previous export, and broadcast it so the client terminal sees the file - the old
// fire-and-forget device_addFile refused to overwrite and synced server-only, so re-exports vanished.
if (_exportPath isNotEqualTo "") then {
    private _nl = toString [10];
    private _text = "Network Scan Results" + _nl + "IP Address | Type | External SSH | Interface | Hackable Devices" + _nl;
    {
        _x params ["_ip", "_type", "_ssh", "_iface", ["_count", 0]];
        _text = _text + format ["%1 | %2 | %3 | %4 | %5", _ip, _type, _ssh, _iface, _count] + _nl;
    } forEach _rows;

    private _filesystem = _computer getVariable ["AE3_filesystem", []];
    if (_filesystem isEqualTo []) then {
        [_computer, format ["<t color='%1'>Export failed: laptop filesystem is not initialized.</t>", ROOT_CYBERWARFARE_COLOR_ERROR]] remoteExec ["AE3_armaos_fnc_shell_stdout", _owner];
    } else {
        // Ensure the destination folder exists before writing the file into it.
        private _parts = _exportPath splitString "/";
        _parts deleteAt ((count _parts) - 1);
        private _dir = "/" + (_parts joinString "/");
        private _ok = true;
        try {
            if (_dir != "/") then { [[], _filesystem, _dir, "root", "root", [[true, true, true], [true, false, true]]] call AE3_filesystem_fnc_ensureDir; };
            [[], _filesystem, _exportPath, "", "root", "root", [[true, true, true], [true, false, true]]] call AE3_filesystem_fnc_ensureFile;
            [[], _filesystem, _exportPath, "root", _text, false] call AE3_filesystem_fnc_writeToFile;
            _computer setVariable ["AE3_filesystem", _filesystem, true];
        } catch {
            _ok = false;
            ROOT_CYBERWARFARE_LOG_ERROR_2("Network scan CLI export to %1 failed: %2",_exportPath,_exception);
        };
        private _msg = if (_ok) then {
            format ["<t color='%1'>Network scan exported to %2</t>", ROOT_CYBERWARFARE_COLOR_SUCCESS, _exportPath]
        } else {
            format ["<t color='%1'>Failed to export network scan to %2</t>", ROOT_CYBERWARFARE_COLOR_ERROR, _exportPath]
        };
        [_computer, _msg] remoteExec ["AE3_armaos_fnc_shell_stdout", _owner];
    };
};

if (_nameOfVariable isNotEqualTo "") then {
    missionNamespace setVariable [_nameOfVariable, true, true];
};
