/*
 * Author: Root
 * Description: Macro definitions for Root's Cyberwarfare addon
 *              Provides constants, utility macros, and CBA integration
 *
 * Notes:
 * - Common CBA macros (QUOTE, QGVAR, GVAR, DOUBLES, TRIPLES, FUNC) are imported from CBA via script_mod.hpp
 * - PREFIX is defined in script_mod.hpp
 * - Debug macros are conditionally compiled based on DEBUG_MODE_FULL
 *
 * Public: No
 */

// Note: CBA's script_macros_common.hpp is already included via script_mod.hpp
// QUOTE, QGVAR, GVAR, DOUBLES, TRIPLES, FUNC, PREP are provided by CBA
// PREFIX is defined in script_mod.hpp

// ============================================================================
// Device Type Constants
// ============================================================================
// These constants identify different device types in the cyberwarfare system
// Used for cache lookups, access control, and device operations

#ifndef DEVICE_TYPE_DOOR
    #define DEVICE_TYPE_DOOR 1          // Building doors (lockable)
#endif
#ifndef DEVICE_TYPE_LIGHT
    #define DEVICE_TYPE_LIGHT 2         // Building lights (switchable)
#endif
#ifndef DEVICE_TYPE_DRONE
    #define DEVICE_TYPE_DRONE 3         // UAVs (hackable, faction changeable)
#endif
#ifndef DEVICE_TYPE_DATABASE
    #define DEVICE_TYPE_DATABASE 4      // Database files (downloadable)
#endif
#ifndef DEVICE_TYPE_CUSTOM
    #define DEVICE_TYPE_CUSTOM 5        // Custom scripted devices
#endif
#ifndef DEVICE_TYPE_GPS_TRACKER
    #define DEVICE_TYPE_GPS_TRACKER 6   // GPS tracking devices
#endif
#ifndef DEVICE_TYPE_VEHICLE
    #define DEVICE_TYPE_VEHICLE 7       // Vehicles (alarm, doors, etc.)
#endif
#ifndef DEVICE_TYPE_POWERGRID
    #define DEVICE_TYPE_POWERGRID 8     // Power generators (light control in radius)
#endif

// ============================================================================
// Device Cache Keys
// ============================================================================
// HashMap keys for storing devices by type in the device cache
// Used with GET_DEVICE_CACHE macro for O(1) lookups

#ifndef CACHE_KEY_DOORS
    #define CACHE_KEY_DOORS "doors"
#endif
#ifndef CACHE_KEY_LIGHTS
    #define CACHE_KEY_LIGHTS "lights"
#endif
#ifndef CACHE_KEY_DRONES
    #define CACHE_KEY_DRONES "drones"
#endif
#ifndef CACHE_KEY_DATABASES
    #define CACHE_KEY_DATABASES "databases"
#endif
#ifndef CACHE_KEY_CUSTOM
    #define CACHE_KEY_CUSTOM "custom"
#endif
#ifndef CACHE_KEY_GPS_TRACKERS
    #define CACHE_KEY_GPS_TRACKERS "gpsTrackers"
#endif
#ifndef CACHE_KEY_VEHICLES
    #define CACHE_KEY_VEHICLES "vehicles"
#endif
#ifndef CACHE_KEY_POWERGRIDS
    #define CACHE_KEY_POWERGRIDS "powerGrids"
#endif

// ============================================================================
// CBA Settings Keys
// ============================================================================
// Keys for accessing CBA mission settings
// Settings are configured in fn_initSettings.sqf and accessible via mission params

#ifndef SETTING_GPS_TRACKER_DEVICE
    #define SETTING_GPS_TRACKER_DEVICE "ROOT_CYBERWARFARE_GPS_TRACKER_DEVICE"
#endif
#ifndef SETTING_GPS_DETECTION_DEVICES
    #define SETTING_GPS_DETECTION_DEVICES "ROOT_CYBERWARFARE_GPS_DETECTION_DEVICES"
#endif
#ifndef SETTING_DRONE_HACK_COST
    #define SETTING_DRONE_HACK_COST "ROOT_CYBERWARFARE_DRONE_HACK_COST"
#endif
#ifndef SETTING_DRONE_SIDE_COST
    #define SETTING_DRONE_SIDE_COST "ROOT_CYBERWARFARE_DRONE_SIDE_COST"
