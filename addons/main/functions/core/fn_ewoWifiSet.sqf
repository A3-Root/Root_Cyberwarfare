// File: fn_ewoWifiSet.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Turns an EWO backpack's wireless network on or off and renames it. The network itself is
 *              carried by the hidden router that rides with the pack, and AE3 only lists a router that is
 *              powered, so switching the network on is switching that router's power on - that is what
 *              makes it appear to laptops and what starts it drawing from the pack. An empty name or
 *              password leaves that setting as it is, so the toggle does not have to know the current one.
 *
 * Arguments:
 * 0: _player <OBJECT> - Player wearing the backpack
 * 1: _on <BOOL> - Whether the network broadcasts
 * 2: _name <STRING> - (Optional, default: "") New network name, "" to keep the current one
 * 3: _password <STRING> - (Optional, default: "") New password, "" to keep the current one
 *
 * Return Value:
 * None
 *
 * Example:
 * [_player, true] call Root_fnc_ewoWifiSet;
 *
 * Public: No
 */

params [["_player", objNull, [objNull]], ["_on", false, [false]], ["_name", "", [""]], ["_password", "", [""]]];

if (!isServer || {isNull _player}) exitWith {};

private _bag = backpackContainer _player;
if (isNull _bag || {!(_bag getVariable ["ROOT_EWO_INITIALIZED", false])}) exitWith {};

// A network with nothing left to run on cannot be switched on.
if (_on && {(_bag getVariable ["ROOT_EWO_ENERGY", 0]) <= 0}) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_EWO_NO_ENERGY", ROOT_CYBERWARFARE_COLOR_ERROR] remoteExecCall [QFUNC(ewoNotify), _player];
};

if (_name isEqualTo "") then { _name = _bag getVariable ["ROOT_EWO_NETWORK_NAME", "EWO Net"]; };
if (_password isEqualTo "") then { _password = _bag getVariable ["ROOT_EWO_PASSWORD", ""]; };

private _gateway = _bag getVariable ["ROOT_EWO_GATEWAY", [77, 95, 0, 1]];

_bag setVariable ["ROOT_EWO_NETWORK_NAME", _name, true];
_bag setVariable ["ROOT_EWO_PASSWORD", _password, true];
_bag setVariable ["ROOT_EWO_WIFI_ON", _on, true];

// The pack's router is created on the sync pass; asking for it here as well means the switch works the
// moment a pack is picked up rather than only after the next pass has run.
private _router = [_bag] call FUNC(ewoRouterProxy);
if (isNull _router) exitWith {};

[_router, _name, EWO_WIFI_RANGE, _password, _gateway, true, EWO_SUBNET_ALLOW] call AE3_network_fnc_applyRouterConfig;

// The power state is what a laptop's network scan filters on, so it is the switch.
_router setVariable ["AE3_power_powerState", [0, 1] select _on, true];

// A network that goes off the air takes its laptops off with it. Leaving them attached would leave them
// holding addresses on a network that is no longer running, which is a laptop that can still be reached
// over a network nobody can see - and it would let them come back up on it when it is switched on again
// from the other side of the map, without ever being in range of the pack.
if (!_on) then {
    [_router] call AE3_network_fnc_router_onTurnOff;
};

// The drain is counted from the moment the network came up.
if (_on) then {
    _bag setVariable ["ROOT_EWO_WIFI_SINCE", time, true];
};

[
    format [
        localize "STR_ROOT_CYBERWARFARE_EWO_WIFI_SET",
        _name,
        localize ([
            "STR_ROOT_CYBERWARFARE_EWO_WIFI_OFF",
            "STR_ROOT_CYBERWARFARE_EWO_WIFI_ON"
        ] select _on)
    ],
    [ROOT_CYBERWARFARE_COLOR_WARNING, ROOT_CYBERWARFARE_COLOR_SUCCESS] select _on
] remoteExecCall [QFUNC(ewoNotify), _player];
