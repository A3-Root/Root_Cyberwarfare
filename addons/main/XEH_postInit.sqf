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
	[FUNC(ewoSyncBackpacks), 5] call CBA_fnc_addPerFrameHandler;
	[FUNC(ewoChargeTick), 1] call CBA_fnc_addPerFrameHandler;
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

    // GPS tracker status update from a client (replaces client-side full-array broadcasts)
    // The server applies the change to the authoritative array and broadcasts it (debounced)
    ["root_cyberwarfare_updateTrackerStatus", {
        params ["_trackerId", "_status"];

        private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
        private _allGpsTrackers = _allDevices param [5, []];

        {
            if ((_x select 0) == _trackerId) exitWith {
                _x set [8, _status];
            };
        } forEach _allGpsTrackers;

        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices];
        call FUNC(syncDeviceData);
    }] call CBA_fnc_addEventHandler;

    // ------------------------------------------------------------------------
    // GUI (desktop app) server handlers: clients never read the device registry
    // directly; they request lists and submit actions which the server validates.
    // ------------------------------------------------------------------------
    ["root_cyberwarfare_gui_reqDevices", { _this call FUNC(gui_sendDeviceList); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_doorAction", { _this call FUNC(gui_doorAction); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_lightAction", { _this call FUNC(gui_lightAction); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_droneAction", { _this call FUNC(gui_droneAction); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_powergridAction", { _this call FUNC(gui_powergridAction); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_databaseAction", { _this call FUNC(gui_databaseAction); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_customAction", { _this call FUNC(gui_customAction); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_vehicleAction", { _this call FUNC(gui_vehicleAction); }] call CBA_fnc_addEventHandler;
    ["root_cyberwarfare_gui_gpsAction", { _this call FUNC(gui_gpsAction); }] call CBA_fnc_addEventHandler;
    // Clears the intro-video flag once a client has started playing it, so it plays once per mount.
    ["root_cyberwarfare_clearIntroPending", {
        params ["_computerNetId"];
        private _computer = objectFromNetId _computerNetId;
        if (!isNull _computer) then {
            _computer setVariable ["ROOT_CYBERWARFARE_INTRO_PENDING", false, true];
        };
    }] call CBA_fnc_addEventHandler;
    // Network Scanner GUI export: build the scan on the server and write it to the chosen (or default)
    // file in the laptop's filesystem.
    ["root_cyberwarfare_gui_netscanExport", {
        params ["_owner", "_computerNetId", ["_savePath", ""]];
        private _computer = objectFromNetId _computerNetId;
        if (isNull _computer) exitWith {};
        private _target = _savePath;
        if (_target isEqualTo "") then { _target = "/root/netscan.txt"; };
        private _rows = [_computer] call FUNC(scanNetwork);
        private _nl = toString [10];
        private _text = "Network Scan Results" + _nl + "IP Address | Type | External SSH | Interface | Hackable Devices" + _nl;
        {
            _x params ["_ip", "_devType", "_ssh", "_iface", ["_breakdown", []]];
            private _devicesStr = if (_breakdown isEqualTo []) then { "0" } else {
                (_breakdown apply { format ["%1 %2", _x select 1, _x select 0] }) joinString ", "
            };
            _text = _text + format ["%1 | %2 | %3 | %4 | %5", _ip, _devType, _ssh, _iface, _devicesStr] + _nl;
        } forEach _rows;

        // Write through the laptop's own filesystem (ensureFile + writeToFile), overwriting any previous
        // export, then broadcast the filesystem so the requesting client sees the new file - device_addFile
        // both refused to overwrite an existing file and synced server-only, so re-exports were dropped and
        // the client's browser never showed the result. Mirrors the database-download write.
        private _ok = true;
        private _filesystem = _computer getVariable ["AE3_filesystem", []];
        if (_filesystem isEqualTo []) exitWith {
            ["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_NETSCAN, "Laptop filesystem is not initialized.", false, _target], _owner] call CBA_fnc_ownerEvent;
        };
        // Ensure the destination folder exists before writing the file into it.
        private _parts = _target splitString "/";
        _parts deleteAt ((count _parts) - 1);
        private _dir = "/" + (_parts joinString "/");
        try {
            if (_dir != "/") then { [[], _filesystem, _dir, "root", "root", [[true, true, true], [true, false, true]]] call AE3_filesystem_fnc_ensureDir; };
            [[], _filesystem, _target, "", "root", "root", [[true, true, true], [true, false, true]]] call AE3_filesystem_fnc_ensureFile;
            [[], _filesystem, _target, "root", _text, false] call AE3_filesystem_fnc_writeToFile;
            _computer setVariable ["AE3_filesystem", _filesystem, true];
        } catch {
            _ok = false;
            ROOT_CYBERWARFARE_LOG_ERROR_2("Network scan export to %1 failed: %2",_target,_exception);
        };

        // Confirm to the requesting client so the app shows the saved path instead of hanging on "Export...".
        private _msg = if (_ok) then { format ["Network scan exported to %1", _target] } else { format ["Failed to export network scan to %1", _target] };
        ["root_cyberwarfare_gui_actionResult", [DEVICE_TYPE_NETSCAN, _msg, _ok, _target], _owner] call CBA_fnc_ownerEvent;
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
    call FUNC(createDiaryEntry);
};

call FUNC(cipherRegister);

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

    // Single debounced broadcast instead of three immediate publicVariable calls - the
    // initial setVariable calls above already used the public flag where needed, and any
    // 3DEN module registrations that ran before this point are included in this broadcast
    call FUNC(syncDeviceData);

    ROOT_CYBERWARFARE_LOG_INFO("Device cache initialized");
};

// Register the RootCW desktop GUI apps + client reply handlers (no-op if AE3 desktop absent).
if (hasInterface) then {
    call FUNC(gui_registerApps);
    ["ae3_desktop_volChanged", {
        private _session = uiNamespace getVariable ["AE3_desktop_session", createHashMap];
        private _computer = _session getOrDefault ["computer", objNull];
        if (isNull _computer) then {
            private _browserCtrl = uiNamespace getVariable ["AE3_desktop_browserCtrl", controlNull];
            if (!isNull _browserCtrl) then {
                private _display = ctrlParent _browserCtrl;
                _computer = _display getVariable ["AE3_desktop_computer", objNull];
            };
        };
        if (!isNull _computer) then {
            [_computer] spawn FUNC(gui_pushExtApps);
        };
    }] call CBA_fnc_addEventHandler;
    ["ae3_desktop_ready", {
        params [["_computer", objNull, [objNull]]];
        if (!isNull _computer) then {
            [_computer] spawn FUNC(gui_pushExtApps);
        };
    }] call CBA_fnc_addEventHandler;
    // Server-driven refresh: after a re-plugged hacking-tools drive has its install flag rebroadcast,
    // rebuild the desktop app list for the laptop this client is currently viewing.
    ["root_cyberwarfare_refreshExtApps", {
        private _session = uiNamespace getVariable ["AE3_desktop_session", createHashMap];
        private _computer = _session getOrDefault ["computer", objNull];
        if (isNull _computer) then {
            private _browserCtrl = uiNamespace getVariable ["AE3_desktop_browserCtrl", controlNull];
            if (!isNull _browserCtrl) then {
                private _display = ctrlParent _browserCtrl;
                _computer = _display getVariable ["AE3_desktop_computer", objNull];
            };
        };
        if (!isNull _computer) then {
            [_computer] spawn FUNC(gui_pushExtApps);
        };
    }] call CBA_fnc_addEventHandler;
};

if (isServer) then {
    ["ae3_computer_userAdded", {
        params [["_computer", objNull, [objNull]]];
        if (!isNull _computer) then {
            [_computer, [_computer] call FUNC(hasHackingToolsAvailable)] call FUNC(gui_syncHackermanDesktop);
        };
    }] call CBA_fnc_addEventHandler;

    // A flash drive that was picked up and re-plugged has its RootCW install flag restored only on
    // the server: AE3 rebuilds the drive object on reconnect and restores its variables without the
    // public broadcast flag, so clients evaluating tool availability read the default (false). On any
    // USB volume change, walk every AE3 computer's mounted drives; for a laptop with a hacking-tools
    // drive mounted, re-broadcast the drive's flag and provision the CLI toolset onto the laptop so
    // terminal commands work while plugged in. When the last tools drive is removed, withdraw a
    // USB-provisioned toolset again. Finally, ask clients to rebuild their desktop app list so the
    // Hacking Tools menu, launcher and dock icon track availability for all users of that laptop.
    ["ae3_desktop_volChanged", {
        {
            private _comp = _x;
            private _occupied = _comp getVariable ["AE3_USB_Interfaces_occupied", []];
            private _mounted = _comp getVariable ["AE3_USB_Interfaces_mounted", []];

            // Detect any mounted drive carrying the hacking toolset and re-broadcast its flag so
            // clients reading tool availability from the drive object see the restored value.
            private _hasToolsUsb = false;
            for "_i" from 0 to ((count _occupied) - 1) do {
                private _drive = _occupied param [_i, objNull];
                if (
                    !isNull _drive
                    && {_mounted param [_i, false]}
                    && {_drive getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]}
                ) then {
                    _drive setVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", true, true];
                    private _platformName = _drive getVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", ""];
                    _drive setVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _platformName, true];
                    _hasToolsUsb = true;
                };
            };

            // Provision / withdraw the laptop's own CLI toolset based on drive presence. A laptop
            // whose tools were installed directly (mission-side, not via a USB) is left untouched.
            private _provisioned = _comp getVariable ["ROOT_CYBERWARFARE_USB_PROVISIONED", false];
            private _selfInstalled = (_comp getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]) && {!_provisioned};
            if (_hasToolsUsb) then {
                if (!_provisioned && {!_selfInstalled}) then {
                    [_comp, "/rubberducky/tools", owner _comp, ""] call FUNC(addHackingToolsZeusMain);
                    _comp setVariable ["ROOT_CYBERWARFARE_USB_PROVISIONED", true, true];
                    // Arm the intro video so the next desktop open plays it once for this mount.
                    _comp setVariable ["ROOT_CYBERWARFARE_INTRO_PENDING", true, true];
                };
                // Drop the configured default login onto the laptop (if enabled and not already present),
                // so an operator plugging in the Rubberducky always has a known account to log in with.
                [_comp] call FUNC(seedRubberduckyCredentials);
            } else {
                if (_provisioned) then {
                    [_comp, "/rubberducky/tools"] call FUNC(removeHackingTools);
                    _comp setVariable ["ROOT_CYBERWARFARE_USB_PROVISIONED", false, true];
                };
            };
        } forEach (missionNamespace getVariable ["ae3_desktop_computers", []]);

        // Always refresh so re-plugged drives (flag rebroadcast only, no provisioning change) surface too.
        ["root_cyberwarfare_refreshExtApps", []] call CBA_fnc_globalEvent;
    }] call CBA_fnc_addEventHandler;
};

if (hasInterface) then {
    [{(!isNull ACE_player) && (uiTime > 10) && (serverTime > 10)}, {
        call FUNC(createDiaryEntry);

        private _actionEwoRegisterLaptop = [
            "ROOT_EWO_RegisterLaptop",
            "Register Hackable Laptop",
            "",
            {
                params ["_target", "_player"];
                [_target, owner _player, getText (configOf _target >> "displayName")] remoteExecCall ["Root_fnc_registerHackableLaptopZeusMain", 2];
            },
            {
                missionNamespace getVariable [SETTING_EWO_MODE, false]
                && {!(_target getVariable ["ROOT_CYBERWARFARE_HACKABLE_LAPTOP", false])}
            }
        ] call ace_interact_menu_fnc_createAction;

        {
            [_x, 0, ["ACE_MainActions"], _actionEwoRegisterLaptop, true] call ace_interact_menu_fnc_addActionToClass;
        } forEach ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"];

        private _actionEwoCharge = [
            "ROOT_EWO_ChargeLaptop",
            "Charge Laptop",
            "",
            {},
            {
                missionNamespace getVariable [SETTING_EWO_MODE, false]
                && {!isNull (backpackContainer _player)}
                && {(backpackContainer _player) getVariable ["ROOT_EWO_INITIALIZED", false]}
                && {([_player] call FUNC(ewoGetInventoryLaptops)) isNotEqualTo []}
            },
            {
                params ["_target", "_player"];
                private _actions = [];
                {
                    private _item = _x;
                    private _label = getText (configFile >> "CfgWeapons" >> _item >> "displayName");
                    private _action = [
                        "ROOT_EWO_Charge_" + _item,
                        _label,
                        "",
                        {
                            params ["_target", "_player", "_item"];
                            [_player, _item] remoteExecCall ["Root_fnc_ewoStartCharging", 2];
                        },
                        {true},
                        {},
                        _item
                    ] call ace_interact_menu_fnc_createAction;
                    _actions pushBack [_action, [], _target];
                } forEach ([_player] call FUNC(ewoGetInventoryLaptops));
                _actions
            }
        ] call ace_interact_menu_fnc_createAction;

        [player, 1, ["ACE_SelfActions"], _actionEwoCharge] call ace_interact_menu_fnc_addActionToObject;

        private _actionEwoStatus = [
            "ROOT_EWO_Status",
            "EWO Charging Status",
            "",
            {
                params ["_target", "_player"];
                private _bag = backpackContainer _player;
                private _energy = _bag getVariable ["ROOT_EWO_ENERGY", 0];
                private _jobs = _bag getVariable ["ROOT_EWO_CHARGE_JOBS", createHashMap];
                hintSilent format ["EWO backpack energy: %1%2\nActive laptop charging jobs: %3", _energy, "%", count _jobs];
            },
            {
                missionNamespace getVariable [SETTING_EWO_MODE, false]
                && {!isNull (backpackContainer _player)}
                && {(backpackContainer _player) getVariable ["ROOT_EWO_INITIALIZED", false]}
            }
        ] call ace_interact_menu_fnc_createAction;

        [player, 1, ["ACE_SelfActions"], _actionEwoStatus] call ace_interact_menu_fnc_addActionToObject;

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
