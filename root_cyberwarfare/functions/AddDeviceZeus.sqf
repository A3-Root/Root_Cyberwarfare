params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

if (isNull _targetObject) exitWith {
    ["Place the module on an object!"] call zen_common_fnc_showMessage;
};

if !(hasInterface) exitWith {};

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_HackingTools", false]) then {
        private _computerName = _x getVariable ["ROOT_CustomName", getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName")];
        private _netId = netId _x;
        private _position = getPosATL _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [%2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

private _dialogControls = [
    ["TOOLBOX:YESNO", ["Treat as Custom Device", "Add the object EXCLUSIVELY to the 'Custom' section?"], false],
    ["EDIT", ["Custom Device Name", "Name that will appear in the terminal for this device (only if treated as custom)"], ["Power Generator Overload"]],
    ["EDIT:CODE", ["Activation Code (Custom Device Only)", "Code to run in a SCHEDULED environment (spawn) when device is activated. Use (_this select 0) to reference the computer object."], ["// Example: Display Hint when triggered 
hint str format ['Code triggered'];", {}, 7]],
    ["EDIT:CODE", ["Deactivation Code (Custom Device Only)", "Code to run in a SCHEDULED environment (spawn) when device is deactivated. Use (_this select 0) to reference the computer object."], ["// Example: Display Hint when triggered 
hint str format ['Code triggered'];", {}, 7]],
    ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this device be available to laptops that are added later?"], false]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    format ["Add Hackable Object - %1", getText (configFile >> "CfgVehicles" >> typeOf _targetObject >> "displayName")], 
    _dialogControls,
    // Fix the dialog result handler section:
    {
        params ["_results", "_args"];
        _args params ["_targetObject", "_execUserId", "_allComputers"];
        
        // First five results are the device configuration
        _results params ["_treatAsCustom", "_customName", "_activationCode", "_deactivationCode", "_availableToFutureLaptops"];
        
        // The rest are checkbox values for each computer
        private _selectedComputers = [];
        private _checkboxStartIndex = 5;
        
        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // If available to future laptops, keep the selected computers but mark for future availability
        // If not available to future laptops and no computers selected, use all current computers
        if (!_availableToFutureLaptops && count _selectedComputers == 0) then {
            _selectedComputers = _allComputers apply { _x select 0 };
        };
        
        // Pass all parameters including the availability setting
        [_targetObject, _execUserId, _selectedComputers, _treatAsCustom, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_AddDeviceZeusMain", 2];
        ["Hackable Object Added!"] call zen_common_fnc_showMessage;
    }, 
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_targetObject, _execUserId, _allComputers]
] call zen_dialog_fnc_create;

deleteVehicle _logic;