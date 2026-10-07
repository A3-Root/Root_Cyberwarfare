#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Zeus module to add hackable building doors.
 * For lights, use fn_addLightsZeus. For drones, use fn_addVehicleZeus. For custom devices, use fn_addCustomDeviceZeus.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addDoorsZeus;
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

    // Find the closest compatible object that exposes door animations or configs
    {
        if (_x != _logic && !(_x isKindOf "Logic")) then {
            private _detectedDoors = [_x] call Root_fnc_detectBuildingDoors;
            private _isBuilding = count _detectedDoors > 0;

            if (_isBuilding) exitWith {
                _targetObject = _x;
            };
        };
    } forEach _nearObjects;
};

private _useRadiusMode = isNull _targetObject;

if !(hasInterface) exitWith {};

// In direct mode, validate that the target object exposes door animations or configs
if (!_useRadiusMode) then {
    private _detectedDoors = [_targetObject] call Root_fnc_detectBuildingDoors;
    private _isBuilding = count _detectedDoors > 0;

    if !(_isBuilding) exitWith {
        deleteVehicle _logic;
        [(localize "STR_ROOT_CYBERWARFARE_UI_OBJECT_DOES_NOT_EXPOSE_ANY_DOOR_ANIMATIONS")] call zen_common_fnc_showMessage;
    };
};

// Detected engine door numbers for the target building (direct mode). One custom-ID entry field is
// offered per door so the curator can rename each door's addressable ID.
private _detectedDoors = [];
if (!_useRadiusMode) then {
    _detectedDoors = [_targetObject] call Root_fnc_detectBuildingDoors;
};

// Draw a temporary "Door #N" label in front of each door so the curator can tell which door number
// maps to which physical door while assigning custom IDs. The handler is local to this client and is
// removed again when the dialog is confirmed or cancelled.
if (!_useRadiusMode && _detectedDoors isNotEqualTo []) then {
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DOORLABEL_DATA", [_targetObject] call Root_fnc_getDoorPositions];
    private _drawHandle = addMissionEventHandler ["Draw3D", {
        {
            _x params ["_num", "_pos"];
            drawIcon3D ["", [0.6, 0.1, 0.9, 1], _pos, 0, 0, 0, format [(localize "STR_ROOT_CYBERWARFARE_UI_DOOR_1"), _num], 2, 0.035, "PuristaMedium"];
        } forEach (missionNamespace getVariable ["ROOT_CYBERWARFARE_DOORLABEL_DATA", []]);
    }];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DOORLABEL_HANDLE", _drawHandle];
};

// Every laptop the doors can be linked to. Without one the dialog still works, but only the Unassigned
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
    _dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_MAKE_UNBREACHABLE"), (localize "STR_ROOT_CYBERWARFARE_UI_PREVENT_DOOR_BREACHING_BY_ACE_EXPLOSIVES_FOR_ALL_BUILDINGS_WITH_DOORS_IN")], false];
};

_dialogControls pushBack ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
    [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
    [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"],
    0
]];
_dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE"), (localize "STR_ROOT_CYBERWARFARE_UI_ONLY_APPLIES_TO_LINKED_COMPUTERS_ONLY_THE_LINKED_COMPUTERS_KEEP_ACCESS_AND")], false];
_dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW"), (localize "STR_ROOT_CYBERWARFARE_UI_SHOW_THIS_DEVICE_S_GRID_LOCATION_ON_THE_LAPTOP_CLI_GUI_DISABLE")], true];

// Add unbreachable option for buildings (always available in this module)
if (!_useRadiusMode) then {
    _dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_MAKE_UNBREACHABLE"), (localize "STR_ROOT_CYBERWARFARE_UI_PREVENT_DOOR_BREACHING_BY_ACE_EXPLOSIVES_LOCKPICKING_AND_OTHER_NON_HACKING_METHODS")], false];
};

