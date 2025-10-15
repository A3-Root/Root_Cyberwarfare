/*
 * Author: Root
 * Zeus module to add a hackable device (door/light/drone/custom)
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addDeviceZeus;
 *
 * Public: No
 */

params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;

if (isNull _targetObject) exitWith {
    deleteVehicle _logic;
    ["Place the module on an object!"] call zen_common_fnc_showMessage;
};

if !(hasInterface) exitWith {};

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

private _dialogControls = [
    ["TOOLBOX:YESNO", ["Treat as Custom Device", "Add the object EXCLUSIVELY to the 'Custom' section?"], false],
    ["EDIT", ["Custom Device Name", "Name that will appear in the terminal for this device (only if treated as custom)"], ["Power Generator Overload"]],
    ["EDIT:CODE", ["Activation Code (Custom Device Only)", "Code to run in a SCHEDULED environment (spawn) when device is activated. Default parameters ['_computer', '_customObject', '_executedUserId']"], ["hint str format ['Custom Activation triggered using (computer):%1 on: %2 by %3', _this select 0, _this select 1, _this select 2];", {}, 7]],
    ["EDIT:CODE", ["Deactivation Code (Custom Device Only)", "Code to run in a SCHEDULED environment (spawn) when device is deactivated. Default parameters ['_computer', '_customObject', '_executedUserId']"], ["hint str format ['Custom Deactivation triggered using (computer):%1 on: %2 by %3', _this select 0, _this select 1, _this select 2];", {}, 7]],
    ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this device be available to laptops that are added later?"], false]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    format ["Add Hackable Object - %1", getText (configOf _targetObject >> "displayName")], 
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
        if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
            _selectedComputers = _allComputers apply { _x select 0 };
        };
        
        // Pass all parameters including the availability setting
        [_targetObject, _execUserId, _selectedComputers, _treatAsCustom, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
        ["Hackable Object Added!"] call zen_common_fnc_showMessage;
    }, 
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_targetObject, _execUserId, _allComputers]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
