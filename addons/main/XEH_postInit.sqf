/*
 * Author: Root
 * Description: CBA PostInit Event Handler for Root's Cyberwarfare addon
 *              Executes after mission objects are created but before mission starts
 *
 * Responsibilities:
 * - Register CBA server-side event handlers for network communication
 * - Initialize device cache hashmap structure (server-side)
 * - Initialize link cache hashmap for computer->device relationships
 * - Set up ACE interaction menus for GPS tracker operations (client-side)
 *
 * Execution Order: PreInit -> PostInit -> Mission Objects Created -> Mission Start
 *
 * Public: No
 */

#include "script_component.hpp"

// ============================================================================
// Server-Side: CBA Event Handlers Registration
// ============================================================================
// Register event handlers for networked operations
// Using CBA events instead of remoteExec for better reliability and bandwidth

if (isServer) then {
    // Power consumption event (server-side only)
    // Triggered when a laptop operation consumes battery power
    ["root_cyberwarfare_consumePower", {
        params ["_computer", "_battery", "_newLevel", "_powerWh"];
        [_computer, _battery, _newLevel] call FUNC(removePower);
        LOG_DEBUG_2("Power consumed: %1 Wh, new level: %2 kWh",_powerWh,_newLevel);
    }] call CBA_fnc_addEventHandler;

    // Device state change event
    // Triggered when a device changes state (door locked, light toggled, etc.)
    ["root_cyberwarfare_deviceStateChanged", {
        params ["_deviceType", "_deviceId", "_newState"];
        LOG_DEBUG_3("Device state changed - Type: %1, ID: %2, State: %3",_deviceType,_deviceId,_newState);
    }] call CBA_fnc_addEventHandler;

    // GPS tracking event
    // Triggered when a GPS tracker updates its tracking status
    ["root_cyberwarfare_gpsTrackingUpdate", {
        params ["_trackerId", "_status"];
        LOG_DEBUG_2("GPS tracking update - ID: %1, Status: %2",_trackerId,_status);
    }] call CBA_fnc_addEventHandler;

    // Device linked event
    // Triggered when a computer is granted access to a device
    ["root_cyberwarfare_deviceLinked", {
        params ["_computerNetId", "_deviceType", "_deviceId"];
        LOG_DEBUG_3("Device linked - Computer: %1, Type: %2, ID: %3",_computerNetId,_deviceType,_deviceId);
    }] call CBA_fnc_addEventHandler;
};

// ============================================================================
// Server-Side: Initialize Device Cache and Link Cache
// ============================================================================
// Create hashmap structures for O(1) device lookups
// Replaces legacy array-based storage for better performance

if (isServer) then {
    // Initialize device cache hashmap
    // Structure: HashMap<String, Array> - deviceType -> [device entries]
    private _deviceCache = createHashMap;
    _deviceCache set [CACHE_KEY_DOORS, []];
    _deviceCache set [CACHE_KEY_LIGHTS, []];
    _deviceCache set [CACHE_KEY_DRONES, []];
    _deviceCache set [CACHE_KEY_DATABASES, []];
    _deviceCache set [CACHE_KEY_CUSTOM, []];
    _deviceCache set [CACHE_KEY_GPS_TRACKERS, []];
    _deviceCache set [CACHE_KEY_VEHICLES, []];

    // Store in global namespace with network sync
    missionNamespace setVariable [GVAR_DEVICE_CACHE, _deviceCache, true];

    // Initialize link cache hashmap (only if it doesn't already exist)
    // Structure: HashMap<String, Array> - computerNetId -> [[deviceType, deviceId], ...]
    // 3DEN modules may have already populated this during mission initialization
    if (isNil GVAR_LINK_CACHE) then {
        missionNamespace setVariable [GVAR_LINK_CACHE, createHashMap, true];
    };

    // Initialize public devices array (only if it doesn't already exist)
    // Structure: Array of [deviceType, deviceId, [excludedNetIds]]
    // 3DEN modules may have already populated this during mission initialization
    if (isNil GVAR_PUBLIC_DEVICES) then {
        missionNamespace setVariable [GVAR_PUBLIC_DEVICES, [], true];
    };

    // Initialize legacy ALL_DEVICES array for backward compatibility (only if it doesn't already exist)
    // Structure: [doors, lights, drones, databases, custom, gpsTrackers, vehicles]
    // 3DEN modules may have already populated this during mission initialization
    if (isNil "ROOT_CYBERWARFARE_ALL_DEVICES") then {
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []], true];
    };

    publicVariable "ROOT_CYBERWARFARE_ALL_DEVICES";
    publicVariable GVAR_LINK_CACHE;
    publicVariable GVAR_PUBLIC_DEVICES;

    LOG_INFO("Device cache initialized");
};