// Device ID entry: radius mode distributes a Start..End range across the found buildings; direct mode
// takes a single fixed ID plus a custom ID field per detected door.
if (_useRadiusMode) then {
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIRST_BUILDING_ID_HANDED_OUT_ACROSS_THE_AREA_0_AUTO_ASSIGN")], ["0"]];
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_LAST_BUILDING_ID_HANDED_OUT_ACROSS_THE_AREA_0_AUTO_ASSIGN")], ["0"]];
} else {
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIXED_ID_FOR_THIS_BUILDING_0_AUTO_ASSIGN_A_FREE_ID")], ["0"]];
    {
        _dialogControls pushBack ["EDIT", [format [(localize "STR_ROOT_CYBERWARFARE_UI_DOOR_1_ID"), _x], (localize "STR_ROOT_CYBERWARFARE_UI_CUSTOM_NUMERIC_ID_A_HACKER_USES_TO_ADDRESS_THIS_DOOR_DEFAULTS_TO")], [str _x]];
    } forEach _detectedDoors;
};

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_THIS_DEVICE_TO_1"), _computerName]], false];
} forEach _allComputers;

[
    if (_useRadiusMode) then {(localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_DOORS_RADIUS_MODE")} else {format [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_DOORS_1"), getText (configOf _targetObject >> "displayName")]},
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_logicPosition", "_targetObject", "_execUserId", "_allComputers", "_useRadiusMode", "_detectedDoors"];

        // Remove the temporary door labels now that the dialog has closed.
        private _labelHandle = missionNamespace getVariable ["ROOT_CYBERWARFARE_DOORLABEL_HANDLE", -1];
        if (_labelHandle >= 0) then {
            removeMissionEventHandler ["Draw3D", _labelHandle];
            missionNamespace setVariable ["ROOT_CYBERWARFARE_DOORLABEL_HANDLE", -1];
        };
        missionNamespace setVariable ["ROOT_CYBERWARFARE_DOORLABEL_DATA", []];

        private _resultIndex = 0;
        private _radius = 0;
        private _makeUnbreachable = false;

        // Extract radius and unbreachable flag if in radius mode
        if (_useRadiusMode) then {
            _radius = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
            _makeUnbreachable = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
        };

        // Extract the access mode, then the availability setting that refines the linked mode
        private _accessMode = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        private _availableToFutureLaptops = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        // Extract "Allow Location View" (pushed right after availability)
        private _allowLocation = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        // Extract unbreachable setting (for direct mode)
        if (!_useRadiusMode) then {
            _makeUnbreachable = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
        };

        // Extract the device ID field(s) and, in direct mode, the per-door custom IDs.
        private _requestedId = 0;
        private _rangeEndId = 0;
        private _doorIdMap = [];
        if (_useRadiusMode) then {
            _requestedId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
            _rangeEndId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
        } else {
            _requestedId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
            {
                private _custom = parseNumber (_results select _resultIndex);
                _resultIndex = _resultIndex + 1;
                if (_custom > 0) then { _doorIdMap pushBack [_x, _custom]; };
            } forEach _detectedDoors;
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
            [_logicPosition, _radius, _execUserId, _selectedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation, _requestedId, _rangeEndId, _accessMode] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
        } else {
            // Direct mode: Register single object
            [_targetObject, _execUserId, _selectedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation, _requestedId, _doorIdMap, _accessMode] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
            [(localize "STR_ROOT_CYBERWARFARE_UI_HACKABLE_DOORS_ADDED")] call zen_common_fnc_showMessage;
        };

        // Linked access with nothing ticked registers a device no laptop can reach, which the success
        // message above does not convey on its own.
        [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
    },
    {
        // Remove the temporary door labels on cancel as well.
        private _labelHandle = missionNamespace getVariable ["ROOT_CYBERWARFARE_DOORLABEL_HANDLE", -1];
        if (_labelHandle >= 0) then {
            removeMissionEventHandler ["Draw3D", _labelHandle];
            missionNamespace setVariable ["ROOT_CYBERWARFARE_DOORLABEL_HANDLE", -1];
        };
        missionNamespace setVariable ["ROOT_CYBERWARFARE_DOORLABEL_DATA", []];

        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_logicPosition, _targetObject, _execUserId, _allComputers, _useRadiusMode, _detectedDoors]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
