#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Initializes integration with TSP Breach mod to prevent breaching of cyber-locked doors.
 *              Overrides breach mod functions to check for ROOT_CYBERWARFARE_CYBER_LOCKED markers
 *              on doors locked via the cyberwarfare system.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call Root_fnc_initBreachIntegration;
 *
 * Public: No
 */

// Exit if breach mod is not loaded
if (isNil "tsp_fnc_breach_adjust") exitWith {
    LOG_INFO("Breach mod not detected - skipping integration");
};

LOG_INFO("Initializing Breach mod integration");

// Store original breach adjust function
GVAR(original_breach_adjust) = tsp_fnc_breach_adjust;

// Override breach adjust to prevent breaking cyber-locked doors
tsp_fnc_breach_adjust = {
    params ["_data", ["_amount", -1], ["_lock", -1]];
    _data params ["_id", "_house", "_door", "_pos", "_animName", "_animPhase", "_locked", "_triggerName", "_triggerPos", "_handleName", "_handlePos", "_hingeName", "_hingePos"];

    // Check if this specific door is cyber-locked
    private _isCyberLocked = _house getVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _id], false];

    // If trying to break (_lock == 3) a cyber-locked door, block it completely
    if (_lock == 3 && _isCyberLocked) exitWith {
        LOG_DEBUG_1("Blocked breach attempt on cyber-locked door %1",_id);
        // Play failure sound if position is available
        if (!isNil "_pos") then {
            playSound3D ["tsp_breach\snd\fail.ogg", _pos, false, _pos, 2, 1, 40];
        };
    };

    // Otherwise, call original function to handle normal breach operations
    [_data, _amount, _lock] call GVAR(original_breach_adjust)
};

// Store original breach effectiveness function
GVAR(original_breach_effectiveness) = tsp_fnc_breach_effectiveness;

// Override breach effectiveness to return 0 for buildings with cyber-locked doors
// This provides an additional layer of protection at the effectiveness calculation level
tsp_fnc_breach_effectiveness = {
    params ["_house", "_damage"];

    // Check if this building has any cyber-locked doors
    // We check all possible door IDs (0-99) for cyber-lock markers
    private _hasCyberLockedDoors = false;
    for "_i" from 0 to 99 do {
        if (_house getVariable [format ["ROOT_CYBERWARFARE_CYBER_LOCKED_%1", _i], false]) exitWith {
            _hasCyberLockedDoors = true;
        };
    };

    // If building has cyber-locked doors, return 0 (unbreachable)
    // This affects ALL doors in the building, which is intentional security behavior
    if (_hasCyberLockedDoors) exitWith {
        LOG_DEBUG_1("Building %1 has cyber-locked doors - breach effectiveness set to 0",typeOf _house);
        0
    };

    // Otherwise, call original function for normal breach calculations
    [_house, _damage] call GVAR(original_breach_effectiveness)
};

LOG_INFO("Breach mod integration initialized successfully");
