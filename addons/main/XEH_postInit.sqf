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
        ROOT_CYBERWARFARE_LOG_DEBUG_2("Power consumed: %1 Wh, new level: %2 kWh",_powerWh,_newLevel);
    }] call CBA_fnc_addEventHandler;

    // Device state change event
    // Triggered when a device changes state (door locked, light toggled, etc.)
    ["root_cyberwarfare_deviceStateChanged", {
        params ["_deviceType", "_deviceId", "_newState"];
        ROOT_CYBERWARFARE_LOG_DEBUG_3("Device state changed - Type: %1, ID: %2, State: %3",_deviceType,_deviceId,_newState);
    }] call CBA_fnc_addEventHandler;

    // GPS tracking event
    // Triggered when a GPS tracker updates its tracking status
    ["root_cyberwarfare_gpsTrackingUpdate", {
        params ["_trackerId", "_status"];
        ROOT_CYBERWARFARE_LOG_DEBUG_2("GPS tracking update - ID: %1, Status: %2",_trackerId,_status);
    }] call CBA_fnc_addEventHandler;

    // Device linked event
    // Triggered when a computer is granted access to a device
    ["root_cyberwarfare_deviceLinked", {
        params ["_computerNetId", "_deviceType", "_deviceId"];
        ROOT_CYBERWARFARE_LOG_DEBUG_3("Device linked - Computer: %1, Type: %2, ID: %3",_computerNetId,_deviceType,_deviceId);
    }] call CBA_fnc_addEventHandler;
};

// ============================================================================
// Server-Side: Initialize Device Cleanup Task
// ============================================================================
// Starts background task to periodically clean up invalid device links
// Ensures integrity of device links when computers or devices are deleted
// Runs only on server to maintain authoritative state
if (isServer) then {
    call FUNC(cleanupDeviceLinks);
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
    _deviceCache set [CACHE_KEY_POWERGRIDS, []];

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
    // Structure: [doors, lights, drones, databases, custom, gpsTrackers, vehicles, powerGrids]
    // 3DEN modules may have already populated this during mission initialization
    if (isNil "ROOT_CYBERWARFARE_ALL_DEVICES") then {
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []], true];
    };

    publicVariable "ROOT_CYBERWARFARE_ALL_DEVICES";
    publicVariable GVAR_LINK_CACHE;
    publicVariable GVAR_PUBLIC_DEVICES;

    ROOT_CYBERWARFARE_LOG_INFO("Device cache initialized");
};

