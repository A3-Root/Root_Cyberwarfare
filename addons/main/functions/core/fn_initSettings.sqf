#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Initializes all CBA settings for Root's Cyber Warfare mod
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call Root_fnc_initSettings;
 *
 * Public: No
 */

// GPS Tracker Device Setting
[
    SETTING_GPS_TRACKER_DEVICE,
    "EDITBOX",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_TRACKER_DEVICE", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_TRACKER_DEVICE_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    "ACE_Banana",
    1, // mission-level
    {
        missionNamespace setVariable [SETTING_GPS_TRACKER_DEVICE, _this, true];
    },
    false // doesn't requires mission restart
] call CBA_fnc_addSetting;

// Drone Hacking Power Cost Setting
[
    SETTING_DRONE_HACK_COST,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_DRONE_HACK_COST", localize "STR_ROOT_CYBERWARFARE_SETTING_DRONE_HACK_COST_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 10, 0], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// Drone Side Change Power Cost Setting
[
    SETTING_DRONE_SIDE_COST,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_DRONE_SIDE_COST", localize "STR_ROOT_CYBERWARFARE_SETTING_DRONE_SIDE_COST_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 20, 0], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// Door Lock/Unlock Power Cost Setting
[
    SETTING_DOOR_COST,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_DOOR_COST", localize "STR_ROOT_CYBERWARFARE_SETTING_DOOR_COST_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 50, 2, 0], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// Custom Device Power Cost Setting
[
    SETTING_CUSTOM_COST,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CUSTOM_COST", localize "STR_ROOT_CYBERWARFARE_SETTING_CUSTOM_COST_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 10, 0], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Spectrum Devices Setting
[
    SETTING_GPS_SPECTRUM_DEVICES,
    "EDITBOX",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_SPECTRUM_DEVICES", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_SPECTRUM_DEVICES_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    "hgun_esd_01_antenna_01_F,hgun_esd_01_antenna_02_F,hgun_esd_01_antenna_03_F,hgun_esd_01_base_F,hgun_esd_01_dummy_F,hgun_esd_01_F",
    1, // mission-level
    {
        missionNamespace setVariable [SETTING_GPS_SPECTRUM_DEVICES, _this, true];
    },
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Search Success Chance (Normal) Setting
[
    SETTING_GPS_SEARCH_CHANCE_NORMAL,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_SEARCH_CHANCE_NORMAL", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_SEARCH_CHANCE_NORMAL_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    [1, 1, 0.2, 2], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Search Success Chance (With Detection Tool) Setting
[
    SETTING_GPS_SEARCH_CHANCE_TOOL,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_SEARCH_CHANCE_TOOL", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_SEARCH_CHANCE_TOOL_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    [1, 1, 0.8, 2], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Marker Color (Active Ping) Setting
[
    SETTING_GPS_MARKER_COLOR_ACTIVE,
    "LIST",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_COLOR_ACTIVE", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_COLOR_ACTIVE_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    [["ColorBlack", "ColorGrey", "ColorRed", "ColorBrown", "ColorOrange", "ColorYellow", "ColorKhaki", "ColorGreen", "ColorBlue", "ColorPink", "ColorWhite", "ColorWEST", "ColorEAST", "ColorGUER", "ColorCIV", "ColorUNKNOWN"], ["Black", "Grey", "Red", "Brown", "Orange", "Yellow", "Khaki", "Green", "Blue", "Pink", "White", "BLUFOR", "OPFOR", "Independent", "Civilian", "Unknown"], 2],
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Marker Color (Last Ping) Setting
[
    SETTING_GPS_MARKER_COLOR_LASTPING,
    "LIST",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_COLOR_LASTPING", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_COLOR_LASTPING_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    [["ColorBlack", "ColorGrey", "ColorRed", "ColorBrown", "ColorOrange", "ColorYellow", "ColorKhaki", "ColorGreen", "ColorBlue", "ColorPink", "ColorWhite", "ColorWEST", "ColorEAST", "ColorGUER", "ColorCIV", "ColorUNKNOWN"], ["Black", "Grey", "Red", "Brown", "Orange", "Yellow", "Khaki", "Green", "Blue", "Pink", "White", "BLUFOR", "OPFOR", "Independent", "Civilian", "Unknown"], 14],
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

LOG_INFO("CBA settings initialized");
