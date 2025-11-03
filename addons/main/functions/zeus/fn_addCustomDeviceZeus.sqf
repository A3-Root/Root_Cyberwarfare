/*
 * Author: Root
 * Zeus module to add a custom device with activation/deactivation code
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addCustomDeviceZeus;
 *
 * Public: No
 */

params ["_logic"];
private _targetObject = attachedTo _logic;
private _execUserId = clientOwner;
private _useRadiusMode = isNull _targetObject;

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

private _dialogControls = [];

// Add radius slider if in radius mode
if (_useRadiusMode) then {
    _dialogControls pushBack ["SLIDER:RADIUS", [localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS", localize "STR_ROOT_CYBERWARFARE_ZEUS_BULK_RADIUS_DESC"], [10, 3000, 1000, 0, getPosATL _logic, [7,120,32,1]]];
};

_dialogControls append [
    ["EDIT", ["Custom Device Name", "Name that will appear in the terminal for this device"], ["Custom Device"]],
    ["EDIT:CODE", ["Activation Code", "Code to run in a SCHEDULED environment (spawn) when device is activated. The code is run on the player who activated the device. Default parameters ['_computer', '_customObject', '_playerNetID']"], ["hint str format ['Custom Activation triggered USING: %1 ---- ON: %2 ---- BY: %3 (Client ID: %4)', getText (configOf (_this select 0) >> 'displayName'), getText (configOf (_this select 1) >> 'displayName'), name (_this select 2), _this select 3];", {}, 7]],
    ["EDIT:CODE", ["Deactivation Code", "Code to run in a SCHEDULED environment (spawn) when device is deactivated. The code is run on the player who deactivated the device. Default parameters ['_computer', '_customObject', '_playerNetID']"], ["hint str format ['Custom Deactivation triggered USING: %1 ---- ON: %2 ---- BY: %3 (Client ID: %4)', getText (configOf (_this select 0) >> 'displayName'), getText (configOf (_this select 1) >> 'displayName'), name (_this select 2), _this select 3];", {}, 7]],
    ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this device be available to laptops that are added later?"], false]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    if (_useRadiusMode) then {"Add Custom Devices - Radius Mode"} else {format ["Add Custom Device - %1", getText (configOf _targetObject >> "displayName")]},
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_logic", "_targetObject", "_execUserId", "_allComputers", "_useRadiusMode"];

        private _resultIndex = 0;
        private _radius = 0;

        // Extract radius if in radius mode
        if (_useRadiusMode) then {
            _radius = _results select _resultIndex;
            _resultIndex = _resultIndex + 1;
        };

        // Extract device configuration
        private _customName = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;
        private _activationCode = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;
        private _deactivationCode = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;
        private _availableToFutureLaptops = _results select _resultIndex;
        _resultIndex = _resultIndex + 1;

        // Process laptop checkboxes
        private _selectedComputers = [];
        {
            if (_results select (_resultIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // If available to future laptops, keep the selected computers but mark for future availability
        // If not available to future laptops and no computers selected, use all current computers
        if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
            _selectedComputers = _allComputers apply { _x select 0 };
        };

        // Handle radius mode or direct mode
        if (_useRadiusMode) then {
            // Radius mode: Pass position array instead of logic object
            private _centerPos = getPosATL _logic;
            [_centerPos, _radius, _execUserId, _selectedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
        } else {
            // Direct mode: Register single object
            [_targetObject, _execUserId, _selectedComputers, _customName, _activationCode, _deactivationCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addCustomDeviceZeusMain", 2];
            ["Custom Device Added!"] call zen_common_fnc_showMessage;
        };
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_logic, _targetObject, _execUserId, _allComputers, _useRadiusMode]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
