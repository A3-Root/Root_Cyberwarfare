#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Builds a snapshot of the AE3 network devices (laptops and routers) that share the
 *              scanning computer's subnet. For each reachable, powered device it reports the IP
 *              address, device type, whether external SSH is allowed, and which interfaces it exposes
 *              (CLI, GUI, or both). Intended to run where the AE3 network registries are authoritative
 *              (the server).
 *
 * Arguments:
 * 0: _computer <OBJECT> - The scanning laptop
 *
 * Return Value:
 * Rows <ARRAY> - Array of [ipString, typeString, sshString, interfaceString]
 *
 * Example:
 * [_laptop] call Root_fnc_scanNetwork;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith { [] };

private _selfAddr = _computer getVariable ["AE3_network_address", [127, 0, 0, 1]];
// Loopback means the scanning laptop is not on a network, so there is nothing to enumerate.
if (_selfAddr isEqualTo [127, 0, 0, 1]) exitWith { [] };
private _subnet = [_selfAddr select 0, _selfAddr select 1, _selfAddr select 2];

private _devices = (missionNamespace getVariable ["ae3_desktop_computers", []]) + (missionNamespace getVariable ["AE3_network_routers", []]);
private _defaultMode = missionNamespace getVariable ["AE3_Desktop_DefaultMode", "both"];

private _rows = [];
private _seen = [];
{
    private _dev = _x;
    if (isNull _dev) then { continue };

    private _addr = _dev getVariable ["AE3_network_address", [127, 0, 0, 1]];
    if (_addr isEqualTo [127, 0, 0, 1]) then { continue };                                  // not connected
    if ([_addr select 0, _addr select 1, _addr select 2] isNotEqualTo _subnet) then { continue }; // other subnet
    if ((_dev getVariable ["AE3_power_powerState", 0]) != 1) then { continue };             // powered devices only

    private _ipStr = if (isNil "AE3_network_fnc_ip2str") then {
        (_addr apply {str _x}) joinString "."
    } else {
        [_addr] call AE3_network_fnc_ip2str
    };
    if (_ipStr in _seen) then { continue };
    _seen pushBack _ipStr;

    private _isRouter = _dev getVariable ["AE3_cap_isRouter", false];
    private _typeStr = ["Laptop", "Router"] select _isRouter;

    private _sshAllowed = if (_isRouter) then {
        _dev getVariable ["AE3_network_allowExternalSsh", false]
    } else {
        _dev getVariable ["AE3_ssh_enabled", true]
    };
    private _sshStr = ["No", "Yes"] select _sshAllowed;

    private _ifaceStr = if (_isRouter) then {
        "N/A"
    } else {
        switch (toLower (_dev getVariable ["AE3_interfaceMode", _defaultMode])) do {
            case "cli": { "CLI only" };
            case "gui": { "GUI only" };
            default { "CLI + GUI" };
        };
    };

    _rows pushBack [_ipStr, _typeStr, _sshStr, _ifaceStr];
} forEach _devices;

_rows
