#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to copy device links from one laptop to another
 *
 * Arguments:
 * 0: _sourceNetId <STRING> - Network ID of source laptop
 * 1: _targetNetId <STRING> - Network ID of target laptop (empty string if creating new)
 * 2: _removePreviousLinks <BOOL> - Remove previous links from target
 * 3: _nameHandling <NUMBER> - Name handling mode (0=keep target name, 1=use source name, 2=use new name)
 * 4: _newName <STRING> - New name for target (if nameHandling == 2)
 * 5: _execUserId <NUMBER> - User ID for feedback
 * 6: _mergeMode <BOOL> - If true, always merge (never remove previous links)
 * 7: _createNew <BOOL> (Optional) - If true, create new laptop at position
 * 8: _createPos <ARRAY> (Optional) - Position to create new laptop [x,y,z]
 * 9: _installHackingTools <BOOL> (Optional) - If true, install hacking tools on target laptop (if not already installed)
 * 10: _hackingToolsPath <STRING> (Optional) - Path for hacking tools installation (default: /rubberducky/tools)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["123", "456", true, 1, "", 0, false, false, [], true, "/rubberducky/tools"] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
 *
 * Public: No
 */

params ["_sourceNetId", "_targetNetId", "_removePreviousLinks", "_nameHandling", "_newName", "_execUserId", ["_mergeMode", false], ["_createNew", false], ["_createPos", []], ["_installHackingTools", false], ["_hackingToolsPath", "/rubberducky/tools"]];

private _sourceLaptop = objectFromNetId _sourceNetId;

// Validate source
if (isNull _sourceLaptop) exitWith {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_SOURCE_LAPTOP_NOT_FOUND"] remoteExec ["systemChat", _execUserId];
    LOG_ERROR("Source laptop not found");
};

private _targetLaptop = objNull;

// Handle laptop creation
if (_createNew) then {
    // Create new laptop at specified position
    _targetLaptop = "Land_Laptop_03_black_F_AE3" createVehicle _createPos;
    _targetLaptop setPosATL _createPos;

    // Get source laptop name for default naming
    private _sourceName = _sourceLaptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", ""];
    private _laptopIndex = missionNamespace getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", 1];

    // Determine name for new laptop
    private _laptopName = "";
    if (_nameHandling == 1) then {
        // Use source name
        _laptopName = _sourceName + "_Copy";
    } else {
        if (_nameHandling == 2 && {_newName != ""}) then {
            // Use specified name
            _laptopName = _newName;
        } else {
            // Generate default name
            _laptopName = format ["HackTool_%1", _laptopIndex];
        };
    };

    // Install hacking tools on new laptop
    [_targetLaptop, _hackingToolsPath, _execUserId, _laptopName] call FUNC(addHackingToolsZeusMain);

    _laptopIndex = _laptopIndex + 1;
    missionNamespace setVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", _laptopIndex, true];

    _targetNetId = netId _targetLaptop;

    LOG_INFO_2("Created new laptop %1 at position %2",_laptopName,_createPos);
} else {
    // Use existing laptop
    _targetLaptop = objectFromNetId _targetNetId;

    if (isNull _targetLaptop) exitWith {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_TARGET_LAPTOP_NOT_FOUND"] remoteExec ["systemChat", _execUserId];
        LOG_ERROR("Target laptop not found");
    };
};

private _targetLaptopNetId = netId _targetLaptop;

// Install hacking tools if requested and not already installed
if (_installHackingTools && !_createNew) then {
    private _hasTools = _targetLaptop getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false];
    if (!_hasTools) then {
        private _targetName = _targetLaptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", ""];
        [_targetLaptop, _hackingToolsPath, _execUserId, _targetName] call FUNC(addHackingToolsZeusMain);
        LOG_INFO_1("Installed hacking tools on existing laptop %1",_targetName);
    };
};

// Override removePreviousLinks if in merge mode
if (_mergeMode) then {
    _removePreviousLinks = false;
};

// Get source laptop's device links from link cache
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

// Get source laptop's accessible devices (all types)
private _sourceLinks = _linkCache getOrDefault [_sourceNetId, []];
private _targetLinks = _linkCache getOrDefault [_targetLaptopNetId, []];

private _devicesModified = 0;

// Copy each device link from source to target
{
    _x params ["_deviceType", "_deviceId"];

    // Skip if target already has this device
    if !([_deviceType, _deviceId] in _targetLinks) then {
        // Check if device is in public devices (available to future)
        private _isPublic = _publicDevices findIf {
            _x params ["_type", "_id", "_excluded"];
            _type == _deviceType && _id == _deviceId
        } != -1;

        // Only copy if not a public device (those auto-link to new laptops)
        if !(_isPublic) then {
            _targetLinks pushBack [_deviceType, _deviceId];
            _devicesModified = _devicesModified + 1;

            // Broadcast device link event
            ["root_cyberwarfare_deviceLinked", [_targetLaptopNetId, _deviceType, _deviceId]] call CBA_fnc_serverEvent;
        };
    };
} forEach _sourceLinks;

// Remove previous links if requested and not in merge mode
if (_removePreviousLinks && !_mergeMode) then {
    private _linksToRemove = [];
    {
        _x params ["_deviceType", "_deviceId"];

        // Remove if not in source links
        if !([_deviceType, _deviceId] in _sourceLinks) then {
            _linksToRemove pushBack _x;

            // Broadcast device unlink event
            ["root_cyberwarfare_deviceUnlinked", [_targetLaptopNetId, _deviceType, _deviceId]] call CBA_fnc_serverEvent;
        };
    } forEach _targetLinks;

    // Remove links
    {
        _targetLinks deleteAt (_targetLinks find _x);
    } forEach _linksToRemove;
};

// Update link cache
_linkCache set [_targetLaptopNetId, _targetLinks];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];

// Handle name change (skip if newly created laptop)
if (!_createNew) then {
    private _sourceName = _sourceLaptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", ""];

    if (_nameHandling == 1) then {
        // Use source name
        _targetLaptop setVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _sourceName, true];
    } else {
        if (_nameHandling == 2 && {_newName != ""}) then {
            // Use new name
            _targetLaptop setVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _newName, true];
        };
        // else: keep target's current name (nameHandling == 0)
    };
};

// Log and feedback
private _sourceName = _sourceLaptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", "Source"];
private _targetName = _targetLaptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", "Target"];

LOG_INFO_2("Copied device links from %1 to %2",_sourceName,_targetName);
[format [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_COMPLETE", _devicesModified, _sourceName, _targetName]] remoteExec ["systemChat", _execUserId];
