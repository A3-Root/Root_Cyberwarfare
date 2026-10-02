#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Draws an unused tracker identifier: eight characters from an alphabet that leaves out
 * the pairs a person confuses when reading a code out loud or typing it from memory (I and 1, O and
 * 0). A draw that lands on an identifier already in use is thrown away and redrawn, so two trackers
 * can never answer to the same code. Server only, because the identifier map it checks against lives
 * on the server and nowhere else.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * <STRING> - A fresh identifier, or "" when called anywhere but the server
 *
 * Example:
 * private _code = call Root_fnc_generateGpsIdentifier;
 *
 * Public: No
 */

if (!isServer) exitWith {""};

private _alphabet = GPS_IDENTIFIER_ALPHABET;
private _alphabetSize = count _alphabet;
private _taken = keys GET_GPS_IDENTIFIERS;

private _identifier = "";

// A fresh draw is almost always free; the loop is here so that a mission which has handed out an
// improbable number of codes still terminates rather than returning a duplicate.
for "_attempt" from 1 to 64 do {
    private _chars = [];
    for "_i" from 1 to GPS_IDENTIFIER_LENGTH do {
        _chars pushBack (_alphabet select [floor random _alphabetSize, 1]);
    };

    private _candidate = _chars joinString "";
    if !(_candidate in _taken) exitWith {
        _identifier = _candidate;
    };
};

if (_identifier isEqualTo "") then {
    ROOT_CYBERWARFARE_LOG_ERROR("generateGpsIdentifier: could not draw an unused tracker identifier");
};

_identifier
