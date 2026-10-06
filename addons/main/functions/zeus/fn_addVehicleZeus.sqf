#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
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
        [(localize "STR_ROOT_CYBERWARFARE_UI_OBJECT_IS_NOT_A_VEHICLE_OR_DRONE")] call zen_common_fnc_showMessage;
    };
};

private _index = missionNamespace getVariable ["ROOT_CYBERWARFARE_VEHICLE_INDEX", 1];
ROOT_hackingVehicleName = format ["Vehicle_%1", _index];

// Every laptop the vehicle can be linked to. Without one the dialog still works, but only the Unassigned
// and Public access modes can do anything, so the curator is told before spending time on the form.
private _allComputers = call FUNC(getRegisteredLaptops);
if (_allComputers isEqualTo []) then {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS_WARN"] call zen_common_fnc_showMessage;
};

// Capture logic position before dialog (needed for radius mode callback after logic is deleted)
private _logicPosition = getPosATL _logic;

// Build dialog controls based on object type
private _dialogControls = [];
private _dialogTitle = "";

// Add radius slider if in radius mode
if (_useRadiusMode) then {
    _dialogTitle = (localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_VEHICLES_DRONES_RADIUS_MODE");
    _dialogControls pushBack ["SLIDER:RADIUS", [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS", localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS_DESC"], [10, 3000, 1000, 0, _logicPosition, [7,120,32,1]]];
} else {
    if (_isDrone) then {
        // A drone is named and priced the same way a vehicle is: the name is what an operator reads in
        // the terminal and on the desktop, and the two costs are what hacking this particular drone is
        // worth. They start at the mission's own settings, so a drone left alone is charged like every
        // other drone and only a drone that is deliberately changed here departs from that.
        _dialogTitle = format [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_DRONE_1"), getText (configOf _targetObject >> "displayName")];
        _dialogControls = [
            ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DRONE_NAME"), (localize "STR_ROOT_CYBERWARFARE_UI_NAME_THAT_WILL_APPEAR_IN_THE_TERMINAL_FOR_HACKING")], [format ["Drone_%1", _index]]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_POWER_COST_TO_DISABLE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_DISABLE_THIS_DRONE")], [1, 100, missionNamespace getVariable [SETTING_DRONE_HACK_COST, 10], 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_POWER_COST_TO_SWITCH_SIDE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_CHANGE_THIS_DRONE_S_SIDE")], [1, 100, missionNamespace getVariable [SETTING_DRONE_SIDE_COST, 20], 0]]
        ];
    } else {
        // Full dialog for vehicles
        _dialogTitle = format [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_VEHICLE_1"), getText (configOf _targetObject >> "displayName")];
        _dialogControls = [
            ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_VEHICLE_NAME"), (localize "STR_ROOT_CYBERWARFARE_UI_NAME_THAT_WILL_APPEAR_IN_THE_TERMINAL_FOR_HACKING")], [ROOT_hackingVehicleName]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_POWER_COST_TO_HACK"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_HACK_THIS_VEHICLE_CONSUMPTION_PER_HACKING")], [1, 30, 2, 1]],
            ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_BATTERY_FUEL_CONTROL"), (localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_THE_VEHICLE_FUEL_BATTERY_TO_BE_HACKED_AND_MODIFIED")], true],
            ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_SPEED_VELOCITY_CONTROL"), (localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_THE_VEHICLE_SPEED_TO_BE_HACKED_AND_MODIFIED")], true],
            ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_BRAKES_CONTROL"), (localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_THE_VEHICLE_BRAKES_TO_BE_HACKED_AND_APPLIED")], true],
            ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_LIGHTS_CONTROL"), (localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_THE_VEHICLE_LIGHTS_TO_BE_HACKED_AND_MODIFIED")], true],
            ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_ENGINE_CONTROL"), (localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_THE_VEHICLE_ENGINE_TO_BE_HACKED_AND_TURNED_ON_OFF")], true],
            ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_CAR_ALARM"), (localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_THE_VEHICLE_ALARM_TO_BE_HACKED_TO_PRODUCE_ITS_SOUND")], true],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MIN_FUEL"), (localize "STR_ROOT_CYBERWARFARE_UI_MINIMUM_FUEL_PERCENTAGE_0_100")], [0, 100, 0, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MAX_FUEL"), (localize "STR_ROOT_CYBERWARFARE_UI_MAXIMUM_FUEL_PERCENTAGE_0_100")], [0, 100, 100, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MIN_SPEED_BOOST_KM_H"), (localize "STR_ROOT_CYBERWARFARE_UI_MINIMUM_SPEED_BOOST_NEGATIVE_SLOWDOWN_RANGE_2000_TO_2000")], [-2000, 2000, -50, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MAX_SPEED_BOOST_KM_H"), (localize "STR_ROOT_CYBERWARFARE_UI_MAXIMUM_SPEED_BOOST_RANGE_2000_TO_2000")], [-2000, 2000, 50, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MIN_BRAKE_DECEL_M_S"), (localize "STR_ROOT_CYBERWARFARE_UI_MINIMUM_DECELERATION_RATE")], [0.5, 20, 1, 1]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MAX_BRAKE_DECEL_M_S"), (localize "STR_ROOT_CYBERWARFARE_UI_MAXIMUM_DECELERATION_RATE")], [0.5, 20, 10, 1]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MAX_LIGHT_TOGGLES"), (localize "STR_ROOT_CYBERWARFARE_UI_MAXIMUM_TOGGLE_COUNT_1_UNLIMITED")], [-1, 100, -1, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_LIGHT_COOLDOWN_SEC"), (localize "STR_ROOT_CYBERWARFARE_UI_SECONDS_BETWEEN_LIGHT_TOGGLES")], [0, 300, 0, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MAX_ENGINE_TOGGLES"), (localize "STR_ROOT_CYBERWARFARE_UI_MAXIMUM_TOGGLE_COUNT_1_UNLIMITED")], [-1, 100, -1, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_ENGINE_COOLDOWN_SEC"), (localize "STR_ROOT_CYBERWARFARE_UI_SECONDS_BETWEEN_ENGINE_TOGGLES")], [0, 300, 0, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MIN_ALARM_DURATION_SEC"), (localize "STR_ROOT_CYBERWARFARE_UI_MINIMUM_ALARM_DURATION")], [1, 300, 1, 0]],
            ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_MAX_ALARM_DURATION_SEC"), (localize "STR_ROOT_CYBERWARFARE_UI_MAXIMUM_ALARM_DURATION")], [1, 300, 30, 0]]
        ];
    };
};

