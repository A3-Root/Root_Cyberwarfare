#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Periodically cleans up device links for deleted/invalid computers and devices
 *              Runs as a background task on the server to maintain cache integrity
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

// Exit if not running on server
if (!isServer) exitWith {};

// Only run if not already running
if (missionNamespace getVariable ["ROOT_CYBERWARFARE_CLEANUP_STARTED", false]) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("Device cleanup task already running,aborting duplicate initialization.");
};
if (isNil "ROOT_CYBERWARFARE_CLEANUP_TIME") then { ROOT_CYBERWARFARE_CLEANUP_TIME = 60 };

// Set default cleanup interval (60 seconds)
if (isNil "ROOT_CYBERWARFARE_CLEANUP_TIME") then { ROOT_CYBERWARFARE_CLEANUP_TIME = 60 };

// Get global indices
missionNamespace getVariable ["ROOT_CYBERWARFARE_GPS_TRACKER_INDEX", 1];
missionNamespace getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_INDEX", 1];
missionNamespace getVariable ["ROOT_CYBERWARFARE_VEHICLE_INDEX", 1];

publicVariable "ROOT_CYBERWARFARE_CLEANUP_TIME";

// Get power costs from CBA settings (backwards compatibility with legacy variables)
private _doorCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DOOR_EDIT", 2];
private _droneSideCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT", 20];
private _droneDestructionCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT", 10];
private _customCost = missionNamespace getVariable ["ROOT_CYBERWARFARE_COST_CUSTOM_EDIT", 10];

// Store costs globally (legacy support)
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];

ROOT_CYBERWARFARE_LOG_INFO_1(format ["Regular Device Cleanup script started! Running periodically every %1 seconds. You can change this value by modifying the 'ROOT_CYBERWARFARE_CLEANUP_TIME' variable. Set the variable value to 0 to disable/stop the clean up.",ROOT_CYBERWARFARE_CLEANUP_TIME]);

// Main cleanup loop
[] spawn {
    while {ROOT_CYBERWARFARE_CLEANUP_TIME != 0} do {
        uiSleep ROOT_CYBERWARFARE_CLEANUP_TIME;
        ROOT_CYBERWARFARE_LOG_INFO("Running periodic device link cleanup...");

        // Get current device links (legacy array structure)
        private _deviceLinks = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", []];
        private _cleanLinks = [];
        private _removedCount = 0;

        DEBUG_LOG_1("Cleanup: Checking %1 legacy device links",count _deviceLinks);

        // Clean up deleted computer links
        {
            private _computerNetId = _x select 0;

            private _computer = objectFromNetId _computerNetId;

            // Check if computer still exists and has hacking tools
            if (!isNull _computer && {_computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]}) then {
                _cleanLinks pushBack _x;
            } else {
                // Computer is deleted or no longer has hacking tools
                _removedCount = _removedCount + 1;
                ROOT_CYBERWARFARE_LOG_INFO_1(format ["Periodic Cleanup: Removed device links for deleted computer: %1",_computerNetId]);
                DEBUG_LOG_1("Cleanup: Removed legacy link for netId: %1",_computerNetId);
            };
        } forEach _deviceLinks;

        // Update the device links
        missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", _cleanLinks, true];

        if (_removedCount > 0) then {
            ROOT_CYBERWARFARE_LOG_INFO_2(format ["Cleanup removed %1 computer links. %2 links active in the server.",_removedCount,count _cleanLinks]);
        };

        // Clean up link cache (mode-aware validation)
        private _linkCache = GET_LINK_CACHE;
        private _identifiersToRemove = [];

        DEBUG_LOG_2("Cleanup: Checking %1 link cache entries (Mode: %2)",count keys _linkCache,GET_DEVICE_MODE);

        {
            private _identifier = _x;
            private _isValid = false;

            if (IS_EXPERIMENTAL_MODE) then {
                // Experimental mode: Check if player UID exists
                DEBUG_LOG_1("Cleanup: Validating player UID: %1",_identifier);

                {
                    if (getPlayerUID _x == _identifier) exitWith {
                        _isValid = true;
                        DEBUG_LOG_2("Cleanup: Found player %1 for UID %2",name _x,_identifier);
                    };
                } forEach allPlayers;

                if (!_isValid) then {
                    DEBUG_LOG_1("Cleanup: Player UID %1 no longer exists",_identifier);
                };
            } else {
                // Simple mode: Check if laptop object exists
                DEBUG_LOG_1("Cleanup: Validating laptop netId: %1",_identifier);

                private _computer = objectFromNetId _identifier;
                _isValid = !isNull _computer && {_computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false]};

                if (!_isValid) then {
                    DEBUG_LOG_1("Cleanup: Laptop netId %1 invalid or no hacking tools",_identifier);
                };
            };

            if (!_isValid) then {
                _identifiersToRemove pushBack _identifier;
            };
        } forEach (keys _linkCache);

        // Remove invalid identifiers from cache
        {
            _linkCache deleteAt _x;
            ROOT_CYBERWARFARE_LOG_INFO_1(format ["Periodic Cleanup: Removed link cache for invalid identifier: %1",_x]);
            DEBUG_LOG_1("Cleanup: Removed link cache for identifier: %1",_x);
        } forEach _identifiersToRemove;

        if (_identifiersToRemove isNotEqualTo []) then {
            missionNamespace setVariable [GVAR_LINK_CACHE, _linkCache, true];
            ROOT_CYBERWARFARE_LOG_INFO_2(format ["Cleanup removed %1 link cache entries. %2 entries remain.",count _identifiersToRemove,count keys _linkCache]);
            DEBUG_LOG_2("Cleanup: Removed %1 cache entries, %2 remain",count _identifiersToRemove,count keys _linkCache);
        };

        // Clean up invalid devices from the main device list (legacy array structure)
        private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
        private _cleanedDevices = [[], [], [], [], [], [], [], []];

        {
            private _deviceList = _allDevices select _forEachIndex;
            private _cleanedList = [];

            // Check each device to see if it still exists
            {
                private _deviceData = _x;
                private _deviceNetId = _deviceData select 1;
                private _deviceObject = objectFromNetId _deviceNetId;

                if (isNull _deviceObject) then {
                    ROOT_CYBERWARFARE_LOG_INFO_2(format ["[Root Cyber Warfare] Removing Invalid/Null/Deleted Device: Type %1, NetId %2",_forEachIndex,_deviceNetId]);
                } else {
                    _cleanedList pushBack _deviceData;
                };
            } forEach _deviceList;

            _cleanedDevices set [_forEachIndex, _cleanedList];
        } forEach _allDevices;

        // Update cleaned device list
        missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _cleanedDevices, true];
    };
};

missionNamespace setVariable ["ROOT_CYBERWARFARE_CLEANUP_STARTED", true, true];
true
