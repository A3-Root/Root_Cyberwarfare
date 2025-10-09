params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

if !(hasInterface) exitWith {};

if (isNull _targetObject) exitWith {
    deleteVehicle _logic;
    ["Place the module on an object!"] call zen_common_fnc_showMessage;
};

private _index = missionNamespace getVariable ["ROOT_hackingVehicleIndex", 1];
ROOT_hackingVehicleName = format ["Vehicle_%1", _index];

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_HackingTools", false]) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CustomName", _displayName];
        private _netId = netId _x;
        private _position = getPosATL _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

private _dialogControls = [
    ["EDIT", ["Vehicle Name", "Name that will appear in the terminal for hacking"], [ROOT_hackingVehicleName]],
    ["SLIDER", ["Power Cost to Hack", "Energy / Power (in Wh) required to hack this vehicle. Consumption per hacking action / use."], [1, 30, 2, 1]],
    ["TOOLBOX:YESNO", ["Allow Fuel Draining", "Allow the vehicle fuel / battery to be hacked."], true],
    ["TOOLBOX:YESNO", ["Allow Speed Control", "Allow the vehicle speed to be hacked."], true],
    ["TOOLBOX:YESNO", ["Allow Brakes Control", "Allow the vehicle brakes to be hacked."], true],
    ["TOOLBOX:YESNO", ["Allow Lights Control", "Allow the vehicle lights to be hacked."], true],
    ["TOOLBOX:YESNO", ["Allow Engine Control", "Allow the vehicle engine to be hacked."], true],
    ["TOOLBOX:YESNO", ["Allow Car Alarm", "Allow the vehicle alarm to sound."], true],
    ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this vehicle be available to tools that are added later?"], false]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    format ["Add Hackable Vehicle - %1", getText (configOf _targetObject >> "displayName")], 
    _dialogControls,
    // Fix the dialog result handler section:
    {
        params ["_results", "_args"];
        _args params ["_targetObject", "_execUserId", "_allComputers", "_index"];
        
        // First seven results are the device configuration
        _results params ["_vehicleName", "_powerCost", "_allowFuel", "_allowSpeed", "_allowBrakes", "_allowLights", "_allowEngine", "_allowAlarm", "_availableToFutureLaptops"];
        
        // The rest are checkbox values for each computer
        private _selectedComputers = [];
        private _checkboxStartIndex = 9;
        
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
        
        // Pass all parameters including the availability setting
        [_targetObject, _execUserId, _selectedComputers, _vehicleName, _allowFuel, _allowSpeed, _allowBrakes, _allowLights, _allowEngine, _allowAlarm, _availableToFutureLaptops, _powerCost] remoteExec ["Root_fnc_addVehicleZeusMain", 2];
        ["Hackable Vehicle Added!"] call zen_common_fnc_showMessage;
        _index = _index + 1;
        missionNamespace setVariable ["ROOT_hackingVehicleIndex", _index, true];
    }, 
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_targetObject, _execUserId, _allComputers, _index]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