// Add access mode and availability setting (common to all modes)
_dialogControls pushBack ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
    [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
    [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"],
    0
]];
_dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE"), (localize "STR_ROOT_CYBERWARFARE_UI_ONLY_APPLIES_TO_LINKED_COMPUTERS_ONLY_THE_LINKED_COMPUTERS_KEEP_ACCESS_AND")], false];
// Allow Location View (common to all modes, #3) - pushed right after availability.
_dialogControls pushBack ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW"), (localize "STR_ROOT_CYBERWARFARE_UI_SHOW_THIS_DEVICE_S_GRID_LOCATION_ON_THE_LAPTOP_CLI_GUI_DISABLE")], true];

// Device ID entry: radius mode distributes a Start..End range across the found objects; direct and
// drone modes take a single fixed ID.
if (_useRadiusMode) then {
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIRST_DEVICE_ID_HANDED_OUT_ACROSS_THE_AREA_0_AUTO_ASSIGN")], ["0"]];
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_LAST_DEVICE_ID_HANDED_OUT_ACROSS_THE_AREA_0_AUTO_ASSIGN")], ["0"]];
} else {
    _dialogControls pushBack ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIXED_ID_FOR_THIS_VEHICLE_DRONE_0_AUTO_ASSIGN_A_FREE_ID")], ["0"]];
};

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_THIS_DEVICE_TO_1"), _computerName]], false];
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
            // Radius mode: Extract access mode and availability flag, then process computers
            private _accessMode = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
            private _availableToFutureLaptops = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
            private _allowLocation = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
            private _requestedId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
            private _rangeEndId = parseNumber (_results select _resultIndex);
            _resultIndex = _resultIndex + 1;
            _checkboxStartIndex = _resultIndex;

            // Process laptop checkboxes
            {
                if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                    _selectedComputers pushBack (_x select 0);
                };
            } forEach _allComputers;

            // Radius mode: Use captured position (logic is already deleted)
            [_logicPosition, _radius, _execUserId, _selectedComputers, _availableToFutureLaptops, _allowLocation, _requestedId, _rangeEndId, _accessMode] remoteExec ["Root_fnc_addVehicleZeusMain", 2];

            // Linked access with nothing ticked registers a device no laptop can reach, which the
            // dialog does not convey on its own.
            [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);

        } else {
            if (_isDrone) then {
                // Drone: name, the two hacking costs, then the flags every device carries
                private _droneName = _results select _resultIndex;
                _resultIndex = _resultIndex + 1;
                private _disableCost = _results select _resultIndex;
                _resultIndex = _resultIndex + 1;
                private _sideCost = _results select _resultIndex;
                _resultIndex = _resultIndex + 1;
                private _accessMode = _results select _resultIndex;
                _resultIndex = _resultIndex + 1;
                private _availableToFutureLaptops = _results select _resultIndex;
                _resultIndex = _resultIndex + 1;
                private _allowLocation = _results select _resultIndex;
                _resultIndex = _resultIndex + 1;
                private _requestedId = parseNumber (_results select _resultIndex);
                _resultIndex = _resultIndex + 1;
                _checkboxStartIndex = _resultIndex;

                // Process laptop checkboxes
                {
                    if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                        _selectedComputers pushBack (_x select 0);
                    };
                } forEach _allComputers;

                if (_disableCost < 1) then { _disableCost = 1; };
                if (_sideCost < 1) then { _sideCost = 1; };

                // Hand off to the vehicle worker, which detects drones and applies the drone-specific handling.
                [_targetObject, _execUserId, _selectedComputers, _availableToFutureLaptops, _droneName, _disableCost, _sideCost, _requestedId, _accessMode] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
                // Drone path can't carry the flag through the registration call; apply it on the object.
                [_targetObject, ["ROOT_CYBERWARFARE_ALLOW_LOCATION", _allowLocation, true]] remoteExec ["setVariable", 2];
                [(localize "STR_ROOT_CYBERWARFARE_UI_HACKABLE_DRONE_ADDED")] call zen_common_fnc_showMessage;

                // Linked access with nothing ticked registers a device no laptop can reach, which the
                // dialog does not convey on its own.
                [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
                _index = _index + 1;
                missionNamespace setVariable ["ROOT_CYBERWARFARE_VEHICLE_INDEX", _index, true];

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
                    "_accessMode", "_availableToFutureLaptops", "_allowLocation", "_requestedIdText"
                ];
                private _requestedId = parseNumber _requestedIdText;
                _checkboxStartIndex = 24;

                // Process laptop checkboxes
                {
                    if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                        _selectedComputers pushBack (_x select 0);
                    };
                } forEach _allComputers;

                // Validate power cost
                if (_powerCost < 1) then { _powerCost = 1; };

                [
                    _targetObject, _execUserId, _selectedComputers, _vehicleName,
                    _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm,
                    _availableToFutureLaptops, _powerCost,
                    _fuelMinPercent, _fuelMaxPercent, _speedMinValue, _speedMaxValue,
                    _brakesMinDecel, _brakesMaxDecel, _lightsMaxToggles, _lightsCooldown,
                    _engineMaxToggles, _engineCooldown, _alarmMinDuration, _alarmMaxDuration, _allowLocation, _requestedId, _accessMode
                ] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
                [(localize "STR_ROOT_CYBERWARFARE_UI_HACKABLE_VEHICLE_ADDED")] call zen_common_fnc_showMessage;

                // Linked access with nothing ticked registers a device no laptop can reach, which the
                // dialog does not convey on its own.
                [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
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
