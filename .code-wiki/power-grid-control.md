---
topic: power-grid-control
status: verified
last-verified: 2026-11-03
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
- Registry row index 10 is the effect area `[centerASL, a, b, angle, isRectangle]`; `[]` means the radius around the generator. Callers pass the area, else the radius, to `getPowerGridObjects` as its second argument.
- 3DEN: synced objects are the grids, the module area is the effect area. Missions without `objectArea` fall back to the legacy radius attribute.
- Zeus: dialog adds shape, size B and angle; `zen_common_fnc_selectPosition` picks the area center, Escape centers it on the generator.
- GUI map marker takes the area shape, size and direction.

## decisions
- Derive coverage directly from the registry row so the map view and the action target the same radius.
- `Root_fnc_getPowerGridObjects [_gridObject, _radius, _excluded]` is the one affected-object query; the action, the GUI count and `powerGridControl` call it.
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
