#include "../../script_component.hpp"
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
    {},
    true // requires mission restart
] call CBA_fnc_addSetting;

// GPS Detection Devices Setting
[
    SETTING_GPS_DETECTION_DEVICES,
    "EDITBOX",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_DETECTION_DEVICES", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_DETECTION_DEVICES_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    "",
    1, // mission-level
    {},
    true // requires mission restart
] call CBA_fnc_addSetting;

// Drone Hacking Power Cost Setting
[
    SETTING_DRONE_HACK_COST,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_DRONE_HACK_COST", localize "STR_ROOT_CYBERWARFARE_SETTING_DRONE_HACK_COST_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [0, 100, 10, 0], // [min, max, default, decimal places]
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
    [0, 100, 20, 0], // [min, max, default, decimal places]
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
    [0, 50, 2, 0], // [min, max, default, decimal places]
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
    [0, 100, 10, 0], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

LOG_INFO("CBA settings initialized");
