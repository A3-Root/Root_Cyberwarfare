#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Zeus module to add a power generator that controls lights within radius
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addPowerGeneratorZeus;
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

    // Find the closest object that isn't the logic itself
    {
        if (_x != _logic && !(_x isKindOf "Logic")) exitWith {
            _targetObject = _x;
        };
    } forEach _nearObjects;

    // If still no object found, show error
    if (isNull _targetObject) exitWith {
        deleteVehicle _logic;
        ["Place the module on an object!"] call zen_common_fnc_showMessage;
    };
};

private _position = getPosATL _targetObject;

if !(hasInterface) exitWith {};

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) then {
        private _displayName = getText (configOf _x >> "displayName");
        private _computerName = _x getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _displayName];
        private _netId = netId _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [Grid: %2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

private _dialogControls = [
    ["EDIT", ["Generator Name", "Name that will appear in the terminal"], ["Power Generator"]],
    ["SLIDER:RADIUS",["Effect Radius","Radius in meters to affect lights"],[100, 25000, 1000, 0, _position, [7,120,32,1]]],
    ["TOOLBOX:YESNO", ["Allow Explosion on Overload", "Create explosion when generator is overloaded"], false],
    ["LIST", ["Explosion Type", "Choose the type of explosion created on overload"], [
        ["ClaymoreDirectionalMine_Remote_Ammo_Scripted", "G_40mm_HE", "M_Mo_82mm_AT_LG", "Sh_120mm_APFSDS", "Sh_120mm_HE", "Sh_155mm_AMOS", "HelicopterExploSmall", "HelicopterExploBig", "Bo_GBU12_LGB", "Bo_GBU12_LGB_MI10"],
        ["Claymore", "40mm High Explosive", "82mm High Explosive", "120mm APFSDS Tank Shell", "120mm HE Shell", "155mm HE Shell", "Small Helicopter Explosion", "Large Helicopter Explosion", "500lb GBU-12 (Type I)", "500lb GBU-12 (Type II)"],
        0,
        11
    ]],
    ["EDIT", ["Excluded Light Classnames", "Comma-separated list of classnames to exclude (e.g., Lamp_Street_small_F,Land_LampHalogen_F)"], [""]],
    ["TOOLBOX:YESNO", ["Available to Future Laptops", "Should this device be available to laptops that are added later?"], false]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link this device to %1", _computerName]], false];
} forEach _allComputers;

[
    format ["Add Power Generator - %1", getText (configOf _targetObject >> "displayName")],
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_targetObject", "_execUserId", "_allComputers"];

        // Parse results
        _results params ["_generatorName", "_radius", "_allowExplosionOverload", "_explosionType", "_excludedClassnames", "_availableToFutureLaptops"];

        // Parse excluded classnames (convert comma-separated string to array)
        private _excludedArray = [];
        if (_excludedClassnames != "") then {
            _excludedArray = _excludedClassnames splitString ",";
            _excludedArray = _excludedArray apply {
                private _str = _x;
                // Trim whitespace
                while {_str select [0, 1] == " "} do { _str = _str select [1] };
                while {_str select [count _str - 1, 1] == " "} do { _str = _str select [0, count _str - 1] };
                _str
            };
        };

        // Get selected computers
        private _selectedComputers = [];
        private _checkboxStartIndex = 6;

        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // If not available to future laptops and no computers selected, use all current computers
        if (!_availableToFutureLaptops && _selectedComputers isEqualTo []) then {
            _selectedComputers = _allComputers apply { _x select 0 };
        };

        // Call main function
        [_targetObject, _execUserId, _selectedComputers, _generatorName, _radius, _allowExplosionOverload, _explosionType, _excludedArray, _availableToFutureLaptops] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
        ["Power Generator Added!"] call zen_common_fnc_showMessage;
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_targetObject, _execUserId, _allComputers]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
