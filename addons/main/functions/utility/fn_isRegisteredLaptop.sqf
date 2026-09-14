#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Answers whether an object can hold device access - that is, whether it may appear as a
 *              link target in the curator dialogs and in the future-laptop exclusion lists. A laptop
 *              the Register Hackable Laptop module marked as a station always qualifies; how far past
 *              that the answer reaches is decided by the ROOT_CYBERWARFARE_LIST_ALL_LAPTOPS setting.
 *              With it off - the default - the hacking toolset has to already be within reach, so a
 *              mission that places unrelated laptops as scenery never sees them offered. With it on,
 *              any laptop qualifies, even one the toolset has never touched, because a mission commonly
 *              places bare laptops, wires devices to them during setup, and delivers the toolset later
 *              by USB or by module. A link handed to a tool-less laptop is inert rather than wrong -
 *              fn_isDeviceAccessible re-checks for tools at access time and refuses until they arrive -
 *              so the link starts working the moment the laptop is armed, with no rewiring needed.
 *              A laptop is recognised from its config as well as from its runtime capability flag: AE3
 *              raises that flag only once the machine has finished initializing, which a laptop nobody
 *              has switched on yet has not done, and a dialog must still be able to offer it.
 *              A flash drive carrying the toolset is a delivery item rather than a station and is
 *              rejected either way, because it owns no ArmaOS terminal to run the commands from.
 *
 * Arguments:
 * 0: _object <OBJECT> - Object to test
 *
 * Return Value:
 * Object can hold device access <BOOL>
 *
 * Example:
 * private _isStation = [_laptop] call Root_fnc_isRegisteredLaptop;
 *
 * Public: No
 */

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {false};
if (_object getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]) exitWith {true};

// An initialized machine reports its terminal through the capability flag; one that has never been
// switched on is recognised by the USB ports every AE3 laptop config declares and a drive does not.
private _isLaptop = (_object getVariable ["AE3_cap_hasTerminal", false])
    || {isClass (configOf _object >> "AE3_USB_Interface")};
if (!_isLaptop) exitWith {false};

if (missionNamespace getVariable [SETTING_LIST_ALL_LAPTOPS, false]) exitWith {true};

[_object] call FUNC(hasHackingToolsAvailable)
