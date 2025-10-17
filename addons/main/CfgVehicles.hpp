class CfgVehicles {
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
	class ROOT_CyberWarfareAddCustomDeviceZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddCustomDeviceZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addCustomDeviceZeus";
		displayName = "Add Custom Device";
	};
	class ROOT_CyberWarfareModifyPowerZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareModifyPowerZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_modifyPowerZeus";
		displayName = "Modify Power Costs";
	};
	class ROOT_CyberWarfareAddFileZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddFileZeus";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addDatabaseZeus";
		displayName = "Add Hackable File";
	};
	class ROOT_CyberWarfareAddGPSTrackerZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddGPSTrackerZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addGPSTrackerZeus";
		displayName = "Add GPS Tracker";
	};
	class ROOT_CyberWarfareAddVehicleZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddVehicleZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addVehicleZeus";
		displayName = "Add Hackable Vehicle";
	};
	class ROOT_CyberWarfareAddPowerGeneratorZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddPowerGeneratorZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addPowerGeneratorZeus";
		displayName = "Add Power Generator";
	};
	class ROOT_CyberWarfareCopyDeviceLinksZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareCopyDeviceLinksZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_copyDeviceLinksZeus";
		displayName = "Copy Device Links";
	};

	// 3DEN Editor Modules
	class Logic;
	class Module_F: Logic {
		class AttributesBase {
			class Edit;
			class Checkbox;
			class ModuleDescription;
		};
		class ModuleDescription;
	};

	class ROOT_Module3DEN_AddHackingTools: Module_F {
		scope = 2;
		displayName = "Add Hacking Tools";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddHackingTools";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_HACK_TOOL_PATH: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_HACK_TOOL_PATH";
				displayName = "Tool Path";
				tooltip = "Path for the Hacking Tool. Do not add trailing '/'. Always end with a letter. No special characters or spaces except '/' and '_'. Example: /rubberducky/tools";
				typeName = "STRING";
				defaultValue = """/rubberducky/tools""";
			};
			class ROOT_CYBERWARFARE_3DEN_HACK_TOOL_BACKDOOR: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_HACK_TOOL_BACKDOOR";
				displayName = "Backdoor Function Prefix";
				tooltip = "Prefix name for the backdoor. Example: 'backdoor_'. Leave empty for no backdoor.";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "Synchronize this module to AE3 Laptop or USB Stick objects to add hacking tools to them.";
			sync[] = {"Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AdjustPowerCost: Module_F {
		scope = 2;
		displayName = "Adjust Power Cost Settings";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAdjustPowerCost";
		functionPriority = 1;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_COST_DOOR: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_DOOR";
				displayName = "Door Lock/Unlock Cost";
				tooltip = "Power cost in Wh to lock or unlock a door";
				typeName = "NUMBER";
				defaultValue = 2;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_DRONE_SIDE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_DRONE_SIDE";
				displayName = "Drone Side Change Cost";
				tooltip = "Power cost in Wh to hack a drone and switch its side";
				typeName = "NUMBER";
				defaultValue = 20;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_DRONE_DISABLE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_DRONE_DISABLE";
				displayName = "Drone Disable Cost";
				tooltip = "Power cost in Wh to hack a drone and disable (blow) it";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_CUSTOM: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_CUSTOM";
				displayName = "Custom Device Cost";
				tooltip = "Power cost in Wh to hack a custom device";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "Configures power costs for hacking operations. Only one module of this type should exist.";
		};
	};

	class ROOT_Module3DEN_AddDevices: Module_F {
		scope = 2;
		displayName = "Add Devices";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddDevices";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_DEVICES_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_DEVICES_PUBLIC";
				displayName = "Add to Public Device List";
				tooltip = "If checked, these devices will be accessible by all laptops (current and future)";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "Synchronize this module to buildings (with doors), drones, and lights to make them hackable.";
			sync[] = {"House", "Building", "UAV", "Lamps_base_F", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddDatabase: Module_F {
		scope = 2;
		displayName = "Add Hackable File";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddDatabase";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_DATABASE_NAME: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_NAME";
				displayName = "File Name";
				tooltip = "Name of the File";
				typeName = "STRING";
				defaultValue = """Secret Database""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_SIZE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_SIZE";
				displayName = "Download Time (seconds)";
				tooltip = "Time in seconds required to download this file";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_CONTENT: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_CONTENT";
				control = "EditCodeMulti5";
				displayName = "File Contents";
				tooltip = "Contents to be displayed when the file is opened using the 'cat' command";
				typeName = "STRING";
				defaultValue = """This is a secret file downloaded from the network.""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_EXEC: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_EXEC";
				control = "EditCodeMulti5";
				displayName = "Execution Code (Optional)";
				tooltip = "Code to execute upon successful download. Leave empty for no execution.";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_PUBLIC";
				displayName = "Add to Public Device List";
				tooltip = "If checked, this file will be accessible by all laptops (current and future)";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "Creates a hackable file/database. Synchronize to AE3 Laptop objects to link the file to specific computers.";
			sync[] = {"Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddVehicle: Module_F {
		scope = 2;
		displayName = "Add Hackable Vehicle";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddVehicle";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_NAME: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_NAME";
				displayName = "Vehicle Name";
				tooltip = "Display name for this vehicle in the hacking terminal";
				typeName = "STRING";
				defaultValue = """Target Vehicle""";
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_COST: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_COST";
				displayName = "Power Cost per Action";
				tooltip = "Power cost in Wh for each hacking action on this vehicle";
				typeName = "NUMBER";
				defaultValue = 2;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL";
				displayName = "Allow Fuel/Battery Hacking";
				tooltip = "Allow hacking the vehicle's fuel/battery level";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED";
				displayName = "Allow Speed Hacking";
				tooltip = "Allow hacking the vehicle's speed";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES";
				displayName = "Allow Brakes Hacking";
				tooltip = "Allow hacking the vehicle's brakes";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS";
				displayName = "Allow Lights Hacking";
				tooltip = "Allow hacking the vehicle's lights";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE";
				displayName = "Allow Engine Hacking";
				tooltip = "Allow hacking the vehicle's engine";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM";
				displayName = "Allow Alarm Hacking";
				tooltip = "Allow hacking the vehicle's car alarm";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_PUBLIC";
				displayName = "Add to Public Device List";
				tooltip = "If checked, this vehicle will be accessible by all laptops (current and future)";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "Makes a vehicle hackable. Synchronize to vehicle objects and optionally to AE3 Laptop objects.";
			sync[] = {"Car", "Tank", "Air", "Ship", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddGPSTracker: Module_F {
		scope = 2;
		displayName = "Add GPS Tracker";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddGPSTracker";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_GPS_NAME: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_NAME";
				displayName = "GPS Tracker Name";
				tooltip = "Name that will appear in the terminal and as the default marker name";
				typeName = "STRING";
				defaultValue = """Target_GPS""";
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_TRACKING_TIME: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_TRACKING_TIME";
				displayName = "Tracking Time (seconds)";
				tooltip = "Maximum time in seconds the tracking will stay active";
				typeName = "NUMBER";
				defaultValue = 60;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_UPDATE_FREQ: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_UPDATE_FREQ";
				displayName = "Update Frequency (seconds)";
				tooltip = "Frequency in seconds between position updates";
				typeName = "NUMBER";
				defaultValue = 5;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_LAST_PING: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_LAST_PING";
				displayName = "Last Ping Duration (seconds)";
				tooltip = "Duration in seconds for the last ping marker to remain visible";
				typeName = "NUMBER";
				defaultValue = 5;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_POWER_COST: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_POWER_COST";
				displayName = "Power Cost to Track";
				tooltip = "Energy / Power (in Wh) required to track this signal";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_MARKER: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_MARKER";
				displayName = "Custom Marker Name (Optional)";
				tooltip = "Custom name for the map marker. Leave empty to use Tracker Name";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_RETRACK: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_RETRACK";
				displayName = "Allow Retracking";
				tooltip = "Allow tracking again after the initial tracking time ends";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_PUBLIC";
				displayName = "Add to Public Device List";
				tooltip = "If checked, this GPS tracker will be accessible by all laptops (current and future)";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "Attaches a GPS tracker to an object. Synchronize to the object to track and optionally to AE3 Laptop objects.";
			sync[] = {"All", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddCustomDevice: Module_F {
		scope = 2;
		displayName = "Add Custom Device";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddCustomDevice";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_NAME: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_NAME";
				displayName = "Custom Device Name";
				tooltip = "Name that will appear in the terminal for this device";
				typeName = "STRING";
				defaultValue = """Power Generator""";
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_ACTIVATE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_ACTIVATE";
				control = "EditCodeMulti5";
				displayName = "Activation Code";
				tooltip = "Code to run when device is activated. Use (_this select 0) to reference the computer object.";
				typeName = "STRING";
				defaultValue = """// Example: Display Hint when triggered
hint 'Custom device activated';""";
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_DEACTIVATE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_DEACTIVATE";
				control = "EditCodeMulti5";
				displayName = "Deactivation Code";
				tooltip = "Code to run when device is deactivated. Use (_this select 0) to reference the computer object.";
				typeName = "STRING";
				defaultValue = """// Example: Display Hint when triggered
hint 'Custom device deactivated';""";
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_PUBLIC";
				displayName = "Add to Public Device List";
				tooltip = "If checked, this custom device will be accessible by all laptops (current and future)";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "Creates a custom hackable device with programmable activation/deactivation code.";
			sync[] = {"All", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"};
		};
	};

	class Man;
    class CAManBase: Man {
        class ACE_SelfActions {
			class ACE_Equipment {
				class ROOT_AttachGPSTracker_Self {
					displayName = "Attach GPS Tracker";
					condition = "private _gpsTrackerClass = missionNamespace getVariable ['ROOT_CYBERWARFARE_GPS_TRACKER_DEVICE', 'ACE_Banana']; _gpsTrackerClass in (uniformItems _player + vestItems _player + backpackItems _player + items _player)";
					exceptions[] = {};
					statement = "[vehicle _player, _player] call ROOT_fnc_aceAttachGPSTracker;";
				};
			};
        };
    };
};
