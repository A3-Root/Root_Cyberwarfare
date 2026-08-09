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

// Device Setup Mode Setting
[
    "ROOT_CYBERWARFARE_DEVICE_SETUP_MODE",
    "LIST",
    ["Device Setup Mode", "Simple: Uses laptop object directly for logic checking and verification. Experimental: Uses variables for logic checking and verification. Recommened only when using AE3's Experimental Deployment Type"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Core Settings"],
    [["SIMPLE", "EXPERIMENTAL"], ["Simple (Default)", "Experimental (AE3 Portable)"], 0],
    1, // mission-level
    {},
    true // requires mission restart
] call CBA_fnc_addSetting;

[
    SETTING_VEHICLE_COST,
    "SLIDER",
    ["Vehicle Hacking Power Cost", "Energy in Wh consumed by each vehicle hacking action unless the vehicle has a mission-specific cost."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 2, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_EWO_MODE,
    "CHECKBOX",
    ["77th JSOC EWO Mode", "Enables EWO laptop registration and EWO backpack support."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "EWO Settings"],
    false,
    1,
    {},
    false
] call CBA_fnc_addSetting;

// Which backpack classnames are treated as EWO packs. Read by the sync handler on every pass, so a
// mission can point the mode at its own pack without a restart. Broadcast on change because the sync
// handler runs on the server.
[
    SETTING_EWO_BACKPACKS,
    "EDITBOX",
    ["EWO Backpack Classnames", "Comma-separated backpack classnames that behave as 77th JSOC EWO packs. Leave empty to restore the default list."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "EWO Settings"],
    EWO_BACKPACKS_DEFAULT,
    1,
    {
        missionNamespace setVariable [SETTING_EWO_BACKPACKS, _this, true];
    },
    false
] call CBA_fnc_addSetting;

// What a broadcasting network costs the pack, what a laptop on charge takes out of it, and what a
// connected power source puts back in. All three are read per tick, so a mission can retune the pack's
// endurance without touching the code that spends the energy.
[
    SETTING_EWO_WIFI_DRAIN,
    "SLIDER",
    ["EWO Network Drain", "Energy per minute an EWO backpack spends while its wireless network is broadcasting. The pack holds 400 energy."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "EWO Settings"],
    [0, 60, EWO_WIFI_DRAIN_DEFAULT, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_EWO_CHARGE_RATE,
    "SLIDER",
    ["EWO Laptop Charge Rate", "Energy per minute an EWO backpack delivers to a laptop it is charging. One energy raises a laptop battery by one percent."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "EWO Settings"],
    [1, 60, EWO_CHARGE_RATE_DEFAULT, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_EWO_RECHARGE_RATE,
    "SLIDER",
    ["EWO Power Source Recharge Rate", "Energy per minute an EWO backpack takes in from the power source it is connected to."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "EWO Settings"],
    [1, 60, EWO_RECHARGE_RATE_DEFAULT, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

// Debug Mode Setting
[
    "ROOT_CYBERWARFARE_DEBUG_MODE",
    "CHECKBOX",
    ["Debug Mode", "Enable comprehensive logging to RPT file for troubleshooting."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Core Settings"],
    false, // default OFF
    1, // mission-level
    {},
    false // can toggle during mission
] call CBA_fnc_addSetting;

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

// GPS Tracker Ping Power Cost Setting
[
    SETTING_GPS_COST,
    "SLIDER",
    ["GPS Tracker Power Cost", "Energy in Wh consumed by each GPS tracker ping unless the tracker has a mission-specific cost."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 10, 0], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// Power Grid Control Power Cost Setting
[
    SETTING_POWERGRID_COST,
    "SLIDER",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_POWERGRID_COST", localize "STR_ROOT_CYBERWARFARE_SETTING_POWERGRID_COST_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 15, 0], // [min, max, default, decimal places]
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
    [0.01, 1.0, 0.2, 2], // [min, max, default, decimal places]
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
    [0.01, 1.0, 0.8, 2], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Marker Color (Active Ping) Setting
[
    SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE,
    "LIST",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    [["ColorBlack", "ColorGrey", "ColorRed", "ColorBrown", "ColorOrange", "ColorYellow", "ColorKhaki", "ColorGreen", "ColorBlue", "ColorPink", "ColorWhite", "ColorWEST", "ColorEAST", "ColorGUER", "ColorCIV", "ColorUNKNOWN"], ["Black", "Grey", "Red", "Brown", "Orange", "Yellow", "Khaki", "Green", "Blue", "Pink", "White", "BLUFOR", "OPFOR", "Independent", "Civilian", "Unknown"], 2],
    0, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Marker Color (Last Ping) Setting
[
    SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING,
    "LIST",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    [["ColorBlack", "ColorGrey", "ColorRed", "ColorBrown", "ColorOrange", "ColorYellow", "ColorKhaki", "ColorGreen", "ColorBlue", "ColorPink", "ColorWhite", "ColorWEST", "ColorEAST", "ColorGUER", "ColorCIV", "ColorUNKNOWN"], ["Black", "Grey", "Red", "Brown", "Orange", "Yellow", "Khaki", "Green", "Blue", "Pink", "White", "BLUFOR", "OPFOR", "Independent", "Civilian", "Unknown"], 14],
    0, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// GPS Interaction Mode Setting
[
    SETTING_GPS_INTERACTION_MODE,
    "LIST",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_INTERACTION_MODE", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_INTERACTION_MODE_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    [["SEARCH_MODE", "ALWAYS"], ["Search Mode (Default)", "Always Visible"], 0],
    1, // mission-level
    {},
    true // requires mission restart (ACE action conditions are set at init)
] call CBA_fnc_addSetting;

// GPS Interaction Whitelist Setting
[
    SETTING_GPS_INTERACTION_WHITELIST,
    "EDITBOX",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_INTERACTION_WHITELIST", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_INTERACTION_WHITELIST_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    "Car,Tank,Helicopter,Plane,Ship,Motorcycle,Man,House,Building,Lamps_base_F",
    1, // mission-level
    {
        missionNamespace setVariable [SETTING_GPS_INTERACTION_WHITELIST, _this, true];
    },
    true // requires mission restart (ACE actions are added at mission start)
] call CBA_fnc_addSetting;

// Automatic Device Link Cleanup - Enable (OFF by default; admins opt in)
[
    "ROOT_CYBERWARFARE_CLEANUP_ENABLED",
    "CHECKBOX",
    ["Automatic Link Cleanup", "Periodically remove device links whose laptop/device has been deleted. OFF by default - links can always be cleared on demand with the 'Clear Broken Device Links' ZEN module or Root_fnc_clearBrokenDeviceLinks."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Cleanup Settings"],
    false, // default OFF
    1, // mission-level
    {},
    false // read live each pass, no restart needed
] call CBA_fnc_addSetting;

// Automatic Device Link Cleanup - Interval (seconds)
[
    "ROOT_CYBERWARFARE_CLEANUP_TIME",
    "SLIDER",
    ["Link Cleanup Interval", "How often (seconds) the automatic cleanup runs when enabled."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Cleanup Settings"],
    [30, 3600, 180, 0], // [min, max, default, decimals]
    1, // mission-level
    {},
    false // read live each pass, no restart needed
] call CBA_fnc_addSetting;

// Automatic Device Link Cleanup - Strike grace vs immediate
[
    "ROOT_CYBERWARFARE_CLEANUP_STRIKE_GRACE",
    "CHECKBOX",
    ["Link Cleanup Strike Grace", "ON (recommended): a link is only removed after its object has been missing for several consecutive passes, absorbing brief lookup misses right after a player joins. OFF: remove as soon as the object is missing. Only affects the automatic loop; the manual clear always acts immediately."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Cleanup Settings"],
    true, // default ON (grace)
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Which laptops the curator device dialogs list. On, a mission can wire devices to a bare laptop during
// setup and deliver the hacking toolset later, because a link to a tool-less laptop lies dormant rather
// than failing - it starts working the moment the tools arrive. Off, only laptops that are already
// hacking stations can be picked, which suits missions that place unrelated laptops as scenery.
// Server-forced: this decides what a curator may wire a device to, so a client cannot change it.
[
    SETTING_LIST_ALL_LAPTOPS,
    "CHECKBOX",
    ["List All Laptops In Device Modules", "List every laptop on the map as a link target in the Zeus and device modules, including ones with no hacking tools yet. Disable to list only laptops that are already registered stations or already carry the tools."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Core Settings"],
    true, // default ON
    2, // server-forced; clients cannot overwrite it
    {},
    false // takes effect on the next dialog opened, no restart needed
] call CBA_fnc_addSetting;

// Desktop intro video - whether it plays, and how often it may replay on the same laptop. The cooldown
// exists because the video is triggered by a tools drive being mounted, and a drive can be re-plugged
// repeatedly; zero seconds plays it on every mount.
[
    SETTING_INTRO_VIDEO_ENABLED,
    "CHECKBOX",
    ["Hackerman Intro Video", "Play the Hackerman loading video when a hacking-tools drive is connected and the desktop is opened."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Desktop & Audio Settings"],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_INTRO_VIDEO_COOLDOWN,
    "SLIDER",
    ["Hackerman Intro Video Cooldown", "Minimum seconds between two plays of the Hackerman loading video on the same laptop. Set to 0 to play it on every connection."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Desktop & Audio Settings"],
    [0, 3600, ROOT_CYBERWARFARE_INTRO_COOLDOWN, 0],
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Drive connect and disconnect audio. The Rubberducky and the ordinary AE3 flash drives are separate
// toggles so a mission can keep one and silence the other; the volume applies to both.
[
    SETTING_DUCKY_SOUND_ENABLED,
    "CHECKBOX",
    ["Rubberducky Connection Sound", "Play the Rubberducky sound when a Rubberducky USB is connected to or disconnected from a laptop."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Desktop & Audio Settings"],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_USB_SOUND_ENABLED,
    "CHECKBOX",
    ["Flash Drive Connection Sound", "Play the standard flash drive sound when any other USB drive is connected to or disconnected from a laptop."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Desktop & Audio Settings"],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_DEVICE_SOUND_VOLUME,
    "SLIDER",
    ["Drive Connection Sound Volume", "Loudness of the drive connect and disconnect sounds. Higher values carry further from the laptop."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Desktop & Audio Settings"],
    [0, 10, DEVICE_SOUND_VOLUME_DEFAULT, 1],
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Rubberducky Default Credentials - Enable
[
    "ROOT_CYBERWARFARE_RUBBERDUCKY_CREDS_ENABLED",
    "CHECKBOX",
    ["Rubberducky Default Login", "When a Rubberducky/hacking-tools USB is connected to a laptop, add a default login account to that laptop (if one with the same username does not already exist)."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Rubberducky Settings"],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Rubberducky Default Credentials - Username
[
    "ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_USER",
    "EDITBOX",
    ["Rubberducky Login Username", "Username of the account injected on connect."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Rubberducky Settings"],
    "quack",
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Rubberducky Default Credentials - Password
[
    "ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_PASS",
    "EDITBOX",
    ["Rubberducky Login Password", "Password of the account injected on connect."],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", "Rubberducky Settings"],
    "quack",
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

ROOT_CYBERWARFARE_LOG_INFO("CBA settings initialized");
