#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns every identifier a computer's device links may be stored under, most specific
 *              first. Access checks read this set rather than a single key: links are written under
 *              the one identifier fn_getComputerIdentifier reports, but a mission's link cache can
 *              also hold entries a script wrote by netId, or entries an earlier build of this mod
 *              wrote before the identity in use today existed. Matching against the whole set means
 *              those keep granting the access they were meant to grant instead of quietly going dead.
 *              In Simple mode the set is the laptop's netId alone. In Experimental mode the laptop's
 *              persistent identity leads, because that is what survives the machine being packed and
 *              redeployed, and its current netId follows as the fallback.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Laptop/computer object
 *
 * Return Value:
 * Identifiers to match against <ARRAY> - [<STRING>, ...], empty when none could be resolved
 *
 * Example:
 * private _identifiers = [_laptop] call Root_fnc_getComputerIdentifiers;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

if (isNull _computer) exitWith {[]};

private _identifiers = [];

if (IS_EXPERIMENTAL_MODE) then {
    _identifiers pushBack ([_computer] call FUNC(getLaptopUid));
};

_identifiers pushBack (netId _computer);

// A laptop that has not been stamped yet, or one the engine cannot name, contributes nothing.
_identifiers select {_x isNotEqualTo ""}
