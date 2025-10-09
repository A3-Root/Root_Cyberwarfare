#include "script_mod.hpp"
#include "CfgFunctions.hpp"
#include "CfgVehicles.hpp"
#include "CfgFactionClasses.hpp"

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
			"ROOT_CyberWarfareAddFileZeus",
			"ROOT_CyberWarfareAddGPSTrackerZeus",
			"ROOT_CyberWarfareAddVehicleZeus"
		};
		requiredAddons[] = {
			"A3_Modules_F_Curator",
			"cba_main",
			"3DEN",
			"zen_custom_modules",
			"ae3_main",
			"ae3_filesystem"
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

#include "CfgEventHandlers.hpp"
#include "CfgSounds.hpp"
