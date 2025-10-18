# Configuration Guide

This guide covers all CBA settings and configuration options for Root's Cyber Warfare.

## Table of Contents

- [CBA Settings](#cba-settings)
- [Power Costs](#power-costs)
- [GPS Settings](#gps-settings)
- [Advanced Configuration](#advanced-configuration)

## CBA Settings

Root's Cyber Warfare uses CBA (Community Base Addons) for configuration. Access settings via:

**Main Menu → Options → Addon Options → Root's Cyber Warfare**

or in-game via:

**ESC → Addon Options → Root's Cyber Warfare**

## Power Costs

All hacking operations consume power from the laptop battery (managed by AE3). Configure power costs for different operations:

### Door Operations

**Setting**: `ROOT_CYBERWARFARE_COST_DOOR_EDIT`
**Default**: 2 Wh
**Range**: 1-100 Wh
**Description**: Power cost to lock/unlock a door

**Use Cases:**
- Low (1-2 Wh): Easy missions, plentiful power
- Medium (3-5 Wh): Balanced gameplay
- High (10+ Wh): Difficult missions, power management critical

### Light Operations

**Setting**: `ROOT_CYBERWARFARE_COST_LIGHT_EDIT`
**Default**: 2 Wh
**Range**: 1-100 Wh
**Description**: Power cost to control lights (on/off/toggle)

### Drone Faction Change

**Setting**: `ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT`
**Default**: 20 Wh
**Range**: 1-100 Wh
**Description**: Power cost to change drone faction

**Rationale**: Higher cost reflects significant impact of faction change

### Drone Disable

**Setting**: `ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT`
**Default**: 10 Wh
**Range**: 1-100 Wh
**Description**: Power cost to permanently disable a drone

### Custom Device Operations

**Setting**: `ROOT_CYBERWARFARE_COST_CUSTOM_EDIT`
**Default**: 10 Wh
**Range**: 1-100 Wh
**Description**: Default power cost for custom device activation/deactivation

**Note**: Individual custom devices can override this with their own power cost settings

### Vehicle Operations

Vehicle hacking power costs are configured per-vehicle when registered (not via CBA settings). Default: 2 Wh

## GPS Settings

### GPS Tracker Update Interval

**Setting**: `ROOT_CYBERWARFARE_GPS_UPDATE_INTERVAL`
**Default**: 10 seconds
**Range**: 5-300 seconds
**Description**: How often GPS trackers update their position

## Advanced Configuration

### Server-Side Settings

Most CBA settings are enforced server-side. Clients inherit server settings automatically.

**To force server settings:**
1. Configure settings in server's CBA_settings.sqf
2. Set "Force" option to true for each setting
3. Clients cannot override forced settings

### Mission-Specific Configuration

Override CBA settings in mission init:

```sqf
// Set custom power costs for this mission
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DOOR_EDIT", 5, true];
missionNamespace setVariable ["ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT", 30, true];
```

### Difficulty Profiles

**Easy Mode:**
```sqf
// Low power costs, generous gameplay
ROOT_CYBERWARFARE_COST_DOOR_EDIT = 1;
ROOT_CYBERWARFARE_COST_LIGHT_EDIT = 1;
ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT = 10;
ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT = 5;
ROOT_CYBERWARFARE_COST_CUSTOM_EDIT = 5;
ROOT_CYBERWARFARE_GPS_UPDATE_INTERVAL = 5;
```

**Normal Mode (Default):**
```sqf
ROOT_CYBERWARFARE_COST_DOOR_EDIT = 2;
ROOT_CYBERWARFARE_COST_LIGHT_EDIT = 2;
ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT = 20;
ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT = 10;
ROOT_CYBERWARFARE_COST_CUSTOM_EDIT = 10;
ROOT_CYBERWARFARE_GPS_UPDATE_INTERVAL = 10;
```

**Hard Mode:**
```sqf
// High power costs, resource management critical
ROOT_CYBERWARFARE_COST_DOOR_EDIT = 5;
ROOT_CYBERWARFARE_COST_LIGHT_EDIT = 3;
ROOT_CYBERWARFARE_COST_DRONE_SIDE_EDIT = 40;
ROOT_CYBERWARFARE_COST_DRONE_DISABLE_EDIT = 20;
ROOT_CYBERWARFARE_COST_CUSTOM_EDIT = 20;
ROOT_CYBERWARFARE_GPS_UPDATE_INTERVAL = 20;
```

### Power Management Best Practices

**Calculating Mission Power Budget:**

1. Count expected hacking operations
2. Multiply by power costs
3. Ensure laptop batteries can sustain operations
4. Provide power sources/generators if needed

**Example:**
```
Mission: Infiltrate enemy base
- Unlock 3 doors: 3 × 2 Wh = 6 Wh
- Disable 2 lights: 2 × 2 Wh = 4 Wh
- Disable 1 drone: 1 × 10 Wh = 10 Wh
Total: 20 Wh required

Laptop battery (AE3): ~50 Wh typical
Result: Sufficient power with buffer
```

## Troubleshooting

### Settings Not Applying

**Problem**: Changed CBA settings but they don't work

**Solutions:**
- Restart mission
- Check server has forced settings
- Verify you have admin/host privileges
- Check RPT log for errors

### Power Costs Too High/Low

**Problem**: Gameplay feels unbalanced due to power costs

**Solutions:**
- Adjust CBA settings to match desired difficulty
- Test with different values
- Consider mission design (provide more/fewer laptops)
- Balance power costs with mission objectives

### GPS Trackers Not Updating

**Problem**: GPS trackers show old positions

**Solutions:**
- Check GPS update interval setting
- Verify tracker is still attached
- Ensure tracked unit is not destroyed
- Check network connectivity (multiplayer)

---

For more information, see:
- [Player Guide](Player-Guide.md) - Power management from player perspective
- [Mission Maker Guide](Mission-Maker-Guide.md) - Scripting custom settings
- [API Reference](API-Reference.md) - Power-related functions
