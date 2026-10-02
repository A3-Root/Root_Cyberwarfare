#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Looks up what a typed tracker identifier belongs to. Case and surrounding whitespace
 * are forgiven, because the code is something an operator reads off a note or hears over the radio.
 * Server only: the identifier map is the mission's secret, so a client asks the server to resolve a
 * code rather than holding the codes itself.
 *
 * Arguments:
 * 0: _identifier <STRING> - The identifier as the operator typed it
 *
 * Return Value:
 * <ARRAY> - [deviceId, trackerName, objectName, plantedByUid, hidden] for a known identifier,
 *           [] for anything else
 *
 * Example:
 * private _entry = ["d34fndum"] call Root_fnc_resolveGpsIdentifier;
 *
 * Public: No
 */

if (!isServer) exitWith {[]};

params [["_identifier", "", [""]]];

private _normalized = toUpperANSI ([_identifier] call CBA_fnc_trim);
if (_normalized isEqualTo "") exitWith {[]};

(GET_GPS_IDENTIFIERS) getOrDefault [_normalized, []]
