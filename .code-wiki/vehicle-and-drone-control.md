---
topic: vehicle-and-drone-control
status: verified
last-verified: 2026-07-08
confidence_score: 0.92
priority: core
rank: 5
tokens: 420
code-paths:
  - addons/main/functions/vehicle/
  - addons/main/functions/zeus/
  - addons/main/functions/gui/fn_gui_vehicleAction.sqf
related-topics:
  - device-registry-and-access
  - terminal-and-desktop
---

## overview
Vehicle and drone hacking path. Vehicles expose parameter controls with per-object limits and cooldowns, while drones can be disabled or reassigned to a different side.

## current behavior
- `Root_fnc_addVehicleZeusMain` registers vehicles and drones, including bulk radius mode for mission setup.
- Vehicle registration stores per-object limits for fuel, speed, brakes, lights, engine, and alarm actions.
- `Root_fnc_changeVehicleParams` implements the terminal command for battery/fuel, speed, brakes, lights, engine, and alarm control.
- `Root_fnc_gui_vehicleAction` provides the desktop-side action UI.
- `Root_fnc_disableDrone` destroys an accessible drone or all accessible drones.
- `Root_fnc_changeDroneFaction` moves an accessible drone or all accessible drones to a different side by joining a new group.

## decisions
- Use object variables for per-vehicle caps and cooldowns, so mission makers can customize each target independently.
- Treat drone and vehicle registration as one family, because the UI and access model both work from the same registry category.
- Implement speed changes by adding to velocity rather than forcing a hard teleport-like speed set, because the code is acting on a live vehicle state.
- Keep engine and lights under toggle counters and cooldowns, so repeated abuse can be throttled per object.

## gotchas
- `battery` in the terminal help behaves like fuel control, and values over 100 destroy the vehicle.
- Brake control only applies to land vehicles.
- Lights control uses hitpoint damage and AI light toggling, so some vehicles will behave differently depending on their model.
- Drone disable is permanent and removes the drone by damage, not by a reversible state toggle.
- Access checks still apply even when the object exists and is alive.

## references
- `addons/main/functions/vehicle/`
- `addons/main/functions/zeus/`
- `addons/main/functions/gui/fn_gui_vehicleAction.sqf`
- `addons/main/CfgFunctions.hpp`
