#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Lists all accessible devices in the subnet for a computer
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _commandPath <STRING> - Command path for access checking
 * 4: _type <STRING> - Device type to list (doors, lights, etc.)
 * 5: _deviceId <STRING> (Optional) - Specific device ID to show details for, default: ""
 *
 * Return Value:
 * None
 *
 * Example:
 * [123, _laptop, "var1", "/tools/", "doors"] call Root_fnc_listDevicesInSubnet;
 * [123, _laptop, "var1", "/tools/", "doors", "1234"] call Root_fnc_listDevicesInSubnet;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_commandPath', '_type', ['_deviceId', '', ['']]];

private _string = "";
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _allDoors = _allDevices select 0;
private _allLights = _allDevices select 1;
private _allDrones = _allDevices select 2;
private _allDatabases = _allDevices select 3;
private _allCustom = _allDevices select 4;
private _allGpsTrackers = _allDevices select 5;
private _allVehicles = _allDevices select 6;
private _allPowerGrids = _allDevices select 7;

// Filter devices based on accessibility
private _accessibleDoors = _allDoors select { 
    [_computer, 1, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleLights = _allLights select { 
    [_computer, 2, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleDrones = _allDrones select { 
    [_computer, 3, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleDatabases = _allDatabases select { 
    [_computer, 4, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleCustom = _allCustom select { 
    [_computer, 5, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleGpsTrackers = _allGpsTrackers select { 
    private _deviceData = _x;
    private _deviceId = _deviceData select 0;
    [_computer, 6, _deviceId, _commandPath] call Root_fnc_isDeviceAccessible 
};

private _accessibleVehicles = _allVehicles select {
    [_computer, 7, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible
};

private _accessiblePowerGrids = _allPowerGrids select {
    [_computer, 8, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible
};

if (_type in ["doors", "all", "a"]) then {
    if (_accessibleDoors isNotEqualTo []) then {
        // Check if a specific building ID was provided
        if (_deviceId != "") then {
            // Detailed view for specific building
            private _buildingIdNum = parseNumber _deviceId;
            private _foundBuilding = false;

            {
                private _currentBuildingId = _x select 0;
                if (_currentBuildingId == _buildingIdNum) exitWith {
                    _foundBuilding = true;
                    private _building = objectFromNetId (_x select 1);
                    private _buildingDisplayName = getText (configOf _building >> "displayName");
                    private _mapGridPos = mapGridPosition _building;
                    private _doorsOfBuilding = _x select 2;
                    private _doorCount = count _doorsOfBuilding;

                    _string = format ["Building: %1 (%2) - %3 door(s) - Grid: %4", _currentBuildingId, _buildingDisplayName, _doorCount, _mapGridPos];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Doors:"];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                    {
                        private _currentState = _building getVariable [format ['bis_disabled_Door_%1', _x], 5];
                        private _currentStateString = "";
                        private _currentStateStringColor = "#8ce10b";
                        if(_currentState == 1) then {
                            _currentStateString = "locked ";
                            _currentStateStringColor = "#fa4c58";
                        } else {
                            _currentStateString = "unlocked ";
                        };

                        private _doorAnim = format ["Door_%1_rot", _x];
                        private _phase = _building animationPhase _doorAnim;

                        private _phaseString = "";
                        private _phaseStringColor = "#8ce10b";
                        if(_phase > 0.5) then {
                            _phaseString = "open";
                        } else {
                            _phaseString = "closed";
                            _phaseStringColor = "#fa4c58";
                        };

                        _string = format ["    Door %1 - Status: ", _x];
                        [_computer, [[_string, [_currentStateString, _currentStateStringColor], " / ", [_phaseString, _phaseStringColor]]]] call AE3_armaos_fnc_shell_stdout;
                    } forEach _doorsOfBuilding;
                };
            } forEach _accessibleDoors;

            if (!_foundBuilding) then {
                _string = format ["Building ID %1 not found or not accessible!", _deviceId];
                [_computer, [[[_string, "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
            };
        } else {
            // Summary view - show building count and IDs with aggregate lock status
            private _buildingCount = count _accessibleDoors;
            _string = format ["Buildings with doors: %1", _buildingCount];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;

            {
                private _buildingId = _x select 0;
                private _building = objectFromNetId (_x select 1);
                private _buildingDisplayName = getText (configOf _building >> "displayName");
                private _mapGridPos = mapGridPosition _building;
                private _doorsOfBuilding = _x select 2;

                // Calculate aggregate lock status
                private _lockedCount = 0;
                {
                    private _currentState = _building getVariable [format ['bis_disabled_Door_%1', _x], 5];
                    if (_currentState == 1) then {
                        _lockedCount = _lockedCount + 1;
                    };
                } forEach _doorsOfBuilding;

                // Determine status color based on lock state
                private _statusColor = "";
                if (_lockedCount == count _doorsOfBuilding) then {
                    _statusColor = "#fa4c58"; // RED - Locked
                } else {
                    if (_lockedCount == 0) then {
                        _statusColor = "#8ce10b"; // GREEN - Unlocked
                    } else {
                        _statusColor = "#FFD966"; // YELLOW - Partially Locked
                    };
                };

                _string = format ["    %1 - %2 - %3", _buildingId, _buildingDisplayName, _mapGridPos];
                [_computer, [[[_string, _statusColor]]]] call AE3_armaos_fnc_shell_stdout;
            } forEach _accessibleDoors;
        };
    };
};

if (_type in ["lights", "all", "a"]) then {
    if (_accessibleLights isNotEqualTo []) then {
        // Check if a specific light ID was provided
        if (_deviceId != "") then {
            // Detailed view for specific light
            private _lightIdNum = parseNumber _deviceId;
            private _foundLight = false;

            {
                private _currentLightId = _x select 0;
                if (_currentLightId == _lightIdNum) exitWith {
                    _foundLight = true;
                    private _light = objectFromNetId (_x select 1);
                    private _lightDisplayName = getText (configOf _light >> "displayName");
                    private _mapGridPos = mapGridPosition _light;
                    private _currentState = lightIsOn _light;
                    private _currentStateStringColor = "#8ce10b"; // GREEN for ON
                    if (_currentState isEqualTo "OFF") then {
                        _currentStateStringColor = "#fa4c58"; // RED for OFF
                    };

                    _string = format ["Light: %1 (%2) - Grid: %3", _currentLightId, _lightDisplayName, _mapGridPos];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Status: "];
                    [_computer, [[_string, [_currentState, _currentStateStringColor]]]] call AE3_armaos_fnc_shell_stdout;
                };
            } forEach _accessibleLights;

            if (!_foundLight) then {
                _string = format ["Light ID %1 not found or not accessible!", _deviceId];
                [_computer, [[[_string, "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
            };
        } else {
            // Summary view - show light count and IDs with status
            private _lightCount = count _accessibleLights;
            _string = format ["Lights: %1", _lightCount];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;

            {
                private _lightId = _x select 0;
                private _light = objectFromNetId (_x select 1);
                private _lightDisplayName = getText (configOf _light >> "displayName");
                private _mapGridPos = mapGridPosition _light;
                private _currentState = lightIsOn _light;
                private _currentStateStringColor = "#8ce10b"; // GREEN for ON
                if (_currentState isEqualTo "OFF") then {
                    _currentStateStringColor = "#fa4c58"; // RED for OFF
                };

                _string = format ["    %1 - %2 - %3", _lightId, _lightDisplayName, _mapGridPos];
                [_computer, [[[_string, _currentStateStringColor]]]] call AE3_armaos_fnc_shell_stdout;
            } forEach _accessibleLights;
        };
    };
};

if (_type in ["drones", "all", "a"]) then {
    if (_accessibleDrones isNotEqualTo []) then {
        // Check if a specific drone ID was provided
        if (_deviceId != "") then {
            // Detailed view for specific drone
            private _droneIdNum = parseNumber _deviceId;
            private _foundDrone = false;

            {
                private _currentDroneId = _x select 0;
                if (_currentDroneId == _droneIdNum) exitWith {
                    _foundDrone = true;
                    private _drone = objectFromNetId (_x select 1);
                    private _droneName = getText (configOf (vehicle _drone) >> "displayName");
                    private _mapGridPos = mapGridPosition _drone;
                    private _droneSide = side _drone;
                    private _droneSideString = str _droneSide;
                    private _damage = damage (vehicle _drone);
                    private _droneSideColor = "#8CE10B"; // Default green

                    if (_damage == 1) then {
                        _droneSideString = "DEAD";
                        _droneSideColor = "#8B0000"; // DARK RED
                    } else {
                        if (_droneSide == west) then {
                            _droneSideString = "BLUFOR";
                            _droneSideColor = "#008DF8"; // BLUE
                        };
                        if (_droneSide == east) then {
                            _droneSideString = "OPFOR";
                            _droneSideColor = "#FA4C58"; // RED
                        };
                        if (_droneSide == civilian) then {
                            _droneSideString = "CIVILIAN";
                            _droneSideColor = "#9B59B6"; // PURPLE
                        };
                        if (_droneSide == independent) then {
                            _droneSideString = "INDFOR";
                            _droneSideColor = "#8CE10B"; // GREEN
                        };
                    };

                    _string = format ["Drone: %1 (%2) - Grid: %3", _currentDroneId, _droneName, _mapGridPos];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Side: "];
                    [_computer, [[_string, [_droneSideString, _droneSideColor]]]] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Damage: %1%2", round (_damage * 100), "%"];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            } forEach _accessibleDrones;

            if (!_foundDrone) then {
                _string = format ["Drone ID %1 not found or not accessible!", _deviceId];
                [_computer, [[[_string, "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
            };
        } else {
            // Summary view - show drone count and IDs with side coloring
            private _droneCount = count _accessibleDrones;
            _string = format ["Drones: %1", _droneCount];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;

            {
                private _droneId = _x select 0;
                private _drone = objectFromNetId (_x select 1);
                private _droneName = getText (configOf (vehicle _drone) >> "displayName");
                private _mapGridPos = mapGridPosition _drone;
                private _droneSide = side _drone;
                private _damage = damage (vehicle _drone);
                private _droneSideColor = "#8CE10B"; // Default green

                if (_damage == 1) then {
                    _droneSideColor = "#8B0000"; // DARK RED for dead
                } else {
                    if (_droneSide == west) then {
                        _droneSideColor = "#008DF8"; // BLUE for BLUFOR
                    };
                    if (_droneSide == east) then {
                        _droneSideColor = "#FA4C58"; // RED for OPFOR
                    };
                    if (_droneSide == civilian) then {
                        _droneSideColor = "#9B59B6"; // PURPLE for civilian
                    };
                    if (_droneSide == independent) then {
                        _droneSideColor = "#8CE10B"; // GREEN for INDFOR
                    };
                };

                _string = format ["    %1 - %2 - %3", _droneId, _droneName, _mapGridPos];
                [_computer, [[[_string, _droneSideColor]]]] call AE3_armaos_fnc_shell_stdout;
            } forEach _accessibleDrones;
        };
    };
};

if (_type in ["files", "all", "a"]) then {
    if (_accessibleDatabases isNotEqualTo []) then {
        private _fileCount = count _accessibleDatabases;
        _string = format ["Files: %1", _fileCount];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        {
            private _databaseId = _x select 0;
            private _databaseName = _x select 2;
            private _databaseSize = _x select 3;
            _string = format ["    %1 - %2 - %3 seconds", _databaseId, _databaseName, _databaseSize];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        } forEach _accessibleDatabases;
    };
};

if (_type in ["custom", "all", "a"]) then {
    if (_accessibleCustom isNotEqualTo []) then {
        // If deviceId is provided, show detailed view for that device
        if (_deviceId != "") then {
            private _foundCustom = false;
            {
                _x params ["_customId", "_objectNetId", "_customName", "_activationCode", "_deactivationCode", "_availableToFuture"];

                if (str _customId == _deviceId) exitWith {
                    _foundCustom = true;
                    private _customObject = objectFromNetId _objectNetId;
                    private _mapGridPos = mapGridPosition _customObject;
                    private _displayName = getText (configOf _customObject >> "displayName");

                    // Header
                    _string = format ["%1 - %2 (%3) @ %4", _customId, _customName, _displayName, _mapGridPos];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                    // Status (if device has state tracking)
                    private _deviceState = _customObject getVariable ["ROOT_CYBERWARFARE_CUSTOM_DEVICE_STATE", ""];
                    if (_deviceState != "") then {
                        private _stateColor = ["#fa4c58", "#8ce10b"] select (_deviceState in ["ACTIVE", "ON"]);
                        _string = "    Status: ";
                        [_computer, [[_string, [_deviceState, _stateColor]]]] call AE3_armaos_fnc_shell_stdout;
                    };
                };
            } forEach _accessibleCustom;

            if (!_foundCustom) then {
                _string = format ["Custom Device ID %1 not found or not accessible.", _deviceId];
                [_computer, [[[_string, "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
            };
        } else {
            // Summary view - just show device count and basic info
            _string = format ["Custom Devices: %1", count _accessibleCustom];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            {
                _x params ["_customId", "_objectNetId", "_customName"];
                private _customObject = objectFromNetId _objectNetId;
                private _mapGridPos = mapGridPosition _customObject;

                // Get device state and determine color
                private _deviceState = _customObject getVariable ["ROOT_CYBERWARFARE_CUSTOM_DEVICE_STATE", "INACTIVE"];
                private _stateColor = "#FFD966"; // Default YELLOW for Inactive

                if (_deviceState in ["ACTIVE", "ON", "ACTIVATED", "ACTIVATE"]) then {
                    _stateColor = "#8ce10b"; // GREEN for Active
                };
                if (_deviceState in ["DESTROYED", "ERROR", "FAILED", "DEAD"]) then {
                    _stateColor = "#fa4c58"; // RED for Errors
                };

                _string = format ["    %1 - %2 - %3", _customId, _customName, _mapGridPos];
                [_computer, [[[_string, _stateColor]]]] call AE3_armaos_fnc_shell_stdout;
            } forEach _accessibleCustom;
        };
    };
};

if (_type in ["gps", "all", "a"]) then {
    if (_accessibleGpsTrackers isNotEqualTo []) then {
        // Check if a specific GPS tracker ID was provided
        if (_deviceId != "") then {
            // Detailed view for specific GPS tracker
            private _trackerIdNum = parseNumber _deviceId;
            private _foundTracker = false;

            {
                private _currentTrackerId = _x select 0;
                if (_currentTrackerId == _trackerIdNum) exitWith {
                    _foundTracker = true;
                    private _trackerName = _x select 2;
                    private _trackingTime = _x select 3;
                    private _updateFrequency = _x select 4;
                    private _status = (_x select 8) select 0;
                    private _powerCost = _x select 11;

                    private _statusColor = "#8ce10b"; // Green for Untracked
                    if (_status == "Tracking") then {
                        _statusColor = "#008DF8"; // Blue for Tracking
                    };
                    if (_status == "Completed") then {
                        _statusColor = "#FFD966"; // Yellow for Completed
                    };
                    if (_status in ["Dead", "Untrackable", "Disabled", "Failed"]) then {
                        _statusColor = "#fa4c58"; // Red for errors
                    };

                    _string = format ["GPS Tracker: %1 (ID: %2)", _trackerName, _currentTrackerId];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Status: "];
                    [_computer, [[_string, [_status, _statusColor]]]] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Track Time: %1s", _trackingTime];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Update Frequency: %1s", _updateFrequency];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["Power Cost: %1 Wh", _powerCost];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            } forEach _accessibleGpsTrackers;

            if (!_foundTracker) then {
                _string = format ["GPS Tracker ID %1 not found or not accessible!", _deviceId];
                [_computer, [[[_string, "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
            };
        } else {
            // Summary view - show tracker count and IDs with status
            private _trackerCount = count _accessibleGpsTrackers;
            _string = format ["GPS Trackers: %1", _trackerCount];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;

            {
                private _trackerId = _x select 0;
                private _trackerName = _x select 2;
                private _status = (_x select 8) select 0;

                private _statusColor = "#8ce10b"; // Green for Untracked
                if (_status == "Tracking") then {
                    _statusColor = "#008DF8"; // Blue for Tracking
                };
                if (_status == "Completed") then {
                    _statusColor = "#FFD966"; // Yellow for Completed
                };
                if (_status in ["Dead", "Untrackable", "Disabled", "Failed"]) then {
                    _statusColor = "#fa4c58"; // Red for errors
                };

                _string = format ["    %1 - %2", _trackerId, _trackerName];
                [_computer, [[[_string, _statusColor]]]] call AE3_armaos_fnc_shell_stdout;
            } forEach _accessibleGpsTrackers;
        };
    };
};

if (_type in ["vehicles", "all", "a"]) then {
    if (_accessibleVehicles isNotEqualTo []) then {
        // If deviceId is provided, show detailed view for that device
        if (_deviceId != "") then {
            private _foundVehicle = false;
            {
                _x params ["_vehicleId", "_netId", "_vehicleName", "_allowFuel", "_allowSpeed", "_allowBrakes", "_allowLights", "_allowEngine", "_allowAlarm", "_availableToFutureLaptops", "_powerCost", "_linkedComputers"];

                if (str _vehicleId == _deviceId) exitWith {
                    _foundVehicle = true;
                    private _vehicle = objectFromNetId _netId;
                    private _mapGridPos = mapGridPosition _vehicle;
                    private _displayName = getText (configOf _vehicle >> "displayName");

                    // Header
                    _string = format ["Vehicle %1 - %2 (%3) @ %4", _vehicleId, _vehicleName, _displayName, _mapGridPos];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                    // Hackable features in order: Lights - Engine - Battery - Speed - Brakes - Alarm
                    private _lightsColor = ["#fa4c58", "#8ce10b"] select _allowLights;
                    private _lightsStatus = ["Not Allowed", "Allowed"] select _allowLights;
                    _string = "    Lights: ";
                    [_computer, [[_string, [_lightsStatus, _lightsColor]]]] call AE3_armaos_fnc_shell_stdout;

                    private _engineColor = ["#fa4c58", "#8ce10b"] select _allowEngine;
                    private _engineStatus = ["Not Allowed", "Allowed"] select _allowEngine;
                    _string = "    Engine: ";
                    [_computer, [[_string, [_engineStatus, _engineColor]]]] call AE3_armaos_fnc_shell_stdout;

                    private _fuelColor = ["#fa4c58", "#8ce10b"] select _allowFuel;
                    private _fuelStatus = ["Not Allowed", "Allowed"] select _allowFuel;
                    _string = "    Battery: ";
                    [_computer, [[_string, [_fuelStatus, _fuelColor]]]] call AE3_armaos_fnc_shell_stdout;

                    private _speedColor = ["#fa4c58", "#8ce10b"] select _allowSpeed;
                    private _speedStatus = ["Not Allowed", "Allowed"] select _allowSpeed;
                    _string = "    Speed: ";
                    [_computer, [[_string, [_speedStatus, _speedColor]]]] call AE3_armaos_fnc_shell_stdout;

                    private _brakesColor = ["#fa4c58", "#8ce10b"] select _allowBrakes;
                    private _brakesStatus = ["Not Allowed", "Allowed"] select _allowBrakes;
                    _string = "    Brakes: ";
                    [_computer, [[_string, [_brakesStatus, _brakesColor]]]] call AE3_armaos_fnc_shell_stdout;

                    private _alarmColor = ["#fa4c58", "#8ce10b"] select _allowAlarm;
                    private _alarmStatus = ["Not Allowed", "Allowed"] select _allowAlarm;
                    _string = "    Alarm: ";
                    [_computer, [[_string, [_alarmStatus, _alarmColor]]]] call AE3_armaos_fnc_shell_stdout;

                    // Vehicle status information
                    private _fuelLevel = fuel _vehicle;
                    private _engineOn = isEngineOn _vehicle;
                    private _lightsOn = isLightOn _vehicle;

                    _string = format ["    Current Status:"];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["        Battery: %1%2", round (_fuelLevel * 100), "%"];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["        Engine: %1", ["OFF", "ON"] select _engineOn];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["        Lights: %1", ["OFF", "ON"] select _lightsOn];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                    _string = format ["        Speed: %1kmph", speed _vehicle];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                };
            } forEach _accessibleVehicles;

            if (!_foundVehicle) then {
                _string = format ["Vehicle ID %1 not found or not accessible.", _deviceId];
                [_computer, [[[_string, "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
            };
        } else {
            // Summary view - just show vehicle count and basic info
            _string = format ["Vehicles: %1", count _accessibleVehicles];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            {
                _x params ["_vehicleId", "_netId", "_vehicleName"];
                private _vehicle = objectFromNetId _netId;
                private _mapGridPos = mapGridPosition _vehicle;
                _string = format ["    %1 - %2 - %3", _vehicleId, _vehicleName, _mapGridPos];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            } forEach _accessibleVehicles;
        };
    };
};

if (_type in ["powergrids", "all", "a"]) then {
    if (_accessiblePowerGrids isNotEqualTo []) then {
        // If deviceId is provided, show detailed view for that device
        if (_deviceId != "") then {
            private _foundGrid = false;
            {
                _x params ["_gridId", "_objectNetId", "_gridName", "_radius", "_allowExplosionOverload", "_explosionType", "_excludedClassnames", "_availableToFutureLaptops", "_powerCost", "_linkedComputers"];

                if (str _gridId == _deviceId) exitWith {
                    _foundGrid = true;
                    private _gridObject = objectFromNetId _objectNetId;
                    private _mapGridPos = mapGridPosition _gridObject;
                    private _displayName = getText (configOf _gridObject >> "displayName");
                    private _currentState = _gridObject getVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "ON"];

                    // Header
                    _string = format ["Power Grid %1 - %2 (%3) @ %4", _gridId, _gridName, _displayName, _mapGridPos];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                    // Radius
                    _string = format ["    Radius: %1m", _radius];
                    [_computer, _string] call AE3_armaos_fnc_shell_stdout;

                    // State with color
                    private _stateColor = ["#fa4c58", "#8ce10b"] select (_currentState == "ON");
                    _string = "    State: ";
                    [_computer, [[_string, [_currentState, _stateColor]]]] call AE3_armaos_fnc_shell_stdout;
                };
            } forEach _accessiblePowerGrids;

            if (!_foundGrid) then {
                _string = format ["Power Grid ID %1 not found or not accessible.", _deviceId];
                [_computer, [[[_string, "#fa4c58"]]]] call AE3_armaos_fnc_shell_stdout;
            };
        } else {
            // Summary view - just show grid count and basic info
            _string = format ["Power Grids: %1", count _accessiblePowerGrids];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            {
                _x params ["_gridId", "_objectNetId", "_gridName"];
                private _gridObject = objectFromNetId _objectNetId;
                private _mapGridPos = mapGridPosition _gridObject;

                // Get grid state and determine color
                private _currentState = _gridObject getVariable ["ROOT_CYBERWARFARE_POWERGRID_STATE", "OFF"];
                private _stateColor = "#FFD966"; // Default YELLOW for OFF (inactive)

                if (_currentState in ["ON", "ACTIVE", "ACTIVATED"]) then {
                    _stateColor = "#8ce10b"; // GREEN for ON (active)
                };
                if (_currentState in ["DESTROYED", "ERROR", "FAILED", "DEAD"]) then {
                    _stateColor = "#fa4c58"; // RED for Errors
                };

                _string = format ["    %1 - %2 - %3", _gridId, _gridName, _mapGridPos];
                [_computer, [[[_string, _stateColor]]]] call AE3_armaos_fnc_shell_stdout;
            } forEach _accessiblePowerGrids;
        };
    };
};

missionNamespace setVariable [_nameOfVariable, true, true];
