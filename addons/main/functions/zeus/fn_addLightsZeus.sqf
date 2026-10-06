#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Zeus module to add hackable lights.
 * For doors, use fn_addDoorsZeus. For drones, use fn_addVehicleZeus. For custom devices, use fn_addCustomDeviceZeus.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addLightsZeus;
 *
 * Public: No
 */

params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

// If no attached object (Zeus-placed), try to find terrain object at logic position
if (isNull _targetObject) then {
    private _logicPos = getPosATL _logic;
    private _nearObjects = nearestObjects [_logicPos, [], 5];

    // Find the closest compatible object (light only)
    {
        if (_x != _logic && !(_x isKindOf "Logic")) then {
            // Only accept lights
            private _isLight = _x isKindOf "Lamps_base_F";

            if (_isLight) exitWith {
                _targetObject = _x;
            };
        };
    } forEach _nearObjects;
};

private _useRadiusMode = isNull _targetObject;

if !(hasInterface) exitWith {};

// In direct mode, validate that the target object is compatible (light only)
if (!_useRadiusMode) then {
    private _isLight = _targetObject isKindOf "Lamps_base_F";

    if !(_isLight) exitWith {
        deleteVehicle _logic;
        [(localize "STR_ROOT_CYBERWARFARE_UI_OBJECT_IS_NOT_A_LIGHT")] call zen_common_fnc_showMessage;
    };
};

// Every laptop the lights can be linked to. Without one the dialog still works, but only the Unassigned
// and Public access modes can do anything, so the curator is told before spending time on the form.
private _allComputers = call FUNC(getRegisteredLaptops);
if (_allComputers isEqualTo []) then {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS_WARN"] call zen_common_fnc_showMessage;
};

// Capture logic position before dialog (needed for radius mode callback after logic is deleted)
private _logicPosition = getPosATL _logic;

private _dialogControls = [];

// Add radius slider if in radius mode
if (_useRadiusMode) then {
    _dialogControls pushBack ["SLIDER:RADIUS", [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS", localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS_DESC"], [10, 3000, 1000, 0, _logicPosition, [7,120,32,1]]];
};

_dialogControls pushBack ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
    [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
    [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"],
    0
]];
_dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE"), (localize "STR_ROOT_CYBERWARFARE_UI_ONLY_APPLIES_TO_LINKED_COMPUTERS_ONLY_THE_LINKED_COMPUTERS_KEEP_ACCESS_AND")], false];
_dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW"), (localize "STR_ROOT_CYBERWARFARE_UI_SHOW_THIS_DEVICE_S_GRID_LOCATION_ON_THE_LAPTOP_CLI_GUI_DISABLE")], true];

// Device ID entry: radius mode distributes a Start..End range across the found lights; direct mode
// takes a single fixed ID.
if (_useRadiusMode) then {
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIRST_LIGHT_ID_HANDED_OUT_ACROSS_THE_AREA_0_AUTO_ASSIGN")], ["0"]];
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_LAST_LIGHT_ID_HANDED_OUT_ACROSS_THE_AREA_0_AUTO_ASSIGN")], ["0"]];
} else {
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIXED_ID_FOR_THIS_LIGHT_0_AUTO_ASSIGN_A_FREE_ID")], ["0"]];
};

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_THIS_DEVICE_TO_1"), _computerName]], false];
} forEach _allComputers;

[
    if (_useRadiusMode) then {(localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_LIGHTS_RADIUS_MODE")} else {format [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_LIGHT_1"), getText (configOf _targetObject >> "displayName")]},
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_logicPosition", "_targetObject", "_execUserId", "_allComputers", "_useRadiusMode"];

        private _resultIndex = 0;
        private _radius = 0;

        // Extract radius if in radius mode
        if (_useRadiusMode) then {
            _radius = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
        };

        // Extract the access mode, then the availability setting that refines the linked mode
        private _accessMode = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        private _availableToFutureLaptops = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        // Extract "Allow Location View"
        private _allowLocation = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        // Extract the device ID field(s): a Start..End range in radius mode, a single ID otherwise.
        private _requestedId = 0;
        private _rangeEndId = 0;
        if (_useRadiusMode) then {
            _requestedId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
            _rangeEndId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
        } else {
            _requestedId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
        };

        // Process laptop checkboxes
        private _selectedComputers = [];
        {
            if (_results select (_resultIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // Handle radius mode or direct mode
        if (_useRadiusMode) then {
            // Radius mode: Use captured position (logic is already deleted)
            [_logicPosition, _radius, _execUserId, _selectedComputers, _availableToFutureLaptops, _allowLocation, _requestedId, _rangeEndId, _accessMode] remoteExec ["Root_fnc_addLightsZeusMain", 2];
        } else {
            // Direct mode: Register single object
            [_targetObject, _execUserId, _selectedComputers, _availableToFutureLaptops, _allowLocation, _requestedId, _accessMode] remoteExec ["Root_fnc_addLightsZeusMain", 2];
            [(localize "STR_ROOT_CYBERWARFARE_UI_HACKABLE_LIGHT_ADDED")] call zen_common_fnc_showMessage;
        };

        // Linked access with nothing ticked registers a device no laptop can reach, which the success
        // message above does not convey on its own.
        [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_logicPosition, _targetObject, _execUserId, _allComputers, _useRadiusMode]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
