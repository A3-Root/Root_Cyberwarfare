// Root_fnc_isDeviceAccessible
// Checks if a computer can access a specific device with optional backdoor bypass
// Parameters: [_computer, _deviceType, _deviceId, _commandPath]
// Returns: Boolean

params ["_computer", "_deviceType", "_deviceId", ["_commandPath", ""]];

if (isNull _computer) exitWith { false };

// Check if this command is running from a backdoor path
private _backdoorPaths = _computer getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", []];
private _isBackdoorAccess = false;

{
    if (_commandPath find _x == 0) then {
        _isBackdoorAccess = true;
        break;
    };
} forEach _backdoorPaths;

// If this is a backdoor path, grant access to all devices
if (_isBackdoorAccess) exitWith { true };

if !(_computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) exitWith { false };

// Check if this device is in the public list FIRST
private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

// Find the public entry for this device (if any)
private _publicEntries = _publicDevices select { (_x select 0) == _deviceType && ((_x select 1) == _deviceId) };

private _publicStatus = false;

if (_publicEntries isNotEqualTo []) then {
    private _entry = _publicEntries select 0;
    private _excludedNetIds = if ((count _entry) > 2) then { _entry select 2 } else { [] };
    private _computerNetId = netId _computer;

    // If there's no exclusion list -> fully public
    if (_excludedNetIds isEqualTo []) exitWith {
        _publicStatus = true;
        true
    };

    // If exclusion list exists, allow only if this computer's netId is NOT listed
    if !(_computerNetId in _excludedNetIds) exitWith {
        _publicStatus = true;
        true
    };
};

if (_publicStatus) exitWith { true };
// ONLY if public access is not granted, check private device links
private _computerNetId = netId _computer;
private _deviceLinks = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", []];

// If no devices are linked to any computers, no access to private devices
if (_deviceLinks isEqualTo []) exitWith { false };

// Find this computer's allowed devices
private _computerLinks = _deviceLinks select { _x select 0 == _computerNetId };

// If computer has no specific links, it can't access any restricted devices
if (_computerLinks isEqualTo []) exitWith { false };

// Check if this device is in the allowed list
private _allowedDevices = (_computerLinks select 0) select 1;
private _isAllowed = (_allowedDevices findIf { _x select 0 == _deviceType && {_x select 1 == _deviceId} }) != -1;

_isAllowed
