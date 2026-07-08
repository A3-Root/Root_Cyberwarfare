---
topic: zeus-and-eden-setup
status: verified
last-verified: 2026-07-08
confidence_score: 0.93
priority: core
rank: 3
tokens: 330
code-paths:
  - addons/main/functions/3den/
  - addons/main/functions/zeus/
  - addons/main/CfgVehicles.hpp
  - addons/main/CfgFunctions.hpp
related-topics:
  - device-registry-and-access
  - terminal-and-desktop
---

## overview
Mission-maker setup layer for RootCW. Zeus and 3DEN modules are thin editors over the same server-side registration functions, so mission authors can place or bulk-register hackable content without hand-writing calls.

## current behavior
- `CfgFunctions.hpp` exposes Zeus, 3DEN, core, and utility functions by category.
- `CfgVehicles.hpp` defines Zeus modules and 3DEN logic modules for hacking tools, hackable laptops, devices, databases, vehicles, GPS trackers, lights, doors, power generators, and custom devices.
- `Root_fnc_registerHackableLaptopZeus` prompts for a laptop name and calls the server-side register function.
- `Root_fnc_registerHackableLaptopZeusMain` marks the laptop as a hackable station and stores the display name used by link dialogs.
- `Root_fnc_addHackingToolsZeusMain` installs the file tree and, in the `OPS_DEBUG` case, can attach a debug backdoor prefix.
- 3DEN modules call the same server-side registration functions as Zeus, including radius-mode bulk registration for vehicles, databases, and custom devices.

## decisions
- Keep module UIs thin and push the real work into server-side functions, so Zeus and 3DEN stay in sync.
- Use a running index for generated laptop and vehicle names, so mission makers get stable defaults even when they skip naming.
- Treat radius mode as a bulk convenience over the same registration path, not as a separate data model.
- Skip logic modules during radius scans, because they are editor artifacts rather than game objects worth registering.

## gotchas
- `OPS_DEBUG` handling is special-case behavior and should not be assumed for normal missions.
- The custom laptop name falls back to the object display name when the curator leaves it blank.
- The station flag and the toolset are separate states; placing one does not imply the other.
- Radius mode can recurse into the same registration path many times, so it inherits all of the underlying access and public-device rules.

## references
- `addons/main/functions/3den/`
- `addons/main/functions/zeus/`
- `addons/main/CfgVehicles.hpp`
- `addons/main/CfgFunctions.hpp`
