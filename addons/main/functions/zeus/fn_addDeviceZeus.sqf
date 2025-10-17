/*
 * Author: Root
 * Zeus module to add a hackable door/light
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addDeviceZeus;
 *
 * Public: No
 */

params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

if (isNull _targetObject) exitWith {
    deleteVehicle _logic;
    ["Place the module on an object!"] call zen_common_fnc_showMessage;
};

if !(hasInterface) exitWith {};

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

// Check if target is a building (for unbreachable option)
private _isBuilding = _targetObject isKindOf "House" || _targetObject isKindOf "Building";

private _dialogControls = [
    ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this device be available to laptops that are added later?"], false]
];

// Add unbreachable option only for buildings with doors
if (_isBuilding) then {
    _dialogControls pushBack ["TOOLBOX:YESNO", ["Make Unbreachable", "Prevent door breaching by ACE explosives, lockpicking, and other non-hacking methods"], false];
};

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    format ["Add Hackable Object - %1", getText (configOf _targetObject >> "displayName")], 
    _dialogControls,
    // Fix the dialog result handler section:
    {
        params ["_results", "_args"];
        _args params ["_targetObject", "_execUserId", "_allComputers", "_isBuilding"];

        // Extract results based on whether this is a building
        private _availableToFutureLaptops = _results select 0;
        private _makeUnbreachable = false;
        private _checkboxStartIndex = 1;

        if (_isBuilding) then {
            _makeUnbreachable = _results select 1;
            _checkboxStartIndex = 2;
        };

        // Process laptop checkboxes
        private _selectedComputers = [];
        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // If available to future laptops, keep the selected computers but mark for future availability
        // If not available to future laptops and no computers selected, use all current computers
        if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
            _selectedComputers = _allComputers apply { _x select 0 };
        };

        // Call addDeviceZeusMain with unbreachable parameter
        [_targetObject, _execUserId, _selectedComputers, false, "", "", "", _availableToFutureLaptops, _makeUnbreachable] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
        ["Hackable Object Added!"] call zen_common_fnc_showMessage;
    }, 
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_targetObject, _execUserId, _allComputers, _isBuilding]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
