// Root_fnc_CleanupDeviceLinks
// Cleans up device links for deleted computers

if (!isServer) exitWith {};

if (isNil "ROOT_CleanupTimer") then { ROOT_CleanupTimer = 60 };
publicVariable "ROOT_CleanupTimer";

diag_log format ["[Root Cyber Warfare] Regular Device Cleanup script started! Running periodically every %1 seconds. You can change this value by modifying the 'ROOT_CleanupTimer' variable. Set the variable value to 0 to disable/stop the clean up.", ROOT_CleanupTimer];

private _doorCost = missionNamespace getVariable ["ROOT_Hack_Door_Cost_Edit", 2];
private _droneSideCost = missionNamespace getVariable ["ROOT_Hack_Drone_Side_Cost_Edit", 20];
private _droneDestructionCost = missionNamespace getVariable ["ROOT_Hack_Drone_Disable_Cost_Edit", 10];
private _customCost = missionNamespace getVariable ["ROOT_Hack_Custom_Cost_Edit", 10];

missionNamespace setVariable ["ROOT-All-Costs", [_doorCost, _droneSideCost, _droneDestructionCost, _customCost], true];

while {ROOT_CleanupTimer != 0} do {
    uiSleep ROOT_CleanupTimer;
    diag_log "[Root Cyber Warfare] Running periodic device link cleanup...";
    private _deviceLinks = missionNamespace getVariable ["ROOT-Device-Links", []];
    private _cleanLinks = [];
    private _removedCount = 0;

    {
        private _computerNetId = _x select 0;
        private _linkedDevices = _x select 1;
        
        private _computer = objectFromNetId _computerNetId;
        
        // Check if computer still exists and has hacking tools
        if (!isNull _computer && {_computer getVariable ["ROOT_HackingTools", false]}) then {
            _cleanLinks pushBack _x;
        } else {
            // Computer is deleted or no longer has hacking tools
            _removedCount = _removedCount + 1;
            diag_log format ["[Root Cyber Warfare] Periodic Cleanup: Removed device links for deleted computer: %1", _computerNetId];
        };
    } forEach _deviceLinks;

    // Update the device links
    missionNamespace setVariable ["ROOT-Device-Links", _cleanLinks, true];

    if (_removedCount > 0) then {
        diag_log format ["[Root Cyber Warfare] Cleanup removed %1 computer links. %2 links active in the server.", _removedCount, count _cleanLinks];
    };

    // Also clean up any invalid devices from the main device list
    private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", [[], [], [], [], []]];
    private _cleanedDevices = [[], [], [], [], []];

    {
        private _deviceType = _x;
        private _deviceList = _allDevices select _forEachIndex;
        private _cleanedList = [];
        
        {
            private _deviceData = _x;
            private _deviceNetId = _deviceData select 1;
            private _deviceObject = objectFromNetId _deviceNetId;
            
            if (!isNull _deviceObject) then {
                _cleanedList pushBack _deviceData;
            } else {
                diag_log format ["[Root Cyber Warfare] Removing Invalid/Null/Deleted Device: Type %1, NetId %2", _forEachIndex, _deviceNetId];
            };
        } forEach _deviceList;
        
        _cleanedDevices set [_forEachIndex, _cleanedList];
    } forEach _allDevices;

    missionNamespace setVariable ["ROOT-All-Devices", _cleanedDevices, true];
};

true