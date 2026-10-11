#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Drops the access grants this machine received from device identifiers, so a code
 *              only grants access for the command it was typed into.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call Root_fnc_clearIdentifierGrants;
 *
 * Public: No
 */

missionNamespace setVariable [GVAR_IDENTIFIER_GRANTS, createHashMap];
