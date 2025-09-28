#define _ARMA_

class CfgPatches
{
	class ROOT_CyberWarfare
	{
		name = "Root's Cyber Warfare";
		units[] = {"ROOT_CyberWarfareAddDeviceZeus","ROOT_ModuleAddDevices","ROOT_ModuleAddHackingTools","ROOT_ModuleAddDatabase","ROOT_CyberWarfareAddHackingToolsZeus","ROOT_CyberWarfareModifyPowerZeus","ROOT_CyberWarfareAddDatabaseZeus"};
		requiredAddons[] = {"A3_Modules_F_Curator","cba_main","3DEN","zen_custom_modules"};
		weapons[] = {};
		author = "Root";
		authors[] = {"Root","Mister Adrian"};
		url = "https://github.com/A3-Root/Root_CyberWarfare";
		requiredVersion = 2.18;
	};
};

class CfgFactionClasses
{
	class NO_CATEGORY;
	class ROOT_CYBERWARFARE: NO_CATEGORY
	{
		displayName = "Root's Cyber Warfare";
		priority = 1;
		side = 7;
	};
};

class CfgFunctions
{
	class Root
	{
		class RootCyberWarfareCategory
		{
			class AddDatabaseZeus
			{
				file = "root_cyberwarfare\functions\AddDatabaseZeus.sqf";
			};
			class AddDatabaseZeusMain
			{
				file = "root_cyberwarfare\functions\AddDatabaseZeusMain.sqf";
			};
			class AddDevices
			{
				file = "root_cyberwarfare\functions\AddDevices.sqf";
			};
			class AddDeviceZeus
			{
				file = "root_cyberwarfare\functions\AddDeviceZeus.sqf";
			};
			class AddDeviceZeusMain
			{
				file = "root_cyberwarfare\functions\AddDeviceZeusMain.sqf";
			};
			class AddHackingTools
			{
				file = "root_cyberwarfare\functions\AddHackingTools.sqf";
			};
			class AddHackingToolsZeus
			{
				file = "root_cyberwarfare\functions\AddHackingToolsZeus.sqf";
			};
			class AddHackingToolsZeusMain
			{
				file = "root_cyberwarfare\functions\AddHackingToolsZeusMain.sqf";
			};
			class ChangeDoorState
			{
				file = "root_cyberwarfare\functions\ChangeDoorState.sqf";
			};
			class ChangeDroneFaction
			{
				file = "root_cyberwarfare\functions\ChangeDroneFaction.sqf";
			};
			class ChangeLightState
			{
				file = "root_cyberwarfare\functions\ChangeLightState.sqf";
			};
			class CleanupDeviceLinks
			{
				file = "root_cyberwarfare\functions\CleanupDeviceLinks.sqf";
				postInit = 1;
			};
			class CustomDevice
			{
				file = "root_cyberwarfare\functions\CustomDevice.sqf";
			};
			class DisableDrone
			{
				file = "root_cyberwarfare\functions\DisableDrone.sqf";
			};
			class DownloadDatabase
			{
				file = "root_cyberwarfare\functions\DownloadDatabase.sqf";
			};
			class IsDeviceAccessible
			{
				file = "root_cyberwarfare\functions\IsDeviceAccessible.sqf";
			};
			class ListDevicesInSubnet
			{
				file = "root_cyberwarfare\functions\ListDevicesInSubnet.sqf";
			};
			class ModifyPowerZeus
			{
				file = "root_cyberwarfare\functions\ModifyPowerZeus.sqf";
			};
			class RemovePower
			{
				file = "root_cyberwarfare\functions\RemovePower.sqf";
			};
		};
	};
};

