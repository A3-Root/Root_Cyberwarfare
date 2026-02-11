class CfgFunctions {
	class Root {
		tag = "Root";

		class Eden {
			file = "\z\root_cyberwarfare\addons\main\functions\3den";
			class 3denAddCustomDevice {};
			class 3denAddDatabase {};
			class 3denAddDevices {};
			class 3denAddDoors {};
			class 3denAddGPSTracker {};
			class 3denAddHackingTools {};
			class 3denAddLights {};
			class 3denAddPowerGenerator {};
			class 3denAddVehicle {};
			class 3denAdjustPowerCost {};
		};

		class Core {
			file = "\z\root_cyberwarfare\addons\main\functions\core";
			class addHackingToolsZeusMain {};
			class cleanupDeviceLinks {};
			class createDiaryEntry {};
			class initBreachIntegration {};
			class initSettings {};
			class isDeviceAccessible {};
			class listDevicesInSubnet {};
		};

		class Custom {
			file = "\z\root_cyberwarfare\addons\main\functions\custom";
			class addCustomDeviceZeusMain {};
			class customDevice {};
		};

		class Database {
			file = "\z\root_cyberwarfare\addons\main\functions\database";
			class addDatabaseZeusMain {};
			class downloadDatabase {};
		};

		class Devices {
			file = "\z\root_cyberwarfare\addons\main\functions\devices";
			class addDeviceZeusMain {};
			class addDoorsZeusMain {};
			class addLightsZeusMain {};
			class changeDoorState {};
			class changeLightState {};
		};

		class GPS {
			file = "\z\root_cyberwarfare\addons\main\functions\gps";
			class aceAttachGPSTracker {};
			class addGPSTrackerZeusMain {};
			class disableGPSTracker {};
			class disableGPSTrackerServer {};
			class displayGPSPosition {};
			class gpsTrackerClient {};
			class gpsTrackerServer {};
			class revealLaptopLocations {};
			class searchForGPSTracker {};
		};

		class PowerGenerator {
			file = "\z\root_cyberwarfare\addons\main\functions\powergenerator";
			class addPowerGeneratorZeusMain {};
			class powerGeneratorLights {};
			class powerGridControl {};
		};

		class Utility {
			file = "\z\root_cyberwarfare\addons\main\functions\utility";
			class cacheDeviceLinks {};
			class checkPowerAvailable {};
			class consumePower {};
			class copyDeviceLinksZeusMain {};
			class detectBuildingDoors {};
			class getAccessibleDevices {};
			class getComputerIdentifier {};
			class getObjectsInTriggerArea {};
			class getPlayerFromComputer {};
			class getUserConfirmation {};
			class localSoundBroadcast {};
			class removePower {};
		};

		class Vehicle {
			file = "\z\root_cyberwarfare\addons\main\functions\vehicle";
			class addVehicleZeusMain {};
			class changeDroneFaction {};
			class changeVehicleParams {};
			class disableDrone {};
		};

		class Zeus {
			file = "\z\root_cyberwarfare\addons\main\functions\zeus";
			class addDeviceZeus {};
			class addDoorsZeus {};
			class addLightsZeus {};
			class addCustomDeviceZeus {};
			class addDatabaseZeus {};
			class addGPSTrackerZeus {};
			class addVehicleZeus {};
			class addPowerGeneratorZeus {};
			class modifyPowerZeus {};
			class addHackingToolsZeus {};
			class copyDeviceLinksZeus {};
		};
	};
};
