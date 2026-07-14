#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Initializes the supported EWO backpacks and records their energy pool, then keeps each
 *              pack's hidden router riding with it and clears away the routers of packs that are gone.
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
        private _gateway = [77, 95, _index mod 256, 1];

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
    };

    // Every initialized pack keeps a router of its own, created on the first pass it is seen on and
    // re-attached on later ones so that a pack handed to another operator, dropped or picked up takes
    // its network with it.
    if (!isNull _bag && {_bag getVariable ["ROOT_EWO_INITIALIZED", false]}) then {
        [_bag] call FUNC(ewoRouterProxy);
    };
} forEach _bags;

// A router whose pack no longer exists - the backpack was deleted, or its carrier left the mission -
// would otherwise keep broadcasting a network nobody carries, so it is taken off the air and out of
// the registry the laptop scan reads.
private _proxies = missionNamespace getVariable ["ROOT_EWO_ROUTERS", []];
private _orphans = _proxies select {isNull (_x getVariable ["ROOT_EWO_BAG", objNull])};

if (_orphans isNotEqualTo []) then {
    private _registry = missionNamespace getVariable ["AE3_network_routers", []];
    _registry = _registry - _orphans;
    {
        deleteVehicle _x;
    } forEach _orphans;
    missionNamespace setVariable ["AE3_network_routers", _registry, true];
    missionNamespace setVariable ["ROOT_EWO_ROUTERS", _proxies - _orphans, true];
};
