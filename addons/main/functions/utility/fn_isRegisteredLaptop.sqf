#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Answers whether an object can hold device access - that is, whether it may appear as a
 *              link target in the curator dialogs and in the future-laptop exclusion lists. A laptop
 *              the Register Hackable Laptop module marked as a station always qualifies; how far past
 *              that the answer reaches is decided by the ROOT_CYBERWARFARE_LIST_ALL_LAPTOPS setting.
 *              With it on, any object owning an ArmaOS terminal qualifies, even one the hacking toolset
 *              has never touched. That is deliberately broader than "can hack right now", because a
 *              mission commonly places bare laptops, wires devices to them during setup, and delivers
 *              the toolset later by USB or by module. A link handed to a tool-less laptop is inert
 *              rather than wrong - fn_isDeviceAccessible re-checks for tools at access time and refuses
 *              until they arrive - so the link starts working the moment the laptop is armed, with no
 *              rewiring needed. With it off, the toolset has to already be within reach, which suits a
 *              mission that places unrelated laptops as scenery and does not want them offered.
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
if !(_object getVariable ["AE3_cap_hasTerminal", false]) exitWith {false};

if (missionNamespace getVariable [SETTING_LIST_ALL_LAPTOPS, true]) exitWith {true};

[_object] call FUNC(hasHackingToolsAvailable)
