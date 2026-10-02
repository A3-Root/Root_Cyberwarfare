#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Answers whether a laptop is on a network. A laptop joined to a router holds that router
 * as its network parent and has been given an address off it; one that has joined nothing keeps the
 * loopback address and no parent, which is the same pair of facts AE3's own `ip` command reports as
 * having no gateway. Both are networked variables, so this reads the same on a client as on the
 * server.
 *
 * Arguments:
 * 0: _computer <OBJECT> - The laptop to test
 *
 * Return Value:
 * <BOOL> - true when the laptop is connected to a network
 *
 * Example:
 * if ([_computer] call Root_fnc_isLaptopOnline) then { ... };
 *
 * Public: Yes
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith {false};

if (isNull (_computer getVariable ["AE3_network_parent", objNull])) exitWith {false};

private _address = _computer getVariable ["AE3_network_address", [127, 0, 0, 1]];

_address isNotEqualTo [127, 0, 0, 1]
