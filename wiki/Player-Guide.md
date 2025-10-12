# Player Guide

This guide teaches you how to use Root's Cyber Warfare as a player in-game.

## Overview

As a cyber warfare operator, you'll use laptops equipped with hacking tools to control devices remotely. This includes doors, lights, drones, vehicles, and more. All operations consume laptop battery power, so manage your resources wisely.

---

## Getting Started

### Finding a Hacking Laptop

Mission makers will place laptops in the mission. Look for:
- Laptop objects on tables or desks
- Items in your inventory (if pre-equipped)
- Zeus-placed laptops during dynamic missions

### Accessing the Terminal

1. **Approach a laptop** with hacking tools installed
2. **Use ACE interaction** (default: Windows key)
3. **Select**: `ArmaOS` → `Use`
4. **Terminal opens** - You're now in the AE3 virtual filesystem

---

## Understanding the Terminal

The terminal is a command-line interface similar to Linux/Unix terminals.

### Basic Terminal Navigation

```bash
# See available commands
ls /rubberducky/tools

# View help
cat /rubberducky/tools/guide.txt

# List all accessible devices
/rubberducky/tools/devices
```

### Terminal Syntax

All hacking commands follow this pattern:
```bash
/path/to/command [arguments]
```

Example:
```bash
/rubberducky/tools/door 1234 lock
```

---

## Power Management

Every hacking operation consumes battery power (measured in Wh - Watt-hours).

### Checking Battery Level

Your laptop's battery level is displayed in the AE3 interface. Before executing commands:

1. **Check power cost** - Commands show power requirements before execution
2. **Confirm operation** - Most commands prompt "Are you sure? (Y/N)"
3. **Monitor battery** - If power is insufficient, the command will fail

### Power Consumption Examples

| Operation | Typical Cost |
|-----------|-------------|
| Lock/Unlock Door | 2 Wh |
| Toggle Light | 0 Wh (instant) |
| Change Drone Faction | 20 Wh |
| Disable Drone | 10 Wh |
| GPS Tracking | 2 Wh |
| Custom Device | 10 Wh |
| Vehicle Hacking | 2 Wh per action |

**Note**: Mission makers can configure these costs via CBA settings.

---

## Basic Commands

### 1. List Devices (`devices`)

Lists all devices you have access to in the network.

**Usage**:
```bash
/rubberducky/tools/devices
```

**Output**:
```
Building: 1234 (Land_Cargo_House_V1_F) located at Grid - 123456
    Door: 1  locked closed
    Door: 2  unlocked open

Lights:
    Light: 5678 (Land_LampShabby_F) @ 123457  OFF

Drones:
    Drone: 9012  'EAST' B_UAV_02_F  @ 123458

Files:
    File: Secret Intel (ID: 3456)    Est. Transfer Time: 10 seconds

GPS Trackers:
    Target_Vehicle (ID: 7890) - Track Time: 60s - Frequency: 5s - Untracked

Vehicles:
    Vehicle: 1111 - Offroad_01 (C_Offroad_01_F) - Battery, Speed, Engine @ 123459
```

### 2. View Guide (`guide.txt`)

Displays in-game help text.

**Usage**:
```bash
cat /rubberducky/tools/guide.txt
```

---

## Door Control

Control building doors (lock/unlock).

### Command: `door`

**Syntax**:
```bash
/rubberducky/tools/door <doorID> <state>
/rubberducky/tools/door <buildingID> <doorNumber> <state>
```

**Arguments**:
- `<doorID>`: Building ID from `devices` command
- `<doorNumber>`: Specific door number (1, 2, 3, etc.)
- `<state>`: `lock` or `unlock`

**Examples**:
```bash
# Lock door 1 of building 1234
/rubberducky/tools/door 1234 1 lock

# Unlock door 2 of building 1234
/rubberducky/tools/door 1234 2 unlock

# Lock all doors in building 1234
/rubberducky/tools/door 1234 a lock
```

**Power Cost**: 2 Wh per door (default)

---

## Light Control

Toggle lights on/off.

### Command: `light`

**Syntax**:
```bash
/rubberducky/tools/light <lightID> <state>
```

**Arguments**:
- `<lightID>`: Light ID from `devices` command, or `a` for all lights
- `<state>`: `on` or `off`

**Examples**:
```bash
# Turn on light 5678
/rubberducky/tools/light 5678 on

# Turn off light 5678
/rubberducky/tools/light 5678 off

# Turn all lights on
/rubberducky/tools/light a on
```

**Power Cost**: 0 Wh (instant)

---

## Drone Hacking

Control or disable drones.

### Command: `changedrone`

Change a drone's faction/side.

**Syntax**:
```bash
/rubberducky/tools/changedrone <droneID> <faction>
```

**Arguments**:
- `<droneID>`: Drone ID from `devices`, or `a` for all drones
- `<faction>`: `west`, `east`, `guer` (independent), or `civ` (civilian)

**Examples**:
```bash
# Change drone 9012 to BLUFOR
/rubberducky/tools/changedrone 9012 west

# Change all drones to OPFOR
/rubberducky/tools/changedrone a east
```

**Power Cost**: 20 Wh per drone (default)

### Command: `disabledrone`

Destroy/disable a drone.

**Syntax**:
```bash
/rubberducky/tools/disabledrone <droneID>
```

**Examples**:
```bash
# Disable drone 9012
/rubberducky/tools/disabledrone 9012

# Disable all drones
/rubberducky/tools/disabledrone a
```

**Power Cost**: 10 Wh per drone (default)

---

## Database/File Access

Download files from the network to your laptop.

