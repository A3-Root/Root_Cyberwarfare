#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Keeps an EWO backpack's wireless network on a hidden router object that rides with the
 *              pack. A backpack that is being worn is a container inside a unit's inventory rather than
 *              an entity standing in the world: it has no world position of its own and its variables
 *              only read back reliably where its carrier is local, so a laptop on another machine can
 *              neither measure its distance nor see that its network is up. The router the laptops scan
 *              for is therefore a real, invisible object attached to whoever is carrying the pack (or to
 *              the pack itself once it is on the ground), which every AE3 network path - scan, connect,
 *              resolve, ping - already knows how to handle. Called for each pack on the sync pass, so it
 *              also re-attaches a router whose pack has changed hands and returns the router in use.
 *
 * Arguments:
 * 0: _bag <OBJECT> - The EWO backpack container
 *
 * Return Value:
 * Router <OBJECT> - The pack's router object, objNull if it could not be created
 *
 * Example:
 * [_bag] call Root_fnc_ewoRouterProxy;
 *
 * Public: No
 */

params [["_bag", objNull, [objNull]]];

if (!isServer || {isNull _bag}) exitWith {objNull};

// Whoever is wearing the pack carries its network with them; a pack lying on the ground carries its own.
private _holder = _bag;
{
    if ((backpackContainer _x) isEqualTo _bag) exitWith {_holder = _x};
} forEach allPlayers;

private _router = _bag getVariable ["ROOT_EWO_ROUTER", objNull];

if (isNull _router) then {
    // An empty helipad has no model, no geometry and no collision, so an invisible one riding on a
    // player's back is a position and nothing else.
    _router = createVehicle ["Land_HelipadEmpty_F", getPosATL _holder, [], 0, "CAN_COLLIDE"];
    hideObjectGlobal _router;

    private _name = _bag getVariable ["ROOT_EWO_NETWORK_NAME", "EWO Net"];
    private _password = _bag getVariable ["ROOT_EWO_PASSWORD", ""];
    private _gateway = _bag getVariable ["ROOT_EWO_GATEWAY", [77, 95, 0, 1]];

    [_router, objNull, _gateway, true] call AE3_network_fnc_initRouter;
    // EWO networks are one force's networks wherever they stand, so they are open to each other and to
    // nothing else: the allow list is every address on an EWO subnet, which lets an operator reach a
    // laptop on another EWO's network across the map while a laptop on any other network is still
    // turned away at the gateway.
    [_router, _name, EWO_WIFI_RANGE, _password, _gateway, true, EWO_SUBNET_ALLOW] call AE3_network_fnc_applyRouterConfig;

    // initRouter leaves the router powered as a matter of course, and a laptop's scan lists a router
    // only while it is powered. The network follows the switch the operator left it on: off for a pack
    // that has never broadcast, on for one whose router had to be rebuilt while it was on the air.
    _router setVariable ["AE3_power_powerState", [0, 1] select (_bag getVariable ["ROOT_EWO_WIFI_ON", false]), true];

    _router setVariable ["ROOT_EWO_BAG", _bag, true];
    _bag setVariable ["ROOT_EWO_ROUTER", _router, true];

    private _proxies = missionNamespace getVariable ["ROOT_EWO_ROUTERS", []];
    _proxies pushBackUnique _router;
    missionNamespace setVariable ["ROOT_EWO_ROUTERS", _proxies, true];
};

// The pack can be handed on, dropped or picked up at any time, and the network has to follow it.
if ((attachedTo _router) isNotEqualTo _holder) then {
    detach _router;
    _router attachTo [_holder, [0, 0, 0]];
};

_router
