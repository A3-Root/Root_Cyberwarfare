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
