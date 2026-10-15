/*
 * Author: Root
 * Description: CBA PreInit Event Handler for Root's Cyberwarfare addon
 *              Executes before mission init to prepare functions and settings
 *
 * Responsibilities:
 * - Precompile all function files via XEH_PREP.hpp
 * - Initialize CBA settings for mission configuration
 * - Set up mod components before mission objects spawn
 *
 * Execution Order: PreInit -> PostInit -> Mission Objects Created
 *
 * Public: No
 */

#include "script_component.hpp"
#include "script_macros.hpp"

// Mark addon as not ready
ADDON = false;

// Precompile all function files for performance
// This uses CBA's PREP macro to compile functions into mission namespace
#include "XEH_PREP.hpp"

// Initialize CBA settings (must be done in PreInit)
// Settings will be available in mission parameters and Zeus menu
call FUNC(initSettings);

// Hacking tools may be brought along into an AE3 SSH session: when the target computer has no tools
// installed, the operator's own copies run against the target (and its device links).
if (!isNil "AE3_armaos_fnc_shell_addSshPortableCommands") then {
    [["guide", "devices", "door", "light", "changedrone", "disabledrone", "download", "custom", "gpstrack", "vehicle", "powergrid", "netscan", "hackssh"], ["/rubberducky/tools"]] call AE3_armaos_fnc_shell_addSshPortableCommands;
};

// Mark addon as ready
ADDON = true;
