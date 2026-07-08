---
topic: device-registry-and-access
status: verified
last-verified: 2026-07-08
confidence_score: 0.95
priority: core
rank: 1
tokens: 420
code-paths:
  - addons/main/functions/core/
  - addons/main/functions/utility/
  - addons/main/functions/zeus/
related-topics:
  - terminal-and-desktop
  - zeus-and-eden-setup
  - power-grid-control
  - vehicle-and-drone-control
  - gps-tracking
  - database-and-custom-devices
---

## overview
Server-authoritative registry and access model for all hackable devices. It is the shared layer that decides who can see a device, how laptops become stations, and when stale links are cleaned up.

## current behavior
- `ROOT_CYBERWARFARE_ALL_DEVICES` stores eight device categories in mission namespace.
- `ROOT_CYBERWARFARE_LINK_CACHE` tracks laptop-to-device links.
- `ROOT_CYBERWARFARE_PUBLIC_DEVICES` tracks devices exposed to current or future laptops, with per-laptop exclusions when needed.
- `Root_fnc_addComputerDeviceLinks` is used by registration functions to add links atomically.
- `Root_fnc_isDeviceAccessible` gates terminal actions by device type, command path, and link/public state.
- `Root_fnc_registerHackableLaptopZeusMain` marks a laptop as a hackable station and publishes its display name.
- `Root_fnc_addHackingToolsZeusMain` installs the toolset but does not itself make an object a station.
- `Root_fnc_syncHackingToolAvailability` publishes whether a laptop has tools locally or on a mounted USB drive.
- `Root_fnc_runDeviceLinkCleanup` removes stale links and device rows using a strike-based grace period.
- `Root_fnc_initBreachIntegration` blocks breach attempts against cyber-locked doors when the optional breach mod is present.

## decisions
- Keep station registration separate from tool installation, so a laptop can be named and linked before it has a toolset. Supersedes the older implied-coupling behavior where install and station status were treated as one action.
- Support both simple and experimental device setup modes, because the mod can identify laptops by netId in one mode and by player UID in the other.
- Store public device exclusions for current laptops when a device is meant for future laptops, so access does not retroactively appear on machines already in the mission.
- Use strike-based cleanup for missing objects because object references can disappear briefly during replication or player join timing.
- Treat a resolved object as the strongest existence signal. A missing network flag alone is not enough to delete registry data.

## gotchas
- Cleanup must not trust `ROOT_CYBERWARFARE_HACKABLE_LAPTOP` by itself; that flag can lag replication.
- Public devices and link cache both need to stay synchronized with mission namespace, or terminal access will drift from the registry.
- Device IDs are generated randomly and must remain unique across the per-type arrays.
- The simple mode depends on laptop netIds resolving on the server, so null resolution can happen transiently before the grace limit expires.

## references
- `addons/main/functions/core/`
- `addons/main/functions/utility/`
- `addons/main/functions/zeus/`
- `addons/main/CfgFunctions.hpp`
- `addons/main/config.cpp`
