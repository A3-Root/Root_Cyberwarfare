#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Gathers what the Zeus Device Identifier module shows, which depends on where it was
 *              dropped. On open ground it is every registered device with the grid it stands on and
 *              the code it answers to; on a device it is that device alone, with the code it has
 *              now. Either way the answer goes to the curator who asked and to nobody else, because
 *              the identifier table is server-only and a code is mission intel. Runs on the server.
 *
 * Arguments:
 * 0: _owner <NUMBER> - clientOwner of the curator
 * 1: _objectNetId <STRING> - netId of the object the module was dropped on, "" for open ground
 *
 * Return Value:
 * None
 *
 * Example:
 * [clientOwner, ""] call Root_fnc_identifierOverview;
 *
 * Public: No
 */

if (!isServer) exitWith {};

params [["_owner", 0, [0]], ["_objectNetId", "", [""]]];

private _rows = [] call FUNC(getRegisteredDevices);

// Whether knowing the code is enough to work the device is kept with the code itself, so it is read
// back the same way the resolver reads it
private _fnc_describe = {
	params ["_row"];

	_row params ["_type", "_id", "", "_object", "", "_label"];

	private _code = [_type, _id] call FUNC(getDeviceIdentifier);
	private _grants = ((GET_DEVICE_IDENTIFIERS getOrDefault [_code, []]) param [2, true]) isEqualTo true;
	private _grid = if (isNull _object) then {""} else {mapGridPosition _object};

	[_type, _id, _label, _grid, _code, _grants]
};

if (_objectNetId isEqualTo "") exitWith {
	["root_cyberwarfare_identifierOverview", ["all", _rows apply {[_x] call _fnc_describe}], _owner] call CBA_fnc_ownerEvent;
};

private _object = objectFromNetId _objectNetId;

// A GPS tracker carries its own code and is read through the Hidden Trackers module, so it is not one
// of the devices this module rewrites
private _mine = _rows select {(_x select 3) isEqualTo _object && {(_x select 0) != DEVICE_TYPE_GPS_TRACKER}};

if (_mine isEqualTo []) exitWith {
	["root_cyberwarfare_identifierOverview", ["none", []], _owner] call CBA_fnc_ownerEvent;
};

["root_cyberwarfare_identifierOverview", ["device", _mine apply {[_x] call _fnc_describe}], _owner] call CBA_fnc_ownerEvent;