if (hasInterface) then {
    [{(!isNull ACE_player) && (uiTime > 10) && (serverTime > 10)}, {
        call FUNC(createDiaryEntry);

        // ========================================================================
        // ACE Action: GPS Tracker Operations (Parent Menu)
        // ========================================================================
        // Creates a submenu to group all GPS tracker related actions
        // Large downward position offset creates significant gap below default actions like "Take Item"
        private _actionGPSParent = [
            "ROOT_GPSTracker_Menu",                              // 0: Action name
            localize "STR_ROOT_CYBERWARFARE_GPS_MENU",          // 1: Display name
            "",                                                  // 2: Icon
            {},                                                  // 3: Statement
            {                                                    // 4: Condition (check search mode setting)
                private _mode = missionNamespace getVariable [SETTING_GPS_INTERACTION_MODE, "SEARCH_MODE"];
                if (_mode == "ALWAYS") exitWith {true};
                _player getVariable ["ROOT_CYBERWARFARE_GPS_SEARCH_MODE", false]
            },
            {},                                                  // 5: Insert children
            [],                                                  // 6: Action parameters
            {[0, 0, -0.3]},                                      // 7: Position (offset downward 0.3m for clear separation)
            4                                                    // 8: Distance
        ] call ace_interact_menu_fnc_createAction;

        // Add parent action to classes specified in CBA settings whitelist
        // Robust parsing: handles spaces, quotes, empty entries, and other user formatting errors
        private _whitelistString = missionNamespace getVariable [SETTING_GPS_INTERACTION_WHITELIST, "Car,Tank,Helicopter,Plane,Ship,Motorcycle,Man,House,Building,Lamps_base_F,ThingX"];
        ROOT_CYBERWARFARE_LOG_DEBUG_1("GPS whitelist raw input: %1",_whitelistString);

        private _validClasses = (_whitelistString splitString ",") apply {
            // Trim whitespace
            private _cleaned = [_x] call CBA_fnc_trim;
            // Remove all double quotes and single quotes that users might add
            _cleaned = _cleaned splitString """'" joinString "";
            // Trim again after quote removal
            [_cleaned] call CBA_fnc_trim
        };
        // Filter out empty strings
        _validClasses = _validClasses select {_x != ""};

        ROOT_CYBERWARFARE_LOG_INFO_1("GPS interaction menu enabled for classes: %1",_validClasses);

        // Add GPS actions to whitelisted classes
        {
            [_x, 0, ["ACE_MainActions"], _actionGPSParent, true] call ace_interact_menu_fnc_addActionToClass;
        } forEach _validClasses;

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
                // Action condition - only show if player has GPS tracker item AND target is not a weapon holder or ACE item
                if (_target isKindOf "WeaponHolder") exitWith {false};
                if (_target isKindOf "WeaponHolderSimulated") exitWith {false};
                // Exclude all ACE items to prevent conflicts with ACE interaction menus
                private _typeOf = typeOf _target;
                if ((_typeOf select [0, 4]) in ["ACE_", "ace_"] || (_typeOf select [0, 5]) == "acex_") exitWith {false};
                private _gpsTrackerClass = missionNamespace getVariable [SETTING_GPS_TRACKER_DEVICE, "ACE_Banana"];
                _gpsTrackerClass in (uniformItems _player + vestItems _player + backpackItems _player + items _player);
            }
        ] call ace_interact_menu_fnc_createAction;

        // Add as child action to GPS Tracker menu (using same whitelist as parent)
        {
            [_x, 0, ["ACE_MainActions", "ROOT_GPSTracker_Menu"], _actionAttach, true] call ace_interact_menu_fnc_addActionToClass;
        } forEach _validClasses;

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
                // Action condition - available on all objects except weapon holders and ACE items
                if (_target isKindOf "WeaponHolder") exitWith {false};
                if (_target isKindOf "WeaponHolderSimulated") exitWith {false};
                // Exclude all ACE items to prevent conflicts with ACE interaction menus
                private _typeOf = typeOf _target;
                if ((_typeOf select [0, 4]) in ["ACE_", "ace_"] || (_typeOf select [0, 5]) == "acex_") exitWith {false};
                true
            }
        ] call ace_interact_menu_fnc_createAction;

        // Add as child action to GPS Tracker menu (using same whitelist as parent)
        {
            [_x, 0, ["ACE_MainActions", "ROOT_GPSTracker_Menu"], _actionSearch, true] call ace_interact_menu_fnc_addActionToClass;
        } forEach _validClasses;

        // ========================================================================
        // ACE Self-Actions: GPS Tracker Search Mode Toggle
        // ========================================================================
        // Only added when GPS Interaction Mode is set to "Search Mode"
        // Allows players to toggle GPS tracker visibility on interaction targets

        private _gpsInteractionMode = missionNamespace getVariable [SETTING_GPS_INTERACTION_MODE, "SEARCH_MODE"];

        if (_gpsInteractionMode == "SEARCH_MODE") then {
            // Enable GPS Tracker Search action
            private _actionEnableSearch = [
                "ROOT_GPSTracker_EnableSearch",
                localize "STR_ROOT_CYBERWARFARE_GPS_ENABLE_SEARCH",
                "",
                {
                    params ["_target", "_player", "_params"];
                    _player setVariable ["ROOT_CYBERWARFARE_GPS_SEARCH_MODE", true];
                    [localize "STR_ROOT_CYBERWARFARE_GPS_SEARCH_MODE_ON", true, 1.5, 2] call ace_common_fnc_displayText;
                },
                {
                    !(_player getVariable ["ROOT_CYBERWARFARE_GPS_SEARCH_MODE", false])
                }
            ] call ace_interact_menu_fnc_createAction;

            [player, 1, ["ACE_SelfActions"], _actionEnableSearch] call ace_interact_menu_fnc_addActionToObject;

            // Disable GPS Tracker Search action
            private _actionDisableSearch = [
                "ROOT_GPSTracker_DisableSearch",
                localize "STR_ROOT_CYBERWARFARE_GPS_DISABLE_SEARCH",
                "",
                {
                    params ["_target", "_player", "_params"];
                    _player setVariable ["ROOT_CYBERWARFARE_GPS_SEARCH_MODE", false];
                    [localize "STR_ROOT_CYBERWARFARE_GPS_SEARCH_MODE_OFF", true, 1.5, 2] call ace_common_fnc_displayText;
                },
                {
                    _player getVariable ["ROOT_CYBERWARFARE_GPS_SEARCH_MODE", false]
                }
            ] call ace_interact_menu_fnc_createAction;

            [player, 1, ["ACE_SelfActions"], _actionDisableSearch] call ace_interact_menu_fnc_addActionToObject;
        };

    }, [], 5] call CBA_fnc_waitUntilAndExecute;
};

// ============================================================================
// Initialize Breach Mod Integration
// ============================================================================
// Check if TSP Breach mod is loaded, then wait for its functions to initialize
// and override them to prevent breaching of cyber-locked doors.
// Runs on all machines since breach effects are client-side.

if (isClass (configFile >> "CfgPatches" >> "tsp_breach")) then {
    [{!isNil "tsp_fnc_breach_adjust"}, {
        call FUNC(initBreachIntegration);
    }] call CBA_fnc_waitUntilAndExecute;
} else {
    ROOT_CYBERWARFARE_LOG_INFO("TSP Breach mod not loaded - skipping breach integration");
};

ROOT_CYBERWARFARE_LOG_INFO("Post-init complete");
