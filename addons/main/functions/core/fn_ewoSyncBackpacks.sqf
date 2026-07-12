#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Initializes the supported EWO backpacks as hidden routers and records their energy pool.
 *              The network starts switched off: an EWO decides when to broadcast, and until then the pack
 *              gives nothing away and spends nothing. A router is only listed by a laptop's scan while it
 *              is powered, so the power state is what the operator's on/off switch moves. Runs on the
 *              server and is safe to call repeatedly.
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
    "jsoc_ew_base_backpack_multicamtropic", "jsoc_ew_base_backpack_multicamod", "B_RadioBag_01_black_F"
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

        // A password that is simply the network name is no password at all: anyone who can see the network
        // can read it off the scan. The pack ships with a random one the EWO can look up and change.
        // Letters and digits that cannot be misread for one another over a radio: no O against 0, no I
        // against 1, since a password is only useful if it can be passed on correctly.
        private _alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "2", "3", "4", "5", "6", "7", "8", "9"];
        private _password = "";
        for "_i" from 1 to 8 do {
            _password = _password + (selectRandom _alphabet);
        };

        _bag setVariable ["ROOT_EWO_INITIALIZED", true, true];
        _bag setVariable ["ROOT_EWO_ENERGY", EWO_ENERGY_MAX, true];
        _bag setVariable ["ROOT_EWO_NETWORK_NAME", _name, true];
        _bag setVariable ["ROOT_EWO_PASSWORD", _password, true];
        _bag setVariable ["ROOT_EWO_GATEWAY", _gateway, true];
        _bag setVariable ["ROOT_EWO_WIFI_ON", false, true];

        [_bag, objNull, _gateway, true] call AE3_network_fnc_initRouter;
        [_bag, _name, EWO_WIFI_RANGE, _password, _gateway, true, "77\\.77\\.\\d+\\.1"] call AE3_network_fnc_applyRouterConfig;

        // initRouter leaves the router powered as a matter of course; an EWO network is off until asked
        // for, so it is switched back down here and only comes up from the operator's own action.
        _bag setVariable ["AE3_power_powerState", 0, true];
    };
} forEach _bags;
