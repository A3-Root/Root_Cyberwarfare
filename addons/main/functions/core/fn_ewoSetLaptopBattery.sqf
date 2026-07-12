// File: fn_ewoSetLaptopBattery.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Writes a charge level back to a laptop that is packed away in someone's inventory. The
 *              counterpart of ewoLaptopBattery: a stable-packed laptop still owns a real battery object,
 *              so the level goes through the AE3 power system and is there when the laptop is unpacked,
 *              while an item-buffer laptop only has its stored state to update.
 *
 * Arguments:
 * 0: _item <STRING> - Laptop item class (Item_Laptop_AE3_ID_N)
 * 1: _percent <NUMBER> - Battery level to write, in percent (0-100)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_item, 42] call Root_fnc_ewoSetLaptopBattery;
 *
 * Public: No
 */

params [["_item", "", [""]], ["_percent", 0, [0]]];

if (!isServer || {_item isEqualTo ""}) exitWith {};

_percent = (_percent max 0) min 100;

([_item] call FUNC(ewoLaptopBattery)) params ["", "_battery"];

if (!isNull _battery) exitWith {
    [_battery, _percent] call AE3_power_fnc_setBatteryLevel;
};

private _buffer = missionNamespace getVariable ["AE3_LAPTOP_ITEM", createHashMap];
private _state = _buffer getOrDefault [_item, createHashMap];
_state set ["ROOT_EWO_BATTERY_PERCENT", _percent];
_buffer set [_item, _state];
missionNamespace setVariable ["AE3_LAPTOP_ITEM", _buffer, false];
