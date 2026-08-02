#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: ZEN module that changes which computers can reach devices that are already registered.
 *              Placed on a registered laptop it works on that laptop; placed on the ground it offers a
 *              picker of every registered laptop. The dialog lists all registered devices with their
 *              type, id, name, and whether the chosen laptop currently reaches them, so a device that
 *              was registered as unassigned can be handed out during play. The chosen action is
 *              applied server-side by fn_setDeviceLinksMain.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_manageDeviceLinksZeus;
 *
 * Public: No
 */

params ["_logic"];

private _targetLaptop = attachedTo _logic;
deleteVehicle _logic;

if !(hasInterface) exitWith {};

// A laptop placed under the module counts as the target only once it is a registered station.
if (!isNull _targetLaptop && {!(_targetLaptop getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false])}) then {
    _targetLaptop = objNull;
};

// Collect every registered laptop so the module can be dropped on the ground and still be usable.
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        _allComputers pushBack [netId _x, format ["%1 [%2]", _computerName, mapGridPosition _x]];
    };
} forEach (24 allObjects 1);

if (_allComputers isEqualTo []) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS"] call zen_common_fnc_showMessage;
};

// Flatten the registry into [deviceType, deviceId, label] rows. Doors carry their display name one
// slot further along than the other device types.
private _deviceLabels = [
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_GPS",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID"
];

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _deviceRows = [];

{
    private _deviceType = _forEachIndex + 1;
    private _nameIndex = [3, 2] select (_deviceType != DEVICE_TYPE_DOOR);
    private _typeLabel = _deviceLabels select _forEachIndex;

    {
        private _deviceId = _x select 0;
        private _deviceName = _x param [_nameIndex, ""];
        if !(_deviceName isEqualType "") then { _deviceName = ""; };
        _deviceRows pushBack [_deviceType, _deviceId, format ["%1 %2 - %3", _typeLabel, _deviceId, _deviceName]];
    } forEach _x;
} forEach _allDevices;

if (_deviceRows isEqualTo []) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_LINKS_NO_DEVICES"] call zen_common_fnc_showMessage;
};

// Pre-tick the devices the target laptop already reaches privately. With no single target laptop the
// boxes start clear, since there is nothing to pre-tick them from.
private _currentLinks = [];
if (!isNull _targetLaptop) then {
    _currentLinks = (GET_LINK_CACHE) getOrDefault [[_targetLaptop] call FUNC(getComputerIdentifier), []];
};

private _dialogControls = [
    ["COMBO", [localize "STR_ROOT_CYBERWARFARE_LINKS_ACTION", localize "STR_ROOT_CYBERWARFARE_LINKS_ACTION_DESC"], [
        [ACCESS_ACTION_LINK, ACCESS_ACTION_UNLINK, ACCESS_ACTION_PUBLIC, ACCESS_ACTION_UNASSIGN],
        [
            localize "STR_ROOT_CYBERWARFARE_LINKS_ACTION_LINK",
            localize "STR_ROOT_CYBERWARFARE_LINKS_ACTION_UNLINK",
            localize "STR_ROOT_CYBERWARFARE_LINKS_ACTION_PUBLIC",
            localize "STR_ROOT_CYBERWARFARE_LINKS_ACTION_UNASSIGN"
        ],
        0
    ]]
];

// Only offer the laptop picker when the module was not placed on a laptop.
private _needsLaptopPicker = isNull _targetLaptop;
if (_needsLaptopPicker) then {
    _dialogControls pushBack ["COMBO", [localize "STR_ROOT_CYBERWARFARE_LINKS_LAPTOP", localize "STR_ROOT_CYBERWARFARE_LINKS_LAPTOP_DESC"], [
        _allComputers apply {_x select 0},
        _allComputers apply {_x select 1},
        0
    ]];
};

{
    _x params ["_deviceType", "_deviceId", "_label"];
    private _isLinked = (_currentLinks findIf {(_x select 0) == _deviceType && {(_x select 1) == _deviceId}}) > -1;
    _dialogControls pushBack ["CHECKBOX", [_label, localize "STR_ROOT_CYBERWARFARE_LINKS_DEVICE_DESC"], _isLinked];
} forEach _deviceRows;

[
    localize "STR_ROOT_CYBERWARFARE_LINKS_TITLE",
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_targetLaptop", "_needsLaptopPicker", "_deviceRows"];

        private _resultIndex = 0;
        private _action = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        private _computerNetId = "";
        if (_needsLaptopPicker) then {
            _computerNetId = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
        } else {
            _computerNetId = netId _targetLaptop;
        };

        private _selectedDevices = [];
        {
            if (_results select (_resultIndex + _forEachIndex)) then {
                _selectedDevices pushBack [_x select 0, _x select 1];
            };
        } forEach _deviceRows;

        if (_selectedDevices isEqualTo []) exitWith {
            [localize "STR_ROOT_CYBERWARFARE_LINKS_NONE_SELECTED"] call zen_common_fnc_showMessage;
        };

        // The server resolves the identifier for the chosen laptop, so Experimental mode keeps working.
        [[_computerNetId], _selectedDevices, _action, clientOwner] remoteExec ["Root_fnc_setDeviceLinksMain", 2];
        [localize "STR_ROOT_CYBERWARFARE_LINKS_APPLIED"] call zen_common_fnc_showMessage;
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_targetLaptop, _needsLaptopPicker, _deviceRows]
] call zen_dialog_fnc_create;