#endif
#ifndef SETTING_DOOR_COST
    #define SETTING_DOOR_COST "ROOT_CYBERWARFARE_DOOR_COST"
#endif
#ifndef SETTING_CUSTOM_COST
    #define SETTING_CUSTOM_COST "ROOT_CYBERWARFARE_CUSTOM_COST"
#endif
#ifndef SETTING_POWERGRID_COST
    #define SETTING_POWERGRID_COST "ROOT_CYBERWARFARE_POWERGRID_COST"
#endif
#ifndef SETTING_GPS_SEARCH_CHANCE_NORMAL
    #define SETTING_GPS_SEARCH_CHANCE_NORMAL "ROOT_CYBERWARFARE_GPS_SEARCH_CHANCE_NORMAL"
#endif
#ifndef SETTING_GPS_SEARCH_CHANCE_TOOL
    #define SETTING_GPS_SEARCH_CHANCE_TOOL "ROOT_CYBERWARFARE_GPS_SEARCH_CHANCE_TOOL"
#endif
#ifndef SETTING_GPS_SPECTRUM_DEVICES
    #define SETTING_GPS_SPECTRUM_DEVICES "ROOT_CYBERWARFARE_GPS_SPECTRUM_DEVICES"
#endif
#ifndef SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE
    #define SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE "ROOT_CYBERWARFARE_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_ACTIVE"
#endif
#ifndef SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING
    #define SETTING_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING "ROOT_CYBERWARFARE_GPS_MARKER_ROOT_CYBERWARFARE_COLOR_LASTPING"
#endif
#ifndef SETTING_GPS_INTERACTION_WHITELIST
    #define SETTING_GPS_INTERACTION_WHITELIST "ROOT_CYBERWARFARE_GPS_INTERACTION_WHITELIST"
#endif
#ifndef SETTING_GPS_INTERACTION_MODE
    #define SETTING_GPS_INTERACTION_MODE "ROOT_CYBERWARFARE_GPS_INTERACTION_MODE"
#endif

// ============================================================================
// Global Variable Keys
// ============================================================================
// Keys for accessing global hashmaps and arrays in missionNamespace

#ifndef GVAR_DEVICE_CACHE
    #define GVAR_DEVICE_CACHE "ROOT_CYBERWARFARE_DEVICE_CACHE"      // HashMap of all devices by type
#endif
#ifndef GVAR_LINK_CACHE
    #define GVAR_LINK_CACHE "ROOT_CYBERWARFARE_LINK_CACHE"          // HashMap of computer->device links
#endif
#ifndef GVAR_PUBLIC_DEVICES
    #define GVAR_PUBLIC_DEVICES "ROOT_CYBERWARFARE_PUBLIC_DEVICES"  // Array of publicly accessible devices
#endif

// ============================================================================
// Debug Logging Macros
// ============================================================================
// Runtime debug logging controlled by CBA setting ROOT_CYBERWARFARE_DEBUG_MODE
// Logs to RPT file with file name and formatted message

// Check if debug mode is enabled (runtime check)
#ifndef DEBUG_MODE
    #define DEBUG_MODE (missionNamespace getVariable ["ROOT_CYBERWARFARE_DEBUG_MODE", false])
#endif

// Debug logging macros - only log if DEBUG_MODE is enabled
#ifndef DEBUG_LOG
    #define DEBUG_LOG(msg) \
        if (DEBUG_MODE) then { \
            diag_log format ["[ROOT_CW] %1 | %2", __FILE__, msg]; \
        }
#endif

#ifndef DEBUG_LOG_1
    #define DEBUG_LOG_1(msg,arg1) \
        if (DEBUG_MODE) then { \
            diag_log format ["[ROOT_CW] %1 | " + msg, __FILE__, arg1]; \
        }
#endif

#ifndef DEBUG_LOG_2
    #define DEBUG_LOG_2(msg,arg1,arg2) \
        if (DEBUG_MODE) then { \
            diag_log format ["[ROOT_CW] %1 | " + msg, __FILE__, arg1, arg2]; \
        }
#endif

#ifndef DEBUG_LOG_3
    #define DEBUG_LOG_3(msg,arg1,arg2,arg3) \
        if (DEBUG_MODE) then { \
            diag_log format ["[ROOT_CW] %1 | " + msg, __FILE__, arg1, arg2, arg3]; \
        }
