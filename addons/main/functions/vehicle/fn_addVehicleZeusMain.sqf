#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to add a hackable vehicle or drone to the network.
 * Automatically detects drones (UAVs) vs vehicles and applies appropriate registration.
 * Supports radius mode to register multiple vehicles/drones at once.
 *
 * Arguments:
 * For Radius Mode (when called with 5 parameters starting with position array):
 * 0: _centerPos <ARRAY> - Center position [x, y, z]
 * 1: _radius <NUMBER> - Search radius in meters
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 4: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * For Drones (when called with 4 parameters or when unitIsUAV):
 * 0: _targetObject <OBJECT> - The drone to make hackable
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 *
 * For Vehicles (when called with 12 parameters):
 * 0: _targetObject <OBJECT> - The vehicle to make hackable
 * 1: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 2: _linkedComputers <ARRAY> (Optional) - Array of computer netIds, default: []
 * 3: _vehicleName <STRING> - Vehicle display name
 * 4: _allowFuel <BOOLEAN> (Optional) - Allow fuel/battery control, default: false
 * 5: _allowSpeed <BOOLEAN> (Optional) - Allow speed control, default: false
 * 6: _allowBrakes <BOOLEAN> (Optional) - Allow brakes control, default: false
 * 7: _allowLights <BOOLEAN> (Optional) - Allow lights control, default: false
 * 8: _allowEngine <BOOLEAN> (Optional) - Allow engine control, default: true
 * 9: _allowAlarm <BOOLEAN> (Optional) - Allow alarm control, default: false
 * 10: _availableToFutureLaptops <BOOLEAN> (Optional) - Available to future laptops, default: false
 * 11: _powerCost <NUMBER> (Optional) - Power cost per action, default: 2
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, 0, [], "Car1", true, true, false, false, true, false, false, 2] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
 * [_drone, 0, [], false] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
 * [[0, 0, 0], 1000, 0, [], false] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
 *
 * Public: No
 */

// Detect call type:
// - Radius mode: 5 params starting with position array
// - Drone call: 4 params or less
// - Vehicle call: 12 params
private _isRadiusMode = (count _this) == 5 && {(_this select 0) isEqualType []};
private _isDroneCall = !_isRadiusMode && {(count _this) <= 4};

