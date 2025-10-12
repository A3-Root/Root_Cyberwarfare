# Configuration Reference

Complete reference for all Root's Cyber Warfare settings and configuration options.

## Overview

Root's Cyber Warfare uses **CBA Settings** for all configuration. Settings can be adjusted:
- In-game via ESC → Addon Options → Root Cyberwarfare
- Server-side via `userconfig/cba_settings.sqf`
- Mission-specific via mission config

---

## CBA Settings Menu

### Accessing Settings

1. **In-Game**:
   - Press `ESC`
   - Select `Addon Options`
   - Find `Root Cyberwarfare`
   - Adjust settings
   - Click `OK`

2. **Server Configuration**:
   Edit `userconfig/cba_settings.sqf`:
   ```sqf
   force root_cyberwarfare_gps_tracker_device = "ACE_Banana";
   force root_cyberwarfare_drone_hack_cost = 10;
   ```

3. **Mission Override**:
   In `description.ext`:
   ```cpp
   class CfgSettings {
       class CBA {
           class root_cyberwarfare {
               // Settings here
           };
       };
   };
   ```

---

## GPS Tracker Settings

### `root_cyberwarfare_gps_tracker_device`

**Description**: Item classname used for GPS trackers when placing via ACE interaction.

**Type**: String (item classname)
**Default**: `"ACE_Banana"`
**Category**: GPS System
**Force on Server**: Recommended

**Usage**:
- Players need this item in inventory to place GPS trackers
- Default uses `ACE_Banana` as a placeholder (humorous choice)
- Recommended to change to actual GPS device item

**Examples**:
```sqf
// Use ACE GPS item
force root_cyberwarfare_gps_tracker_device = "ACE_MicroDAGR";

// Use custom item
force root_cyberwarfare_gps_tracker_device = "MyMod_GPS_Tracker_Item";

// Keep default (bananas!)
force root_cyberwarfare_gps_tracker_device = "ACE_Banana";
```

**Notes**:
- Item is consumed when placing tracker
- Mission makers can override per-tracker via Zeus/script
- Setting only affects ACE interaction placement

---

### `root_cyberwarfare_gps_detection_devices`

**Description**: Comma-separated list of device classnames that can detect GPS trackers during search.

**Type**: String (comma-separated classnames)
**Default**: `""`
**Category**: GPS System
**Force on Server**: Recommended

**Usage**:
- Devices in this list improve GPS tracker detection chance
- Base detection: 50% chance
- With detector device: Higher chance (configurable)
- Empty string = no special devices required

**Examples**:
```sqf
// RF detectors
force root_cyberwarfare_gps_detection_devices = "ACE_RangeCard,MyMod_RF_Detector";

// Metal detectors
force root_cyberwarfare_gps_detection_devices = "ItemGPS,ACE_Altimeter";

// No special devices (base 50%)
force root_cyberwarfare_gps_detection_devices = "";
```

**Notes**:
- Player must have device in inventory
- Detection is still probability-based
- Does not guarantee finding tracker

---

## Power Cost Settings

Power costs are measured in **Wh (Watt-hours)**.

### `root_cyberwarfare_drone_hack_cost`

**Description**: Power cost to disable/destroy a drone.

**Type**: Number (Wh)
**Default**: `10`
**Range**: 0-100
**Category**: Power Costs
**Force on Server**: Recommended

**Examples**:
```sqf
// Easy mode (cheap hacking)
force root_cyberwarfare_drone_hack_cost = 2;

// Default
force root_cyberwarfare_drone_hack_cost = 10;

// Hard mode (expensive)
force root_cyberwarfare_drone_hack_cost = 30;

// Free (no cost)
force root_cyberwarfare_drone_hack_cost = 0;
```

---

### `root_cyberwarfare_drone_side_cost`

**Description**: Power cost to change a drone's faction/side.

**Type**: Number (Wh)
**Default**: `20`
**Range**: 0-100
**Category**: Power Costs
**Force on Server**: Recommended

**Examples**:
```sqf
// Easy
force root_cyberwarfare_drone_side_cost = 5;

// Default
force root_cyberwarfare_drone_side_cost = 20;

// Hard
force root_cyberwarfare_drone_side_cost = 50;
```

