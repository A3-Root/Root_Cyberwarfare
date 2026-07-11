#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns the persistent laptop item classes currently carried by a unit.
 *
 * Arguments:
 * 0: _unit <OBJECT> - Unit whose inventory is inspected
 *
 * Return Value:
 * Laptop item classes <ARRAY>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {[]};

(items _unit) select {_x find "Item_Laptop_AE3_ID_" == 0}
