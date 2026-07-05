#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Client-side printer for the 'netscan' command. Renders the network snapshot rows to the
 *              AE3 terminal on the machine that owns the shell.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The scanning laptop (its terminal receives the output)
 * 1: _rows <ARRAY> - Rows of [ipString, typeString, sshString, interfaceString]
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]], ["_rows", [], [[]]]];

if (isNull _computer) exitWith {};
if (isNil "AE3_armaos_fnc_shell_stdout") exitWith {};

[_computer, [[["NETWORK SCAN", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
[_computer, [[["IP Address        Type     SSH   Interface     Devices", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;

if (_rows isEqualTo []) exitWith {
    [_computer, [[["No reachable devices found on this subnet.", "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
};

{
    _x params ["_ip", "_type", "_ssh", "_iface", ["_count", 0]];
    private _countStr = if (_type isEqualTo "Laptop") then { format ["  devices:%1", _count] } else { "" };
    [_computer, [[[_ip, "#008DF8"], [format ["   %1   SSH:%2   %3%4", _type, _ssh, _iface, _countStr], ""]]]] call AE3_armaos_fnc_shell_stdout;
} forEach _rows;
