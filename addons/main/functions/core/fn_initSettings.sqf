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
    [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_SETUP_MODE"), (localize "STR_ROOT_CYBERWARFARE_UI_SIMPLE_USES_LAPTOP_OBJECT_DIRECTLY_FOR_LOGIC_CHECKING_AND_VERIFICATION_EXPERIMENTAL_USES")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_CORE_SETTINGS")],
    [["SIMPLE", "EXPERIMENTAL"], [(localize "STR_ROOT_CYBERWARFARE_UI_SIMPLE_DEFAULT"), (localize "STR_ROOT_CYBERWARFARE_UI_EXPERIMENTAL_AE3_PORTABLE")], 0],
    1, // mission-level
    {},
    true // requires mission restart
] call CBA_fnc_addSetting;

[
    SETTING_VEHICLE_COST,
    "SLIDER",
    [(localize "STR_ROOT_CYBERWARFARE_UI_VEHICLE_HACKING_POWER_COST"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_IN_WH_CONSUMED_BY_EACH_VEHICLE_HACKING_ACTION_UNLESS_THE_VEHICLE")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 2, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_EWO_MODE,
    "CHECKBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_77TH_JSOC_EWO_MODE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENABLES_EWO_LAPTOP_REGISTRATION_AND_EWO_BACKPACK_SUPPORT")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_EWO_SETTINGS")],
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
    [(localize "STR_ROOT_CYBERWARFARE_UI_EWO_BACKPACK_CLASSNAMES"), (localize "STR_ROOT_CYBERWARFARE_UI_COMMA_SEPARATED_BACKPACK_CLASSNAMES_THAT_BEHAVE_AS_77TH_JSOC_EWO_PACKS_LEAVE")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_EWO_SETTINGS")],
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
    [(localize "STR_ROOT_CYBERWARFARE_UI_EWO_NETWORK_DRAIN"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_PER_MINUTE_AN_EWO_BACKPACK_SPENDS_WHILE_ITS_WIRELESS_NETWORK_IS")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_EWO_SETTINGS")],
    [0, 60, EWO_WIFI_DRAIN_DEFAULT, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_EWO_CHARGE_RATE,
    "SLIDER",
    [(localize "STR_ROOT_CYBERWARFARE_UI_EWO_LAPTOP_CHARGE_RATE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_PER_MINUTE_AN_EWO_BACKPACK_DELIVERS_TO_A_LAPTOP_IT_IS")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_EWO_SETTINGS")],
    [1, 60, EWO_CHARGE_RATE_DEFAULT, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_EWO_RECHARGE_RATE,
    "SLIDER",
    [(localize "STR_ROOT_CYBERWARFARE_UI_EWO_POWER_SOURCE_RECHARGE_RATE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_PER_MINUTE_AN_EWO_BACKPACK_TAKES_IN_FROM_THE_POWER_SOURCE")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_EWO_SETTINGS")],
    [1, 60, EWO_RECHARGE_RATE_DEFAULT, 0],
    1,
    {},
    false
] call CBA_fnc_addSetting;

// Debug Mode Setting
[
    "ROOT_CYBERWARFARE_DEBUG_MODE",
    "CHECKBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_DEBUG_MODE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENABLE_COMPREHENSIVE_LOGGING_TO_RPT_FILE_FOR_TROUBLESHOOTING")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_CORE_SETTINGS")],
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
    [(localize "STR_ROOT_CYBERWARFARE_UI_GPS_TRACKER_POWER_COST"), (localize "STR_ROOT_CYBERWARFARE_UI_ENERGY_IN_WH_CONSUMED_BY_EACH_GPS_TRACKER_PING_UNLESS_THE_TRACKER")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_POWER_CATEGORY"],
    [1, 100, 10, 0], // [min, max, default, decimal places]
    1, // mission-level
    {},
    false // doesn't require mission restart
] call CBA_fnc_addSetting;

// Whether a tracker identifier may only be entered on a laptop that is on a network. On, because a
// code is meant to be worked from a station that is part of a network rather than from any machine
// lying around; a mission that runs no networks at all can turn it off. Server-forced: it decides
// what a code can do, which is a mission-wide rule rather than a per-client preference.
[
    SETTING_GPS_IDENTIFIER_ONLINE,
    "CHECKBOX",
    [localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_IDENTIFIER_ONLINE", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_IDENTIFIER_ONLINE_DESC"],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", localize "STR_ROOT_CYBERWARFARE_SETTING_GPS_CATEGORY"],
    true,
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
    [["ColorBlack", "ColorGrey", "ColorRed", "ColorBrown", "ColorOrange", "ColorYellow", "ColorKhaki", "ColorGreen", "ColorBlue", "ColorPink", "ColorWhite", "ColorWEST", "ColorEAST", "ColorGUER", "ColorCIV", "ColorUNKNOWN"], [(localize "STR_ROOT_CYBERWARFARE_UI_BLACK"), (localize "STR_ROOT_CYBERWARFARE_UI_GREY"), (localize "STR_ROOT_CYBERWARFARE_UI_RED"), (localize "STR_ROOT_CYBERWARFARE_UI_BROWN"), (localize "STR_ROOT_CYBERWARFARE_UI_ORANGE"), (localize "STR_ROOT_CYBERWARFARE_UI_YELLOW"), (localize "STR_ROOT_CYBERWARFARE_UI_KHAKI"), (localize "STR_ROOT_CYBERWARFARE_UI_GREEN"), (localize "STR_ROOT_CYBERWARFARE_UI_BLUE"), (localize "STR_ROOT_CYBERWARFARE_UI_PINK"), (localize "STR_ROOT_CYBERWARFARE_UI_WHITE"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_WEST"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_EAST"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_GUER"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_CIV"), (localize "STR_ROOT_CYBERWARFARE_UI_UNKNOWN")], 2],
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
    [["ColorBlack", "ColorGrey", "ColorRed", "ColorBrown", "ColorOrange", "ColorYellow", "ColorKhaki", "ColorGreen", "ColorBlue", "ColorPink", "ColorWhite", "ColorWEST", "ColorEAST", "ColorGUER", "ColorCIV", "ColorUNKNOWN"], [(localize "STR_ROOT_CYBERWARFARE_UI_BLACK"), (localize "STR_ROOT_CYBERWARFARE_UI_GREY"), (localize "STR_ROOT_CYBERWARFARE_UI_RED"), (localize "STR_ROOT_CYBERWARFARE_UI_BROWN"), (localize "STR_ROOT_CYBERWARFARE_UI_ORANGE"), (localize "STR_ROOT_CYBERWARFARE_UI_YELLOW"), (localize "STR_ROOT_CYBERWARFARE_UI_KHAKI"), (localize "STR_ROOT_CYBERWARFARE_UI_GREEN"), (localize "STR_ROOT_CYBERWARFARE_UI_BLUE"), (localize "STR_ROOT_CYBERWARFARE_UI_PINK"), (localize "STR_ROOT_CYBERWARFARE_UI_WHITE"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_WEST"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_EAST"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_GUER"), (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_CIV"), (localize "STR_ROOT_CYBERWARFARE_UI_UNKNOWN")], 14],
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
    [["SEARCH_MODE", "ALWAYS"], [(localize "STR_ROOT_CYBERWARFARE_UI_SEARCH_MODE_DEFAULT"), (localize "STR_ROOT_CYBERWARFARE_UI_ALWAYS_VISIBLE")], 0],
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
    [(localize "STR_ROOT_CYBERWARFARE_UI_AUTOMATIC_LINK_CLEANUP"), (localize "STR_ROOT_CYBERWARFARE_UI_PERIODICALLY_REMOVE_DEVICE_LINKS_WHOSE_LAPTOP_DEVICE_HAS_BEEN_DELETED_OFF_BY")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_CLEANUP_SETTINGS")],
    false, // default OFF
    1, // mission-level
    {},
    false // read live each pass, no restart needed
] call CBA_fnc_addSetting;

// Automatic Device Link Cleanup - Interval (seconds)
[
    "ROOT_CYBERWARFARE_CLEANUP_TIME",
    "SLIDER",
    [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_CLEANUP_INTERVAL"), (localize "STR_ROOT_CYBERWARFARE_UI_HOW_OFTEN_SECONDS_THE_AUTOMATIC_CLEANUP_RUNS_WHEN_ENABLED")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_CLEANUP_SETTINGS")],
    [30, 3600, 180, 0], // [min, max, default, decimals]
    1, // mission-level
    {},
    false // read live each pass, no restart needed
] call CBA_fnc_addSetting;

// Automatic Device Link Cleanup - Strike grace vs immediate
[
    "ROOT_CYBERWARFARE_CLEANUP_STRIKE_GRACE",
    "CHECKBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_CLEANUP_STRIKE_GRACE"), (localize "STR_ROOT_CYBERWARFARE_UI_ON_RECOMMENDED_A_LINK_IS_ONLY_REMOVED_AFTER_ITS_OBJECT_HAS_BEEN")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_CLEANUP_SETTINGS")],
    true, // default ON (grace)
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Which laptops the curator device dialogs list. Off - the default - a laptop is offered only once a
// mission has made it a hacking station through the Register Hackable Laptop or Add Hacking Tools
// module, so unrelated laptops placed as scenery stay out of the list. On, every laptop on the map is
// offered, including bare ones: a mission can then wire devices during setup and deliver the toolset
// later, because a link handed to a tool-less laptop lies dormant rather than failing and starts
// working the moment the tools arrive.
// Server-forced: this decides what a curator may wire a device to, so a client cannot change it.
[
    SETTING_LIST_ALL_LAPTOPS,
    "CHECKBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_LIST_ALL_LAPTOPS_IN_DEVICE_MODULES"), (localize "STR_ROOT_CYBERWARFARE_UI_LIST_EVERY_LAPTOP_ON_THE_MAP_AS_A_LINK_TARGET_IN_THE")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_CORE_SETTINGS")],
    false, // default OFF - registered stations only
    2, // server-forced; clients cannot overwrite it
    {},
    false // takes effect on the next dialog opened, no restart needed
] call CBA_fnc_addSetting;

// Desktop intro video - whether it plays, and how often it may replay on the same laptop. The cooldown
// exists because a desktop is opened and closed freely and a tools drive can be re-plugged repeatedly;
// zero seconds plays it on every connection.
[
    SETTING_INTRO_VIDEO_ENABLED,
    "CHECKBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_HACKERMAN_INTRO_VIDEO"), (localize "STR_ROOT_CYBERWARFARE_UI_PLAY_THE_HACKERMAN_LOADING_VIDEO_WHEN_A_DESKTOP_IS_OPENED_ON_A")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_DESKTOP_AUDIO_SETTINGS")],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_INTRO_VIDEO_COOLDOWN,
    "SLIDER",
    [(localize "STR_ROOT_CYBERWARFARE_UI_HACKERMAN_INTRO_VIDEO_COOLDOWN"), (localize "STR_ROOT_CYBERWARFARE_UI_MINIMUM_SECONDS_BETWEEN_TWO_PLAYS_OF_THE_HACKERMAN_LOADING_VIDEO_ON_THE")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_DESKTOP_AUDIO_SETTINGS")],
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
    [(localize "STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_CONNECTION_SOUND"), (localize "STR_ROOT_CYBERWARFARE_UI_PLAY_THE_RUBBERDUCKY_SOUND_WHEN_A_RUBBERDUCKY_USB_IS_CONNECTED_TO_OR")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_DESKTOP_AUDIO_SETTINGS")],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_USB_SOUND_ENABLED,
    "CHECKBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_FLASH_DRIVE_CONNECTION_SOUND"), (localize "STR_ROOT_CYBERWARFARE_UI_PLAY_THE_STANDARD_FLASH_DRIVE_SOUND_WHEN_ANY_OTHER_USB_DRIVE_IS")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_DESKTOP_AUDIO_SETTINGS")],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

[
    SETTING_DEVICE_SOUND_VOLUME,
    "SLIDER",
    [(localize "STR_ROOT_CYBERWARFARE_UI_DRIVE_CONNECTION_SOUND_VOLUME"), (localize "STR_ROOT_CYBERWARFARE_UI_LOUDNESS_OF_THE_DRIVE_CONNECT_AND_DISCONNECT_SOUNDS_HIGHER_VALUES_CARRY_FURTHER")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_DESKTOP_AUDIO_SETTINGS")],
    [0, 10, DEVICE_SOUND_VOLUME_DEFAULT, 1],
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Rubberducky Default Credentials - Enable
[
    "ROOT_CYBERWARFARE_RUBBERDUCKY_CREDS_ENABLED",
    "CHECKBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_DEFAULT_LOGIN"), (localize "STR_ROOT_CYBERWARFARE_UI_WHEN_A_RUBBERDUCKY_HACKING_TOOLS_USB_IS_CONNECTED_TO_A_LAPTOP_ADD")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_SETTINGS")],
    true, // default ON
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Rubberducky Default Credentials - Username
[
    "ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_USER",
    "EDITBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_LOGIN_USERNAME"), (localize "STR_ROOT_CYBERWARFARE_UI_USERNAME_OF_THE_ACCOUNT_INJECTED_ON_CONNECT")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_SETTINGS")],
    "quack",
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

// Rubberducky Default Credentials - Password
[
    "ROOT_CYBERWARFARE_RUBBERDUCKY_CRED_PASS",
    "EDITBOX",
    [(localize "STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_LOGIN_PASSWORD"), (localize "STR_ROOT_CYBERWARFARE_UI_PASSWORD_OF_THE_ACCOUNT_INJECTED_ON_CONNECT")],
    [localize "STR_ROOT_CYBERWARFARE_SETTING_CATEGORY", (localize "STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_SETTINGS")],
    "quack",
    1, // mission-level
    {},
    false
] call CBA_fnc_addSetting;

ROOT_CYBERWARFARE_LOG_INFO("CBA settings initialized");
