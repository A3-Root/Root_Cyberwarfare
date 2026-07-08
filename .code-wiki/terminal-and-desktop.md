---
topic: terminal-and-desktop
status: verified
last-verified: 2026-07-08
confidence_score: 0.94
priority: core
rank: 2
tokens: 380
code-paths:
  - addons/main/functions/gui/
  - addons/main/functions/core/fn_scanNetwork.sqf
  - addons/main/functions/core/fn_scanNetworkCli.sqf
  - addons/main/functions/core/fn_addHackingToolsZeusMain.sqf
  - addons/main/functions/utility/fn_syncDeviceData.sqf
related-topics:
  - device-registry-and-access
  - zeus-and-eden-setup
  - power-grid-control
  - vehicle-and-drone-control
  - gps-tracking
  - database-and-custom-devices
---

## overview
AE3 desktop integration for RootCW. It owns command installation, GUI app registration, request/response wiring, and the network scan view exported from the terminal.

## current behavior
- `Root_fnc_addHackingToolsZeusMain` writes the command tree into the AE3 filesystem and creates the `guide`, `devices`, `door`, `light`, `changedrone`, `disabledrone`, `download`, `custom`, `gpstrack`, `vehicle`, `powergrid`, and `netscan` entries.
- `Root_fnc_gui_registerApps` registers AE3 web apps when the modern desktop exists and falls back to native app registration when only the legacy desktop is present.
- `Root_fnc_gui_requestDevices` asks the server for a filtered device list for a computer and device type.
- `Root_fnc_gui_sendDeviceList` sends device rows back only to the requesting client and inserts a brief scan delay for network enumeration.
- `Root_fnc_gui_appPowergrid` renders the power-grid list and map circle, then sends server events for on, off, and overload actions.
- `Root_fnc_scanNetwork` builds a subnet snapshot from AE3 computer and router registries.
- `Root_fnc_scanNetworkCli` prints network scan results to the terminal and can export them to the laptop filesystem.

## decisions
- Keep the server as the source of truth for device lists, so clients only receive filtered rows and never read the registry directly.
- Support both AE3 web desktop and the older native desktop because the mod has to run in missions that still carry the legacy UI surface.
- Use a visible scan delay for `netscan` so it reads like a real sweep instead of an instant lookup.
- Write command files synchronously when the toolset is installed on the server, because freshly spawned drives can be invalidated in the same frame if writes are deferred.

## gotchas
- If AE3 desktop is absent, GUI registration exits cleanly and nothing is registered.
- `scanNetwork` only reports powered laptops and routers on the same subnet as the scanning laptop.
- `scanNetworkCli` requires an initialized AE3 filesystem or the export fails.
- The request/response path depends on `clientOwner` and per-computer netIds; mismatches break the terminal handshake.

## references
- `addons/main/functions/gui/`
- `addons/main/functions/core/fn_scanNetwork.sqf`
- `addons/main/functions/core/fn_scanNetworkCli.sqf`
- `addons/main/functions/core/fn_addHackingToolsZeusMain.sqf`
- `addons/main/CfgFunctions.hpp`
