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

    // Find the closest compatible object (building only)
    {
        if (_x != _logic && !(_x isKindOf "Logic")) then {
            // Only accept buildings
            private _isBuilding = ((_x isKindOf "House") || (_x isKindOf "Building"));

            if (_isBuilding) exitWith {
                _targetObject = _x;
            };
        };
    } forEach _nearObjects;
};

private _useRadiusMode = isNull _targetObject;

if !(hasInterface) exitWith {};

// In direct mode, validate that the target object is compatible (building only)
if (!_useRadiusMode) then {
    private _isBuilding = ((_targetObject isKindOf "House") || (_targetObject isKindOf "Building"));

    if !(_isBuilding) exitWith {
        deleteVehicle _logic;
        ["Object is not a building!"] call zen_common_fnc_showMessage;
    };
};

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
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

// Add unbreachable option for buildings (always available in this module)
if (!_useRadiusMode) then {
    _dialogControls pushBack ["TOOLBOX:YESNO", ["Make Unbreachable", "Prevent door breaching by ACE explosives, lockpicking, and other non-hacking methods"], false];
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
        _args params ["_logicPosition", "_targetObject", "_execUserId", "_allComputers", "_useRadiusMode"];

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

        // Extract unbreachable setting (for direct mode)
        if (!_useRadiusMode) then {
            _makeUnbreachable = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
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
            [_logicPosition, _radius, _execUserId, _selectedComputers, _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
        } else {
            // Direct mode: Register single object
            [_targetObject, _execUserId, _selectedComputers, _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDoorsZeusMain", 2];
            ["Hackable Doors Added!"] call zen_common_fnc_showMessage;
        };
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_logicPosition, _targetObject, _execUserId, _allComputers, _useRadiusMode]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
