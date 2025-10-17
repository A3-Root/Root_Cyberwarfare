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
 *
 * Return Value:
 * None
 *
 * Example:
 * ["123", "456", true, 1, "", 0, false] remoteExec ["Root_fnc_copyDeviceLinksZeusMain", 2];
 *
 * Public: No
 */

params ["_sourceNetId", "_targetNetId", "_removePreviousLinks", "_nameHandling", "_newName", "_execUserId", ["_mergeMode", false], ["_createNew", false], ["_createPos", []]];

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
            _laptopName = format ["HackingPlatform_%1", _laptopIndex];
        };
    };

    // Install hacking tools on new laptop
    [_targetLaptop, "/rubberducky/tools", _execUserId, _laptopName] call FUNC(addHackingToolsZeusMain);

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

// Override removePreviousLinks if in merge mode
if (_mergeMode) then {
    _removePreviousLinks = false;
};

// Get all device arrays
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;
private _allLights = _allDevices select 1;
private _allDrones = _allDevices select 2;
private _allCustom = _allDevices select 4;
private _allGPSTrackers = _allDevices select 5;
private _allVehicles = _allDevices select 6;
private _allPowerGrids = _allDevices select 7;

private _devicesModified = 0;

// Helper function to process device links
private _fnc_updateDeviceLinks = {
    params ["_deviceArray", "_deviceIndex"];

    {
        private _device = _x;
        private _linkedComputers = _device select _deviceIndex;
        private _availableToFuture = _device select (_deviceIndex + 1);

        // Skip devices available to future laptops (they auto-link)
        if (_availableToFuture) then { continue };

        // Check if source laptop has access
        if (_sourceNetId in _linkedComputers) then {
            // Add target laptop if not already present
            if !(_targetLaptopNetId in _linkedComputers) then {
                _linkedComputers pushBack _targetLaptopNetId;
                _devicesModified = _devicesModified + 1;
            };
        } else {
            // Source doesn't have access - remove target if removing previous links
            if (_removePreviousLinks && {_targetLaptopNetId in _linkedComputers}) then {
                _linkedComputers deleteAt (_linkedComputers find _targetLaptopNetId);
            };
        };

        // Update device entry
        _device set [_deviceIndex, _linkedComputers];
    } forEach _deviceArray;
};

// Process each device type
// Doors: [_deviceId, _netId, _buildingName, _doorNumbers, _availableToFutureLaptops, _powerCost, _linkedComputers]
[_allDoors, 6] call _fnc_updateDeviceLinks;

// Lights: [_deviceId, _netId, _lightName, _availableToFutureLaptops, _powerCost, _linkedComputers]
[_allLights, 5] call _fnc_updateDeviceLinks;

// Drones: [_deviceId, _netId, _droneName, _availableToFutureLaptops, _powerCost, _linkedComputers]
[_allDrones, 5] call _fnc_updateDeviceLinks;

// Custom: [_deviceId, _netId, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops, _linkedComputers]
[_allCustom, 6] call _fnc_updateDeviceLinks;

// GPS Trackers: [_deviceId, _netId, _trackerName, _availableToFutureLaptops, _powerCost, _linkedComputers]
[_allGPSTrackers, 5] call _fnc_updateDeviceLinks;

// Vehicles: [_deviceId, _netId, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost, _linkedComputers]
[_allVehicles, 11] call _fnc_updateDeviceLinks;

// PowerGrids: [_deviceId, _netId, _gridName, _radius, _allowExplosionActivate, _allowExplosionDeactivate, _explosionType, _excludedClassnames, _availableToFutureLaptops, _powerCost, _linkedComputers]
[_allPowerGrids, 10] call _fnc_updateDeviceLinks;

// Update global device storage
_allDevices set [0, _allDoors];
_allDevices set [1, _allLights];
_allDevices set [2, _allDrones];
_allDevices set [4, _allCustom];
_allDevices set [5, _allGPSTrackers];
_allDevices set [6, _allVehicles];
_allDevices set [7, _allPowerGrids];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];

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

// Trigger device link cache update for target laptop
[_targetLaptop] call FUNC(cacheDeviceLinks);

// Log and feedback
private _sourceName = _sourceLaptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", "Source"];
private _targetName = _targetLaptop getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", "Target"];

LOG_INFO_2("Copied device links from %1 to %2",_sourceName,_targetName);
[format [localize "STR_ROOT_CYBERWARFARE_ZEUS_COPY_LINKS_COMPLETE", _devicesModified, _sourceName, _targetName]] remoteExec ["systemChat", _execUserId];
