# Terminal Commands

Complete reference for all Root's Cyber Warfare terminal commands.

## Table of Contents

- [Basic Commands](#basic-commands)
- [Device Control](#device-control)
- [GPS Commands](#gps-commands)
- [System Commands](#system-commands)

## Basic Commands

### help

**Syntax**: `help`

**Description**: Display available commands

**Output**: List of all available terminal commands with brief descriptions

**Power Cost**: None

---

### devices

**Syntax**: `devices`

**Description**: List all hackable devices accessible from the current laptop

**Output**: Organized list by device type:
- Doors (Buildings)
- Lights
- Vehicles
- Drones
- Custom Devices
- GPS Trackers
- Databases

Each device shows:
- Device ID (4-digit number)
- Device name/description
- Current status (where applicable)

**Power Cost**: None

---

## Device Control

### door

Control building doors (lock/unlock)

**Syntax**:
```
door <device_id> lock
door <device_id> unlock
door <device_id> status
```

**Parameters**:
- `device_id`: 4-digit device ID from `devices` command
- `lock`: Lock the door
- `unlock`: Unlock the door
- `status`: Show current door status

**Examples**:
```
door 1234 unlock
door 1234 lock
door 1234 status
```

**Power Cost**: Configurable (default: 2 Wh)

**Notes**:
- Works on all doors in the building
- Some buildings may be marked "UNBREACHABLE" (cannot be breached with ACE explosives)
- Locked doors prevent AI and players from opening them

---

### light

Control lights (street lamps, building lights)

**Syntax**:
```
light <device_id> on
light <device_id> off
light <device_id> toggle
```

**Parameters**:
- `device_id`: 4-digit device ID from `devices` command
- `on`: Turn light on
- `off`: Turn light off
- `toggle`: Switch light state (on↔off)

**Examples**:
```
light 5678 on
light 5678 off
light 5678 toggle
```

**Power Cost**: Configurable (default: 2 Wh)

**Notes**:
- Instant effect
- Affects all lights in multi-lamp fixtures

---

### vehicle

Control vehicle systems (fuel, speed, brakes, engine, etc.)

**Syntax**:
```
vehicle <device_id> fuel <0-100>
vehicle <device_id> speed <value>
vehicle <device_id> brakes <on|off>
vehicle <device_id> lights <on|off>
vehicle <device_id> engine <on|off>
vehicle <device_id> alarm
```

**Parameters**:
- `device_id`: 4-digit device ID from `devices` command
- `fuel <0-100>`: Set fuel/battery level (percentage)
- `speed <value>`: Set maximum speed (km/h)
- `brakes <on|off>`: Apply or release brakes
- `lights <on|off>`: Control lights (empty vehicles only)
- `engine <on|off>`: Start or stop engine
- `alarm`: Trigger vehicle alarm sound

**Examples**:
```
vehicle 2468 fuel 0          # Drain fuel
vehicle 2468 speed 30        # Limit to 30 km/h
vehicle 2468 brakes on       # Apply brakes
vehicle 2468 engine off      # Kill engine
vehicle 2468 alarm           # Trigger alarm
```

**Power Cost**: Configurable per-vehicle (default: 2 Wh)

**Notes**:
- Not all features available on all vehicles (depends on configuration)
- Light control only works on empty/non-AI controlled vehicles
- Speed limit persists until changed
- Fuel can be drained or added

---

### drone

Control drones/UAVs (faction change, disable)

**Syntax**:
```
drone <device_id> side <BLUFOR|OPFOR|INDEPENDENT|CIVILIAN>
drone <device_id> disable
```

**Parameters**:
- `device_id`: 4-digit device ID from `devices` command
- `side <faction>`: Change drone faction
  - `BLUFOR`: NATO/friendly forces
  - `OPFOR`: Enemy forces
  - `INDEPENDENT`: Independent/guerrilla forces
  - `CIVILIAN`: Civilian faction
- `disable`: Permanently disable the drone

**Examples**:
```
drone 3579 side OPFOR        # Turn friendly drone hostile
drone 3579 side BLUFOR       # Turn hostile drone friendly
drone 3579 disable           # Disable permanently
```

**Power Cost**:
- Faction change: Configurable (default: 20 Wh)
- Disable: Configurable (default: 10 Wh)

**Notes**:
- Faction change affects drone's targeting and IFF
- Disable is permanent and cannot be undone
- Drone crew/AI changes with faction

---

### custom

Activate/deactivate custom devices

**Syntax**:
```
custom <device_id> activate
custom <device_id> deactivate
```

**Parameters**:
- `device_id`: 4-digit device ID from `devices` command
- `activate`: Run activation code
- `deactivate`: Run deactivation code

**Examples**:
```
custom 9876 activate
custom 9876 deactivate
```

**Power Cost**: Configurable (default: 10 Wh)

**Notes**:
- Effect depends on script configured by mission maker
- Activation/deactivation code set during device registration
- Can trigger any scripted event (explosions, spawns, variables, etc.)

---

### database

Download files from databases

**Syntax**:
```
database <device_id> download
```

**Parameters**:
- `device_id`: 4-digit device ID from `devices` command
- `download`: Download the file

**Examples**:
```
database 4321 download
```

**Power Cost**: Configurable (default: 5 Wh)

**Output**: Displays file contents in terminal

**Notes**:
- File content is configured by mission maker
- Can contain mission intel, passwords, coordinates, etc.
- Download is instant

---

## GPS Commands

### gps list

List all GPS trackers

**Syntax**: `gps list`

**Description**: Shows all active GPS trackers with details

**Output**: For each tracker:
- Device ID
- Target name
- Last known position (grid coordinates)
- Last update time
- Active status

**Power Cost**: None

**Example**:
```
gps list
```

---

### gps locate

Get detailed position for a specific tracker

**Syntax**: `gps locate <device_id>`

**Parameters**:
- `device_id`: 4-digit device ID from `devices` or `gps list` command

**Description**: Shows detailed position information for a GPS tracker

**Output**:
- Target name
- Grid coordinates
- Latitude/Longitude (optional)
- Last update timestamp
- Distance from laptop (optional)
- Active status

**Power Cost**: None

**Examples**:
```
gps locate 7890
```

**Notes**:
- Trackers update at configured intervals (CBA setting)
- Destroyed targets stop updating
- Position may be slightly outdated depending on update interval

---

### gps attach

Attach GPS tracker to unit/vehicle

**Syntax**: Via ACE interaction menu only (not terminal command)

**Description**: Attach a GPS tracker to a target

**Usage**:
1. Approach target unit/vehicle
2. ACE interaction menu (Windows key)
3. Select "Attach GPS Tracker"
4. Tracker appears in `gps list`

**Power Cost**: None (attachment action)

**Notes**:
- Tracker persists until target destroyed
- Automatic position updates
- Can track both units and vehicles

---

## System Commands

### clear

**Syntax**: `clear`

**Description**: Clear terminal screen

**Power Cost**: None

---

### exit

**Syntax**: `exit`

**Description**: Close terminal

**Power Cost**: None

---

## Command Syntax Reference

### General Format

```
<command> <device_id> <action> [parameters]
```

### Device ID Format

- 4-digit number (1000-9999)
- Unique per device
- Obtain from `devices` command

### Common Actions

- `on` / `off`: Binary state control
- `activate` / `deactivate`: Custom device control
- `lock` / `unlock`: Door control
- `toggle`: Switch state

### Parameter Types

- `<number>`: Numeric value (e.g., fuel percentage, speed)
- `<on|off>`: Boolean choice
- `<faction>`: Faction name (BLUFOR, OPFOR, etc.)
- `<device_id>`: 4-digit device identifier

## Error Messages

### "Device not found"

**Cause**: Invalid device ID or device destroyed

**Solution**: Use `devices` command to verify device ID

---

### "Insufficient power"

**Cause**: Laptop battery too low

**Solution**: Recharge laptop via AE3 power management

---

### "Access denied"

**Cause**: Laptop doesn't have permission for this device

**Solution**: Contact Zeus/mission maker for access

---

### "Invalid parameters"

**Cause**: Incorrect command syntax

**Solution**: Check command syntax in this guide or use `help`

---

### "Feature not available"

**Cause**: Vehicle/device doesn't support requested feature

**Solution**: Check available features with `devices` command

---

## Tips

### Efficiency

- Use `devices` command to plan operations before executing
- Write down critical device IDs for quick access
- Check power level before starting complex operations

### Tab Completion

Some terminal implementations support tab completion for commands (depends on AE3 configuration)

### Command History

Use arrow keys (↑/↓) to navigate command history (depends on AE3 configuration)

### Case Sensitivity

Commands are typically case-insensitive, but parameters (like faction names) may be case-sensitive

---

For more information, see:
- [Player Guide](Player-Guide) - Usage examples and strategies
- [Configuration Guide](Configuration) - Power costs and settings
- [API Reference](API-Reference) - Function implementation details
