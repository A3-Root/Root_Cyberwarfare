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

// Mark addon as ready
ADDON = true;
