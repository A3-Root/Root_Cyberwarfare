#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Builds the laptop roster the curator device dialogs offer as link targets. Every
 *              simulated object is tested with fn_isRegisteredLaptop, so every terminal-capable laptop
 *              appears whether or not the hacking toolset has reached it yet. Each entry pairs the
 *              laptop's persistent netId with a label made of its mission-maker name (falling back to
 *              the class display name) and its map grid, and the roster is sorted by that label so the
 *              checkbox order stays stable between dialogs.
 *              A laptop that cannot hack yet is marked in its label rather than hidden: it is a valid
 *              link target - the link lies dormant until the toolset arrives - but a curator picking
 *              between a dozen laptops needs to see which of them are already armed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Laptop roster <ARRAY> - [[netId <STRING>, label <STRING>], ...]
 *
 * Example:
 * private _laptops = call Root_fnc_getRegisteredLaptops;
 *
 * Public: No
 */

private _laptops = [];
private _noToolsMark = localize "STR_ROOT_CYBERWARFARE_ACCESS_LAPTOP_NO_TOOLS";

{
    if ([_x] call FUNC(isRegisteredLaptop)) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        private _toolsMark = ["", " " + _noToolsMark] select !([_x] call FUNC(hasHackingToolsAvailable));
        _laptops pushBack [netId _x, format ["%1 [Grid: %2]%3", _computerName, mapGridPosition _x, _toolsMark]];
    };
} forEach (24 allObjects 1);

// Sort on the label by flipping each pair, sorting, and flipping back: sort orders arrays of strings by
// their first element, so the label has to lead while the comparison runs.
private _byLabel = _laptops apply {[_x select 1, _x select 0]};
_byLabel sort true;

_byLabel apply {[_x select 1, _x select 0]}
