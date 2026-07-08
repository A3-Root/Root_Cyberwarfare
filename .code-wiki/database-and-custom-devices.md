---
topic: database-and-custom-devices
status: verified
last-verified: 2026-07-08
confidence_score: 0.93
priority: core
rank: 7
tokens: 360
code-paths:
  - addons/main/functions/database/
  - addons/main/functions/custom/
  - addons/main/functions/cipher/
  - addons/main/functions/utility/fn_syncDeviceData.sqf
related-topics:
  - device-registry-and-access
  - terminal-and-desktop
---

## overview
Database downloads and scripted custom devices. This is the subsystem that moves content into the AE3 filesystem and runs mission-defined activation or deactivation code.

## current behavior
- `Root_fnc_addDatabaseZeusMain` registers a file-like device with content, size, optional execution code, and optional encryption.
- `Root_fnc_downloadDatabase` checks access, streams a loading bar in the terminal, writes the file into the AE3 filesystem, and can execute follow-up code after download.
- `Root_fnc_addCustomDeviceZeusMain` registers a custom device with activation and deactivation code.
- `Root_fnc_addCustomDeviceZeusMain` supports both direct object mode and radius bulk-registration mode.
- `Root_fnc_customDevice` executes the custom device behavior at runtime.
- `Root_fnc_cipherOptionsFromText`, `Root_fnc_cipherProcess`, `Root_fnc_os_crack`, and `Root_fnc_os_crypto` support the encrypted database path and security commands.

## decisions
- Store encrypted database content in encrypted form on the object when the mission maker requests encryption, so the registry holds the same payload the player downloads.
- Run custom device code from mission-defined strings, because the feature is meant to be programmable rather than declarative.
- Let custom devices optionally hide their location, so a mission maker can build devices that are only visible through other clues.
- Treat download completion as a terminal event that may trigger script execution, not just a file copy.

## gotchas
- Custom device radius mode recurses through the same registration function, so any direct-mode bug is amplified across the bulk set.
- The direct and radius signatures differ, so callers have to pass the correct shape of arguments.
- Database downloads are tied to file size and can take a long time on large entries.
- Downloaded content may execute mission code after the file is written.
- If the AE3 filesystem is not initialized, the network-scan export path and file writes will fail.

## references
- `addons/main/functions/database/`
- `addons/main/functions/custom/`
- `addons/main/functions/cipher/`
- `addons/main/CfgFunctions.hpp`
