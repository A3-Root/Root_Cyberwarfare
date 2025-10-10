class CfgFunctions {
	class Root {
		tag = "Root";

		class Core {
			file = "\z\root_cyberwarfare\addons\main\functions\core";
			class isDeviceAccessible {};
			class cleanupDeviceLinks { postInit = 1; };
			class createDiaryEntry { postInit = 1; };
			class initSettings { preInit = 1; };
		};

		class Devices {
			file = "\z\root_cyberwarfare\addons\main\functions\devices";
			class addDevices {};
			class changeDoorState {};
			class changeLightState {};
			class changeDroneFaction {};
			class disableDrone {};
			class customDevice {};
			class changeVehicleParams {};
			class listDevicesInSubnet {};
		};

		class GPS {
			file = "\z\root_cyberwarfare\addons\main\functions\gps";
			class gpsTrackerClient {};
			class gpsTrackerServer {};
			class aceAttachGPSTrackerSelf {};
			class aceAttachGPSTrackerObject {};
			class searchForGPSTracker {};
			class disableGPSTracker {};
			class disableGPSTrackerServer {};
			class displayGPSPosition {};
			class revealLaptopLocations {};
		};

		class Database {
			file = "\z\root_cyberwarfare\addons\main\functions\database";
			class downloadDatabase {};
		};

		class Zeus {
			file = "\z\root_cyberwarfare\addons\main\functions\zeus";
			class addDeviceZeus {};
			class addDeviceZeusMain {};
			class addDatabaseZeus {};
			class addDatabaseZeusMain {};
			class addGPSTrackerZeus {};
			class addGPSTrackerZeusMain {};
			class addVehicleZeus {};
			class addVehicleZeusMain {};
			class modifyPowerZeus {};
			class addHackingToolsZeus {};
			class addHackingToolsZeusMain {};
		};

		class Utility {
			file = "\z\root_cyberwarfare\addons\main\functions\utility";
			class checkPowerAvailable {};
			class consumePower {};
			class getUserConfirmation {};
			class getAccessibleDevices {};
			class cacheDeviceLinks {};
			class removePower {};
			class localSoundBroadcast {};
		};

		// Hacking tools functions (not refactored, keep as-is)
		class HackingTools {
			file = "\z\root_cyberwarfare\addons\main\functions";
			class addHackingTools {};
		};
	};
};
