class CfgVehicles {
	class Land_USB_Dongle_01_F_AE3;   // AE3 flash-drive world object (base for the Rubberducky)

	// Placeable / Arsenal-spawnable Rubberducky drive object. Behaves as an AE3 flash drive but is
	// seeded read-only with the hacking toolset by its init handler; picking it up yields the single
	// ROOT_Rubberducky_Item.
	class ROOT_Rubberducky_Object: Land_USB_Dongle_01_F_AE3 {
		author = "Root";
		scope = 2;
		scopeCurator = 2;
		scopeArsenal = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_RUBBERDUCKY_USB";
		ae3_item = "ROOT_Rubberducky_Item";
	};

	class zen_modules_moduleBase;
	class ROOT_CyberWarfareAddHackingToolsZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddHackingToolsZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addHackingToolsZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKING_TOOLS";
	};
	class ROOT_CyberWarfareRegisterHackableLaptopZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareRegisterHackableLaptopZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_registerHackableLaptopZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_REGISTER_HACKABLE_LAPTOP";
	};
	class ROOT_CyberWarfareAddDoorsZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddDoorsZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addDoorsZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_DOORS";
	};
	class ROOT_CyberWarfareAddLightsZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddLightsZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addLightsZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_LIGHTS";
	};
	class ROOT_CyberWarfareAddCustomDeviceZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddCustomDeviceZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addCustomDeviceZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_CUSTOM_DEVICE";
	};
	class ROOT_CyberWarfareModifyPowerZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareModifyPowerZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_modifyPowerZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_MODIFY_POWER_COSTS";
	};
	class ROOT_CyberWarfareCipherZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareCipherZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_cipherZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_CIPHER_TOOLS";
	};
	class ROOT_CyberWarfareAddFileZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddFileZeus";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addDatabaseZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_FILE";
	};
	class ROOT_CyberWarfareAddGPSTrackerZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddGPSTrackerZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addGPSTrackerZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_GPS_TRACKER";
	};
	class ROOT_CyberWarfareAddVehicleZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddVehicleZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addVehicleZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_VEHICLE";
	};
	class ROOT_CyberWarfareAddPowerGeneratorZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareAddPowerGeneratorZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_addPowerGeneratorZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_POWER_GENERATOR";
	};
	class ROOT_CyberWarfareCopyDeviceLinksZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareCopyDeviceLinksZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_copyDeviceLinksZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_COPY_DEVICE_LINKS";
	};
	class ROOT_CyberWarfareManageDeviceLinksZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareManageDeviceLinksZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_manageDeviceLinksZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_LINKS_TITLE";
	};
	class ROOT_CyberWarfareManageDeviceAccessZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareManageDeviceAccessZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_manageDeviceAccessZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_MANAGE_DEVICE_ACCESS";
	};
	class ROOT_CyberWarfareHiddenTrackersZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareHiddenTrackersZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_hiddenTrackersZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_HIDDEN_TRACKERS";
	};
	class ROOT_CyberWarfareClearBrokenLinksZeus: zen_modules_moduleBase {
		author = "Root";
		_generalMacro = "ROOT_CyberWarfareClearBrokenLinksZeus";
		curatorCanAttach = 1;
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_clearBrokenDeviceLinksZeus";
		displayName = "$STR_ROOT_CYBERWARFARE_UI_CLEAR_BROKEN_DEVICE_LINKS";
	};

	// 3DEN Editor Modules
	class Logic;
	class Module_F: Logic {
		class AttributesBase {
			class Edit;
			class Checkbox;
			class Combo;
			class ModuleDescription;
		};
		class ModuleDescription;
	};

	class ROOT_Module3DEN_LinkDevices: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_LINK_DEVICES";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denLinkDevices";
		functionPriority = 1;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_LINKDEVICES_LIST: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_LINKDEVICES_LIST";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICES_TYPE_ID";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_COMMA_SEPARATED_DEVICETYPE_DEVICEID_PAIRS_E_G_4_1003_1_1001_TYPES";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_LINKDEVICES_ACTION: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_LINKDEVICES_ACTION";
				displayName = "$STR_ROOT_CYBERWARFARE_LINKS_ACTION";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_WHAT_TO_DO_WITH_THE_LISTED_DEVICES_FOR_THE_SYNCHRONIZED_LAPTOPS";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class LinkDevices { name = "$STR_ROOT_CYBERWARFARE_UI_LINK_TO_SYNCHRONIZED_LAPTOPS"; value = 0; };
					class UnlinkDevices { name = "$STR_ROOT_CYBERWARFARE_UI_UNLINK_FROM_SYNCHRONIZED_LAPTOPS"; value = 1; };
					class PublishDevices { name = "$STR_ROOT_CYBERWARFARE_UI_MAKE_PUBLIC_ALL_LAPTOPS"; value = 2; };
					class UnassignDevices { name = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGN_NO_LAPTOP_CAN_REACH"; value = 3; };
				};
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_GRANTS_SYNCHRONIZED_AE3_LAPTOPS_ACCESS_TO_DEVICES_THAT_OTHER_MODULES_ALREADY_REGISTERED";
			sync[] = {"Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddHackingTools: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKING_TOOLS";
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
				displayName = "$STR_ROOT_CYBERWARFARE_UI_TOOL_PATH";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_PATH_FOR_THE_HACKING_TOOL_DO_NOT_ADD_TRAILING_ALWAYS_END_WITH";
				typeName = "STRING";
				defaultValue = """/rubberducky/tools""";
			};
			class ROOT_CYBERWARFARE_3DEN_HACK_TOOL_BACKDOOR: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_HACK_TOOL_BACKDOOR";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_BACKDOOR_FUNCTION_PREFIX";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_PREFIX_NAME_FOR_THE_BACKDOOR_EXAMPLE_BACKDOOR_LEAVE_EMPTY_FOR_NO_BACKDOOR";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_HACK_TOOL_CREDENTIALS: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_HACK_TOOL_CREDENTIALS";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_DEFAULT_CREDENTIALS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ADDS_THE_CONFIGURED_RUBBERDUCKY_LOGIN_ACCOUNT_TO_EACH_TARGET_LAPTOP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_SYNCHRONIZE_THIS_MODULE_TO_AE3_LAPTOP_OR_USB_STICK_OBJECTS_TO_ADD";
			sync[] = {"Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3", "Land_USB_Dongle_01_F_AE3"};
		};
	};

	class ROOT_Module3DEN_RegisterHackableLaptop: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_REGISTER_HACKABLE_LAPTOP";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denRegisterHackableLaptop";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_REGISTER_LAPTOP_CREDENTIALS: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_REGISTER_LAPTOP_CREDENTIALS";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_DEFAULT_CREDENTIALS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ADDS_THE_CONFIGURED_RUBBERDUCKY_LOGIN_ACCOUNT_TO_EACH_TARGET_LAPTOP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_SYNCHRONIZE_THIS_MODULE_TO_AE3_LAPTOP_OBJECTS_TO_REGISTER_THEM_AS_HACKABLE";
			sync[] = {"Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AdjustPowerCost: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADJUST_POWER_COST_SETTINGS";
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
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DOOR_LOCK_UNLOCK_COST";
				tooltip = "$STR_ROOT_CYBERWARFARE_SETTING_DOOR_COST_DESC";
				typeName = "NUMBER";
				defaultValue = 2;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_DRONE_SIDE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_DRONE_SIDE";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DRONE_SIDE_CHANGE_COST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_IN_WH_TO_HACK_A_DRONE_AND_SWITCH_ITS_SIDE";
				typeName = "NUMBER";
				defaultValue = 20;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_DRONE_DISABLE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_DRONE_DISABLE";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DRONE_DISABLE_COST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_IN_WH_TO_HACK_A_DRONE_AND_DISABLE_BLOW_IT";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_CUSTOM: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_CUSTOM";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_CUSTOM_DEVICE_COST";
				tooltip = "$STR_ROOT_CYBERWARFARE_SETTING_CUSTOM_COST_DESC";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_GPS: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_GPS";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_GPS_TRACKER_COST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_IN_WH_TO_PING_A_GPS_TRACKER_THAT_WAS_REGISTERED";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_COST_POWERGRID: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_COST_POWERGRID";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_POWER_GRID_COST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_IN_WH_TO_SWITCH_OR_OVERLOAD_A_POWER_GRID";
				typeName = "NUMBER";
				defaultValue = 15;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_CONFIGURES_POWER_COSTS_FOR_HACKING_OPERATIONS_ONLY_ONE_MODULE_OF_THIS_TYPE";
		};
	};

	class ROOT_Module3DEN_AddDoors: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_DOORS";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddDoors";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_DOORS_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_DOORS_PUBLIC";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_TO_PUBLIC_DEVICE_LIST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DEPRECATED_KEPT_SO_MISSIONS_SAVED_BEFORE_THE_DEVICE_ACCESS_SETTING_EXISTED_KEEP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_DOORS_ACCESS: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_DOORS_ACCESS";
				displayName = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGNED_REGISTERED_BUT_NO_LAPTOP_CAN_REACH_IT_GRANT_ACCESS_LATER_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class Unassigned { name = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED"; value = 0; };
					class Linked { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ONLY"; value = 1; };
					class LinkedFuture { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ALL_FUTURE_LAPTOPS"; value = 3; };
					class PublicAll { name = "$STR_ROOT_CYBERWARFARE_UI_PUBLIC_ALL_LAPTOPS"; value = 2; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_DOORS_ALLOWLOCATION: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_DOORS_ALLOWLOCATION";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_IF_CHECKED_DEFAULT_THE_DEVICE_S_GRID_LOCATION_IS_SHOWN_ON_THE";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_DOORS_UNBREACHABLE: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_DOORS_UNBREACHABLE";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MAKE_UNBREACHABLE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_IF_CHECKED_BUILDING_DOORS_CANNOT_BE_BREACHED_BY_ACE_EXPLOSIVES_OR_LOCKPICKING";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_DOORS_ID_START: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DOORS_ID_START";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ASSIGN_A_FIXED_4_DIGIT_ID_1000_9999_0_AUTO_ASSIGN_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_DOORS_ID_END: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DOORS_ID_END";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_FOR_TRIGGERS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_LAST_ID_HANDED_OUT_ACROSS_A_TRIGGER_AREA_0_AUTO_LEAVE_0";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_DOORS_IDMAP: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DOORS_IDMAP";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DOOR_ID_OVERRIDES";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_COMMA_SEPARATED_REALDOOR_CUSTOMID_PAIRS_E_G_1_101_2_102_OMITTED";
				typeName = "STRING";
				defaultValue = "";
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_SYNCHRONIZE_THIS_MODULE_TO_BUILDINGS_WITH_DOORS_OR_TRIGGERS_TO_MAKE_DOORS";
			sync[] = {"All"};
		};
	};

	class ROOT_Module3DEN_AddLights: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_LIGHTS";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddLights";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_LIGHTS_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_LIGHTS_PUBLIC";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_TO_PUBLIC_DEVICE_LIST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DEPRECATED_KEPT_SO_MISSIONS_SAVED_BEFORE_THE_DEVICE_ACCESS_SETTING_EXISTED_KEEP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_LIGHTS_ACCESS: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_LIGHTS_ACCESS";
				displayName = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGNED_REGISTERED_BUT_NO_LAPTOP_CAN_REACH_IT_GRANT_ACCESS_LATER_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class Unassigned { name = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED"; value = 0; };
					class Linked { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ONLY"; value = 1; };
					class LinkedFuture { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ALL_FUTURE_LAPTOPS"; value = 3; };
					class PublicAll { name = "$STR_ROOT_CYBERWARFARE_UI_PUBLIC_ALL_LAPTOPS"; value = 2; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_LIGHTS_ALLOWLOCATION: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_LIGHTS_ALLOWLOCATION";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_IF_CHECKED_DEFAULT_THE_DEVICE_S_GRID_LOCATION_IS_SHOWN_ON_THE";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_LIGHTS_ID_START: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_LIGHTS_ID_START";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ASSIGN_A_FIXED_4_DIGIT_ID_1000_9999_0_AUTO_ASSIGN_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_LIGHTS_ID_END: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_LIGHTS_ID_END";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_FOR_TRIGGERS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_LAST_ID_HANDED_OUT_ACROSS_A_TRIGGER_AREA_0_AUTO_LEAVE_0";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_SYNCHRONIZE_THIS_MODULE_TO_LIGHTS_OR_TRIGGERS_TO_MAKE_THEM_HACKABLE_TRIGGERS";
			sync[] = {"Lamps_base_F", "EmptyDetector", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddDatabase: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_FILE";
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
				displayName = "$STR_ROOT_CYBERWARFARE_UI_FILE_NAME";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_NAME_OF_THE_FILE";
				typeName = "STRING";
				defaultValue = """Secret Database""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_SIZE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_SIZE";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DOWNLOAD_TIME_SECONDS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_TIME_IN_SECONDS_REQUIRED_TO_DOWNLOAD_THIS_FILE";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_CONTENT: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_CONTENT";
				control = "EditCodeMulti5";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_FILE_CONTENTS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_CONTENTS_TO_BE_DISPLAYED_WHEN_THE_FILE_IS_OPENED_USING_THE_CAT";
				typeName = "STRING";
				defaultValue = """This is a secret file downloaded from the network.""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_EXEC: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_EXEC";
				control = "EditCodeMulti5";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_EXECUTION_CODE_OPTIONAL";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_CODE_TO_EXECUTE_UPON_SUCCESSFUL_DOWNLOAD_LEAVE_EMPTY_FOR_NO_EXECUTION";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_PUBLIC";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_TO_PUBLIC_DEVICE_LIST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DEPRECATED_KEPT_SO_MISSIONS_SAVED_BEFORE_THE_DEVICE_ACCESS_SETTING_EXISTED_KEEP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_ACCESS: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_ACCESS";
				displayName = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGNED_REGISTERED_BUT_NO_LAPTOP_CAN_REACH_IT_GRANT_ACCESS_LATER_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class Unassigned { name = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED"; value = 0; };
					class Linked { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ONLY"; value = 1; };
					class LinkedFuture { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ALL_FUTURE_LAPTOPS"; value = 3; };
					class PublicAll { name = "$STR_ROOT_CYBERWARFARE_UI_PUBLIC_ALL_LAPTOPS"; value = 2; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ENCRYPT_FILE_CONTENTS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ENCRYPT_THE_STORED_FILE_CONTENTS_BEFORE_THE_FILE_IS_REGISTERED";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_ALGORITHM: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_ALGORITHM";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ENCRYPTION_ALGORITHM";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_CIPHER_USED_WHEN_ENCRYPTION_IS_ENABLED";
				typeName = "STRING";
				defaultValue = """morse""";
				class Values {
					class morse { name = "$STR_ROOT_CYBERWARFARE_UI_MORSE_CODE"; value = "morse"; };
					class spelling { name = "$STR_ROOT_CYBERWARFARE_UI_SPELLING_ALPHABET"; value = "spelling"; };
					class affine { name = "$STR_ROOT_CYBERWARFARE_UI_AFFINE"; value = "affine"; };
					class rot { name = "ROT"; value = "rot"; };
					class vigenere { name = "$STR_ROOT_CYBERWARFARE_UI_VIGENERE"; value = "vigenere"; };
					class bacon { name = "$STR_ROOT_CYBERWARFARE_UI_BACON"; value = "bacon"; };
					class alpha_sub { name = "$STR_ROOT_CYBERWARFARE_UI_ALPHABETICAL_SUBSTITUTION"; value = "alpha_sub"; };
					class railfence { name = "$STR_ROOT_CYBERWARFARE_UI_RAILFENCE"; value = "railfence"; };
					class base32 { name = "Base32"; value = "base32"; };
					class base64 { name = "Base64"; value = "base64"; };
					class ascii85 { name = "Ascii85"; value = "ascii85"; };
					class unicode { name = "$STR_ROOT_CYBERWARFARE_UI_UNICODE_NOTATION"; value = "unicode"; };
					class integer { name = "$STR_ROOT_CYBERWARFARE_UI_INTEGER"; value = "integer"; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_KEY: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_KEY";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_KEY_VARIANT";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_PRIMARY_KEY_PASSWORD_KEYWORD_OR_VARIANT_EXAMPLES_ROT13_LEMON_3";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_OPTIONS: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_ENCRYPT_OPTIONS";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ENCRYPTION_OPTIONS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_OPTIONAL_KEY_VALUE_PAIRS_EXAMPLES_A_5_B_8_RAILS_3_RADIX";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_DATABASE_ID_START: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_DATABASE_ID_START";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ASSIGN_A_FIXED_4_DIGIT_ID_1000_9999_0_AUTO_ASSIGN_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_CREATES_A_HACKABLE_FILE_DATABASE_SYNCHRONIZE_TO_AE3_LAPTOP_OBJECTS_TO_LINK";
			sync[] = {"Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddVehicle: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_VEHICLE";
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
				displayName = "$STR_ROOT_CYBERWARFARE_UI_VEHICLE_NAME";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DISPLAY_NAME_FOR_THIS_VEHICLE_IN_THE_HACKING_TERMINAL";
				typeName = "STRING";
				defaultValue = """Target Vehicle""";
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_COST: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_COST";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_PER_ACTION";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_IN_WH_FOR_EACH_HACKING_ACTION_ON_THIS_VEHICLE";
				typeName = "NUMBER";
				defaultValue = 2;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_FUEL_BATTERY_HACKING";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_HACKING_THE_VEHICLE_S_FUEL_BATTERY_LEVEL";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_SPEED_HACKING";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_HACKING_THE_VEHICLE_S_SPEED";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_BRAKES_HACKING";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_HACKING_THE_VEHICLE_S_BRAKES";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_LIGHTS_HACKING";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_HACKING_THE_VEHICLE_S_LIGHTS";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_ENGINE_HACKING";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_HACKING_THE_VEHICLE_S_ENGINE";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_ALARM_HACKING";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_HACKING_THE_VEHICLE_S_CAR_ALARM";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_PUBLIC";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_TO_PUBLIC_DEVICE_LIST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DEPRECATED_KEPT_SO_MISSIONS_SAVED_BEFORE_THE_DEVICE_ACCESS_SETTING_EXISTED_KEEP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ACCESS: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ACCESS";
				displayName = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGNED_REGISTERED_BUT_NO_LAPTOP_CAN_REACH_IT_GRANT_ACCESS_LATER_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class Unassigned { name = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED"; value = 0; };
					class Linked { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ONLY"; value = 1; };
					class LinkedFuture { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ALL_FUTURE_LAPTOPS"; value = 3; };
					class PublicAll { name = "$STR_ROOT_CYBERWARFARE_UI_PUBLIC_ALL_LAPTOPS"; value = 2; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ALLOWLOCATION: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ALLOWLOCATION";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_IF_CHECKED_DEFAULT_THE_DEVICE_S_GRID_LOCATION_IS_SHOWN_ON_THE";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL_MIN: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL_MIN";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MIN_FUEL_BATTERY";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MINIMUM_FUEL_PERCENTAGE_ALLOWED_0_100";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL_MAX: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_FUEL_MAX";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MAX_FUEL_BATTERY";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MAXIMUM_FUEL_PERCENTAGE_ALLOWED_0_100";
				typeName = "NUMBER";
				defaultValue = 100;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED_MIN: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED_MIN";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MIN_SPEED_BOOST_KM_H";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MINIMUM_SPEED_BOOST_ALLOWED_NEGATIVE_SLOWDOWN_CLAMPED_TO_2000_2000";
				typeName = "NUMBER";
				defaultValue = -50;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED_MAX: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_SPEED_MAX";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MAX_SPEED_BOOST_KM_H";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MAXIMUM_SPEED_BOOST_ALLOWED_CLAMPED_TO_2000_2000";
				typeName = "NUMBER";
				defaultValue = 50;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES_MIN: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES_MIN";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MIN_BRAKE_DECEL_M_S";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MINIMUM_DECELERATION_RATE";
				typeName = "NUMBER";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES_MAX: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_BRAKES_MAX";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MAX_BRAKE_DECEL_M_S";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MAXIMUM_DECELERATION_RATE";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS_MAX_TOGGLES: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS_MAX_TOGGLES";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MAX_LIGHT_TOGGLES";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MAXIMUM_TOGGLE_COUNT_1_UNLIMITED";
				typeName = "NUMBER";
				defaultValue = -1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS_COOLDOWN: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_LIGHTS_COOLDOWN";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_LIGHT_COOLDOWN_SEC";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_SECONDS_BETWEEN_LIGHT_TOGGLES";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE_MAX_TOGGLES: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE_MAX_TOGGLES";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MAX_ENGINE_TOGGLES";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MAXIMUM_TOGGLE_COUNT_1_UNLIMITED";
				typeName = "NUMBER";
				defaultValue = -1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE_COOLDOWN: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ENGINE_COOLDOWN";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ENGINE_COOLDOWN_SEC";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_SECONDS_BETWEEN_ENGINE_TOGGLES";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM_MIN: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM_MIN";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MIN_ALARM_DURATION_SEC";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MINIMUM_ALARM_DURATION";
				typeName = "NUMBER";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM_MAX: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ALARM_MAX";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_MAX_ALARM_DURATION_SEC";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_MAXIMUM_ALARM_DURATION";
				typeName = "NUMBER";
				defaultValue = 30;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ID_START: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ID_START";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ASSIGN_A_FIXED_4_DIGIT_ID_1000_9999_0_AUTO_ASSIGN_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_VEHICLE_ID_END: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_VEHICLE_ID_END";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_FOR_TRIGGERS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_LAST_ID_HANDED_OUT_ACROSS_A_TRIGGER_AREA_0_AUTO_LEAVE_0";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_MAKES_A_VEHICLE_HACKABLE_SYNCHRONIZE_TO_VEHICLES_AND_DRONES_AND_OPTIONALLY_TO";
			sync[] = {"Car", "Tank", "Air", "Ship", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"};
		};
	};

	// Extends AE3's Add File module with the cipher algorithms provided by this mod.
	// The parent classes must be repeated here, otherwise the re-open resets the module's
	// base chain and the editor loses side/faction/vehicleClass/displayName.
	class AE3_AddFile: Module_F {
		class Attributes: AttributesBase {
			class AE3_Module_AddFile_EncryptionAlgorithm: Combo {
				class Values {
					class caesar { name = "$STR_ROOT_CYBERWARFARE_UI_CAESAR"; value = "caesar"; };
					class columnar { name = "$STR_ROOT_CYBERWARFARE_UI_COLUMNAR_TRANSPOSITION"; value = "columnar"; };
					class morse { name = "$STR_ROOT_CYBERWARFARE_UI_MORSE_CODE"; value = "morse"; };
					class spelling { name = "$STR_ROOT_CYBERWARFARE_UI_SPELLING_ALPHABET"; value = "spelling"; };
					class affine { name = "$STR_ROOT_CYBERWARFARE_UI_AFFINE"; value = "affine"; };
					class rot { name = "ROT"; value = "rot"; };
					class vigenere { name = "$STR_ROOT_CYBERWARFARE_UI_VIGENERE"; value = "vigenere"; };
					class bacon { name = "$STR_ROOT_CYBERWARFARE_UI_BACON"; value = "bacon"; };
					class alpha_sub { name = "$STR_ROOT_CYBERWARFARE_UI_ALPHABETICAL_SUBSTITUTION"; value = "alpha_sub"; };
					class railfence { name = "$STR_ROOT_CYBERWARFARE_UI_RAILFENCE"; value = "railfence"; };
					class base32 { name = "Base32"; value = "base32"; };
					class base64 { name = "Base64"; value = "base64"; };
					class ascii85 { name = "Ascii85"; value = "ascii85"; };
					class unicode { name = "$STR_ROOT_CYBERWARFARE_UI_UNICODE_NOTATION"; value = "unicode"; };
					class integer { name = "$STR_ROOT_CYBERWARFARE_UI_INTEGER"; value = "integer"; };
				};
			};
		};
	};

	class ROOT_Module3DEN_AddGPSTracker: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_GPS_TRACKER";
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
				displayName = "$STR_ROOT_CYBERWARFARE_UI_GPS_TRACKER_NAME";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_NAME_THAT_WILL_APPEAR_IN_THE_TERMINAL_AND_AS_THE_DEFAULT_MARKER";
				typeName = "STRING";
				defaultValue = """Target_GPS""";
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_TRACKING_TIME: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_TRACKING_TIME";
				displayName = "$STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME";
				tooltip = "$STR_ROOT_CYBERWARFARE_GPS_ATTACH_TIME_DESC";
				typeName = "NUMBER";
				defaultValue = 60;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_UPDATE_FREQ: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_UPDATE_FREQ";
				displayName = "$STR_ROOT_CYBERWARFARE_GPS_ATTACH_FREQ";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_FREQUENCY_IN_SECONDS_BETWEEN_POSITION_UPDATES";
				typeName = "NUMBER";
				defaultValue = 5;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_LAST_PING: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_LAST_PING";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_LAST_PING_DURATION_SECONDS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DURATION_IN_SECONDS_FOR_THE_LAST_PING_MARKER_TO_REMAIN_VISIBLE";
				typeName = "NUMBER";
				defaultValue = 5;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_POWER_COST: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_POWER_COST";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_TO_TRACK";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ENERGY_POWER_IN_WH_REQUIRED_TO_TRACK_THIS_SIGNAL";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_MARKER: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_MARKER";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_CUSTOM_MARKER_NAME_OPTIONAL";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_CUSTOM_NAME_FOR_THE_MAP_MARKER_LEAVE_EMPTY_TO_USE_TRACKER_NAME";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_RETRACK: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_RETRACK";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_RETRACKING";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_TRACKING_AGAIN_AFTER_THE_INITIAL_TRACKING_TIME_ENDS";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_PUBLIC";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_TO_PUBLIC_DEVICE_LIST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DEPRECATED_KEPT_SO_MISSIONS_SAVED_BEFORE_THE_DEVICE_ACCESS_SETTING_EXISTED_KEEP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_ACCESS: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_ACCESS";
				displayName = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGNED_REGISTERED_BUT_NO_LAPTOP_CAN_REACH_IT_GRANT_ACCESS_LATER_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class Unassigned { name = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED"; value = 0; };
					class Linked { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ONLY"; value = 1; };
					class LinkedFuture { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ALL_FUTURE_LAPTOPS"; value = 3; };
					class PublicAll { name = "$STR_ROOT_CYBERWARFARE_UI_PUBLIC_ALL_LAPTOPS"; value = 2; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_HIDDEN: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_HIDDEN";
				displayName = "$STR_ROOT_CYBERWARFARE_GPS_HIDDEN";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_IF_CHECKED_THIS_TRACKER_APPEARS_IN_NO_TERMINAL_OR_DESKTOP_LISTING_ON";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_IDENTIFIER: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_IDENTIFIER";
				displayName = "$STR_ROOT_CYBERWARFARE_GPS_IDENTIFIER_FIELD";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_THE_8_CHARACTER_CODE_THIS_TRACKER_ANSWERS_TO_FOR_A_BRIEFING_THAT";
				typeName = "STRING";
				defaultValue = "";
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_ID_START: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_ID_START";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ASSIGN_A_FIXED_4_DIGIT_ID_1000_9999_0_AUTO_ASSIGN_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_GPS_ID_END: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_GPS_ID_END";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_FOR_TRIGGERS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_LAST_ID_HANDED_OUT_ACROSS_A_TRIGGER_AREA_0_AUTO_LEAVE_0";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_ATTACHES_A_GPS_TRACKER_TO_AN_OBJECT_SYNCHRONIZE_TO_THE_OBJECT_TO";
			sync[] = {"Air", "Car", "Tank", "Ship", "Motorcycle", "CAManBase", "Static", "ThingX", "Thing", "House", "Building", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"};
		};
	};

	class ROOT_Module3DEN_AddCustomDevice: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_CUSTOM_DEVICE";
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
				displayName = "$STR_ROOT_CYBERWARFARE_UI_CUSTOM_DEVICE_NAME";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_NAME_THAT_WILL_APPEAR_IN_THE_TERMINAL_FOR_THIS_DEVICE";
				typeName = "STRING";
				defaultValue = """Custom Device""";
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_ACTIVATE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_ACTIVATE";
				control = "EditCodeMulti5";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ACTIVATION_CODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_CODE_TO_RUN_WHEN_DEVICE_IS_ACTIVATED_USE_THIS_SELECT_0_TO";
				typeName = "STRING";
				defaultValue = """hint 'Custom device activated';""";
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_DEACTIVATE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_DEACTIVATE";
				control = "EditCodeMulti5";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEACTIVATION_CODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_CODE_TO_RUN_WHEN_DEVICE_IS_DEACTIVATED_USE_THIS_SELECT_0_TO";
				typeName = "STRING";
				defaultValue = """hint 'Custom device deactivated';""";
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_PUBLIC";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_TO_PUBLIC_DEVICE_LIST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DEPRECATED_KEPT_SO_MISSIONS_SAVED_BEFORE_THE_DEVICE_ACCESS_SETTING_EXISTED_KEEP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_ACCESS: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_ACCESS";
				displayName = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGNED_REGISTERED_BUT_NO_LAPTOP_CAN_REACH_IT_GRANT_ACCESS_LATER_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class Unassigned { name = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED"; value = 0; };
					class Linked { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ONLY"; value = 1; };
					class LinkedFuture { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ALL_FUTURE_LAPTOPS"; value = 3; };
					class PublicAll { name = "$STR_ROOT_CYBERWARFARE_UI_PUBLIC_ALL_LAPTOPS"; value = 2; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_ALLOWLOCATION: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_ALLOWLOCATION";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_IF_CHECKED_DEFAULT_THE_DEVICE_S_GRID_LOCATION_IS_SHOWN_ON_THE";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_ID_START: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_ID_START";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ASSIGN_A_FIXED_4_DIGIT_ID_1000_9999_0_AUTO_ASSIGN_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_CUSTOM_ID_END: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_CUSTOM_ID_END";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_FOR_TRIGGERS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_LAST_ID_HANDED_OUT_ACROSS_A_TRIGGER_AREA_0_AUTO_LEAVE_0";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_CREATES_A_CUSTOM_HACKABLE_DEVICE_WITH_PROGRAMMABLE_ACTIVATION_DEACTIVATION_CODE_TRIGGERS_ENABLE";
			sync[] = {"All"};
		};
	};

	class ROOT_Module3DEN_AddPowerGenerator: Module_F {
		scope = 2;
		displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_POWER_GENERATOR";
		category = "ROOT_CYBERWARFARE";
		function = "Root_fnc_3denAddPowerGenerator";
		functionPriority = 4;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase {
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_NAME: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_NAME";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_GENERATOR_NAME";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_NAME_THAT_WILL_APPEAR_IN_THE_TERMINAL_FOR_THIS_POWER_GENERATOR";
				typeName = "STRING";
				defaultValue = """Power Generator""";
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_RADIUS: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_RADIUS";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_EFFECT_RADIUS_METERS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_RADIUS_IN_METERS_TO_AFFECT_LIGHTS";
				typeName = "NUMBER";
				defaultValue = 1000;
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_EXPLOSION_OVERLOAD: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_EXPLOSION_OVERLOAD";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_CREATE_EXPLOSION_ON_OVERLOAD";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_CREATE_EXPLOSION_WHEN_THE_GENERATOR_IS_OVERLOADED";
				typeName = "BOOL";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_EXPLOSION_TYPE: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_EXPLOSION_TYPE";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_EXPLOSION_TYPE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_AMMO_CLASSNAME_FOR_EXPLOSION_ON_OVERLOAD_E_G_CLAYMOREDIRECTIONALMINE_REMOTE_AMMO_SCRIPTED";
				typeName = "STRING";
				defaultValue = """ClaymoreDirectionalMine_Remote_Ammo_Scripted""";
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_EXCLUDED: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_EXCLUDED";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_EXCLUDED_LIGHT_CLASSNAMES";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_COMMA_SEPARATED_LIST_OF_LIGHT_CLASSNAMES_TO_EXCLUDE_FROM_POWER_CONTROL";
				typeName = "STRING";
				defaultValue = """""";
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_COST: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_COST";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_POWER_COST_IN_WH_PER_OPERATION";
				typeName = "NUMBER";
				defaultValue = 10;
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_PUBLIC: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_PUBLIC";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ADD_TO_PUBLIC_DEVICE_LIST";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_DEPRECATED_KEPT_SO_MISSIONS_SAVED_BEFORE_THE_DEVICE_ACCESS_SETTING_EXISTED_KEEP";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_ACCESS: Combo {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_ACCESS";
				displayName = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_UNASSIGNED_REGISTERED_BUT_NO_LAPTOP_CAN_REACH_IT_GRANT_ACCESS_LATER_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
				class Values {
					class Unassigned { name = "$STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED"; value = 0; };
					class Linked { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ONLY"; value = 1; };
					class LinkedFuture { name = "$STR_ROOT_CYBERWARFARE_UI_LINKED_LAPTOPS_ALL_FUTURE_LAPTOPS"; value = 3; };
					class PublicAll { name = "$STR_ROOT_CYBERWARFARE_UI_PUBLIC_ALL_LAPTOPS"; value = 2; };
				};
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_ALLOWLOCATION: Checkbox {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_ALLOWLOCATION";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_ALLOW_LOCATION_VIEW";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_IF_CHECKED_DEFAULT_THE_DEVICE_S_GRID_LOCATION_IS_SHOWN_ON_THE";
				typeName = "BOOL";
				defaultValue = 1;
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_ID_START: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_ID_START";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_START";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_ASSIGN_A_FIXED_4_DIGIT_ID_1000_9999_0_AUTO_ASSIGN_WITH";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ROOT_CYBERWARFARE_3DEN_POWERGRID_ID_END: Edit {
				property = "ROOT_CYBERWARFARE_3DEN_POWERGRID_ID_END";
				displayName = "$STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_END_FOR_TRIGGERS";
				tooltip = "$STR_ROOT_CYBERWARFARE_UI_LAST_ID_HANDED_OUT_ACROSS_A_TRIGGER_AREA_0_AUTO_LEAVE_0";
				typeName = "NUMBER";
				defaultValue = 0;
			};
			class ModuleDescription: ModuleDescription{};
		};
		class ModuleDescription: ModuleDescription {
			description = "$STR_ROOT_CYBERWARFARE_UI_CREATES_A_POWER_GENERATOR_THAT_CONTROLS_LIGHTS_WITHIN_A_RADIUS_SYNCHRONIZE_TO";
			sync[] = {"GeneratorMaster_01_F_AE3", "Land_PortableGenerator_01_F_AE3", "Land_PortableGenerator_01_black_F_AE3", "Land_PortableGenerator_01_sand_F_AE3", "Land_MobileRadar_01_generator_F_AE3", "Land_DieselGroundPowerUnit_01_F_AE3", "Land_PowerGenerator_F_AE3", "Land_Portable_generator_F_AE3", "Land_PortableGenerator_01_F", "Land_PortableGenerator_01_black_F", "Land_PortableGenerator_01_sand_F", "Land_MobileRadar_01_generator_F", "Land_DieselGroundPowerUnit_01_F", "Land_PowerGenerator_F", "Land_Portable_generator_F", "Static", "ThingX", "Thing", "House", "Building", "EmptyDetector", "Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"};
		};
	};

	class Man;
    class CAManBase: Man {
        class ACE_SelfActions {
			class ACE_Equipment {
				class ROOT_AttachGPSTracker_Self {
					displayName = "$STR_ROOT_CYBERWARFARE_UI_ATTACH_GPS_TRACKER_SELF";
					condition = "private _gpsTrackerClass = missionNamespace getVariable ['ROOT_CYBERWARFARE_GPS_TRACKER_DEVICE', 'ACE_Banana']; _gpsTrackerClass in (uniformItems _player + vestItems _player + backpackItems _player + items _player)";
					exceptions[] = {};
					statement = "[vehicle _player, _player] call ROOT_fnc_aceAttachGPSTracker;";
				};
			};
        };
    };
};