// ============================================================================
// Client-Side: ACE Interaction Menus for GPS Trackers
// ============================================================================
// Set up ACE interaction menu actions after player is initialized
// Allows players to attach and search for GPS trackers on objects/units
if (hasInterface) then {
    [{(!isNull ACE_player) && (CBA_missionTime > 0)}, {
        // ========================================================================
        // ACE Action: Attach GPS Tracker to Object
        // ========================================================================
        // Allows player to attach a GPS tracker from inventory to another object/unit
        private _actionAttach = [
            "ROOT_AttachGPSTracker_Object",
            localize "STR_ROOT_CYBERWARFARE_GPS_ATTACH_OBJECT",
            "",
            {
                // Action statement - executed when action is selected
                params ["_actionTarget", "_actionPlayer", "_params"];

                // Validate target (cannot attach to self)
                if (isNull _actionTarget || {_actionTarget == _actionPlayer}) exitWith {
                    [localize "STR_ROOT_CYBERWARFARE_GPS_UNABLE_ATTACH", true, 1.5, 2] call ace_common_fnc_displayText;
                };

                // Call unified attach function (handles config dialog + progress bar)
                [_actionTarget, _actionPlayer] call FUNC(aceAttachGPSTracker);
            },
            {
                // Action condition - only show if player has GPS tracker item
                private _gpsTrackerClass = missionNamespace getVariable [SETTING_GPS_TRACKER_DEVICE, "ACE_Banana"];
                _gpsTrackerClass in (uniformItems _player + vestItems _player + backpackItems _player + items _player);
            }
        ] call ace_interact_menu_fnc_createAction;

        // Add action to all objects (class "All")
        ["All", 0, ["ACE_MainActions"], _actionAttach, true] call ace_interact_menu_fnc_addActionToClass;

        // ========================================================================
        // ACE Action: Search for GPS Tracker on Object
        // ========================================================================
        // Allows player to search an object/unit for hidden GPS trackers
        private _actionSearch = [
            "ROOT_SearchGPSTracker_Object",
            localize "STR_ROOT_CYBERWARFARE_GPS_SEARCH",
            "",
            {
                // Action statement - executed when action is selected
                params ["_actionTarget", "_actionPlayer", "_params"];

                // Validate target (cannot search self)
                if (isNull _actionTarget || {_actionTarget == _actionPlayer}) exitWith {
                    [localize "STR_ROOT_CYBERWARFARE_GPS_CANNOT_SEARCH_SELF", true, 1.5, 2] call ace_common_fnc_displayText;
                };

                // Start progress bar (10 second action)
                [
                    10,  // Duration in seconds
                    [_actionTarget, _actionPlayer],
                    {
                        // On completion
                        params ["_args"];
                        _args params ["_args_target", "_args_player"];
                        [_args_target, _args_player] call FUNC(searchForGPSTracker);
                    },
                    {},  // On failure
                    format [localize "STR_ROOT_CYBERWARFARE_GPS_SEARCHING", getText (configOf _actionTarget >> "displayName")],
                    {
                        // Condition to continue - target and player must be valid
                        params ["_args"];
                        _args params ["_args_target", "_args_player"];
                        !isNull _args_target && {alive _args_player}
                    },
                    ["isNotInside"]  // Exceptions
                ] call ace_common_fnc_progressBar;
            },
            {
                // Action condition - always available
                true
            }
        ] call ace_interact_menu_fnc_createAction;

        // Add action to all objects (class "All")
        ["All", 0, ["ACE_MainActions"], _actionSearch, true] call ace_interact_menu_fnc_addActionToClass;

    }, []] call CBA_fnc_waitUntilAndExecute;
};

LOG_INFO("Post-init complete");