class CfgVehicles
{
	class Logic;
	class Item_Base_F;
	class Module_F: Logic
	{
		class AttributesBase
		{
			class Default;
			class Edit;
			class Combo;
			class CheckBox;
			class CheckBoxNumber;
			class ModuleDescription;
		};
		class ModuleDescription
		{
			class Anything;
		};
	};
	class ROOT_ModuleAddDevices: Module_F
	{
		scope = 2;
		displayName = "Add Devices";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_AddDevices";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		class Attributes: AttributesBase
		{
			class ROOT_Hack_Door_Cost_Edit: Edit
			{
				property = "ROOT_Hack_Door_Cost_Edit";
				displayName = "Door Hacking Cost";
				tooltip = "Power cost in Wh to hack a Door";
				typeName = "NUMBER";
				defaultValue = 2;
			};
			class ROOT_Hack_Drone_Side_Cost_Edit: Edit
			{
				property = "ROOT_Hack_Drone_Side_Cost_Edit";
				displayName = "Drone Side Changing Cost";
				tooltip = "Power cost in Wh to hack a drone and switch its side";
				typeName = "NUMBER";
				defaultValue = 20;
			};
			class ROOT_Hack_Drone_Disable_Cost_Edit: Edit
			{
				property = "ROOT_Hack_Drone_Disable_Cost_Edit";
				displayName = "Drone disable hacking cost";
				tooltip = "Power cost in Wh to hack a drone and disable (blow) it";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_Hack_Custom_Cost_Edit: Edit
			{
				property = "ROOT_Hack_Custom_Cost_Edit";
				displayName = "Custom device hacking cost";
				tooltip = "Power cost in Wh to hack a custom device";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription
		{
			description[] = {"- Create a trigger area and synchronize this module with the trigger.<br/>- All hackable devices (doors, drones, custom) within the trigger area will be hackable from AE3 laptops and USB sticks that have hacking tools installed.<br/>- Synchronize this module with the Database Module to add them to the hacking list.<br/>- You can also dynamically add devices to the list and modify the hacking cost during missions as 'Zeus'."};
		};
	};
	class ROOT_ModuleAddHackingTools: Module_F
	{
		scope = 2;
		displayName = "Add Hacking Tools";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_AddHackingTools";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		class Attributes: AttributesBase
		{
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription
		{
			description[] = {"- Synchronize this module to the AE3 Laptop or USB Stick.<br/>- Default Path: /rubberducky/tools <br/>- You can dynamically specify path and add the tools to custom location during missions as 'Zeus' or by calling the function 'Root_fnc_AddHackingToolsAPI' in your script by passing the AE3 Laptop/USB Stick and the Path as the parameters.<br/><br/>- Example: [MY_CUSTOM_LAPTOP, '/path/where/i/want/the/tools/installed'] call Root_fnc_AddHackingToolsAPI;<br/>**WARNING** - ENSURE THAT THE PATH DOES NOT END WITH A '/' OR BACKSLASH.<br/>- DO NOT USE SPACE OR SPECIAL CHARACTERS IN THE PATH."};
		};
	};
	class ROOT_ModuleAddDatabase: Module_F
	{
		scope = 2;
		displayName = "Add Files";
		category = "ROOT_CYBERWARFARE";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		class Attributes: AttributesBase
		{
			class ROOT_DatabaseName_Edit: Edit
			{
				property = "ROOT_DatabaseName_Edit";
				displayName = "File Name";
				tooltip = "Name of the File";
				typeName = "STRING";
				defaultValue = """Very important Database""";
			};
			class ROOT_DatabaseSize_Edit: Edit
			{
				property = "ROOT_DatabaseSize_Edit";
				displayName = "File Size";
				tooltip = "Seconds to hack and download";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_DatabaseData_Edit: Edit
			{
				property = "ROOT_DatabaseData_Edit";
				control = "EditCodeMulti5";
				displayName = "File Contents";
				tooltip = "Contents to be displayed when the file is opened using the 'cat' command";
				typeName = "STRING";
				defaultValue = """... Check out the source code of this and other projects in my Github (https://github.com/A3-Root/). I welcome any effort in improving any of my projects :) ...""";
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription
		{
			description[] = {"Adds Database. Synchronize to 'AddDevices'. Can also be added dynamically during missions as 'Zeus'."};
		};
	};
	class zen_modules_moduleBase;
	class ROOT_CyberWarfareAddHackingToolsZeus: zen_modules_moduleBase
	{
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddHackingToolsZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_AddHackingToolsZeus";
		displayName = "Add Hacking Tools";
	};
	class ROOT_CyberWarfareAddDeviceZeus: zen_modules_moduleBase
	{
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddDeviceZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_AddDeviceZeus";
		displayName = "Add Hackable Object";
	};
	class ROOT_CyberWarfareModifyPowerZeus: zen_modules_moduleBase
	{
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareModifyPowerZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_ModifyPowerZeus";
		displayName = "Modify Power Requirements";
	};
	class ROOT_CyberWarfareAddDatabaseZeus: zen_modules_moduleBase
	{
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddDatabaseZeus";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_AddDatabaseZeus";
		displayName = "Add Hackable File";
	};
};
