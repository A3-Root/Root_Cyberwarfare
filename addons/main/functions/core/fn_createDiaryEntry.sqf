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
private _index = player createDiarySubject ["CyberTerminal", "Cyberwarfare Guide", "\a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"];

// Create individual diary records for each section
private _diaryNotice = player createDiaryRecord [
	"CyberTerminal",
	["Important Notice", 
	"<font color='#E74C3C' size='16' face='PuristaBold'>ALL COMMANDS ARE CASE SENSITIVE</font><br/><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>Execute all commands with precision and attention to case sensitivity.</font>"],
	taskNull,
	"",
	true
];

private _diaryInstallation = player createDiaryRecord [
	"CyberTerminal",
	["Installation Directory",
	"<font color='#E67E22' size='14' face='PuristaBold'>DEFAULT TOOL LOCATION</font><br/><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>/rubberducky/tools</font><br/><br/>
	<font color='#3498DB' face='PuristaMedium'>Execute 'cat guide' from this directory to access the short in-terminal manual for various functions.</font>"],
	taskNull,
	"",
	true
];

private _diaryNavigation = player createDiaryRecord [
	"CyberTerminal",
	["System Navigation", 
	"<font color='#E67E22' size='14' face='PuristaBold'>DIRECTORY OPERATIONS</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>Change Directory</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>cd [directory]</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>cd Files &nbsp;&nbsp;&nbsp;&nbsp;// Enter Files directory</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>cd .. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Return to parent directory</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>List Contents</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>ls [options]</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>ls &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Basic file listing</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>ls -la &nbsp;&nbsp;// Detailed listing with hidden files</font>"],
	taskNull,
	"",
	true
];

private _diaryDevices = player createDiaryRecord [
	"CyberTerminal",
	["Device Discovery",
	"<font color='#E67E22' size='14' face='PuristaBold'>NETWORK DEVICE SCANNING</font><br/><br/>
	
	<font color='#FFFFFF' face='EtelkaMonospacePro'>devices [filter]</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>Available Filters:</font><br/>
	<font color='#CCCCCC' face='EtelkaMonospacePro'>
	all&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// All devices<br/>
	doors&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Access control systems<br/>
	lights&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Lighting systems<br/>
	drones&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Unmanned aerial vehicles<br/>
	files&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Data storage systems<br/>
	custom&nbsp;&nbsp;&nbsp;&nbsp;// Custom script objects<br/>
	gps&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// Positioning systems<br/>
	vehicles&nbsp;&nbsp;// Vehicle control systems</font>"],
	taskNull,
	"",
	true
];

private _diaryDoors = player createDiaryRecord [
	"CyberTerminal",
	["Door Control",
	"<font color='#E67E22' size='14' face='PuristaBold'>ACCESS CONTROL SYSTEMS</font><br/><br/>
	
	<font color='#FFFFFF' face='EtelkaMonospacePro'>door BuildingID DoorID [action]</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>Examples:</font><br/>
	<font color='#CCCCCC' face='EtelkaMonospacePro'>
	door 4514 2 lock &nbsp;&nbsp;&nbsp;&nbsp;// Secure specific door<br/>
	door 4514 a unlock &nbsp;&nbsp;// Unlock all building access points</font>"],
	taskNull,
	"",
	true
];

private _diaryLights = player createDiaryRecord [
	"CyberTerminal",
	["Lighting Control", 
	"<font color='#E67E22' size='14' face='PuristaBold'>ENVIRONMENTAL LIGHTING SYSTEMS</font><br/><br/>
	
	<font color='#FFFFFF' face='EtelkaMonospacePro'>light LightID [action]</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>Examples:</font><br/>
	<font color='#CCCCCC' face='EtelkaMonospacePro'>
	light a on &nbsp;&nbsp;// Illuminate all lighting systems<br/>
	light 3 off &nbsp;// Deactivate lighting unit 3</font>"],
	taskNull,
	"",
	true
];

private _diaryDrones = player createDiaryRecord [
	"CyberTerminal",
	["Drone Operations",
	"<font color='#E67E22' size='14' face='PuristaBold'>UAV CONTROL SYSTEMS</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>Allegiance Modification</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>changedrone DroneID [side]</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>changedrone 2 east</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>Termination Protocol</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>disabledrone DroneID</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>disabledrone 2 &nbsp;&nbsp;// Single unit termination</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>disabledrone a &nbsp;&nbsp;// Fleet-wide termination</font>"],
	taskNull,
	"",
	true
];

private _diaryData = player createDiaryRecord [
	"CyberTerminal",
	["Data Operations",
	"<font color='#E67E22' size='14' face='PuristaBold'>INFORMATION MANAGEMENT</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>File Acquisition</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>download FileID</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>download 1234 &nbsp;&nbsp;// Transfer to /Files directory</font><br/><br/>
	
	<font color='#3498DB' face='PuristaSemibold'>Custom Script Execution</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>custom CustomID activate</font><br/>
	&nbsp;&nbsp;<font color='#CCCCCC' face='EtelkaMonospacePro'>custom 2312 activate</font>"],
	taskNull,
	"",
	true
];

private _diaryTerminal = player createDiaryRecord [
	"CyberTerminal",
	["Terminal Management",
	"<font color='#E67E22' size='14' face='PuristaBold'>INTERFACE CONTROL</font><br/><br/>
	
	<font color='#FFFFFF' face='EtelkaMonospacePro'>clear &nbsp;&nbsp;&nbsp;&nbsp;// Purge terminal display</font><br/>
	<font color='#FFFFFF' face='EtelkaMonospacePro'>history &nbsp;// Access command log</font>"],
	taskNull,
	"",
	true
];

// Create main table of contents with navigation links
player createDiaryRecord [
	"CyberTerminal",
	["Operations Manual",
	"<font color='#E67E22' size='18' face='PuristaBold'>CYBERWARFARE TERMINAL</font><br/>
	<font color='#7F8C8D' face='PuristaLight'>Command Reference Documentation</font><br/><br/>
	
	<font color='#FFFFFF' size='16' face='PuristaSemibold'>TABLE OF CONTENTS</font><br/>
	<font color='#CCCCCC' face='PuristaMedium'>
	" + createDiaryLink ["CyberTerminal", _diaryNotice, "1. Important Notice"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryInstallation, "2. Installation Directory"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryNavigation, "3. System Navigation"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryDevices, "4. Device Discovery"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryDoors, "5. Door Control"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryLights, "6. Lighting Control"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryDrones, "7. Drone Operations"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryData, "8. Data Operations"] + "<br/>
	" + createDiaryLink ["CyberTerminal", _diaryTerminal, "9. Terminal Management"] + "<br/>
	</font><br/>
	
	<font color='#E74C3C' face='PuristaBold'>OPERATIONAL SECURITY</font><br/>
	<font color='#FFFFFF' face='PuristaMedium'>All operations are logged and monitored. Use with discretion.</font>"],
	taskNull,
	"",
	true
];


true