### Command: `download`

**Syntax**:
```bash
/rubberducky/tools/download <fileID>
```

**Arguments**:
- `<fileID>`: Database/file ID from `devices` command

**Example**:
```bash
# Download file 3456
/rubberducky/tools/download 3456
```

**Output**:
```
Downloading File: 050%. [############.............]
Downloading File: 100%. [#########################]
File saved to: '/rubberducky/tools/Files/Secret_Intel.txt'
Exit the terminal and re-open to see the 'Files' directory updated.
```

**Reading Downloaded Files**:
```bash
cat /rubberducky/tools/Files/Secret_Intel.txt
```

**Power Cost**: 0 Wh (no cost to download)

---

## GPS Tracking

Track objects with GPS trackers attached.

### Command: `gpstrack`

**Syntax**:
```bash
/rubberducky/tools/gpstrack <trackerID>
```

**Arguments**:
- `<trackerID>`: GPS tracker ID from `devices` command

**Example**:
```bash
# Start tracking target 7890
/rubberducky/tools/gpstrack 7890
```

**Output**:
```
Power Cost: 2Wh.
Are you sure? (Y/N): y
Tracking started for: Target_Vehicle (ID: 7890)
Power Cost: 2Wh
New Power Level: 498Wh
```

**Map Display**:
- A marker appears on your map showing the target's position
- Marker updates every 5 seconds (configurable)
- Tracking stops after 60 seconds (configurable)
- Red "last ping" marker shows final position for 30 seconds

**Power Cost**: 2 Wh per tracking session (default)

---

## Vehicle Hacking

Manipulate vehicle parameters remotely.

### Command: `vehicle`

**Syntax**:
```bash
/rubberducky/tools/vehicle <vehicleID> <action> <value>
```

**Arguments**:
- `<vehicleID>`: Vehicle ID from `devices` command
- `<action>`: `battery`, `speed`, `brakes`, `lights`, `engine`, `alarm`
- `<value>`: Action-specific value

**Actions & Values**:

| Action | Value | Description |
|--------|-------|-------------|
| `battery` | `0-100` | Set fuel/battery % (101+ = destroy) |
| `speed` | `number` | Adjust velocity (m/s) |
| `brakes` | `any` | Apply emergency brakes |
| `lights` | `on/off` | Toggle vehicle lights (empty vehicles only) |
| `engine` | `on/off` | Toggle engine |
| `alarm` | `1-60` | Sound alarm for N seconds |

**Examples**:
```bash
# Drain vehicle battery to 10%
/rubberducky/tools/vehicle 1111 battery 10

# Increase speed by 20 m/s
/rubberducky/tools/vehicle 1111 speed 20

# Apply brakes
/rubberducky/tools/vehicle 1111 brakes

# Turn on lights
/rubberducky/tools/vehicle 1111 lights on

# Sound alarm for 10 seconds
/rubberducky/tools/vehicle 1111 alarm 10
```

**Power Cost**: 2 Wh per action (default)

---

## Custom Devices

Mission makers can create custom hackable devices. These appear in the `devices` list under "Custom Devices".

### Command: `custom`

**Syntax**:
```bash
/rubberducky/tools/custom <deviceID> <state>
```

**Arguments**:
- `<deviceID>`: Custom device ID
- `<state>`: `activate` or `deactivate`

**Example**:
```bash
# Activate custom device 4444
/rubberducky/tools/custom 4444 activate
```

**Power Cost**: 10 Wh (default)

---

## GPS Tracker Placement (ACE Interaction)

You can physically place GPS trackers on objects (including yourself) and search the said tracker on other objects (excluding yourself) using ACE interactions.

### Requirements

- GPS tracker item in inventory (default: `ACE_Banana` - configurable by mission maker)
- Optional GPS Detection item in inventory (default: `Any Spectrum Device from Contact DLC` - configurable by mission maker)
- Target object (vehicle, player, etc.)

### Placing a GPS Tracker on another Object/Player/Vehicle

1. **Approach target** with GPS tracker item in inventory
2. **Use ACE interaction** (Windows key)
3. **Select**: `Attach GPS Tracker`
4. **Configure settings** in ZEN dialog:
   - Tracking Time (seconds)
   - Update Frequency (seconds)
5. **Confirm** - GPS tracker is placed and item is consumed

### Placing a GPS Tracker on yourself

1. **Approach target** with GPS tracker item in inventory
2. **Use ACE Self-Interaction** (Control key + Windows key)
3. **Select**: `Equipment` → `Attach GPS Tracker`
4. **Configure settings** in ZEN dialog:
   - Tracking Time (seconds)
   - Update Frequency (seconds)
5. **Confirm** - GPS tracker is placed and item is consumed

### Searching for GPS Trackers

Players can search for trackers:

1. **Use ACE interaction** on suspected object
2. **Select**: `Search for GPS Tracker`
3. **Success**: 20% chance to find tracker (without Detection item) and 80% chance to find tracker (with Detection item) - configurable by mission maker
4. **If found**: Option to disable the tracker (without Detection item) and find position of all laptops linked to this tracker (with Detection item)

---

## Multiplayer Considerations

- **Power is per-laptop**: Each laptop has its own battery
- **Devices update globally**: Door locks, light states, etc. sync to all players
- **GPS tracking is client-side**: Only the person who initiated the tracking sees the GPS markers

---

## See Also

- [Terminal Commands Reference](Terminal-Commands) - Complete command syntax
- [Configuration Reference](Configuration) - Learn about mission settings

---

**Need help?** Contact your mission maker or join discord or raise an issue in GitHub.