#endif

#ifndef DEBUG_LOG_4
    #define DEBUG_LOG_4(msg,arg1,arg2,arg3,arg4) \
        if (DEBUG_MODE) then { \
            diag_log format ["[ROOT_CW] %1 | " + msg, __FILE__, arg1, arg2, arg3, arg4]; \
        }
#endif

// Legacy debug macros (kept for compatibility, but deprecated)
#ifdef DEBUG_MODE_FULL
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG
        #define ROOT_CYBERWARFARE_LOG_DEBUG(msg) diag_log text format ["[ROOT_CYBERWARFARE DEBUG] %1", msg]
    #endif
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG_1
        #define ROOT_CYBERWARFARE_LOG_DEBUG_1(msg,arg1) diag_log text format ["[ROOT_CYBERWARFARE DEBUG] " + msg, arg1]
    #endif
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG_2
        #define ROOT_CYBERWARFARE_LOG_DEBUG_2(msg,arg1,arg2) diag_log text format ["[ROOT_CYBERWARFARE DEBUG] " + msg, arg1, arg2]
    #endif
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG_3
        #define ROOT_CYBERWARFARE_LOG_DEBUG_3(msg,arg1,arg2,arg3) diag_log text format ["[ROOT_CYBERWARFARE DEBUG] " + msg, arg1, arg2, arg3]
    #endif
#else
    // No-op when debug disabled
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG
        #define ROOT_CYBERWARFARE_LOG_DEBUG(msg)
    #endif
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG_1
        #define ROOT_CYBERWARFARE_LOG_DEBUG_1(msg,arg1)
    #endif
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG_2
        #define ROOT_CYBERWARFARE_LOG_DEBUG_2(msg,arg1,arg2)
    #endif
    #ifndef ROOT_CYBERWARFARE_LOG_DEBUG_3
        #define ROOT_CYBERWARFARE_LOG_DEBUG_3(msg,arg1,arg2,arg3)
    #endif
#endif

// Error and info logging (always enabled)
#ifndef ROOT_CYBERWARFARE_LOG_ERROR
    #define ROOT_CYBERWARFARE_LOG_ERROR(msg) diag_log text format ["[ROOT_CYBERWARFARE ERROR] %1", msg]
#endif
#ifndef ROOT_CYBERWARFARE_LOG_ERROR_1
    #define ROOT_CYBERWARFARE_LOG_ERROR_1(msg,arg1) diag_log text format ["[ROOT_CYBERWARFARE ERROR] " + msg, arg1]
#endif
#ifndef ROOT_CYBERWARFARE_LOG_ERROR_2
    #define ROOT_CYBERWARFARE_LOG_ERROR_2(msg,arg1,arg2) diag_log text format ["[ROOT_CYBERWARFARE ERROR] " + msg, arg1, arg2]
#endif

#ifndef ROOT_CYBERWARFARE_LOG_INFO
    #define ROOT_CYBERWARFARE_LOG_INFO(msg) diag_log text format ["[ROOT_CYBERWARFARE INFO] %1", msg]
#endif
#ifndef ROOT_CYBERWARFARE_LOG_INFO_1
    #define ROOT_CYBERWARFARE_LOG_INFO_1(msg,arg1) diag_log text format ["[ROOT_CYBERWARFARE INFO] " + msg, arg1]
#endif
#ifndef ROOT_CYBERWARFARE_LOG_INFO_2
    #define ROOT_CYBERWARFARE_LOG_INFO_2(msg,arg1,arg2) diag_log text format ["[ROOT_CYBERWARFARE INFO] " + msg, arg1, arg2]
#endif
#ifndef ROOT_CYBERWARFARE_LOG_INFO_3
    #define ROOT_CYBERWARFARE_LOG_INFO_3(msg,arg1,arg2,arg3) diag_log text format ["[ROOT_CYBERWARFARE INFO] " + msg, arg1, arg2, arg3]
#endif

// ============================================================================
// Validation Macros
// ============================================================================
// Quick validation checks for common operations

// Validates that a computer object exists and has hacking tools installed
#ifndef VALIDATE_COMPUTER
    #define VALIDATE_COMPUTER(computer) (!isNull computer && computer getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false])
#endif

