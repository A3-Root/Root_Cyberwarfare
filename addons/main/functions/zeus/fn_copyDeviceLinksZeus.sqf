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

        // Check if computer has ANY device links by checking all device types (1-8, including power grids)
        private _hasDeviceLinks = false;
        for "_deviceType" from 1 to 8 do {
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
// Check if target has any device links across all device types (including power grids)
private _targetHasLinks = false;
for "_deviceType" from 1 to 8 do {
    if (count ([_targetObject, _deviceType] call FUNC(getAccessibleDevices)) > 0) exitWith {
        _targetHasLinks = true;
    };
};

if (!isNull _targetObject && _targetHasLinks) exitWith {
    deleteVehicle _logic;

    // Source laptop detected (has links) - show dropdown to select target
    private _sourceNetId = netId _targetObject;
    private _sourceName = _targetObject getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", getText (configOf _targetObject >> "displayName")];

    // Build dropdown for target selection (exclude source) and track hacking tools status
    private _targetDropdownOptions = [];
    private _targetDropdownValues = [];
    private _targetComputersData = []; // Store [netId, hasHackingTools] for each option
    {
        _x params ["_netId", "_displayText", "_hasTools", "", "_obj"];
        if (_netId != _sourceNetId) then {
            _targetDropdownOptions pushBack _displayText;
            _targetDropdownValues pushBack _netId;
            _targetComputersData pushBack [_netId, _hasTools];
        };
    } forEach _allComputers;

    if (_targetDropdownOptions isEqualTo []) exitWith {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_INVALID_TARGET"] call zen_common_fnc_showMessage;
    };

    // Build dialog fields
    private _dialogFields = [
        ["COMBO", ["Target Laptop", "Select the laptop to copy device links TO (will merge)"], [_targetDropdownValues, _targetDropdownOptions, 0]],
        ["EDIT", ["Hacking Tools Path", "Path for hacking tools (will be installed if target doesn't have them). Example: /rubberducky/tools"], ["/rubberducky/tools"]]
    ];

    [
        format ["Copy Device Links FROM %1", _sourceName],
        _dialogFields,
        {
            params ["_results", "_args"];
            _args params ["_sourceNetId", "_targetComputersData"];
            _results params ["_targetNetId", "_hackingToolsPath"];

            // Check if selected target has hacking tools
            private _targetData = _targetComputersData select {(_x select 0) == _targetNetId};
            private _targetHasTools = if (_targetData isNotEqualTo []) then {(_targetData select 0) select 1} else {false};

            private _execUserId = clientOwner;
            [_sourceNetId, _targetNetId, false, 0, "", _execUserId, true, false, [], !_targetHasTools, _hackingToolsPath] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;
        },
        {
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        },
        [_sourceNetId, _targetComputersData]
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
    private _targetHasTools = _targetObject getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false];

    // Build dropdown for source selection
    private _computerDropdownOptions = [];
    private _computerDropdownValues = [];
    {
        _computerDropdownOptions pushBack (_x select 1);
        _computerDropdownValues pushBack _forEachIndex;
    } forEach _computersWithLinks;

    // Build dialog fields
    private _dialogFields = [
        ["COMBO", ["Source Laptop", "Select the laptop to copy device links FROM"], [_computerDropdownValues, _computerDropdownOptions, 0]],
        ["TOOLBOX:YESNO", ["Replace Existing Links", "Replace all existing links on target (if any)"], false],
        ["COMBO", ["Target Name", "Keep current name, Use source laptop's name or Create new one"], [[0, 1, 2], ["Keep target's current name", "Use source laptop's name", "Specify new name"], 0]],
        ["EDIT", ["New Name (optional)", "New name to be used"], [ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME]]
    ];

    // Add hacking tools path field if target doesn't have tools
    if (!_targetHasTools) then {
        _dialogFields pushBack ["EDIT", ["Hacking Tools Path", "Path for hacking tools (will be installed on target laptop). Example: /rubberducky/tools"], ["/rubberducky/tools"]];
    };

    [
        format ["Copy Device Links TO %1", getText (configOf _targetObject >> "displayName")],
        _dialogFields,
        {
            params ["_results", "_args"];
            _args params ["_computersWithLinks", "_targetNetId", "_index", "_targetHasTools"];

            // Extract hacking tools path if present (field added only when target doesn't have tools)
            private _hackingToolsPath = "/rubberducky/tools";
            if (!_targetHasTools && count _results > 4) then {
                _results params ["_sourceIndex", "_removePreviousLinks", "_nameHandling", "_newName", "_hackingToolsPath"];
            } else {
                _results params ["_sourceIndex", "_removePreviousLinks", "_nameHandling", "_newName"];
            };

            private _sourceNetId = (_computersWithLinks select _sourceIndex) select 0;
            private _execUserId = clientOwner;

            [_sourceNetId, _targetNetId, _removePreviousLinks, _nameHandling, _newName, _execUserId, false, false, [], !_targetHasTools, _hackingToolsPath] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;
        },
        {
            [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        },
        [_computersWithLinks, _targetNetId, _index, _targetHasTools]
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

// Build dropdown for existing target selection and track hacking tools status
private _targetDropdownOptions = ["<Create New Laptop>"];
private _targetDropdownValues = [-1];
private _targetComputersData = []; // Store [index, hasHackingTools]
{
    _targetDropdownOptions pushBack (_x select 1);
    _targetDropdownValues pushBack _forEachIndex;
    _targetComputersData pushBack [_forEachIndex, _x select 2]; // index and hasHackingTools status
} forEach _allComputers;

// Build dialog fields - always include hacking tools path (needed for new laptops or existing ones without tools)
private _dialogFields = [
    ["COMBO", ["Source Laptop", "Select the laptop to copy device links FROM"], [_sourceDropdownValues, _sourceDropdownOptions, 0]],
    ["COMBO", ["Target", "Select existing laptop or create new one"], [_targetDropdownValues, _targetDropdownOptions, 0]],
    ["TOOLBOX:YESNO", ["Replace Existing Links", "Replace all existing links on target (if any)"], false],
    ["COMBO", ["Target Name", "Keep current name, Use source laptop's name or Create new one"], [[0, 1, 2], ["Keep target's current name", "Use source laptop's name", "Specify new name"], 0]],
    ["EDIT", ["New Name (optional)", "New name to be used if 'Specifiy New Name' or 'Create New' is selected in the fields above"], [ROOT_CYBERWARFARE_CUSTOM_LAPTOP_NAME]],
    ["EDIT", ["Hacking Tools Path", "Path for hacking tools (will be installed if creating new laptop or target doesn't have them). Example: /rubberducky/tools"], ["/rubberducky/tools"]]
];

[
    "Copy Device Links",
    _dialogFields,
    {
        params ["_results", "_args"];
        _args params ["_computersWithLinks", "_allComputers", "_logicPos", "_index", "_targetComputersData"];
        _results params ["_sourceIndex", "_targetIndex", "_removePreviousLinks", "_nameHandling", "_newName", "_hackingToolsPath"];

        private _sourceNetId = (_computersWithLinks select _sourceIndex) select 0;
        private _execUserId = clientOwner;

        // Check if creating new laptop
        if (_targetIndex == -1) then {
            // Create new laptop at module position (always needs hacking tools)
            [_sourceNetId, "", _removePreviousLinks, _nameHandling, _newName, _execUserId, false, true, _logicPos, true, _hackingToolsPath] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
        } else {
            // Use existing laptop
            private _targetNetId = (_allComputers select _targetIndex) select 0;

            // Validate source != target
            if (_sourceNetId == _targetNetId) exitWith {
                [localize "STR_ROOT_CYBERWARFARE_ZEUS_SAME_LAPTOP_ERROR"] call zen_common_fnc_showMessage;
            };

            // Check if target has hacking tools
            private _targetData = _targetComputersData select {(_x select 0) == _targetIndex};
            private _targetHasTools = if (_targetData isNotEqualTo []) then {(_targetData select 0) select 1} else {false};

            [_sourceNetId, _targetNetId, _removePreviousLinks, _nameHandling, _newName, _execUserId, false, false, [], !_targetHasTools, _hackingToolsPath] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
        };

        [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_SUCCESS"] call zen_common_fnc_showMessage;

    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_computersWithLinks, _allComputers, _logicPos, _index, _targetComputersData]
] call zen_dialog_fnc_create;
