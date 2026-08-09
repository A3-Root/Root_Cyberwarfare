#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ZEN module that reassigns which laptops reach a device, one device at a time. Placed on
 *              a registered object it opens that object's devices; placed on empty ground it first asks
 *              for a radius, reports what it found inside it, and then walks the devices one dialog at
 *              a time. Each dialog shows the device's current access mode and a checkbox per laptop,
 *              already ticked wherever that laptop reaches the device right now, so a curator can see
 *              the existing wiring before changing it. Confirming rewrites that device's access to
 *              exactly what the dialog shows; cancelling leaves it as it was and moves on to the next
 *              device. This is the device-centric counterpart to the Manage Device Links module, which
 *              works the other way round - one laptop, many devices.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_manageDeviceAccessZeus;
 *
 * Public: No
 */

params ["_logic"];

private _targetObject = attachedTo _logic;
private _logicPosition = getPosATL _logic;
deleteVehicle _logic;

if !(hasInterface) exitWith {};

private _allComputers = call FUNC(getRegisteredLaptops);
if (_allComputers isEqualTo []) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS"] call zen_common_fnc_showMessage;
};

private _allRows = [] call FUNC(getRegisteredDevices);
if (_allRows isEqualTo []) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_LINKS_NO_DEVICES"] call zen_common_fnc_showMessage;
};

// Resolve each laptop to the identifier the link cache is keyed by, so the checkboxes can be pre-ticked
// from the same key the server will write back. Experimental mode keys by the operating player's UID,
// which is empty for a laptop nobody is using - those laptops simply start unticked.
private _computerIdentifiers = _allComputers apply {
    private _laptop = objectFromNetId (_x select 0);
    [_laptop] call FUNC(getComputerIdentifier)
};

// Opens the dialog for one device and, whichever way it is closed, moves on to the next. Passed to
// itself through the dialog arguments because a ZEN dialog hands control back through a callback and
// there is no other way for that callback to reach the routine that created it.
private _showDeviceDialog = {
    params ["_queue", "_index", "_allComputers", "_computerIdentifiers", "_showDeviceDialog"];

    if (_index >= count _queue) exitWith {
        [localize "STR_ROOT_CYBERWARFARE_ACCESS_RUN_FINISHED"] call zen_common_fnc_showMessage;
    };

    (_queue select _index) params ["_deviceType", "_deviceId", "", "", "", "_label"];

    // Read the device's present reachability back out of the registry so the dialog opens showing what
    // is true right now. A public entry with an exclusion list is how registration records "these
    // laptops plus every laptop added later", so it is shown as Linked with the future flag set.
    private _publicEntry = (GET_PUBLIC_DEVICES) select {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}};
    private _linkCache = GET_LINK_CACHE;

    private _currentMode = ACCESS_MODE_UNASSIGNED;
    private _currentFuture = false;
    private _exclusions = [];

    if (_publicEntry isNotEqualTo []) then {
        _exclusions = (_publicEntry select 0) param [2, []];
        if (_exclusions isEqualTo []) then {
            _currentMode = ACCESS_MODE_PUBLIC;
        } else {
            _currentMode = ACCESS_MODE_LINKED;
            _currentFuture = true;
        };
    };

    private _linkedFlags = _computerIdentifiers apply {
        private _identifier = _x;
        if (_identifier isEqualTo "") then {
            false
        } else {
            private _links = _linkCache getOrDefault [_identifier, []];
            private _hasLink = (_links findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}}) > -1;

            // In the "linked plus future laptops" state, reachability is written as an exclusion list
            // rather than as a link, so a laptop that appeared after registration reaches the device
            // with no link of its own. Ticking it from the exclusion list too means confirming the
            // dialog unchanged keeps the access it already had, instead of quietly revoking it.
            _hasLink || {_currentFuture && {!(_identifier in _exclusions)}}
        }
    };

    if (_currentMode == ACCESS_MODE_UNASSIGNED && {true in _linkedFlags}) then {
        _currentMode = ACCESS_MODE_LINKED;
    };

    private _modeValues = [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC];

    // Every control forces its default. ZEN otherwise restores whatever this dialog was last confirmed
    // with, which would quietly overwrite the device's real access state with a stale copy of another
    // device's answers - the opposite of what a dialog whose whole job is to show the current wiring
    // should do.
    private _dialogControls = [
        ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
            _modeValues,
            [
                localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED",
                localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED",
                localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"
            ],
            _modeValues find _currentMode
        ], true],
        ["TOOLBOX:YESNO", [
            localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE",
            localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE_DESC"
        ], _currentFuture, true]
    ];

    {
        _dialogControls pushBack ["CHECKBOX", [
            _x select 1,
            format [localize "STR_ROOT_CYBERWARFARE_ACCESS_LAPTOP_DESC", _x select 1]
        ], _linkedFlags select _forEachIndex, true];
    } forEach _allComputers;

    private _title = format [
        localize "STR_ROOT_CYBERWARFARE_ACCESS_DEVICE_TITLE",
        _index + 1,
        count _queue,
        _label
    ];

    [
        _title,
        _dialogControls,
        {
            params ["_results", "_args"];
            _args params ["_queue", "_index", "_allComputers", "_computerIdentifiers", "_showDeviceDialog"];

            (_queue select _index) params ["_deviceType", "_deviceId"];
            _results params ["_accessMode", "_availableToFutureLaptops"];

            private _selectedComputers = [];
            {
                if (_results select (2 + _forEachIndex)) then {
                    _selectedComputers pushBack (_x select 0);
                };
            } forEach _allComputers;

            [_deviceType, _deviceId, _selectedComputers, _accessMode, _availableToFutureLaptops, clientOwner]
                remoteExec ["Root_fnc_setDeviceAccessMain", 2];

            // The next device waits a frame. This handler runs while the current dialog is still being
            // torn down, and a display created inside that teardown is liable to be closed along with
            // the one it replaced.
            [_showDeviceDialog, [_queue, _index + 1, _allComputers, _computerIdentifiers, _showDeviceDialog]] call CBA_fnc_execNextFrame;
        },
        {
            // Cancelling leaves this device exactly as it was and moves on to the next, so one device
            // can be stepped over without giving up the rest of the run.
            params ["", "_args"];
            _args params ["_queue", "_index", "_allComputers", "_computerIdentifiers", "_showDeviceDialog"];

            [_showDeviceDialog, [_queue, _index + 1, _allComputers, _computerIdentifiers, _showDeviceDialog]] call CBA_fnc_execNextFrame;
        },
        [_queue, _index, _allComputers, _computerIdentifiers, _showDeviceDialog]
    ] call zen_dialog_fnc_create;
};

