// Root_fnc_disableGPSTrackerServer
// Server-side function to disable GPS tracker globally
// Parameters: [_allDevices, _trackerId]

if (!isServer) exitWith {};

params ["_allDevices", "_trackerId"];

missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", _allDevices, true];

diag_log format ["[Root Cyber Warfare] GPS Tracker ID %1 has been disabled by player search.", _trackerId];

true
