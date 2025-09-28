// Root_fnc_IsDeviceAccessible
// Checks if a computer can access a specific device with optional backdoor bypass
// Parameters: [_computer, _deviceType, _deviceId, _commandPath]
// Returns: Boolean

params ["_computer", "_deviceType", "_deviceId", ["_commandPath", ""]];

if (isNull _computer) exitWith { false };

// Check if this command is running from a backdoor path
private _backdoorPaths = _computer getVariable ["ROOT_BackdoorFunction", []];
private _isBackdoorAccess = false;

{
    if (_commandPath find _x == 0) then { // Check if function executed is the BACKDOOR Function
        _isBackdoorAccess = true;
        break;
    };
} forEach _backdoorPaths;

// If this is a backdoor path, grant access to all devices
if (_isBackdoorAccess) exitWith { true };

// Normal access check (existing logic)
if !(_computer getVariable ["ROOT_HackingTools", false]) exitWith { false };

// Check if this device is in the public list
private _publicDevices = missionNamespace getVariable ["ROOT-Public-Devices", []];

// Find the public entry index for this device (if any)
private _publicEntryIndex = _publicDevices findIf { (_x select 0) == _deviceType && ((_x select 1) == _deviceId) };

if (_publicEntryIndex != -1) then {
    private _entry = _publicDevices select _publicEntryIndex;
    private _excludedNetIds = if ((count _entry) > 2) then { _entry select 2 } else { [] };
    private _computerNetId = netId _computer;

    // If there's no exclusion list -> fully public
    if (count _excludedNetIds == 0) exitWith { true };

    // If exclusion list exists, allow only if this computer's netId is NOT listed
    if ((_excludedNetIds find _computerNetId) == -1) exitWith { true };
};



private _computerNetId = netId _computer;
private _deviceLinks = missionNamespace getVariable ["ROOT-Device-Links", []];

// If no devices are linked to any computers, no access to private devices
if (count _deviceLinks == 0) exitWith { false };

// Find this computer's allowed devices
private _computerLinks = _deviceLinks select { _x select 0 == _computerNetId };

// If computer has no specific links, it can't access any restricted devices
if (count _computerLinks == 0) exitWith { false };

// Check if this device is in the allowed list
private _allowedDevices = (_computerLinks select 0) select 1;
private _isAllowed = (_allowedDevices findIf { _x select 0 == _deviceType && {_x select 1 == _deviceId} }) != -1;

_isAllowed