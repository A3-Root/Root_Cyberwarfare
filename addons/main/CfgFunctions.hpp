class CfgFunctions {
	class Root {
		class RootCyberWarfareCategory {
			file = "\z\root_cyberwarfare\addons\main\functions";
			class addDatabaseZeus {};
			class addDatabaseZeusMain {};
			class addDevices {};
			class addDeviceZeus {};
			class addDeviceZeusMain {};
			class addGPSTrackerZeus {};
			class addGPSTrackerZeusMain {};
			class addHackingTools {};
			class addHackingToolsZeus {};
			class addHackingToolsZeusMain {};
			class addVehicleZeus {};
			class addVehicleZeusMain {};
			class changeDoorState {};
			class changeDroneFaction {};
			class changeLightState {};
			class changeVehicleParams {};
			class cleanupDeviceLinks {
				postInit = 1;
			};
			class createDiaryEntry {
				postInit = 1;
			};
			class customDevice {};
			class disableDrone {};
			class displayGPSPosition {};
			class downloadDatabase {};
			class gpsTrackerClient {};
			class gpsTrackerServer {};
			class isDeviceAccessible {};
			class listDevicesInSubnet {};
			class localSoundBroadcast {};
			class modifyPowerZeus {};
			class removePower {};
		};
		class RootAceInteractionCategory {
			file = "\z\root_cyberwarfare\addons\main\functions";
			requiredAddons[] = {
				"ace_main",
				"ace_common",
				"ace_interact_menu"
			};
			class aceAttachGPSTrackerSelf {};
			class aceAttachGPSTrackerObject {};
		};
	};
};
