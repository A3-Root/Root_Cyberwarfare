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
        [(localize "STR_ROOT_CYBERWARFARE_UI_PLACE_THE_MODULE_ON_AN_OBJECT")] call zen_common_fnc_showMessage;
    };
};

private _position = getPosATL _targetObject;

if !(hasInterface) exitWith {};

// Every laptop the generator can be linked to. Without one the dialog still works, but only the
// Unassigned and Public access modes can do anything, so the curator is told before filling the form.
private _allComputers = call FUNC(getRegisteredLaptops);
if (_allComputers isEqualTo []) then {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS_WARN"] call zen_common_fnc_showMessage;
};

private _dialogControls = [
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_GENERATOR_NAME"), (localize "STR_ROOT_CYBERWARFARE_UI_NAME_THAT_WILL_APPEAR_IN_THE_TERMINAL")], ["Power Generator"]],
    ["SLIDER:RADIUS",[(localize "STR_ROOT_CYBERWARFARE_UI_EFFECT_RADIUS"),(localize "STR_ROOT_CYBERWARFARE_UI_RADIUS_IN_METERS_TO_AFFECT_LIGHTS")],[100, 25000, 1000, 0, _position, [7,120,32,1]]],
    ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_EXPLOSION_ON_OVERLOAD"), (localize "STR_ROOT_CYBERWARFARE_UI_CREATE_EXPLOSION_WHEN_GENERATOR_IS_OVERLOADED")], false],
    ["LIST", [(localize "STR_ROOT_CYBERWARFARE_UI_EXPLOSION_TYPE"), (localize "STR_ROOT_CYBERWARFARE_UI_CHOOSE_THE_TYPE_OF_EXPLOSION_CREATED_ON_OVERLOAD")], [
        ["ClaymoreDirectionalMine_Remote_Ammo_Scripted", "G_40mm_HE", "M_Mo_82mm_AT_LG", "Sh_120mm_APFSDS", "Sh_120mm_HE", "Sh_155mm_AMOS", "HelicopterExploSmall", "HelicopterExploBig", "Bo_GBU12_LGB", "Bo_GBU12_LGB_MI10"],
        [(localize "STR_ROOT_CYBERWARFARE_UI_CLAYMORE"), (localize "STR_ROOT_CYBERWARFARE_UI_40MM_HIGH_EXPLOSIVE"), (localize "STR_ROOT_CYBERWARFARE_UI_82MM_HIGH_EXPLOSIVE"), (localize "STR_ROOT_CYBERWARFARE_UI_120MM_APFSDS_TANK_SHELL"), (localize "STR_ROOT_CYBERWARFARE_UI_120MM_HE_SHELL"), (localize "STR_ROOT_CYBERWARFARE_UI_155MM_HE_SHELL"), (localize "STR_ROOT_CYBERWARFARE_UI_SMALL_HELICOPTER_EXPLOSION"), (localize "STR_ROOT_CYBERWARFARE_UI_LARGE_HELICOPTER_EXPLOSION"), (localize "STR_ROOT_CYBERWARFARE_UI_500LB_GBU_12_TYPE_I"), (localize "STR_ROOT_CYBERWARFARE_UI_500LB_GBU_12_TYPE_II")],
        0,
        11
    ]],
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_EXCLUDED_LIGHT_CLASSNAMES"), (localize "STR_ROOT_CYBERWARFARE_UI_COMMA_SEPARATED_LIST_OF_CLASSNAMES_TO_EXCLUDE_E_G_LAMP_STREET_SMALL")], [""]],
    ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
        [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
        [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"],
        0
    ]],
    ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE"), (localize "STR_ROOT_CYBERWARFARE_UI_ONLY_APPLIES_TO_LINKED_COMPUTERS_ONLY_THE_LINKED_COMPUTERS_KEEP_ACCESS_AND")], false],
    ["TOOLBOX:YESNO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW"), (localize "STR_ROOT_CYBERWARFARE_UI_SHOW_THIS_DEVICE_S_GRID_LOCATION_ON_THE_LAPTOP_CLI_GUI_DISABLE")], true],
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIXED_ID_FOR_THIS_GENERATOR_0_AUTO_ASSIGN_A_FREE_ID")], ["0"]]
];

// Add a checkbox for each computer
{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_THIS_DEVICE_TO_1"), _computerName]], false];
} forEach _allComputers;

[
    format [(localize "STR_ROOT_CYBERWARFARE_UI_ADD_POWER_GENERATOR_1"), getText (configOf _targetObject >> "displayName")],
    _dialogControls,
    {
        params ["_results", "_args"];
        _args params ["_targetObject", "_execUserId", "_allComputers"];

        // Parse results
        _results params ["_generatorName", "_radius", "_allowExplosionOverload", "_explosionType", "_excludedClassnames", "_accessMode", "_availableToFutureLaptops", "_allowLocation", "_requestedIdText"];
        private _requestedId = parseNumber _requestedIdText;

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
        private _checkboxStartIndex = 9;

        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _selectedComputers pushBack (_x select 0);
            };
        } forEach _allComputers;

        // Call main function. Power cost keeps the main's default (10 Wh) since this dialog has no
        // cost field; the trailing values carry the requested device ID and the access mode.
        [_targetObject, _execUserId, _selectedComputers, _generatorName, _radius, _allowExplosionOverload, _explosionType, _excludedArray, _availableToFutureLaptops, 10, _requestedId, _accessMode] remoteExec ["Root_fnc_addPowerGeneratorZeusMain", 2];
        [_targetObject, ["ROOT_CYBERWARFARE_ALLOW_LOCATION", _allowLocation, true]] remoteExec ["setVariable", 2]; // General #3
        [(localize "STR_ROOT_CYBERWARFARE_UI_POWER_GENERATOR_ADDED")] call zen_common_fnc_showMessage;

        // Linked access with nothing ticked registers a device no laptop can reach, which the success
        // message above does not convey on its own.
        [_accessMode, _selectedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    },
    [_targetObject, _execUserId, _allComputers]
] call zen_dialog_fnc_create;

deleteVehicle _logic;
