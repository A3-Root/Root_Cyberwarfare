#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Publishes the RootCW operator guide as an AE3 Browser page.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * <BOOLEAN> - True when the registration request was sent
 *
 * Public: No
 */

if (isNil "AE3_desktop_fnc_registerWebpage") exitWith {false};

[
	"hackerman.ez",
	"Cyberwarfare Guide",
	[
		"<t size='1.2'>Cyberwarfare Guide</t>",
		"",
		"<t color='#E67E22'>Terminal Management</t>",
		"history - Show commands entered in this session.",
		"help - List available commands.",
		"man [command] - Read command details.",
		"reboot - Restart the terminal process.",
		"exit - Close the terminal interface.",
		"",
		"<t color='#E67E22'>Discovery</t>",
		"devices - List networked systems available to this laptop.",
		"devices files - List accessible file servers.",
		"devices vehicles - List accessible vehicles.",
		"devices gps - List accessible GPS trackers.",
		"",
		"<t color='#E67E22'>Files</t>",
		"download [DatabaseID] - Download a file from an accessible database.",
		"Downloaded files are saved to the selected path in the laptop filesystem.",
		"",
		"<t color='#E67E22'>Vehicles</t>",
		"vehicle [VehicleID] battery [value] - Reduce fuel or battery level.",
		"vehicle [VehicleID] speed [km/h] - Move toward the target speed over five seconds.",
		"vehicle [VehicleID] brakes apply - Apply braking with the configured deceleration limits.",
		"vehicle [VehicleID] lights [on|off] - Toggle vehicle lights.",
		"vehicle [VehicleID] engine [on|off] - Toggle the engine.",
		"vehicle [VehicleID] alarm [seconds] - Trigger the alarm.",
		"",
		"<t color='#E67E22'>GPS Tracking</t>",
		"gpstrack [GPSID] - Track a networked GPS signal.",
		"Tracker states: Untracked, Tracking, Tracked, Completed, Untrackable, Dead.",
		"",
		"<t color='#E67E22'>Power Grid</t>",
		"powergrid [PowerGridID] [on|off|overload] - Control a configured generator and affected lights.",
		"",
		"<t color='#E67E22'>Custom Devices</t>",
		"custom [DeviceID] [activate|deactivate] - Run the configured device action.",
		"",
		"<t color='#E67E22'>Notes</t>",
		"Actions consume laptop power before changing connected systems.",
		"Use command help before running unfamiliar commands."
	]
] call AE3_desktop_fnc_registerWebpage;

true
