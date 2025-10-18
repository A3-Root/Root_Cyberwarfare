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

private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", 1];
ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME = format ["HackTool_%1", _index];

// Define valid laptop classnames
private _validLaptopClasses = [
    "Land_Laptop_03_black_F_AE3",
    "Land_Laptop_03_olive_F_AE3",
    "Land_Laptop_03_sand_F_AE3",
    "Land_USB_Dongle_01_F_AE3"
];

// Get all existing laptops/devices (filtered by classname)
private _allComputers = [];
{
    // Only include valid laptop classes
    if (typeOf _x in _validLaptopClasses) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        private _netId = netId _x;
        private _gridPos = mapGridPosition _x;
        private _hasHackingTools = _x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false];

        // Check if computer has ANY device links by checking all device types (1-7)
        private _hasDeviceLinks = false;
        for "_deviceType" from 1 to 7 do {
            if (count ([_x, _deviceType] call FUNC(getAccessibleDevices)) > 0) exitWith {
                _hasDeviceLinks = true;
            };
        };

        _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos], _hasHackingTools, _hasDeviceLinks, _x];
    };
} forEach (24 allObjects 1);

// Filter to only computers with device links (potential sources)
private _computersWithLinks = _allComputers select {_x select 3};

if (_computersWithLinks isEqualTo []) exitWith {
    deleteVehicle _logic;
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_DEVICE_LINKS"] call zen_common_fnc_showMessage;
};

// METHOD 1: Module placed ON laptop/device WITH existing device links
// Check if target has any device links across all device types
private _targetHasLinks = false;
for "_deviceType" from 1 to 7 do {
    if (count ([_targetObject, _deviceType] call FUNC(getAccessibleDevices)) > 0) exitWith {
        _targetHasLinks = true;
    };
};

if (!isNull _targetObject && _targetHasLinks) exitWith {
    deleteVehicle _logic;

    // Source laptop detected (has links) - show dropdown to select target
    private _sourceNetId = netId _targetObject;
    private _sourceName = _targetObject getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", getText (configOf _targetObject >> "displayName")];

    // Build dropdown for target selection (exclude source)
    private _targetDropdownOptions = [];
    private _targetDropdownValues = [];
    {
        _x params ["_netId", "_displayText", "", "", "_obj"];
        if (_netId != _sourceNetId) then {
            _targetDropdownOptions pushBack _displayText;
            _targetDropdownValues pushBack _netId;
        };
    } forEach _allComputers;

    if (_targetDropdownOptions isEqualTo []) exitWith {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_INVALID_TARGET"] call zen_common_fnc_showMessage;
    };

    [
        format ["Copy Device Links FROM %1", _sourceName],
        [
            ["COMBO", ["Target Laptop", "Select the laptop to copy device links TO (will merge)"], [_targetDropdownValues, _targetDropdownOptions, 0]]
        ],
        {
            params ["_results", "_args"];
            _args params ["_sourceNetId"];
            _results params ["_targetNetId"];

            private _execUserId = clientOwner;
            [_sourceNetId, _targetNetId, false, 0, "", _execUserId, true] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;
        },
        {
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        },
        [_sourceNetId]
    ] call zen_dialog_fnc_create;
};

// METHOD 2: Module placed ON laptop/device WITHOUT device links
if (!isNull _targetObject) exitWith {
    deleteVehicle _logic;

    // Validate target is a valid laptop class
    if !(typeOf _targetObject in _validLaptopClasses) exitWith {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_INVALID_TARGET"] call zen_common_fnc_showMessage;
    };

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
            ["COMBO", ["Target Name", "Keep current name, Use source laptop's name or Create new one"], [[0, 1, 2], ["Keep target's current name", "Use source laptop's name", "Specify new name"], 0]],
            ["EDIT", ["New Name (optional)", "New name to be used"], [ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME]]
        ],
        {
            params ["_results", "_args"];
            _args params ["_computersWithLinks", "_targetNetId", "_index"];
            _results params ["_sourceIndex", "_removePreviousLinks", "_nameHandling", "_newName"];

            private _sourceNetId = (_computersWithLinks select _sourceIndex) select 0;
            private _execUserId = clientOwner;

            [_sourceNetId, _targetNetId, _removePreviousLinks, _nameHandling, _newName, _execUserId, false] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;
            _index = _index + 1;
		    missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _index, true];
        },
        {
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        },
        [_computersWithLinks, _targetNetId, _index]
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
        ["COMBO", ["Target Name", "Keep current name, Use source laptop's name or Create new one"], [[0, 1, 2], ["Keep target's current name", "Use source laptop's name", "Specify new name"], 0]],
        ["EDIT", ["New Name (optional)", "New name to be used if 'Specifiy New Name' or 'Create New' is selected in the fields above"], [ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME]]
    ],
    {
        params ["_results", "_args"];
        _args params ["_computersWithLinks", "_allComputers", "_logicPos", "_index"];
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

        _index = _index + 1;
        missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _index, true];
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_computersWithLinks, _allComputers, _logicPos, _index]
] call zen_dialog_fnc_create;
