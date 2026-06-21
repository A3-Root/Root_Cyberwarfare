#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Returns a device's map-grid string for display, honoring the per-device "Allow
 * Location View" flag (default on). When the flag is disabled the grid is replaced with a
 * "[location hidden]" placeholder, so both the CLI device listing and the GUI keep the position
 * secret (General #3). GPS trackers are exempt (they gate on their tracked state instead).
 *
 * Arguments:
 * 0: _obj <OBJECT> - The device object
 *
 * Return Value:
 * Grid string, or "[location hidden]" / "unknown" <STRING>
 *
 * Example:
 * private _grid = [_building] call Root_fnc_gridLabel;
 *
 * Public: No
 */

params ["_obj"];

if (isNull _obj) exitWith { "unknown" };
if (!(_obj getVariable ["ROOT_CYBERWARFARE_ALLOW_LOCATION", true])) exitWith { "[location hidden]" };

mapGridPosition _obj
