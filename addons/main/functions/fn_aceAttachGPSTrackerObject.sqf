params ["_target", "_player"];

// Check if player has a banana
private _itemClass = "ACE_Banana";
private _itemFound = false;
if (uniformItems _player find _itemClass >= 0) then {
    _player removeItemFromUniform _itemClass;
    _itemFound = true;
} else {
    if (vestItems _player find _itemClass >= 0) then {
        _player removeItemFromVest _itemClass;
        _itemFound = true;
    } else {
        if (backpackItems _player find _itemClass >= 0) then {
            _player removeItemFromBackpack _itemClass;
            _itemFound = true;
        } else {
            if (items _player find _itemClass >= 0) then {
                _player removeItem _itemClass;
                _itemFound = true;
            };
        };
    };
};

if !(_itemFound) exitWith {
    ["No compatible GPS Tracker device found!", 2] call ACE_common_fnc_displayTextStructured;
};

// Use existing GPS tracker functions with default parameters
private _index = missionNamespace getVariable ["ROOT_gpsTrackerIndex", 1];
private _trackerName = format ["GPS_Tracker_%1", _index];

// Get all existing laptops
private _allComputers = [];
{
    if (_x getVariable ["ROOT_HackingTools", false]) then {
        private _netId = netId _x;
        _allComputers pushBack _netId;
    };
} forEach (24 allObjects 1);

// Default parameters
private _trackingTime = 300; // 5 minutes
private _updateFrequency = 5;
private _lastPingTimer = 30;
private _powerCost = 2;
private _customMarker = "";
private _allowRetracking = true;
private _availableToFutureLaptops = true;

// Call the existing function
[_target, clientOwner, _allComputers, _trackerName, _trackingTime, _updateFrequency, _customMarker, _availableToFutureLaptops, _allowRetracking, _lastPingTimer, _powerCost] remoteExec ["Root_fnc_addGpsTrackerZeusMain", 2];

// Update index
missionNamespace setVariable ["ROOT_gpsTrackerIndex", _index + 1, true];

[format ["GPS Tracker attached successfully to %1!", getText (configOf _target >> "displayName")], 2] call ACE_common_fnc_displayTextStructured;