if (_isRadiusMode) then {
    // Radius mode: Register all vehicles/drones within radius
    params ["_centerPos", "_radius", ["_execUserId", 0], ["_linkedComputers", []], ["_availableToFutureLaptops", false]];

    // Get all objects in radius and filter by vehicle type
    private _allObjects = nearestObjects [_centerPos, [], _radius];
    private _foundObjects = [];
    private _compatibleVehicles = ["Car", "Motorcycle", "Tank", "Helicopter", "Plane", "Ship"];

    // Filter to only include compatible vehicles
    {
        private _obj = _x;
        private _isCompatible = false;
        {
            if (_obj isKindOf _x) exitWith {
                _isCompatible = true;
            };
        } forEach _compatibleVehicles;

        if (_isCompatible) then {
            _foundObjects pushBack _obj;
        };
    } forEach _allObjects;

    private _vehicleCount = 0;
    private _droneCount = 0;
    private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_VEHICLE_INDEX", 1];

    {
        private _obj = _x;
        private _isDrone = unitIsUAV _obj;

        if (_isDrone) then {
            // Register as drone
            [_obj, _execUserId, _linkedComputers, _availableToFutureLaptops] call FUNC(addVehicleZeusMain);
            _droneCount = _droneCount + 1;
        } else {
            // Register as vehicle with default settings
            private _vehicleName = format ["Vehicle_%1", _index];
            private _defaultPowerCost = 2;
            private _allowAllFeatures = true;

            [_obj, _execUserId, _linkedComputers, _vehicleName, _allowAllFeatures, _allowAllFeatures, _allowAllFeatures, _allowAllFeatures, _allowAllFeatures, _allowAllFeatures, _availableToFutureLaptops, _defaultPowerCost] call FUNC(addVehicleZeusMain);
            _vehicleCount = _vehicleCount + 1;
            _index = _index + 1;
        };
    } forEach _foundObjects;

    missionNamespace setVariable ["ROOT_CYBERWARFARE_VEHICLE_INDEX", _index, true];

    private _totalCount = _vehicleCount + _droneCount;
    [format ["Root Cyber Warfare: Radius Mode - Added %1 vehicles and %2 drones (Total: %3 objects)", _vehicleCount, _droneCount, _totalCount]] remoteExec ["systemChat", _execUserId];

} else {
    if (_isDroneCall) then {
        // Drone: handle drone registration directly
        params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], ["_availableToFutureLaptops", false]];

        if (_execUserId == 0) then {
            _execUserId = owner _targetObject;
        };

        // Load device arrays from global storage
        private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
        private _allDrones = _allDevices select 2;

        private _netId = netId _targetObject;
        private _displayName = getText (configOf _targetObject >> "displayName");
        private _typeofhackable = 3; // Drone device type

        // Generate unique device ID
        private _deviceId = (round (random 8999)) + 1000;
        if (_allDrones isNotEqualTo []) then {
            while {true} do {
                _deviceId = (round (random 8999)) + 1000;
                private _droneIsNew = true;
                {
                    if (_x select 0 == _deviceId) then {
                        _droneIsNew = false;
                    };
                } forEach _allDrones;

                if (_droneIsNew) then {
                    break;
                };
            };
        };

        // Store drone entry: [deviceId, droneNetId, droneName, availableToFuture]
        _allDrones pushBack [_deviceId, _netId, _displayName, _availableToFutureLaptops];

        private _availabilityText = "";

        // Store device linking information (for selected computers)
        if (_linkedComputers isNotEqualTo []) then {
            // Update new hashmap-based link cache
            private _linkCache = GET_LINK_CACHE;

            {
                private _computerNetId = _x;
                private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
                _existingLinks pushBack [_typeofhackable, _deviceId];
                _linkCache set [_computerNetId, _existingLinks];
            } forEach _linkedComputers;

            missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];
            _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
        };

        private _excludedNetIds = [];
        // Handle public device access
        if (_availableToFutureLaptops || _linkedComputers isEqualTo []) then {
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

        // Update global storage with modified drone array
        _allDevices set [2, _allDrones];
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
        _targetObject setVariable ["ROOT_CYBERWARFARE_CONNECTED", true, true];

        [format ["Root Cyber Warfare: Drone (%2) Added! ID: %1. %3.", _deviceId, _displayName, _availabilityText]] remoteExec ["systemChat", _execUserId];

    } else {
        // Vehicle: continue with normal vehicle registration
        params ["_targetObject", ["_execUserId", 0], ["_linkedComputers", []], "_vehicleName", ["_allowFuel", false], ["_allowSpeed", false], ["_allowBrakes", false], ["_allowLights", false], ["_allowEngine", true], ["_allowAlarm", false], ["_availableToFutureLaptops", false], ["_powerCost", 2]];

        if (_execUserId == 0) then {
            _execUserId = owner _targetObject;
        };

        // Load device arrays from global storage
        private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
        private _allVehicles = _allDevices select 6;

        private _netId = netId _targetObject;

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
            // Update new hashmap-based link cache
            private _linkCache = GET_LINK_CACHE;

            {
                private _computerNetId = _x;
                private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
                _existingLinks pushBack [_typeofhackable, _deviceId];
                _linkCache set [_computerNetId, _existingLinks];
            } forEach _linkedComputers;

            missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];
            _availabilityText = format ["Accessible by %1 linked computer(s)", count _linkedComputers];
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

        // Update global storage with modified vehicle array
        _allDevices set [6, _allVehicles];
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];
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
        private _vehicleDisplayName = getText (configOf _targetObject >> "displayName");
        private _enabledFeatures = _features select { _x select 1 };
        private _enabledNames = _enabledFeatures apply { _x select 0 };
        private _featureString = if (_enabledNames isNotEqualTo []) then {
            _enabledNames joinString ", "
        };
        if ((_featureString select [(count _featureString) - 2, 2]) isEqualTo "- ") then {
            _featureString = (_featureString select [0, (count _featureString) - 2]) + " ";
        };

        [format ["Root Cyber Warfare: Vehicle (%1) of type (%2) added (ID: %3) with hackable %4. %5.", _vehicleName, _vehicleDisplayName, _deviceId, _featureString, _availabilityText]] remoteExec ["systemChat", _execUserId];
    };
};
