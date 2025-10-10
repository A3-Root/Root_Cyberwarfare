params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], "_vehicleName", ["_allowFuel", false], ["_allowSpeed", false], ["_allowBrakes", false], ["_allowLights", false], ["_allowEngine", true], ["_allowAlarm", false], ["_availableToFutureLaptops", false], ["_powerCost", 2]];

if (_execUserId == 0) then {
    _execUserId = owner _targetObject;
};

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;
private _allLamps = _allDevices select 1;
private _allDrones = _allDevices select 2;
private _allDatabases = _allDevices select 3;
private _allCustom = _allDevices select 4;
private _allGpsTrackers = _allDevices select 5;
private _allVehicles = _allDevices select 6;

private _objectType = typeOf _targetObject;
private _netId = netId _targetObject;

private _existingDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];

private _displayName = getText (configOf _targetObject >> "displayName");

private _deviceId = 0;

private _typeofhackable = 7;

_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_ID", _deviceId, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_NAME", _vehicleName, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_FUEL", _allowFuel, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_SPEED", _allowSpeed, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_BRAKES", _allowBrakes, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_LIGHTS", _allowLights, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_ENGINE", _allowEngine, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_DOOR", _allowAlarm, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_AVAILABLE_FUTURE", _availableToFutureLaptops, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_VEHICLE_COST", _powerCost, true];

_deviceId = (round (random 8999)) + 1000;
if (_allVehicles isNotEqualTo []) then {
    while {true} do {
        _deviceId = (round (random 8999)) + 1000;
        private _vehicleIsNew = true;
        {
            if (_x select 0 == _deviceId) then {
                _vehicleIsNew = false;
            };
        } forEach _allVehicles;
        if (_vehicleIsNew) then { break };
    };
};

// Store with availability flag
_allVehicles pushBack [_deviceId, _netId, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost, _linkedComputers];

private _availabilityText = "";
private _availableHacks = "";

// Store device linking information (for selected computers)
if (_linkedComputers isNotEqualTo []) then {
    private _deviceLinks = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", []];
    
    {
        private _computerNetId = _x;
        private _existingLinks = _deviceLinks select {_x select 0 == _computerNetId};
        
        if (_existingLinks isEqualTo []) then {
            _deviceLinks pushBack [_computerNetId, [[_typeofhackable, _deviceId]]];
        } else {
            private _index = _deviceLinks find (_existingLinks select 0);
            private _devices = (_deviceLinks select _index) select 1;
            _devices pushBack [_typeofhackable, _deviceId];
            _deviceLinks set [_index, [_computerNetId, _devices]];
        };
    } forEach _linkedComputers;

    _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", _deviceLinks, true];
};

private _excludedNetIds = [];
/// Handle public device access
if ((_availableToFutureLaptops) || (_linkedComputers isEqualTo [])) then {
    private _publicDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []];

    if (_availableToFutureLaptops) then {
        if (_linkedComputers isNotEqualTo []) then {
            // Scenario 4: Available to future + some linked
            // Exclude current laptops that are NOT linked
            {
                if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                    private _netId = netId _x;
                    if !(_netId in _linkedComputers) then {
                        _excludedNetIds pushBack _netId;
                    };
                };
            } forEach (24 allObjects 1);
            
            _availabilityText = _availabilityText + format [" and all future computers"];
        } else {
            // Scenario 3: Available to future + no linked
            // Exclude ALL current laptops
            {
                if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
                    _excludedNetIds pushBack (netId _x);
                };
            } forEach (24 allObjects 1);
            _availabilityText = "Available to future computers only";
        };
    } else {
        // Scenario 1: Not available to future + no linked
        // No exclusions - all current laptops get access
        _availabilityText = format ["Available to all current computers"];
    };

    _publicDevices pushBack [_typeofhackable, _deviceId, _excludedNetIds];
    missionNamespace setVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", _publicDevices, true];
};

_existingDevices set [0, _allDoors];
_existingDevices set [1, _allLamps];
_existingDevices set [2, _allDrones];
_existingDevices set [3, _allDatabases];
_existingDevices set [4, _allCustom];
_existingDevices set [5, _allGpsTrackers];
_existingDevices set [6, _allVehicles];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _existingDevices, true];
_targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];

if (_allowFuel) then { _availableHacks = _availableHacks + "Battery, "};
if (_allowSpeed) then { _availableHacks = _availableHacks + "Speed, "};
if (_allowBrakes) then { _availableHacks = _availableHacks + "Brakes, "};
if (_allowLights) then { _availableHacks = _availableHacks + "Lights, "};
if (_allowEngine) then { _availableHacks = _availableHacks + "Engine, "};
if (_allowAlarm) then { _availableHacks = _availableHacks + "Doors, "};


if ((_availableHacks select [(count _availableHacks) - 2, 2]) isEqualTo ", ") then {
    _availableHacks = (_availableHacks select [0, (count _availableHacks) - 2]) + ".";
};

private _features = [
    ["Battery", _allowFuel],
    ["Speed", _allowSpeed],
    ["Brakes", _allowBrakes],
    ["Lights", _allowLights],
    ["Engine", _allowEngine],
    ["Alarm", _allowAlarm]
];
private _displayName = getText (configOf _targetObject >> "displayName");
private _enabledFeatures = _features select { _x select 1 };
private _enabledNames = _enabledFeatures apply { _x select 0 };
private _featureString = if (_enabledNames isNotEqualTo []) then {
    _enabledNames joinString ", "
};
if ((_featureString select [(count _featureString) - 2, 2]) isEqualTo "- ") then {
    _featureString = (_featureString select [0, (count _featureString) - 2]) + " ";
};

[format ["Root Cyber Warfare: Vehicle (%1) of type (%2) added (ID: %3) with hackable %4. %5.", _vehicleName, _displayName, _deviceId, _featureString, _availabilityText]] remoteExec ["systemChat", _execUserId];
