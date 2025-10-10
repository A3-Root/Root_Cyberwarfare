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

diag_log format ["[Root Cyber Warfare] Regular Device Cleanup script started! Running periodically every %1 seconds. You can change this value by modifying the 'ROOT_CYBERWARFARE_CLEANUP_TIME' variable. Set the variable value to 0 to disable/stop the clean up.", ROOT_CYBERWARFARE_CLEANUP_TIME];

// Main cleanup loop
while {ROOT_CYBERWARFARE_CLEANUP_TIME != 0} do {
    uiSleep ROOT_CYBERWARFARE_CLEANUP_TIME;
    diag_log "[Root Cyber Warfare] Running periodic device link cleanup...";

    // Get current device links (legacy array structure)
    private _deviceLinks = missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", []];
    private _cleanLinks = [];
    private _removedCount = 0;

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
            diag_log format ["[Root Cyber Warfare] Periodic Cleanup: Removed device links for deleted computer: %1", _computerNetId];
        };
    } forEach _deviceLinks;

    // Update the device links
    missionNamespace setVariable ["ROOT_CYBERWARFARE_DEVICE_LINKS", _cleanLinks, true];

    if (_removedCount > 0) then {
        diag_log format ["[Root Cyber Warfare] Cleanup removed %1 computer links. %2 links active in the server.", _removedCount, count _cleanLinks];
    };

    // Clean up invalid devices from the main device list (legacy array structure)
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], []]];
    private _cleanedDevices = [[], [], [], [], [], []];

    {
        private _deviceList = _allDevices select _forEachIndex;
        private _cleanedList = [];

        // Check each device to see if it still exists
        {
            private _deviceData = _x;
            private _deviceNetId = _deviceData select 1;
            private _deviceObject = objectFromNetId _deviceNetId;

            if (isNull _deviceObject) then {
                diag_log format ["[Root Cyber Warfare] Removing Invalid/Null/Deleted Device: Type %1, NetId %2", _forEachIndex, _deviceNetId];
            } else {
                _cleanedList pushBack _deviceData;
            };
        } forEach _deviceList;

        _cleanedDevices set [_forEachIndex, _cleanedList];
    } forEach _allDevices;

    // Update cleaned device list
    missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _cleanedDevices, true];
};

true