**Note**: Typically more expensive than destroying since it's more valuable tactically.

---

### `root_cyberwarfare_door_cost`

**Description**: Power cost per door to lock/unlock.

**Type**: Number (Wh)
**Default**: `2`
**Range**: 0-20
**Category**: Power Costs
**Force on Server**: Recommended

**Examples**:
```sqf
// Free door hacking
force root_cyberwarfare_door_cost = 0;

// Default
force root_cyberwarfare_door_cost = 2;

// Expensive (limits usage)
force root_cyberwarfare_door_cost = 10;
```

**Note**: When using "all doors" (`a`), cost is multiplied by number of doors.

---

### `root_cyberwarfare_custom_cost`

**Description**: Power cost for custom device activation/deactivation.

**Type**: Number (Wh)
**Default**: `10`
**Range**: 0-100
**Category**: Power Costs
**Force on Server**: Recommended

**Examples**:
```sqf
// Low-cost custom devices
force root_cyberwarfare_custom_cost = 2;

// Default
force root_cyberwarfare_custom_cost = 10;

// High-impact devices (expensive)
force root_cyberwarfare_custom_cost = 30;
```

**Note**: Individual custom devices can override this via Zeus/script parameters.

---

## Device Type Constants

These constants are used internally for device type identification. **Read-only** - not configurable via CBA.

| Constant | Value | Device Type | Description |
|----------|-------|-------------|-------------|
| `DEVICE_TYPE_DOOR` | 1 | Doors | Building doors |
| `DEVICE_TYPE_LIGHT` | 2 | Lights | Lamps and streetlights |
| `DEVICE_TYPE_DRONE` | 3 | Drones | UAVs |
| `DEVICE_TYPE_DATABASE` | 4 | Files | Downloadable files |
| `DEVICE_TYPE_CUSTOM` | 5 | Custom | Custom devices |
| `DEVICE_TYPE_GPS_TRACKER` | 6 | GPS | GPS trackers |
| `DEVICE_TYPE_VEHICLE` | 7 | Vehicles | Hackable vehicles |

**Usage in scripts**:
```sqf
// Check device type
if (_deviceType == 3) then {
    // It's a drone
};

// Or use constants (if script_macros.hpp included)
#include "\z\root_cyberwarfare\addons\main\script_macros.hpp"
if (_deviceType == DEVICE_TYPE_DRONE) then {
    // It's a drone
};
```

---

## Configuration Examples

### Scenario 1: Easy Mode (Training)

```sqf
// Low power costs, easy GPS detection
force root_cyberwarfare_drone_hack_cost = 2;
force root_cyberwarfare_drone_side_cost = 5;
force root_cyberwarfare_door_cost = 0;
force root_cyberwarfare_custom_cost = 2;
force root_cyberwarfare_gps_tracker_device = "ACE_Banana";
force root_cyberwarfare_gps_detection_devices = "";
```

**Use cases**:
- Training missions
- Story-focused missions
- Casual gameplay
- Testing

---

### Scenario 2: Default (Balanced)

```sqf
// Balanced power costs
force root_cyberwarfare_drone_hack_cost = 10;
force root_cyberwarfare_drone_side_cost = 20;
force root_cyberwarfare_door_cost = 2;
force root_cyberwarfare_custom_cost = 10;
force root_cyberwarfare_gps_tracker_device = "ACE_Banana";
force root_cyberwarfare_gps_detection_devices = "";
```

**Use cases**:
- Standard missions
- Public servers
- Mixed player skill levels

---

### Scenario 3: Hard Mode (Realistic)

```sqf
// High power costs, limited resources
force root_cyberwarfare_drone_hack_cost = 30;
force root_cyberwarfare_drone_side_cost = 50;
force root_cyberwarfare_door_cost = 5;
force root_cyberwarfare_custom_cost = 25;
force root_cyberwarfare_gps_tracker_device = "ACE_MicroDAGR";
force root_cyberwarfare_gps_detection_devices = "ACE_RangeCard,ACE_Altimeter";
```

**Use cases**:
- Milsim operations
- Hardcore servers
- Resource management focus
- Competitive gameplay

---

### Scenario 4: Stealth Focus

