// File: fn_ewoLaptopBattery.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Reads the battery of a laptop that is packed away in someone's inventory. AE3 packs a
 *              laptop in one of two ways, and only one of them copies the battery level into the item:
 *              the stable path leaves the real laptop object alive but hidden and simply remembers which
 *              item stands for it, so its battery is still on the object and nowhere else. Both paths are
 *              resolved here, so a caller asks for a laptop item's charge without caring how it was packed
 *              and never reads a level that was never written.
 *
 * Arguments:
 * 0: _item <STRING> - Laptop item class (Item_Laptop_AE3_ID_N)
 *
 * Return Value:
 * 0: _percent <NUMBER> - Battery level in percent (0-100), 0 when the laptop cannot be resolved
 * 1: _battery <OBJECT> - The battery to write charge back to, null for an item-buffer laptop
 *
 * Example:
 * ([_item] call Root_fnc_ewoLaptopBattery) params ["_percent", "_battery"];
 *
 * Public: No
 */

params [["_item", "", [""]]];

if (_item isEqualTo "") exitWith {[0, objNull]};

// Stable packing: the laptop is a real object, hidden, and the tracker maps the item back to it.
private _tracker = missionNamespace getVariable ["AE3_LAPTOP_STABLE_TRACKER", createHashMap];
private _laptop = _tracker getOrDefault [_item, objNull];

if (!isNull _laptop) exitWith {
    private _battery = _laptop getVariable ["AE3_power_internal", objNull];
    if (isNull _battery) exitWith {[0, objNull]};
    private _info = [_battery, false] call AE3_power_fnc_getBatteryLevel;
    [_info param [1, 0], _battery]
};

// Experimental packing: the laptop object is gone and its state, battery level included, lives in the
// item buffer instead.
private _buffer = missionNamespace getVariable ["AE3_LAPTOP_ITEM", createHashMap];
private _state = _buffer getOrDefault [_item, createHashMap];

[_state getOrDefault ["ROOT_EWO_BATTERY_PERCENT", 0], objNull]
