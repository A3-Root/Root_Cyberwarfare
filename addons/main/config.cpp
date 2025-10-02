#include "script_mod.hpp"


class CfgPatches {
	class ROOT_CyberWarfare {
		name = "Root's Cyber Warfare";
		units[] = {
			"ROOT_ModuleAddDevices",
			"ROOT_ModuleAddHackingTools",
			"ROOT_ModuleAddDatabase",
			"ROOT_CyberWarfareAddDeviceZeus",
			"ROOT_CyberWarfareAddHackingToolsZeus",
			"ROOT_CyberWarfareModifyPowerZeus",
			"ROOT_CyberWarfareAddDatabaseZeus"
		};
		requiredAddons[] = {
			"A3_Modules_F_Curator",
			"cba_main",
			"3DEN",
			"zen_custom_modules"
		};
		weapons[] = {};
		author = "Root";
		authors[] = {
			"Root",
			"Mister Adrian"
		};
		url = "https://github.com/A3-Root/Root_CyberWarfare";
		requiredVersion = VERSION;
	};
};

class CfgFactionClasses {
	class NO_CATEGORY;
	class ROOT_CYBERWARFARE: NO_CATEGORY {
		displayName = "Root's Cyber Warfare";
		priority = 1;
		side = 7;
	};
};

class CfgFunctions {
	class Root {
		class RootCyberWarfareCategory {
			class addDatabaseZeus {};
			class addDatabaseZeusMain {};
			class addDevices {};
			class addDeviceZeus {};
			class addDeviceZeusMain {};
			class addHackingTools {};
			class addHackingToolsZeus {};
			class addHackingToolsZeusMain {};
			class changeDoorState {};
			class changeDroneFaction {};
			class changeLightState {};
			class cleanupDeviceLinks {
				postInit = 1;
			};
			class customDevice {};
			class disableDrone {};
			class downloadDatabase {};
			class isDeviceAccessible {};
			class listDevicesInSubnet {};
			class modifyPowerZeus {};
			class removePower {};
		};
	};
};

class CfgVehicles {
	class Logic;
	class Module_F: Logic {
		class AttributesBase {
			class Edit;
			class ModuleDescription;
		};
		class ModuleDescription {
			class Anything;
		};
	};
	class ROOT_ModuleAddDevices: Module_F {
		scope = 2;
		displayName = "Add Devices";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addDevices";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		class Attributes: AttributesBase {
			class ROOT_Hack_Door_Cost_Edit: Edit {
				property = "ROOT_Hack_Door_Cost_Edit";
				displayName = "Door Hacking Cost";
				tooltip = "Power cost in Wh to hack a Door";
				typeName = "NUMBER";
				defaultValue = 2;
			};
			class ROOT_Hack_Drone_Side_Cost_Edit: Edit {
				property = "ROOT_Hack_Drone_Side_Cost_Edit";
				displayName = "Drone Side Changing Cost";
				tooltip = "Power cost in Wh to hack a drone and switch its side";
				typeName = "NUMBER";
				defaultValue = 20;
			};
			class ROOT_Hack_Drone_Disable_Cost_Edit: Edit {
				property = "ROOT_Hack_Drone_Disable_Cost_Edit";
				displayName = "Drone disable hacking cost";
				tooltip = "Power cost in Wh to hack a drone and disable (blow) it";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_Hack_Custom_Cost_Edit: Edit {
				property = "ROOT_Hack_Custom_Cost_Edit";
				displayName = "Custom device hacking cost";
				tooltip = "Power cost in Wh to hack a custom device";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description[] = {"- Create a trigger area and synchronize this module with the trigger.<br/>- All hackable devices (doors, drones, custom) within the trigger area will be hackable from AE3 laptops and USB sticks that have hacking tools installed.<br/>- Synchronize this module with the Database Module to add them to the hacking list.<br/>- You can also dynamically add devices to the list and modify the hacking cost during missions as 'Zeus'."};
		};
	};
	class ROOT_ModuleAddHackingTools: Module_F {
		scope = 2;
		displayName = "Add Hacking Tools";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addHackingTools";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		class Attributes: AttributesBase {
			class ROOT_Hack_Tool_Location_Edit: Edit {
				property = "ROOT_Hack_Tool_Location_Edit";
				displayName = "Tool Path";
				tooltip = "Path for the tools to be installed from the root path. Example: '/rubberducky/tools/'";
				typeName = "STRING";
				defaultValue = """/rubberducky/tools/""";
			};
			class ROOT_Hack_Tool_Backdoor_Edit: Edit {
				property = "ROOT_Hack_Tool_Backdoor_Edit";
				displayName = "Backdoor Function Prefix";
				tooltip = "Prefix name for the backdoor. Example: 'backdoor_'. Leave empty for no backdoor. If the value is not empty, all hacking functions in the specified path will have this prefix and will have access to all devices in the game even if unlinked to the laptop / module.";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description[] = {"- Synchronize this module to the AE3 Laptop or USB Stick.<br/>- You can dynamically specify path and add the tools to custom location during missions as 'Zeus'.<br/>- You can also call the function 'Root_fnc_addHackingTool' in your script by passing the AE3 Laptop/USB Stick object, path of the tools location, and the optional debug 'backdoor' name as the parameters.<br/><br/>- Example: [MY_CUSTOM_LAPTOP, '/path/where/i/want/the/tools/installed', 'backdoor_function_'] call Root_fnc_addHackingTool;<br/>- Except '/' and '_', all other special characters in the path will be removed.<br/>- The backdoor option appends the specified string to the start of all hacking functions in the path and has access to all the devices in the game even if unlinked to the laptop / module."};
		};
	};
	class ROOT_ModuleAddDatabase: Module_F {
		scope = 2;
		displayName = "Add Files";
		category = "ROOT_CYBERWARFARE";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		class Attributes: AttributesBase {
			class ROOT_DatabaseName_Edit: Edit {
				property = "ROOT_DatabaseName_Edit";
				displayName = "File Name";
				tooltip = "Name of the File";
				typeName = "STRING";
				defaultValue = """Very important Database""";
			};
			class ROOT_DatabaseSize_Edit: Edit {
				property = "ROOT_DatabaseSize_Edit";
				displayName = "File Size";
				tooltip = "Seconds to hack and download";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_DatabaseData_Edit: Edit {
				property = "ROOT_DatabaseData_Edit";
				control = "EditCodeMulti5";
				displayName = "File Contents";
				tooltip = "Contents to be displayed when the file is opened using the 'cat' command";
				typeName = "STRING";
				defaultValue = """... Check out the source code of this and other projects in my Github (https://github.com/A3-Root/). I welcome all efforts in improving any of my projects :) ...""";
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description[] = {"
			Adds Database. Synchronize to 'AddDevices'. Can also be added dynamically during missions as 'Zeus'."
			};
		};
	};
	class zen_modules_moduleBase;
	class ROOT_CyberWarfareAddHackingToolsZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddHackingToolsZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addHackingToolsZeus";
		displayName = "Add Hacking Tools";
	};
	class ROOT_CyberWarfareAddDeviceZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddDeviceZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addDeviceZeus";
		displayName = "Add Hackable Object";
	};
	class ROOT_CyberWarfareModifyPowerZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareModifyPowerZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_modifyPowerZeus";
		displayName = "Modify Power Costs";
	};
	class ROOT_CyberWarfareAddDatabaseZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddDatabaseZeus";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addDatabaseZeus";
		displayName = "Add Hackable File";
	};
};
