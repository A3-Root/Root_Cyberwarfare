/*
 * Author: Root
 * Zeus module to add a hackable vehicle or drone with customizable operation limits
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Dialog Controls (for vehicles):
 * - Vehicle Name: Custom name for terminal display
 * - Power Cost: Energy cost per hacking action (1-30 Wh)
 * - Operation Toggles: Enable/disable fuel, speed, brakes, lights, engine, alarm
 * - Fuel Limits: Min/Max percentage (0-100%)
 * - Speed Limits: Min/Max boost in km/h (-100 to 100)
 * - Brakes Limits: Min/Max deceleration rate (0.5-20 m/s²)
 * - Lights: Max toggles (-1 = unlimited) and cooldown (0-300 sec)
 * - Engine: Max toggles (-1 = unlimited) and cooldown (0-300 sec)
 * - Alarm: Min/Max duration (1-300 seconds)
 * - Future Laptops: Make accessible to future laptops
 * - Computer Selection: Link to specific laptops
 *
 * Modes:
 * - Direct Mode: Attach to a specific vehicle/drone
 * - Radius Mode: No attached object - registers all vehicles/drones in area
 * - Drone Mode: Simplified dialog for UAVs (no vehicle-specific options)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addVehicleZeus;
 *
 * Public: No
 */

params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

// If no attached object (Zeus-placed), try to find terrain object at logic position
if (isNull _targetObject) then {
    private _logicPos = getPosATL _logic;
    private _nearObjects = nearestObjects [_logicPos, [], 5];

    // Find the closest compatible object (vehicle or drone)
    private _compatibleVehicles = ["Car", "Motorcycle", "Tank", "Helicopter", "Plane", "Ship"];
    {
        if (_x != _logic && !(_x isKindOf "Logic")) then {
            // Only accept vehicles or drones
            private _obj = _x;
            private _isVehicle = false;
            {
                if (_obj isKindOf _x) exitWith {
                    _isVehicle = true;
                };
            } forEach _compatibleVehicles;
            private _isDrone = unitIsUAV _obj;

            if (_isVehicle || _isDrone) exitWith {
                _targetObject = _obj;
            };
        };
    } forEach _nearObjects;
};

private _useRadiusMode = isNull _targetObject;

if !(hasInterface) exitWith {};

// In direct mode, validate that the target object is a vehicle or drone
private _isVehicle = false;
private _isDrone = false;

if (!_useRadiusMode) then {
    private _compatibleVehicles = ["Car", "Motorcycle", "Tank", "Helicopter", "Plane", "Ship"];
    {
        if (_targetObject isKindOf _x) then {
            _isVehicle = true;
            break;
        };
    } forEach _compatibleVehicles;
    _isDrone = unitIsUAV _targetObject;

    if !((_isVehicle) || (_isDrone)) exitWith {
        deleteVehicle _logic;
        ["Object is not a vehicle or drone!"] call zen_common_fnc_showMessage;
    };
};

private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_VEHICLE_INDEX", 1];
ROOT_hackingVehicleName = format ["Vehicle_%1", _index];

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        private _netId = netId _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

// Capture logic position before dialog (needed for radius mode callback after logic is deleted)
private _logicPosition = getPosATL _logic;

// Build dialog controls based on object type
private _dialogControls = [];
private _dialogTitle = "";

// Add radius slider if in radius mode
if (_useRadiusMode) then {
    _dialogTitle = "Add Hackable Vehicles/Drones - Radius Mode";
    _dialogControls pushBack ["SLIDER:RADIUS", [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS", localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS_DESC"], [10, 3000, 1000, 0, _logicPosition, [7,120,32,1]]];
} else {
    if (_isDrone) then {
        // Simplified dialog for drones - only availability and laptop selection
        _dialogTitle = format ["Add Hackable Drone - %1", getText (configOf _targetObject >> "displayName")];
    } else {
        // Full dialog for vehicles
        _dialogTitle = format ["Add Hackable Vehicle - %1", getText (configOf _targetObject >> "displayName")];
        _dialogControls = [
            ["EDIT", ["Vehicle Name", "Name that will appear in the terminal for hacking"], [ROOT_hackingVehicleName]],
            ["SLIDER", ["Power Cost to Hack", "Energy / Power (in Wh) required to hack this vehicle. Consumption per hacking action / use."], [1, 30, 2, 1]],
            ["TOOLBOX:YESNO", ["Allow Battery (Fuel) Control", "Allow the vehicle fuel / battery to be hacked and modified."], true],
            ["TOOLBOX:YESNO", ["Allow Speed (Velocity) Control", "Allow the vehicle speed to be hacked and modified."], true],
            ["TOOLBOX:YESNO", ["Allow Brakes Control", "Allow the vehicle brakes to be hacked and applied."], true],
            ["TOOLBOX:YESNO", ["Allow Lights Control", "Allow the vehicle lights to be hacked and modified."], true],
            ["TOOLBOX:YESNO", ["Allow Engine Control", "Allow the vehicle engine to be hacked and turned on/off."], true],
            ["TOOLBOX:YESNO", ["Allow Car Alarm", "Allow the vehicle alarm to be hacked to produce its sound."], true],
            ["SLIDER", ["Min Fuel %", "Minimum fuel percentage (0-100%)"], [0, 100, 0, 0]],
            ["SLIDER", ["Max Fuel %", "Maximum fuel percentage (0-100%)"], [0, 100, 100, 0]],
            ["SLIDER", ["Min Speed Boost (km/h)", "Minimum speed boost (negative = slowdown)"], [-100, 100, -50, 0]],
            ["SLIDER", ["Max Speed Boost (km/h)", "Maximum speed boost"], [-100, 100, 50, 0]],
            ["SLIDER", ["Min Brake Decel (m/s²)", "Minimum deceleration rate"], [0.5, 20, 1, 1]],
            ["SLIDER", ["Max Brake Decel (m/s²)", "Maximum deceleration rate"], [0.5, 20, 10, 1]],
            ["SLIDER", ["Max Light Toggles", "Maximum toggle count (-1 = unlimited)"], [-1, 100, -1, 0]],
            ["SLIDER", ["Light Cooldown (sec)", "Seconds between light toggles"], [0, 300, 0, 0]],
            ["SLIDER", ["Max Engine Toggles", "Maximum toggle count (-1 = unlimited)"], [-1, 100, -1, 0]],
            ["SLIDER", ["Engine Cooldown (sec)", "Seconds between engine toggles"], [0, 300, 0, 0]],
            ["SLIDER", ["Min Alarm Duration (sec)", "Minimum alarm duration"], [1, 300, 1, 0]],
            ["SLIDER", ["Max Alarm Duration (sec)", "Maximum alarm duration"], [1, 300, 30, 0]]
        ];
    };
};

