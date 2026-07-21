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
        ["Object does not expose any door animations!"] call zen_common_fnc_showMessage;
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
            drawIcon3D ["", [0.6, 0.1, 0.9, 1], _pos, 0, 0, 0, format ["Door #%1", _num], 2, 0.035, "PuristaMedium"];
        } forEach (missionNamespace getVariable ["ROOT_CYBERWARFARE_DOORLABEL_DATA", []]);
    }];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DOORLABEL_HANDLE", _drawHandle];
};

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false]) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        private _netId = netId _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

// Capture logic position before dialog (needed for radius mode callback after logic is deleted)
private _logicPosition = getPosATL _logic;

private _dialogControls = [];

// Add radius slider if in radius mode
if (_useRadiusMode) then {
    _dialogControls pushBack ["SLIDER:RADIUS", [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS", localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS_DESC"], [10, 3000, 1000, 0, _logicPosition, [7,120,32,1]]];
    _dialogControls pushBack ["TOOLBOX:YESNO", ["Make Unbreachable", "Prevent door breaching by ACE explosives for all buildings with doors in radius"], false];
};

_dialogControls pushBack ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this device be available to laptops that are added later?"], false];
_dialogControls pushBack ["TOOLBOX:YESNO", ["Allow Location View", "Show this device's grid location on the laptop (CLI + GUI). Disable to hide it."], true];

// Add unbreachable option for buildings (always available in this module)
if (!_useRadiusMode) then {
    _dialogControls pushBack ["TOOLBOX:YESNO", ["Make Unbreachable", "Prevent door breaching by ACE explosives, lockpicking, and other non-hacking methods"], false];
};

// Device ID entry: radius mode distributes a Start..End range across the found buildings; direct mode
// takes a single fixed ID plus a custom ID field per detected door.
if (_useRadiusMode) then {
    _dialogControls pushBack ["EDIT", ["Device ID Start (0 = auto)", "First building ID handed out across the area. 0 = auto-assign."], ["0"]];
    _dialogControls pushBack ["EDIT", ["Device ID End (0 = auto)", "Last building ID handed out across the area. 0 = auto-assign."], ["0"]];
} else {
    _dialogControls pushBack ["EDIT", ["Device ID (0 = auto)", "Fixed ID for this building. 0 = auto-assign a free ID."], ["0"]];
    {
        _dialogControls pushBack ["EDIT", [format ["Door #%1 ID", _x], "Custom numeric ID a hacker uses to address this door. Defaults to the engine number."], [str _x]];
    } forEach _detectedDoors;
};

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    if (_useRadiusMode) then {"Add Hackable Doors - Radius Mode"} else {format ["Add Hackable Doors - %1", getText (configOf _targetObject >> "displayName")]},
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

        // Extract availability setting
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

        // If available to future laptops, keep the selected computers but mark for future availability
        // If not available to future laptops and no computers selected, use all current computers
        if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
            _selectedComputers = _allComputers apply { _x select 0 };
        };

        // Handle radius mode or direct mode
        if (_useRadiusMode) then {
            // Radius mode: Use captured position (logic is already deleted)
            [_logicPosition, _radius, _execUserId, _selectedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation, _requestedId, _rangeEndId] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
        } else {
            // Direct mode: Register single object
            [_targetObject, _execUserId, _selectedComputers, _availableToFutureLaptops, _makeUnbreachable, _allowLocation, _requestedId, _doorIdMap] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
            ["Hackable Doors Added!"] call zen_common_fnc_showMessage;
        };
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
