// File: fn_ewoLaptopDisplayName.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Resolves the operator-facing label of a packed laptop item. Persistent laptops carry an
 *              ID in their class name and may have been renamed on the deployed object, so the label
 *              matches the one the AE3 deploy menu shows ("CustomName (RootBook X)" or "RootBook X").
 *              Any other laptop class falls back to its config display name.
 *
 * Arguments:
 * 0: _item <STRING> - Laptop item class
 *
 * Return Value:
 * Display label <STRING>
 *
 * Example:
 * ["Item_Laptop_AE3_ID_5"] call Root_fnc_ewoLaptopDisplayName;
 *
 * Public: No
 */

params [["_item", "", [""]]];

if (_item find "Item_Laptop_AE3_ID_" != 0) exitWith {
    getText (configFile >> "CfgWeapons" >> _item >> "displayName")
};

private _idStr = _item select [19];

private _tracker = missionNamespace getVariable ["AE3_LAPTOP_STABLE_TRACKER", createHashMap];
private _laptop = _tracker getOrDefault [_item, objNull];
private _customName = if (isNull _laptop) then {""} else {_laptop getVariable ["AE3_laptop_customName", ""]};

if (_customName isEqualTo "") exitWith {
    format ["RootBook %1", _idStr]
};

format ["%1 (RootBook %2)", _customName, _idStr]
