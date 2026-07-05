class CfgWeapons {
	class Item_FlashDisk_AE3;   // AE3 flash-drive item (parent so the laptop Connect menu lists this drive)

	// Rubberducky USB: a single-purpose, read-only flash drive pre-armed with the hacking toolset.
	// Inherits the AE3 flash drive so it plugs into laptops through the stock USB Connect menu, but it
	// is a single stackable item with no per-drive storage. The ROOT_rubberducky flag tells the AE3
	// item<->object bridge to spawn a freshly seeded drive on connect instead of a buffered instance.
	class ROOT_Rubberducky_Item: Item_FlashDisk_AE3 {
		author = "Root";
		scope = 2;
		scopeArsenal = 2;
		displayName = "Rubberducky USB";
		descriptionShort = "Single-purpose USB pre-loaded with hacking tools. Plug into a laptop to enable hacking. Read-only: stores no files.";
		ROOT_rubberducky = 1;
		ae3_vehicle = "ROOT_Rubberducky_Object";
	};
};