// Validates that a device type number is within valid range (1-8)
#ifndef VALIDATE_DEVICE_TYPE
    #define VALIDATE_DEVICE_TYPE(type) (type >= DEVICE_TYPE_DOOR && type <= DEVICE_TYPE_POWERGRID)
#endif

// ============================================================================
// Device Setup Mode Macros
// ============================================================================
// Macros for checking the current device setup mode (Simple vs Experimental)
// Simple: Uses laptop object netId for link cache (default)
// Experimental: Uses player UID for link cache (supports AE3 portable laptops)

// Get current device setup mode
#ifndef GET_DEVICE_MODE
    #define GET_DEVICE_MODE (missionNamespace getVariable ["ROOT_CYBERWARFARE_DEVICE_SETUP_MODE", "SIMPLE"])
#endif

// Check if experimental mode is enabled
#ifndef IS_EXPERIMENTAL_MODE
    #define IS_EXPERIMENTAL_MODE (GET_DEVICE_MODE == "EXPERIMENTAL")
#endif

// ============================================================================
// Power Conversion Macros
// ============================================================================
// Convert between Watt-hours (Wh) and Kilowatt-hours (kWh)
// Power costs are configured in Wh, battery levels stored in kWh

#ifndef WH_TO_KWH
    #define WH_TO_KWH(wh) (wh / 1000)
#endif
#ifndef KWH_TO_WH
    #define KWH_TO_WH(kwh) (kwh * 1000)
#endif

// ============================================================================
// Common Cache Access Macros
// ============================================================================
// Fast access to global hashmaps with default fallback values

// Get device cache hashmap (or create empty one if not exists)
#ifndef GET_DEVICE_CACHE
    #define GET_DEVICE_CACHE (missionNamespace getVariable [GVAR_DEVICE_CACHE, createHashMap])
#endif

// Get link cache hashmap (or create empty one if not exists)
#ifndef GET_LINK_CACHE
    #define GET_LINK_CACHE (missionNamespace getVariable [GVAR_LINK_CACHE, createHashMap])
#endif

// Get public devices array (or empty array if not exists)
#ifndef GET_PUBLIC_DEVICES
    #define GET_PUBLIC_DEVICES (missionNamespace getVariable [GVAR_PUBLIC_DEVICES, []])
#endif

// ============================================================================
// Color Codes for Terminal Output
// ============================================================================
// HTML color codes for AE3 ArmaOS terminal output formatting

#ifndef ROOT_CYBERWARFARE_COLOR_SUCCESS
    #define ROOT_CYBERWARFARE_COLOR_SUCCESS "#8ce10b"     // Green - success messages
#endif
#ifndef ROOT_CYBERWARFARE_COLOR_ERROR
    #define ROOT_CYBERWARFARE_COLOR_ERROR "#fa4c58"       // Red - error messages
#endif
#ifndef ROOT_CYBERWARFARE_COLOR_WARNING
    #define ROOT_CYBERWARFARE_COLOR_WARNING "#FFD966"     // Yellow - warning messages
#endif
#ifndef ROOT_CYBERWARFARE_COLOR_INFO
    #define ROOT_CYBERWARFARE_COLOR_INFO "#008DF8"        // Blue - informational messages
#endif
#ifndef ROOT_CYBERWARFARE_COLOR_NEUTRAL
    #define ROOT_CYBERWARFARE_COLOR_NEUTRAL "#BCBCBC"     // Gray - neutral text
#endif

// Side-specific colors (matches Arma 3 UI conventions)
#ifndef ROOT_CYBERWARFARE_COLOR_SIDE_WEST
    #define ROOT_CYBERWARFARE_COLOR_SIDE_WEST "#008DF8"   // Blue - BLUFOR/NATO
#endif
#ifndef ROOT_CYBERWARFARE_COLOR_SIDE_EAST
    #define ROOT_CYBERWARFARE_COLOR_SIDE_EAST "#FA4C58"   // Red - OPFOR/CSAT
#endif
#ifndef ROOT_CYBERWARFARE_COLOR_SIDE_GUER
    #define ROOT_CYBERWARFARE_COLOR_SIDE_GUER "#8CE10B"   // Green - Independent/AAF
#endif
#ifndef ROOT_CYBERWARFARE_COLOR_SIDE_CIV
    #define ROOT_CYBERWARFARE_COLOR_SIDE_CIV "#FFD966"    // Yellow - Civilian
#endif
