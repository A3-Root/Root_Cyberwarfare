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
			class aceAttachGPSTracker {};
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
			class addPowerGeneratorZeus {};
			class addPowerGeneratorZeusMain {};
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

		class Eden {
			file = "\z\root_cyberwarfare\addons\main\functions\3den";
			class 3denAddHackingTools {};
			class 3denAdjustPowerCost {};
			class 3denAddDevices {};
			class 3denAddDatabase {};
			class 3denAddVehicle {};
			class 3denAddGPSTracker {};
			class 3denAddCustomDevice {};
		};
	};
};
