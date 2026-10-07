#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Description: Localizes a registered device state for display without changing its stored value.
 * Arguments:
 * 0: State <STRING>
 * Return Value: Display text <STRING>
 * Public: No
 */
params [["_state", "", [""]]];

switch (_state) do {
    case "Untracked": { (localize "STR_ROOT_CYBERWARFARE_UI_UNTRACKED") };
    case "Tracking": { (localize "STR_ROOT_CYBERWARFARE_UI_TRACKING") };
    case "Tracked": { (localize "STR_ROOT_CYBERWARFARE_UI_TRACKED") };
    case "Completed": { (localize "STR_ROOT_CYBERWARFARE_UI_COMPLETED") };
    case "Untrackable": { (localize "STR_ROOT_CYBERWARFARE_UI_UNTRACKABLE") };
    case "Disabled": { (localize "STR_ROOT_CYBERWARFARE_UI_DISABLED") };
    case "OFF": { (localize "STR_ROOT_CYBERWARFARE_GUI_STATE_OFF") };
    case "ON": { (localize "STR_ROOT_CYBERWARFARE_GUI_STATE_ON") };
    case "DESTROYED": { (localize "STR_ROOT_CYBERWARFARE_UI_DESTROYED") };
    case "WEST": { (localize "STR_ROOT_CYBERWARFARE_UI_WEST_BLUFOR") };
    case "EAST": { (localize "STR_ROOT_CYBERWARFARE_UI_EAST_OPFOR") };
    case "GUER": { (localize "STR_ROOT_CYBERWARFARE_UI_GUER_INDFOR") };
    case "CIV": { (localize "STR_ROOT_CYBERWARFARE_GUI_SIDE_CIV") };
    default { _state };
};
