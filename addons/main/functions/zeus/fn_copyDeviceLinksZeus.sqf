#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Zeus module to copy device links with three different modes:
 *              1. Place on laptop WITH links -> Point to target laptop (merges links)
 *              2. Place on laptop WITHOUT links -> Select source from dropdown
 *              3. Place on ground -> Full menu (copy to existing or create new)
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_copyDeviceLinksZeus;
 *
 * Public: No
 */

params ["_logic"];
private _targetObject = attachedTo _logic;
private _logicPos = getPosATL _logic;

if !(hasInterface) exitWith {};

// Get all existing laptops/devices
private _allComputers = [];
{
    private _displayName = getText (configOf _x >> "displayName");
    private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
    private _netId = netId _x;
    private _gridPos = mapGridPosition _x;
    private _hasHackingTools = _x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false];
    private _hasDeviceLinks = [_x] call FUNC(getAccessibleDevices) select {count _x > 0} isNotEqualTo [];

    _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos], _hasHackingTools, _hasDeviceLinks, _x];
} forEach (24 allObjects 1);

// Filter to only computers with device links (potential sources)
private _computersWithLinks = _allComputers select {_x select 3};

if (_computersWithLinks isEqualTo []) exitWith {
    deleteVehicle _logic;
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_DEVICE_LINKS"] call zen_common_fnc_showMessage;
};

// METHOD 1: Module placed ON laptop/device WITH existing device links
if (!isNull _targetObject && {[_targetObject] call FUNC(getAccessibleDevices) select {count _x > 0} isNotEqualTo []}) exitWith {
    deleteVehicle _logic;

    // Source laptop detected (has links)
    private _sourceNetId = netId _targetObject;
    private _sourceName = _targetObject getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", getText (configOf _targetObject >> "displayName")];

    [localize "STR_ROOT_CYBERWARFARE_ZEUS_POINT_TO_TARGET"] call zen_common_fnc_showMessage;

    // Wait for curator to point at target
    [
        {
            params ["_sourceNetId", "_sourceName"];

            private _target = cursorObject;

            // Validate target
            if (isNull _target) exitWith {
                [localize "STR_ROOT_CYBERWARFARE_ZEUS_INVALID_TARGET"] call zen_common_fnc_showMessage;
                false
            };

            private _targetNetId = netId _target;

            // Check not same object
            if (_sourceNetId == _targetNetId) exitWith {
                [localize "STR_ROOT_CYBERWARFARE_ZEUS_SAME_LAPTOP_ERROR"] call zen_common_fnc_showMessage;
                false
            };

            // Execute copy with merge mode (removePreviousLinks = false)
            private _execUserId = clientOwner;
            [_sourceNetId, _targetNetId, false, 0, "", _execUserId, true] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;

            true
        },
        [_sourceNetId, _sourceName]
    ] call zen_common_fnc_registerObjects;
};

// METHOD 2: Module placed ON laptop/device WITHOUT device links
if (!isNull _targetObject) exitWith {
    deleteVehicle _logic;

    private _targetNetId = netId _targetObject;

    // Build dropdown for source selection
    private _computerDropdownOptions = [];
    private _computerDropdownValues = [];
    {
        _computerDropdownOptions pushBack (_x select 1);
        _computerDropdownValues pushBack _forEachIndex;
    } forEach _computersWithLinks;

    [
        format ["Copy Device Links TO %1", getText (configOf _targetObject >> "displayName")],
        [
            ["COMBO", ["Source Laptop", "Select the laptop to copy device links FROM"], [_computerDropdownValues, _computerDropdownOptions, 0]],
            ["TOOLBOX:YESNO", ["Replace Existing Links", "Replace all existing links on target (if any)"], false],
            ["TOOLBOX", ["Name Handling", ["Keep target's current name", "Use source laptop's name", "Specify new name"]], 0],
            ["EDIT", ["New Name (if 'Specify new name' selected)", "New name for the target laptop"], [""]]
        ],
        {
            params ["_results", "_args"];
            _args params ["_computersWithLinks", "_targetNetId"];
            _results params ["_sourceIndex", "_removePreviousLinks", "_nameHandling", "_newName"];

            private _sourceNetId = (_computersWithLinks select _sourceIndex) select 0;
            private _execUserId = clientOwner;

            [_sourceNetId, _targetNetId, _removePreviousLinks, _nameHandling, _newName, _execUserId, false] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;
        },
        {
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        },
        [_computersWithLinks, _targetNetId]
    ] call zen_dialog_fnc_create;
};

// METHOD 3: Module placed on GROUND - Full menu
deleteVehicle _logic;

// Build dropdown for source selection
private _sourceDropdownOptions = [];
private _sourceDropdownValues = [];
{
    _sourceDropdownOptions pushBack (_x select 1);
    _sourceDropdownValues pushBack _forEachIndex;
} forEach _computersWithLinks;

// Build dropdown for existing target selection
private _targetDropdownOptions = ["<Create New Laptop>"];
private _targetDropdownValues = [-1];
{
    _targetDropdownOptions pushBack (_x select 1);
    _targetDropdownValues pushBack _forEachIndex;
} forEach _allComputers;

[
    "Copy Device Links",
    [
        ["COMBO", ["Source Laptop", "Select the laptop to copy device links FROM"], [_sourceDropdownValues, _sourceDropdownOptions, 0]],
        ["COMBO", ["Target", "Select existing laptop or create new one"], [_targetDropdownValues, _targetDropdownOptions, 0]],
        ["TOOLBOX:YESNO", ["Replace Existing Links", "Replace all existing links on target (if any)"], false],
        ["TOOLBOX", ["Name Handling", ["Keep target's current name", "Use source laptop's name", "Specify new name"]], 0],
        ["EDIT", ["New Name (if 'Specify new name' or 'Create New' selected)", "New name for the target laptop"], [""]]
    ],
    {
        params ["_results", "_args"];
        _args params ["_computersWithLinks", "_allComputers", "_logicPos"];
        _results params ["_sourceIndex", "_targetIndex", "_removePreviousLinks", "_nameHandling", "_newName"];

        private _sourceNetId = (_computersWithLinks select _sourceIndex) select 0;
        private _execUserId = clientOwner;

        // Check if creating new laptop
        if (_targetIndex == -1) then {
            // Create new laptop at module position
            [_sourceNetId, "", _removePreviousLinks, _nameHandling, _newName, _execUserId, false, true, _logicPos] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
        } else {
            // Use existing laptop
            private _targetNetId = (_allComputers select _targetIndex) select 0;

            // Validate source != target
            if (_sourceNetId == _targetNetId) exitWith {
                [localize "STR_ROOT_CYBERWARFARE_ZEUS_SAME_LAPTOP_ERROR"] call zen_common_fnc_showMessage;
            };

            [_sourceNetId, _targetNetId, _removePreviousLinks, _nameHandling, _newName, _execUserId, false] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
        };

        [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_computersWithLinks, _allComputers, _logicPos]
] call zen_dialog_fnc_create;
