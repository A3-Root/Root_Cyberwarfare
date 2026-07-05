class Extended_PreInit_EventHandlers {
	class root_cyberwarfare_pre_init {
		init = "call compile preprocessFileLineNumbers '\z\root_cyberwarfare\addons\main\XEH_preInit.sqf'";
	};
};

class Extended_PostInit_EventHandlers {
	class root_cyberwarfare_post_init {
		init = "call compile preprocessFileLineNumbers '\z\root_cyberwarfare\addons\main\XEH_postInit.sqf'";
	};
};

class Extended_Init_EventHandlers {
	// Seed every Rubberducky drive object (placed, spawned or connected) with its read-only, pre-armed
	// hacking-tools filesystem and pickup marker.
	class ROOT_Rubberducky_Object {
		class root_cyberwarfare_rubberducky_init {
			init = "(_this select 0) call Root_fnc_seedRubberducky";
		};
	};
};
