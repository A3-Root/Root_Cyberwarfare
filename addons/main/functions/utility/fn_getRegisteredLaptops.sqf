#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Builds the laptop roster the curator device dialogs offer as link targets. Candidates
 *              come from three places and are then tested with fn_isRegisteredLaptop, so every
 *              terminal-capable laptop appears whether or not the hacking toolset has reached it yet:
 *              the mission-placed object scan, AE3's own registry of laptops that have finished
 *              initializing, and this mod's registry of laptops a module has made hacking stations.
 *              The object scan asks for slow entities as well as normal ones: a laptop is a prop, and
 *              the engine files props under the slow-entity collection, so a scan restricted to normal
 *              entities returns none of them and leaves every checkbox list empty - which reads as a
 *              mission with no laptops and quietly registers devices no laptop can reach.
 *              Each entry pairs the laptop's persistent netId with a label made of its mission-maker
 *              name (falling back to the class display name) and its map grid, and the roster is sorted
 *              by that label so the checkbox order stays stable between dialogs.
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

// Mission-placed objects only (type 8): a laptop is always placed by the editor, by Zeus, or by a script,
// never baked into the terrain, so the terrain collection can be skipped. Both the slow-entity and the
// normal-entity collections are read because a laptop prop lives in the former while an object built on
// a vehicle base lives in the latter, and holders carrying a deployed laptop live in the third.
private _candidates = (8 allObjects 0) + (8 allObjects 1) + (8 allObjects 4);

// Laptops AE3 has finished initializing, and laptops a module of this mod registered as a station. Both
// registries are broadcast and JIP-persistent, so they also cover anything the scan above misses.
_candidates append (missionNamespace getVariable ["ae3_desktop_computers", []]);
_candidates append (missionNamespace getVariable [GVAR_LAPTOP_REGISTRY, []]);

private _seen = createHashMap;

{
    private _laptop = _x;
    // netId is the identifier every link is stored under, so it doubles as the deduplication key across
    // the three sources. A deleted object resolves to an empty id and drops out here.
    private _netId = netId _laptop;

    if (
        !isNull _laptop
        && _netId isNotEqualTo ""
        && {!(_netId in _seen)}
        && {[_laptop] call FUNC(isRegisteredLaptop)}
    ) then {
        _seen set [_netId, true];
        private _displayName = getText (configOf _laptop >> "displayName");
        private _computerName = _laptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        private _toolsMark = ["", " " + _noToolsMark] select !([_laptop] call FUNC(hasHackingToolsAvailable));
        _laptops pushBack [_netId, format ["%1 [Grid: %2]%3", _computerName, mapGridPosition _laptop, _toolsMark]];
    };
} forEach _candidates;

// Sort on the label by flipping each pair, sorting, and flipping back: sort orders arrays of strings by
// their first element, so the label has to lead while the comparison runs.
private _byLabel = _laptops apply {[_x select 1, _x select 0]};
_byLabel sort true;

_byLabel apply {[_x select 1, _x select 0]}