```sqf
// Free doors/lights for stealth, expensive combat
force root_cyberwarfare_drone_hack_cost = 20;
force root_cyberwarfare_drone_side_cost = 40;
force root_cyberwarfare_door_cost = 0; // Free for infiltration
force root_cyberwarfare_custom_cost = 0; // Free environmental control
force root_cyberwarfare_gps_tracker_device = "ACE_Banana";
force root_cyberwarfare_gps_detection_devices = "";
```

**Use cases**:
- Stealth missions
- Infiltration scenarios
- Encourage non-lethal approaches

---

## Server Configuration File

### Example `userconfig/cba_settings.sqf`

```sqf
// Root's Cyber Warfare Configuration
// Server: [TAG] Community Server
// Updated: 2025-01-15

// GPS System
force root_cyberwarfare_gps_tracker_device = "ACE_MicroDAGR";
force root_cyberwarfare_gps_detection_devices = "ACE_Altimeter,ACE_RangeCard";

// Power Costs - Balanced for competitive play
force root_cyberwarfare_drone_hack_cost = 15;
force root_cyberwarfare_drone_side_cost = 30;
force root_cyberwarfare_door_cost = 3;
force root_cyberwarfare_custom_cost = 15;

// Add more CBA settings from other mods here...
```

### Force vs Allow

**force**: Server enforces value, players cannot change
```sqf
force root_cyberwarfare_drone_hack_cost = 10; // Server controls this
```

**force (no force keyword)**: Suggests default, players can override
```sqf
root_cyberwarfare_drone_hack_cost = 10; // Player can change
```

**Best Practice**: Use `force` for multiplayer servers to ensure consistency.

---

## Mission-Specific Configuration

### Via description.ext

```cpp
// description.ext
class CfgSettings {
    class CBA {
        class Caching {
            compile = 0;
            xeh = 0;
            functions = 0;
        };
    };
};
```

### Via Init Scripts

```sqf
// init.sqf - Run on mission start

// Override power costs for this mission only
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [5, 30, 15, 20], true];
// Format: [doorCost, droneSideCost, droneHackCost, customCost]

// Note: This overrides global settings but doesn't persist
```

---

## Dynamic Configuration

### Zeus Module: Modify Power

Use the "Modify Power" Zeus module to adjust costs during mission.

### Script-Based

```sqf
// Modify costs mid-mission
private _newCosts = [2, 15, 8, 5]; // [door, droneSide, droneHack, custom]
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", _newCosts, true];
```

**Use cases**:
- Progressive difficulty
- Event triggers (alarm raised = higher costs)
- Time-based scaling
- Performance-based adjustments

---

## Troubleshooting Settings

### Settings Not Applying

**Symptoms**: Changed settings but no effect in-game

**Causes & Solutions**:

1. **Server not forcing**:
   ```sqf
   // Solution: Add "force" keyword
   force root_cyberwarfare_drone_hack_cost = 10;
   ```

2. **File not loaded**:
   - Check file location: `userconfig/cba_settings.sqf`
   - Restart server after editing
   - Check RPT log for CBA loading errors

3. **Mission override**:
   - Mission scripts may override CBA settings
   - Check `init.sqf` for `setVariable` calls

### Verify Current Settings

```sqf
// Debug console
hint str (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []]);
// Should show: [doorCost, droneSideCost, droneHackCost, customCost]
```

---

## Best Practices

### Server Admins

1. **Force all settings** - Prevents player modifications
2. **Test in local** - Verify settings before deploying
3. **Document changes** - Keep comments in `cba_settings.sqf`
4. **Balance for audience** - Adjust based on player feedback

### Mission Makers

1. **Use default CBA settings** - Don't override unless necessary
2. **Document overrides** - Explain why you're changing defaults
3. **Test power costs** - Ensure missions are completable
4. **Consider replayability** - Settings affect difficulty scaling

---

## See Also

- [Mission Maker Guide](Mission-Maker-Guide) - Scripting integration
- [Zeus Guide](Zeus-Guide) - Using Modify Power module
- [Player Guide](Player-Guide) - How power costs affect gameplay
- [Architecture](Architecture) - How settings are stored internally

---

**Need help?** Join discord or raise an issue in GitHub.
