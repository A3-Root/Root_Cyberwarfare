---
topic: power-grid-control
status: verified
last-verified: 2026-07-08
confidence_score: 0.94
priority: core
rank: 4
tokens: 320
code-paths:
  - addons/main/functions/powergenerator/
  - addons/main/functions/gui/fn_gui_appPowergrid.sqf
  - addons/main/functions/utility/fn_syncDeviceData.sqf
related-topics:
  - device-registry-and-access
  - terminal-and-desktop
---

## overview
Power-grid registration and control for lights and electrical areas. The generator stores its own radius, exclusions, and overload behavior, while the GUI provides the operator view and confirm flow.

## current behavior
- `Root_fnc_addPowerGeneratorZeusMain` registers the generator object, radius, overload setting, excluded classes, power cost, and link/public visibility.
- `Root_fnc_powerGridControl` accepts `on`, `off`, and `overload` actions from the terminal.
- `Root_fnc_powerGeneratorLights` toggles the affected lights in the target radius.
- `Root_fnc_gui_appPowergrid` renders a list and live coverage circle, color-coded by generator state.
- Generator state is stored on the object as `ROOT_CYBERWARFARE_POWERGRID_STATE` and `ROOT_CYBERWARFARE_GENERATOR_DESTROYED`.

## decisions
- Derive coverage directly from the registry row so the map view and the action target the same radius.
- Apply the same object query for the displayed "lights affected" count and the action payload, so the UI number matches the actual effect.
- Make overload destructive and one-way, because the mod treats generator destruction as a terminal state.
- Consume power only after confirmation and a successful action path, not during the initial validation pass.

## gotchas
- Overload uses a scripted claymore explosion and cannot be repaired once the generator is marked destroyed.
- Excluded classes affect both the coverage count and the action target list.
- `powergrid` fails if the generator object cannot be resolved from its netId or if the grid has already been destroyed.
- The GUI overload button requires a second click within the confirm window.

## references
- `addons/main/functions/powergenerator/`
- `addons/main/functions/gui/fn_gui_appPowergrid.sqf`
- `addons/main/CfgFunctions.hpp`
