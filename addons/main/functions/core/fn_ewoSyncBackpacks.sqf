#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Initializes the supported EWO backpacks as fixed hidden routers and records their
 *              energy pool. Runs on the server and is safe to call repeatedly.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!isServer || {!(missionNamespace getVariable [SETTING_EWO_MODE, false])}) exitWith {};

private _classes = [
    "jsoc_B_ewo_bag_MC", "jsoc_B_ewo_bag_MCA", "jsoc_B_ewo_bag_MCB", "jsoc_B_ewo_bag_MCD",
    "jsoc_B_ewo_bag_MCT", "jsoc_B_ewo_bag_BLK", "jsoc_B_ewo_bag_GRY", "jsoc_B_ewo_bag_OD",
    "jsoc_B_ewo_bag_Tan", "jsoc_B_ewo_bag_White", "jsoc_ew_base_backpack_multicam",
    "jsoc_ew_base_backpack_multicamarctic", "jsoc_ew_base_backpack_multicamblack",
    "jsoc_ew_base_backpack_multicamtropic", "jsoc_ew_base_backpack_multicamod"
];

private _bags = allPlayers apply {backpackContainer _x};
_bags append ((allMissionObjects "Bag_Base") select {typeOf _x in _classes});

{
    private _bag = _x;
    if (!isNull _bag && {typeOf _bag in _classes} && {!(_bag getVariable ["ROOT_EWO_INITIALIZED", false])}) then {
        private _index = missionNamespace getVariable ["ROOT_EWO_NETWORK_INDEX", 0];
        missionNamespace setVariable ["ROOT_EWO_NETWORK_INDEX", _index + 1, true];
        private _name = format ["EWO Net %1", _index + 1];
        private _gateway = [77, 77, _index mod 256, 1];
        _bag setVariable ["ROOT_EWO_INITIALIZED", true, true];
        _bag setVariable ["ROOT_EWO_ENERGY", 400, true];
        _bag setVariable ["ROOT_EWO_NETWORK_NAME", _name, true];
        _bag setVariable ["ROOT_EWO_GATEWAY", _gateway, true];
        [_bag, objNull, _gateway, true] call AE3_network_fnc_initRouter;
        [_bag, _name, 10, _name, _gateway, true, "77\\.77\\.\\d+\\.1"] call AE3_network_fnc_applyRouterConfig;
    };
} forEach _bags;
