#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Starts the optional background task that periodically clears broken device links on the
 * server. The task is OPT-IN: it does nothing unless the admin enables the
 * ROOT_CYBERWARFARE_CLEANUP_ENABLED CBA setting (default off). Each pass sleeps for the
 * ROOT_CYBERWARFARE_CLEANUP_TIME interval (CBA slider, seconds) and, while enabled, runs one sweep via
 * Root_fnc_runDeviceLinkCleanup using the admin's ROOT_CYBERWARFARE_CLEANUP_STRIKE_GRACE preference.
 * Admins can also clear links on demand at any time (Root_fnc_clearBrokenDeviceLinks / the "Clear Broken
 * Device Links" ZEN module) regardless of this setting. Enable/interval/mode are all read live each pass,
 * so toggling the setting takes effect without a mission restart.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * <BOOLEAN> - Always returns true
 *
 * Example:
 * call Root_fnc_cleanupDeviceLinks;
 *
 * Public: No
 */

if (!isServer) exitWith {};

// Only start the loop once
if (missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_STARTED", false]) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("Device cleanup task already running,aborting duplicate initialization.");
};

// Legacy power-cost snapshot kept for backwards compatibility with older scripts that read ALL_COSTS.
private _doorCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DOOR_EDIT", 2];
private _droneSideCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT", 20];
private _droneDestructionCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT", 10];
private _customCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_CUSTOM_EDIT", 10];
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];

ROOT_CYBERWARFARE_LOG_INFO("Device link cleanup task ready (opt-in via ROOT_CYBERWARFARE_CLEANUP_ENABLED; default off).");

[] spawn {
    while {true} do {
        // Read the interval live so a mid-mission change to the slider takes effect on the next cycle.
        private _interval = missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_TIME", 180];
        _interval = 30 max _interval;
        uiSleep _interval;

        // Opt-in gate: skip the sweep entirely unless the admin turned automatic cleanup on.
        if !(missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_ENABLED", false]) then { continue };

        private _useGrace = missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_STRIKE_GRACE", true];
        ROOT_CYBERWARFARE_LOG_INFO("Running periodic device link cleanup...");
        [_useGrace] call FUNC(runDeviceLinkCleanup);
    };
};

missionNamespace setVariable ["ROOT_CYBERWARFARE_CLEANUP_STARTED", true, true];
true
