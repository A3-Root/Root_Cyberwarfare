// Per-instance unique-item pool for the Rubberducky, matching AE3's own flash-drive pattern
// (addons/flashdrive/script_item_macro.hpp in Advanced-Equipment) so picked-up drives buffer their
// filesystem by a unique class per instance instead of collapsing to one shared item. Defined locally
// (DOUBLES/TRIPLES/QUOTE come from CBA, already available via script_mod.hpp) since HEMTT can't resolve
// an #include into another mod's project tree.
// The per-instance ID classes descend from Item_FlashDisk_AE3, which is what the laptop Connect menu
// tests for: a picked-up drive is buffered as its ID class, so every ID class has to stay inside that
// branch of the tree or it could never be plugged back in. ae3_vehicle keeps it paired with the
// Rubberducky world object, and ace_arsenal_uniqueBase keeps every instance under the single arsenal entry.
#define RUBBERDUCKY_ID_ENTRY(IDN) \
    class TRIPLES(ROOT_Rubberducky_Item,ID,IDN): Item_FlashDisk_AE3 { \
        ae3_id = IDN; \
        ae3_vehicle = "ROOT_Rubberducky_Object"; \
        displayName = QUOTE(Rubberducky USB IDN); \
        descriptionShort = QUOTE(Rubberducky USB IDN); \
        scope = 1; \
        scopeArsenal = 0; \
        scopeCurator = 0; \
        ace_arsenal_uniqueBase = "ROOT_Rubberducky_Item"; \
        class Armory { disabled = 1; }; \
    }

class CfgWeapons {
	class Item_FlashDisk_AE3;   // AE3 flash-drive item (parent so the laptop Connect menu lists this drive)

	// Rubberducky USB: a flash drive pre-armed with the hacking toolset. Inherits the AE3 flash drive so
	// it plugs into laptops through the stock USB Connect menu, and uses the same per-instance
	// item<->object buffering as a regular flash drive (RUBBERDUCKY_ID_ENTRY below) so its filesystem -
	// seeded with the hacking tools on first connect - persists across mount/unmount instead of resetting.
	class ROOT_Rubberducky_Item: Item_FlashDisk_AE3 {
		author = "Root";
		scope = 2;
		scopeArsenal = 2;
		displayName = "Rubberducky USB";
		descriptionShort = "USB pre-loaded with hacking tools. Plug into a laptop to enable hacking.";
		ae3_vehicle = "ROOT_Rubberducky_Object";
	};

	RUBBERDUCKY_ID_ENTRY(1); RUBBERDUCKY_ID_ENTRY(2); RUBBERDUCKY_ID_ENTRY(3); RUBBERDUCKY_ID_ENTRY(4);
	RUBBERDUCKY_ID_ENTRY(5); RUBBERDUCKY_ID_ENTRY(6); RUBBERDUCKY_ID_ENTRY(7); RUBBERDUCKY_ID_ENTRY(8);
	RUBBERDUCKY_ID_ENTRY(9); RUBBERDUCKY_ID_ENTRY(10); RUBBERDUCKY_ID_ENTRY(11); RUBBERDUCKY_ID_ENTRY(12);
	RUBBERDUCKY_ID_ENTRY(13); RUBBERDUCKY_ID_ENTRY(14); RUBBERDUCKY_ID_ENTRY(15); RUBBERDUCKY_ID_ENTRY(16);
	RUBBERDUCKY_ID_ENTRY(17); RUBBERDUCKY_ID_ENTRY(18); RUBBERDUCKY_ID_ENTRY(19); RUBBERDUCKY_ID_ENTRY(20);
	RUBBERDUCKY_ID_ENTRY(21); RUBBERDUCKY_ID_ENTRY(22); RUBBERDUCKY_ID_ENTRY(23); RUBBERDUCKY_ID_ENTRY(24);
	RUBBERDUCKY_ID_ENTRY(25); RUBBERDUCKY_ID_ENTRY(26); RUBBERDUCKY_ID_ENTRY(27); RUBBERDUCKY_ID_ENTRY(28);
	RUBBERDUCKY_ID_ENTRY(29); RUBBERDUCKY_ID_ENTRY(30); RUBBERDUCKY_ID_ENTRY(31); RUBBERDUCKY_ID_ENTRY(32);
};