// Add availability setting (common to all modes)
_dialogControls pushBack ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this device be available to laptops that are added later?"], false];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    _dialogTitle,
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_logicPosition", "_targetObject", "_execUserId", "_allComputers", "_index", "_isDrone", "_useRadiusMode"];

        private _resultIndex = 0;
        private _radius = 0;

        // Extract radius if in radius mode
        if (_useRadiusMode) then {
            _radius = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
        };

        private _selectedComputers = [];
        private _checkboxStartIndex = 0;

        if (_useRadiusMode) then {
            // Radius mode: Extract availability flag and process computers
            private _availableToFutureLaptops = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
            _checkboxStartIndex = _resultIndex;

            // Process laptop checkboxes
            {
                if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                    _selectedComputers pushBack (_x select 0);
                };
            } forEach _allComputers;

            // If available to future laptops, keep the selected computers but mark for future availability
            // If not available to future laptops and no computers selected, use all current computers
            if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
                _selectedComputers = _allComputers apply { _x select 0 };
            };

            // Radius mode: Use captured position (logic is already deleted)
            [_logicPosition, _radius, _execUserId, _selectedComputers, _availableToFutureLaptops] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

        } else {
            if (_isDrone) then {
                // Drone: only availability flag
                private _availableToFutureLaptops = _results select _resultIndex;
                _resultIndex = _resultIndex + 1;
                _checkboxStartIndex = _resultIndex;

                // Process laptop checkboxes
                {
                    if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                        _selectedComputers pushBack (_x select 0);
                    };
                } forEach _allComputers;

                // If available to future laptops, keep the selected computers but mark for future availability
                // If not available to future laptops and no computers selected, use all current computers
                if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
                    _selectedComputers = _allComputers apply { _x select 0 };
                };

                // Call addVehicleZeusMain which will detect drone and redirect to addDeviceZeusMain
                [_targetObject, _execUserId, _selectedComputers, _availableToFutureLaptops] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
                ["Hackable Drone Added!"] call zen_common_fnc_showMessage;

            } else {
                // Vehicle: full configuration
                _results params [
                    "_vehicleName", "_powerCost",
                    "_allowFuel", "_allowSpeed", "_allowBrakes", "_allowLights", "_allowEngine", "_allowAlarm",
                    "_fuelMinPercent", "_fuelMaxPercent",
                    "_speedMinValue", "_speedMaxValue",
                    "_brakesMinDecel", "_brakesMaxDecel",
                    "_lightsMaxToggles", "_lightsCooldown",
                    "_engineMaxToggles", "_engineCooldown",
                    "_alarmMinDuration", "_alarmMaxDuration",
                    "_availableToFutureLaptops"
                ];
                _checkboxStartIndex = 21;

                // Process laptop checkboxes
                {
                    if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                        _selectedComputers pushBack (_x select 0);
                    };
                } forEach _allComputers;

                // If available to future laptops, keep the selected computers but mark for future availability
                // If not available to future laptops and no computers selected, use all current computers
                if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
                    _selectedComputers = _allComputers apply { _x select 0 };
                };

                // Validate power cost
                if (_powerCost < 1) then { _powerCost = 1; };

                [
                    _targetObject, _execUserId, _selectedComputers, _vehicleName,
                    _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm,
                    _availableToFutureLaptops, _powerCost,
                    _fuelMinPercent, _fuelMaxPercent, _speedMinValue, _speedMaxValue,
                    _brakesMinDecel, _brakesMaxDecel, _lightsMaxToggles, _lightsCooldown,
                    _engineMaxToggles, _engineCooldown, _alarmMinDuration, _alarmMaxDuration
                ] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
                ["Hackable Vehicle Added!"] call zen_common_fnc_showMessage;
                _index = _index + 1;
                missionNamespace setVariable ["ROOT_CYBERWARFARE_VEHICLE_INDEX", _index, true];
            };
        };
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_logicPosition, _targetObject, _execUserId, _allComputers, _index, _isDrone, _useRadiusMode]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
