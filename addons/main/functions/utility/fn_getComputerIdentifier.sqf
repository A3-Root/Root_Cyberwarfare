#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the one identifier a computer's device links are written under, chosen by the
 *              current device setup mode. Simple mode names the laptop by its netId, which is stable
 *              for as long as the object exists. Experimental mode names it by the persistent identity
 *              the laptop carries in an object variable, because that mode is meant for laptops that
 *              get packed into inventory and deployed again - a cycle that destroys the object and
 *              builds a new one, taking its netId with it.
 *              Both answers are derived from the laptop alone, so registration works at mission start
 *              and from a script with nobody standing next to the machine. Reading access back is done
 *              through fn_getComputerIdentifiers, which also accepts the keys other callers may have
 *              written.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Laptop/computer object
 *
 * Return Value:
 * <STRING> - Identifier links are stored under (netId in Simple mode, laptop identity in Experimental mode)
 *
 * Example:
 * private _identifier = [_laptop] call Root_fnc_getComputerIdentifier;
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]]];

DEBUG_LOG_1("getComputerIdentifier called with computer: %1",_computer);

if (isNull _computer) exitWith {
    DEBUG_LOG("Computer is null,returning empty string");
    ""
};

if (IS_EXPERIMENTAL_MODE) exitWith {
    private _uid = [_computer] call FUNC(getLaptopUid);

    // A client reading an unstamped laptop gets nothing back; the netId still names the same machine
    // for as long as it is deployed, so it stands in until the server's stamp arrives.
    if (_uid isEqualTo "") exitWith {
        DEBUG_LOG_1("Experimental mode - laptop not stamped yet, falling back to netId: %1",netId _computer);
        netId _computer
    };

    DEBUG_LOG_1("Experimental mode - laptop identity: %1",_uid);
    _uid
};

// Simple mode - use netId
private _netId = netId _computer;
DEBUG_LOG_1("Simple mode - netId: %1",_netId);
_netId
