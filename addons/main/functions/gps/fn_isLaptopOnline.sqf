#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Whether a laptop is on a network (AE3_network_fnc_isOnline). Any machine.
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

[_computer] call AE3_network_fnc_isOnline
