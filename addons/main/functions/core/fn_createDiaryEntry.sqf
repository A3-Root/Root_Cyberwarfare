/*
 * Author: Root
 * Description: Creates a diary entry in the player's map with a cyberwarfare terminal cheat sheet
 *              Provides command reference and usage examples for all hacking commands
 *
 * Arguments:
 * None
 *
 * Return Value:
 * <BOOLEAN> - Always returns true
 *
 * Example:
 * call Root_fnc_createDiaryEntry;
 *
 * Public: No
 */

// Exit if running on dedicated server (no player to create diary for)
if (!hasInterface) exitWith {};

// Create Cyberwarfare Terminal subject
player createDiarySubject [
	"CyberTerminal", 
	"Cyberwarfare Guide", 
	""
];

// =======================================================================
// SECTION 14: TERMINAL MANAGEMENT
// =======================================================================
private _diaryTerminal = player createDiaryRecord [
	"CyberTerminal",
	["Terminal Management",
	"<font color='#E67E22' size='14' face='PuristaBold'>INTERFACE CONTROL</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	These commands control the terminal interface and its local process state.
	They do not directly change external systems unless specified by other commands.<br/><br/>

	<font color='#3498DB'>Common Commands</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	history     // Show previously executed commands in this session<br/>
	exit        // Close the terminal interface (returns to game view)<br/>
	reboot    // Restart the terminal process (may reset session state)<br/>
	help       // List available commands or 'man [command]' for details
	</font><br/><br/>

	<font color='#3498DB'>Examples</font><br/>
	<font color='#CCCCCC' face='EtelkaMonospacePro'>
	history  // Review what you entered during the session<br/>
	man download // Read the manual entry for the download command<br/>
	reboot   // Restart terminal if commands behave unexpectedly
	</font><br/><br/>

	<font color='#3498DB'>Beginner Tips</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	• Use <font color='#FFFFFF'>cat guide</font> or <font color='#FFFFFF'>help</font> or <font color='#FFFFFF'>man [command]</font> before attempting unfamiliar commands.<br/>
	• You can press <font color='#FFFFFF'>Control + C</font> at anytime to stop or exit from an operation provided it has not been executed.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 13: GPS OPERATIONS
// =======================================================================
private _diaryGPSTrack = player createDiaryRecord [
	"CyberTerminal",
	["GPS Tracking",
	"<font color='#E67E22' size='14' face='PuristaBold'>GPS TRACKING</font><br/><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>gpstrack</font> command queries the location state of networked GPS devices.
	Use this to locate friendly, neutral, or enemy trackers exposed to the terminal.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	gpstrack [GPSID]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	gpstrack 1231   // Query GPS device 1231<br/>
	gpstrack 9912   // Query GPS device 9912<br/><br/>

	<font color='#3498DB'>Possible GPS states:</font><br/>
	Untracked      - Available for tracking (never tracked)<br/>
	Tracked        - Previously tracked (location saved)<br/>
	Tracking       - Tracking currently in progress (live update)<br/>
	Untrackable    - Cannot be tracked again (mission logic)<br/>
	Completed      - Tracking completed; no further updates expected<br/>
	Dead           - GPS not found or device destroyed/unresponsive<br/><br/>

	<font color='#3498DB'>Tips:</font><br/>
	• Run <font color='#FFFFFF'>devices gps</font> to list available GPSIDs before tracking.<br/>
	• Tracking reveals coordinates on map as a mildot with the name of the tracker and updates depending on the ping frequency.<br/>
	</font>"],
	taskNull,
	"",
	false
];

// =======================================================================
// SECTION 12: DATA OPERATIONS
// =======================================================================
private _diaryData = player createDiaryRecord [
	"CyberTerminal",
	["Download File Operations",
	"<font color='#E67E22' size='14' face='PuristaBold'>INFORMATION MANAGEMENT</font><br/><br/>
	<font color='#3498DB' face='PuristaSemibold'>File Operations</font><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>download</font> command allows you to retrieve files from remote storage nodes.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	download [FileID]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	download 1523  // Downloads the file having the ID 1523<br/><br/>

	<font color='#3498DB'>Beginner Tips</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	• Use <font color='#FFFFFF'>devices files</font> to discover available file nodes and FileIDs.<br/>
	• Run <font color='#FFFFFF'>download [FileID]</font> to download the file.<br/>
	• Downloaded files are stored inside the 'Files' folder from where the download was executed.<br/>
	• You may have to exit and re-enter the terminal if the Folder does not exist.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 11: VEHICLE OPERATIONS
// =======================================================================
private _diaryVehicles = player createDiaryRecord [
	"CyberTerminal",
	["Vehicle Control",
	"<font color='#E67E22' size='14' face='PuristaBold'>VEHICLE INTERFACE</font><br/><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>vehicle</font> command lets the operator modify network-linked vehicle systems.
	Use it to inspect or change battery level, speed limit, brakes, lights, engine state, and alarm timers.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	vehicle [VehicleID] [action] [value]<br/><br/>

	<font color='#3498DB'>Actions and values:</font><br/>
	battery [0-100]   // Set battery percentage<br/>
	speed [number]    // Set maximum speed or speed limit<br/>
	brakes [on/off]   // Engage or release electronic brakes<br/>
	lights [on/off]   // Toggle vehicle lights<br/>
	engine [on/off]   // Start or stop engine remotely<br/>
	alarm [seconds]   // Trigger alarm for specified seconds<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	vehicle 1231 battery 20   // Set vehicle 1231 battery to 20%<br/>
	vehicle 5121 alarm 14     // Trigger 14s alarm on vehicle 5121<br/>
	vehicle 5125 brakes on    // Engage brakes on vehicle 5125<br/>
	vehicle 1512 lights off   // Turn off lights on vehicle 1512<br/>
	vehicle 9952 speed 12     // Limit vehicle 9952 to speed 12<br/>
	vehicle 2315 engine off   // Stop engine of vehicle 2315<br/><br/>

	<font color='#E74C3C'>CAUTION:</font><br/>
	• Commands may affect AI and player control of the vehicle.<br/>
	• Overwriting settings may cause mission issues. Verify VehicleID with <font color='#FFFFFF'>devices vehicles</font> first.<br/>
	• Use conservative values when testing.</font>"],
	taskNull,
	"",
	false
];

// =======================================================================
// SECTION 10: DRONE OPERATIONS
// =======================================================================
private _diaryDrones = player createDiaryRecord [
	"CyberTerminal",
	["Drone Operations",
	"<font color='#E67E22' size='14' face='PuristaBold'>UAV CONTROL SYSTEMS</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>changedrone</font> and <font color='#3498DB'>disabledrone</font> commands
	control unmanned aerial vehicles (UAVs) connected to the network.<br/><br/>

	These functions are used for electronic warfare, capture of enemy drones,
	or emergency deactivation of compromised assets.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	changedrone [DroneID] [side]<br/>
	disabledrone [DroneID]<br/><br/>

	<font color='#3498DB'>Common Parameters:</font><br/>
	east    // Assign to OPFOR faction<br/>
	west    // Assign to BLUFOR faction<br/>
	guer    // Assign to INDFOR faction<br/>
	civ    // Assign to Civilian faction<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	changedrone 2 east // Force drone ID 2 to enemy control<br/>
	disabledrone 2  // Shut down drone ID 2<br/>
	disabledrone a  // Shut down all networked drones<br/><br/>

	<font color='#3498DB'>Tips for Beginners:</font><br/>
	• Run <font color='#FFFFFF'>devices drones</font> to find available targets first.<br/>
	• Only one drone may respond to a command if multiple share the same ID.<br/>
	• Changing allegiance can alter AI behavior instantly — verify before engaging.<br/>
	• Deactivation (<font color='#FFFFFF'>disabledrone</font>) overloads the drone causing it to explode and as such, cannot be undone unless restarted.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 9: POWER GRID CONTROL
// =======================================================================
private _diaryPowerGrid = player createDiaryRecord [
	"CyberTerminal",
	["Power Generator Control",
	"<font color='#E67E22' size='14' face='PuristaBold'>POWER GRID MANAGEMENT</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>powergrid</font> command allows you to control power generators that supply electricity to lighting systems within a defined radius.
	Use this to disable entire sectors or restore power to areas.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	powergrid [PowerGridID] [action]<br/><br/>

	<font color='#3498DB'>Common Actions:</font><br/>
	activate      // Turn on the power generator<br/>
	deactivate    // Turn off the power generator<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	powergrid 1234 activate    // Power on generator 1234<br/>
	powergrid 5678 deactivate  // Cut power to generator 5678<br/>
	powergrid a deactivate     // Shut down all accessible power grids<br/><br/>

	<font color='#3498DB'>Beginner Tips:</font><br/>
	• Use <font color='#FFFFFF'>devices powergrids</font> to list available power generators.<br/>
	• Power generators control all lights within their configured radius.<br/>
	• Some generators may trigger explosions when activated or deactivated.<br/>
	• Deactivating a generator will turn off all lights in its coverage area.<br/>
	• Power grids are different from individual lights — they control infrastructure.<br/><br/>

	<font color='#E74C3C'>CAUTION:</font><br/>
	• Some power generators are mission-critical — verify before deactivating.<br/>
	• Explosion-enabled generators can cause collateral damage to nearby units.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 7: LIGHTING CONTROL
// =======================================================================
private _diaryLights = player createDiaryRecord [
	"CyberTerminal",
	["Lighting Control",
    "<font color='#E67E22' size='14' face='PuristaBold'>ENVIRONMENTAL LIGHTING SYSTEMS</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>light</font> command lets you control linked lighting systems in the environment.
	Use this to turn lights on or off for tactical advantage or concealment.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	light [LightID] [action]<br/><br/>

	<font color='#3498DB'>Common Actions:</font><br/>
	on      // Turn lights on<br/>
	off     // Turn lights off<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	light a on  // Switch on all available lights<br/>
	light 3 off // Turn off light number 3<br/><br/>

	<font color='#3498DB'>Tips for Beginners:</font><br/>
	• Run <font color='#FFFFFF'>devices lights</font> to identify which light IDs exist nearby.<br/>
	• Actions apply instantly — use caution if operating near hostiles.<br/>
	• If the command has no visible effect, the light may be destroyed or not network-linked.<br/>
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 6: DOOR CONTROL
// =======================================================================
private _diaryDoors = player createDiaryRecord [
	"CyberTerminal",
	["Door Control",
	"<font color='#E67E22' size='14' face='PuristaBold'>ACCESS CONTROL SYSTEMS</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>door</font> command allows you to lock or unlock electronically controlled doors in buildings.
	This can be used for infiltration, containment, or security lockdowns.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	door [BuildingID] [DoorID] [action]<br/><br/>

	<font color='#3498DB'>Common Actions:</font><br/>
	lock      // Secure the door<br/>
	unlock    // Release the lock<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	door 4514 2 lock    // Lock door number 2 in building 4514<br/>
	door 4514 a unlock // Unlock all access points in that building<br/><br/>

	<font color='#3498DB'>Additional Command:</font><br/>
	doorstatus [BuildingID] // Displays door state summary (locked/unlocked)<br/><br/>

	<font color='#3498DB'>Tips for Beginners:</font><br/>
	• Run <font color='#FFFFFF'>devices doors</font> first to find valid BuildingIDs.<br/>
	• Each building and door combination is unique — check the output carefully.<br/>
	• If a command fails, ensure you used lowercase and proper spacing.<br/>
	• Locked doors may restrict both players and AI — use responsibly.
	• Locking doors does NOT close it. It keeps the current state of the door (opened / closed) locked from being switched.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 5: DEVICE DISCOVERY
// =======================================================================
private _diaryDevices = player createDiaryRecord [
	"CyberTerminal",
	["Device Discovery",
	"<font color='#E67E22' size='14' face='PuristaBold'>NETWORK DEVICE SCANNING</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>devices</font> command is used to search for and list all electronic systems
	that can be accessed or controlled through the cyberwarfare terminal.<br/><br/>
	This includes doors, lighting, drones, GPS systems, vehicles, and any custom mission-specific network-enabled units.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	devices [filter]<br/><br/>

	<font color='#3498DB'>Available Filters:</font><br/>
	all     // Show all connected devices<br/>
	doors  // List access control systems (buildings and locks)<br/>
	lights // List environmental lighting units<br/>
	drones // Show unmanned aerial vehicles<br/>
	files  // Display storage or data access nodes<br/>
	gps   // Detect GPS trackers and signal relays<br/>
	vehicles // Identify vehicles with cyber interface modules<br/>
	custom // Scan for mission-specific scripted objects<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	devices all    // List every device currently available to this system<br/>
	devices drones // Show only UAVs controlled by the system<br/><br/>

	<font color='#3498DB'>Tips for Beginners:</font><br/>
	• Always start with <font color='#FFFFFF'>devices all</font> to get a full overview of available systems.<br/>
	• If a category returns no results, it means no compatible targets are nearby.<br/>
	• Scanning does not affect gameplay — it only gathers information.<br/>
	• Device IDs shown in scan results are used by other commands (like <font color='#FFFFFF'>door</font> or <font color='#FFFFFF'>light</font>).
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 4: SYSTEM NAVIGATION
// =======================================================================
private _diaryNavigation = player createDiaryRecord [
	"CyberTerminal",
	["System Navigation",
	"<font color='#E67E22' size='14' face='PuristaBold'>DIRECTORY OPERATIONS</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	This section covers how to move between folders, view contents, copy, move, and remove files using the terminal.<br/>
	Read carefully before using destructive commands.<br/><br/>

	<font color='#3498DB' face='PuristaSemibold'>1. CHANGE DIRECTORY</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	Use the <font color='#3498DB'>cd</font> command to move between directories (folders).<br/><br/>

	<font color='#3498DB'>Syntax:</font> cd [directory_name]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	cd tools      // Enter the 'tools' folder<br/>
	cd ..         // Go up one level<br/>
	cd /          // Go to the root directory<br/>
	cd /rubberducky/tools // Jump directly to a full path<br/><br/>

	<font color='#3498DB'>Tips:</font><br/>
	• Folder names are case-sensitive.<br/>
	• Use <font color='#FFFFFF'>ls</font> first to see what directories exist.<br/>
	• A successful <font color='#FFFFFF'>cd</font> command produces no output — the terminal path simply changes.<br/><br/>

	<font color='#3498DB' face='PuristaSemibold'>2. LIST CONTENTS</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>ls</font> command displays files and folders in the current directory.<br/><br/>

	<font color='#3498DB'>Syntax:</font> ls [options]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	ls        // List visible files<br/>
	ls -a     // Include hidden files<br/>
	ls -l     // Show file sizes and details<br/>
	ls -la    // Combined detailed + hidden view<br/><br/>

	<font color='#3498DB' face='PuristaSemibold'>3. COPY FILES</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>cp</font> command duplicates a file from one location to another.<br/><br/>

	<font color='#3498DB'>Syntax:</font> cp [source] [destination]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	cp readme.txt /Files/    // Copy 'readme.txt' into /Files directory<br/>
	cp /data/log.txt /backup/log.txt // Copy file to a backup location<br/><br/>

	<font color='#3498DB'>Tips:</font><br/>
	• Use absolute paths when copying across directories.<br/>
	• If a file with the same name exists at destination, it will be overwritten.<br/>
	• Always verify the path before executing the command.<br/><br/>

	<font color='#3498DB' face='PuristaSemibold'>4. MOVE OR RENAME FILES</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>mv</font> command moves files or renames them in place.<br/>
	Moving removes the file from the source directory after placing it in the new location.<br/><br/>

	<font color='#3498DB'>Syntax:</font> mv [source] [destination]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	mv report.txt /data/    // Move 'report.txt' into /data<br/>
	mv oldname.txt newname.txt // Rename 'oldname.txt' to 'newname.txt'<br/><br/>

	<font color='#3498DB'>Tips:</font><br/>
	• Works similarly to <font color='#FFFFFF'>cp</font> but removes the original file afterward.<br/>
	• Be careful when renaming — the old filename will no longer exist.<br/>
	• Useful for organizing files without creating duplicates.<br/><br/>

	<font color='#3498DB' face='PuristaSemibold'>5. REMOVE FILES (PERMANENT)</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>rm</font> command permanently deletes a file or folder. <font color='#E74C3C'>Use extreme caution.</font><br/>
	This action cannot be undone.<br/><br/>

	<font color='#3498DB'>Syntax:</font> rm [file_or_directory]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	rm temp.txt       // Delete a single file<br/>
	rm -r oldlogs   // Recursively delete a folder and its contents<br/><br/>

	<font color='#E74C3C' face='PuristaBold'>⚠ •••CAUTION•••</font><br/>
	• Files deleted with <font color='#FFFFFF'>rm</font> cannot be recovered.<br/>
	• Use <font color='#FFFFFF'>ls</font> first to confirm target name and location.<br/>
	• Avoid using <font color='#FFFFFF'>rm -r</font> unless absolutely necessary.<br/>
	• Never run <font color='#FFFFFF'>rm *</font> — this removes everything in the current directory.<br/>
	• Always verify directory paths before executing deletion commands.<br/><br/>
    
    <font color='#3498DB' face='PuristaSemibold'>6. VIEW FILES</font><br/>
    <font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>cat</font> command opens and displays the content of a text file inside the terminal window.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	cat [filename]<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	cat guide     // Show contents of 'guide' file<br/>
	cat logs.txt  // Display the full mission log file<br/>
	cat /Files/config.cfg // View a file in another directory<br/><br/>

	<font color='#3498DB'>Tips for Beginners:</font><br/>
	• Use <font color='#FFFFFF'>ls</font> to confirm the file exists before using <font color='#FFFFFF'>cat</font>.<br/>
	• Text will appear directly in your terminal — use <font color='#FFFFFF'>clear</font> to tidy up after reading.<br/>
	• The command is read-only; it cannot edit or modify files.<br/>
	• Large files may display multiple lines; scroll carefully.
	</font><br/><br/>

    <font color='#3498DB' face='PuristaSemibold'>7. CLEAR TERMINAL</font><br/>
    <font color='#FFFFFF' face='EtelkaMonospacePro'>
	The <font color='#3498DB'>clear</font> command removes all visible text from the terminal window.
	It does not delete any files or data — it simply refreshes the display.<br/><br/>

	<font color='#3498DB'>Syntax:</font><br/>
	clear<br/><br/>

	<font color='#3498DB'>Examples:</font><br/>
	clear     // Erase all previous output<br/><br/>

	<font color='#3498DB'>Tips for Beginners:</font><br/>
	• Use <font color='#FFFFFF'>clear</font> after reading long file outputs for a clean screen.<br/>
	• The command does not affect system memory or command history.<br/>
	• Combine with <font color='#FFFFFF'>history</font> to review past commands without clutter.<br/>
	• Use frequently to maintain readability during active operations.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 3: INSTALLATION DIRECTORY
// =======================================================================
private _diaryInstallation = player createDiaryRecord [
	"CyberTerminal",
	["Installation Directory",
	"<font color='#E67E22' size='14' face='PuristaBold'>DEFAULT TOOL LOCATION</font><br/><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	/rubberducky/tools<br/><br/>
	Execute <font color='#3498DB'>cat guide</font> to read the local manual.<br/>
	Use <font color='#3498DB'>ls</font> to verify installed utilities.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 2: TERMINAL BASICS
// =======================================================================
private _diaryBasics = player createDiaryRecord [
	"CyberTerminal",
	["Basic Terminal Usage",
	"<font color='#E67E22' size='14' face='PuristaBold'>TERMINAL COMMAND STRUCTURE</font><br/><br/>

	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	Commands follow this pattern:<br/><br/>
	&gt;&gt; [command] [target/ID] [parameters]<br/><br/>
	Example:<br/>
	&gt;&gt; light 2125 off<br/>
	&gt;&gt; changedrone 2261 west<br/>
	&gt;&gt; gpstrack 8712<br/>
	</font><br/>

	<font color='#3498DB' face='PuristaSemibold'>HELP AND MANUAL ACCESS</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	cat guide      // Displays the short local manual about cyberwarfare commands<br/>
	help           // Displays list of available system commands<br/>
	man [command]  // Displays detailed manual entry for system commands<br/>
	</font>"],
	taskNull, "", false
];

// =======================================================================
// SECTION 1: IMPORTANT NOTICE
// =======================================================================
private _diaryNotice = player createDiaryRecord [
	"CyberTerminal",
	["Important Notice", 
	"<font color='#E74C3C' size='16' face='PuristaBold'>ALL COMMANDS ARE CASE SENSITIVE</font><br/><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>
	Execute all commands with precision. Incorrect capitalization or syntax will result in command failure.<br/><br/>
	Operators are advised to familiarize themselves with command structure before mission execution.
	</font>"],
	taskNull, "", false
];

// =======================================================================
// TABLE OF CONTENTS
// =======================================================================
player createDiaryRecord [
	"CyberTerminal",
	["Operations Manual",
	"<font color='#E67E22' size='18' face='PuristaBold'>CYBERWARFARE TERMINAL</font><br/>
	<font color='#7F8C8D' face='PuristaLight'>Command Reference Documentation</font><br/><br/>

	<font color='#FFFFFF' size='16' face='PuristaSemibold'>TABLE OF CONTENTS</font><br/>
	<font color='#CCCCCC' face='PuristaMedium'>
	" + createDiaryLink ["CyberTerminal", _diaryNotice, "1. Important Notice"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryBasics, "2. Basic Terminal Usage"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryInstallation, "3. Installation Directory"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryNavigation, "4. System Navigation"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryDevices, "5. Device Discovery (Listing Hackable Devices)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryDoors, "6. Door Control (Hacking Doors)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryLights, "7. Lighting Control (Hacking Lights)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryPowerGrid, "8. Power Generator Control (Power Grids)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryDrones, "9. Drone Operations (Hacking Drones)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryVehicles, "10. Vehicle Operations (Hacking Vehicles)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryData, "11. Data Operations (Downloading Files)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryGPSTrack, "12. GPS Operations (Tracking GPS)"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryTerminal, "13. Terminal Management"] + "<br/>
	</font>"],
	taskNull, "", false
];

true
