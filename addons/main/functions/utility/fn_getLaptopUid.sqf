#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the persistent identity a laptop carries for the lifetime of the mission, and
 *              mints one on first use. The identity lives in an object variable rather than in the
 *              laptop's netId because a laptop is allowed to leave the world: packing one into
 *              inventory deletes the object and deploying it again builds a new one with a new netId,
 *              which would strand every device link written against the old object. AE3 copies a
 *              laptop's object variables into the item buffer as it is packed and writes them back -
 *              broadcast - onto the object it deploys, so a stamp made here travels with the machine
 *              across as many pickup and deploy cycles as the mission runs.
 *              Minting happens on the server only, from a counter the server keeps, so two machines
 *              can never hand the same laptop two different identities. A client asked about a laptop
 *              that has not been stamped yet gets an empty string instead of a locally invented value;
 *              callers pair this with the laptop's netId rather than treating the gap as an error.
 *
 * Arguments:
 * 0: _laptop <OBJECT> - Laptop to read the identity of
 *
 * Return Value:
 * Persistent laptop identity <STRING> - empty when the laptop is null, or unstamped on a client
 *
 * Example:
 * private _uid = [_laptop] call Root_fnc_getLaptopUid;
 *
 * Public: No
 */

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {""};

private _uid = _laptop getVariable [GVAR_LAPTOP_UID, ""];

if (_uid isNotEqualTo "") exitWith {_uid};

// Only the server mints, and it publishes immediately so every client reads the same value.
if (!isServer) exitWith {""};

private _counter = (missionNamespace getVariable [GVAR_LAPTOP_UID_COUNTER, 0]) + 1;
missionNamespace setVariable [GVAR_LAPTOP_UID_COUNTER, _counter];

_uid = format ["RCW_%1", _counter];
_laptop setVariable [GVAR_LAPTOP_UID, _uid, true];

DEBUG_LOG_2("Laptop %1 stamped with persistent identity %2",_laptop,_uid);

_uid