// Module dropped on a registered object: work on the devices that object carries and nothing else. One
// object can hold several - a vehicle that is also a GPS tracker target, say - so all of them are
// queued rather than only the first.
if (!isNull _targetObject) exitWith {
    private _queue = _allRows select {(_x select 3) isEqualTo _targetObject};

    if (_queue isEqualTo []) exitWith {
        [localize "STR_ROOT_CYBERWARFARE_ACCESS_NOT_A_DEVICE"] call zen_common_fnc_showMessage;
    };

    [_queue, 0, _allComputers, _computerIdentifiers, _showDeviceDialog] call _showDeviceDialog;
};

// Module dropped on empty ground: ask for a radius, then queue every registered device standing inside
// it. Devices whose object is gone have no position to test and are left out of a radius run.
[
    localize "STR_ROOT_CYBERWARFARE_ACCESS_RADIUS_TITLE",
    [
        ["SLIDER:RADIUS", [
            localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS",
            localize "STR_ROOT_CYBERWARFARE_ACCESS_RADIUS_DESC"
        ], [10, 3000, 250, 0, _logicPosition, [7, 120, 32, 1]]]
    ],
    {
        params ["_results", "_args"];
        _args params ["_allRows", "_logicPosition", "_allComputers", "_computerIdentifiers", "_showDeviceDialog"];
        _results params ["_radius"];

        private _queue = _allRows select {
            private _object = _x select 3;
            !isNull _object && {(_object distance2D _logicPosition) <= _radius}
        };

        if (_queue isEqualTo []) exitWith {
            [format [localize "STR_ROOT_CYBERWARFARE_ACCESS_RADIUS_EMPTY", round _radius]] call zen_common_fnc_showMessage;
        };

        // Report the haul before opening the first dialog, so a curator who dropped the module on the
        // wrong spot finds out now rather than after paging through the devices one by one.
        private _counts = createHashMap;
        {
            private _typeLabel = _x select 4;
            _counts set [_typeLabel, (_counts getOrDefault [_typeLabel, 0]) + 1];
        } forEach _queue;

        private _summary = (keys _counts) apply {format ["%1: %2", _x, _counts get _x]};
        [format [
            localize "STR_ROOT_CYBERWARFARE_ACCESS_RADIUS_FOUND",
            count _queue,
            round _radius,
            _summary joinString ", "
        ]] call zen_common_fnc_showMessage;

        [_showDeviceDialog, [_queue, 0, _allComputers, _computerIdentifiers, _showDeviceDialog]] call CBA_fnc_execNextFrame;
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_allRows, _logicPosition, _allComputers, _computerIdentifiers, _showDeviceDialog]
] call zen_dialog_fnc_create;
