# Terminal Commands Reference

Complete reference for all Root's Cyber Warfare terminal commands.

## Command Overview

| Command | Category | Purpose | Power Cost |
|---------|----------|---------|------------|
| `devices` | Info | List all accessible devices | 0 Wh |
| `door` | Control | Lock/unlock building doors | 2 Wh (default) |
| `light` | Control | Toggle lights on/off | 0 Wh |
| `changedrone` | Drone | Change drone faction | 20 Wh (default) |
| `disabledrone` | Drone | Destroy/disable drone | 10 Wh (default) |
| `download` | Data | Download database files | 0 Wh |
| `custom` | Control | Activate custom devices | 10 Wh (default) |
| `gpstrack` | Tracking | Track GPS trackers | 2 Wh (default) |
| `vehicle` | Control | Manipulate vehicle parameters | 2 Wh (default) |

**Note**: Power costs are configurable by mission makers via CBA settings.

---

## `devices` - List Accessible Devices

Lists all devices accessible from this laptop.

### Syntax
```bash
/rubberducky/tools/devices
```

### Arguments
None

### Output

Displays categorized list of all accessible devices:

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

Custom Devices:
    Power Generator Overload (ID: 4444)

GPS Trackers:
    Target_Vehicle (ID: 7890) - Track Time: 60s - Frequency: 5s - Untracked

Vehicles:
    Vehicle: 1111 - Offroad_01 (C_Offroad_01_F) - Battery, Speed, Engine @ 123459
```

### Device Information

Each device shows:
- **ID**: Unique identifier for commands
- **Type/Name**: Device class or custom name
- **Location**: Grid coordinates
- **State**: Current status (locked, on/off, faction, etc.)
- **Features**: Available hacking options (for vehicles)

### Access Control

Only devices you have access to will be listed. Access is determined by:
1. **Backdoor commands**: Full access to all devices
2. **Public devices**: Available to all laptops
3. **Linked devices**: Specifically linked to this laptop by mission maker

---

## `door` - Door Control

Lock or unlock building doors remotely.

### Syntax
```bash
/rubberducky/tools/door <buildingID> <doorNumber> <state>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `buildingID` | Number | Building ID from `devices` | Any door ID |
| `doorNumber` | Number/String | Specific door or all | `1`, `2`, `3`, ... or `a` |
| `state` | String | Desired lock state | `lock`, `unlock` |

### Examples

```bash
# Lock door 1 of building 1234
/rubberducky/tools/door 1234 1 lock

# Unlock door 2 of building 1234
/rubberducky/tools/door 1234 2 unlock

# Lock all doors in building 1234
/rubberducky/tools/door 1234 a lock

# Unlock all doors in building 5678
/rubberducky/tools/door 5678 a unlock
```

### Power Cost

**2 Wh per door** (default, configurable via `ROOT_CYBERWARFARE_DOOR_COST`)

When using `a` (all doors), power cost is multiplied by number of affected doors.

### Output

```
Power Cost: 2Wh.
Are you sure? (Y/N): y
Door 1 locked.
Power Cost: 2Wh
New Power Level: 498Wh
```

### Behavior Notes

- Door must exist in building configuration
- Doors update globally for all players
- Physical door state (open/closed) is separate from lock state
- Players can still physically open unlocked doors
- Locked doors cannot be opened by players

---

## `light` - Light Control

Toggle lights on or off.

### Syntax
```bash
/rubberducky/tools/light <lightID> <state>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `lightID` | Number/String | Light ID or all lights | Any light ID or `a` |
| `state` | String | Desired light state | `on`, `off` |

### Examples

```bash
# Turn on light 5678
/rubberducky/tools/light 5678 on

# Turn off light 5678
/rubberducky/tools/light 5678 off

# Turn all lights on
/rubberducky/tools/light a on

# Turn all lights off
/rubberducky/tools/light a off
```

### Power Cost

**0 Wh** (instant operation, no power consumption)

### Output

```
Light turned on.
```

Or for multiple lights:
```
Operation completed on 5 lights.
```

### Behavior Notes

- Only works on `Lamps_base_F` class objects added via Zeus module
- Light state updates globally for all players
- No confirmation prompt (instant operation)
- Already on/off lights are skipped with notification

---

## `changedrone` - Change Drone Faction

Change the faction/side of a drone.

### Syntax
```bash
/rubberducky/tools/changedrone <droneID> <faction>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `droneID` | Number/String | Drone ID or all drones | Any drone ID or `a` |
| `faction` | String | Target faction | `west`, `east`, `guer`, `civ` |

### Faction Values

| Value | Side | Color |
|-------|------|-------|
| `west` | BLUFOR | Blue |
| `east` | OPFOR | Red |
| `guer` | Independent | Green |
| `civ` | Civilian | Purple |

### Examples

```bash
# Change drone 9012 to BLUFOR
/rubberducky/tools/changedrone 9012 west

# Change drone 9012 to OPFOR
/rubberducky/tools/changedrone 9012 east

# Change all drones to Independent
/rubberducky/tools/changedrone a guer

# Change all drones to Civilian
/rubberducky/tools/changedrone a civ
```

### Power Cost

**20 Wh per drone** (default, configurable via `ROOT_CYBERWARFARE_DRONE_SIDE_COST`)

When using `a`, shows total cost before confirmation.

### Output

```
Power Cost: 20Wh.
Are you sure? (Y/N): y
Drone side changed.
Power Cost: 20Wh
New Power Level: 480Wh
```

For multiple drones:
```
Affected Drones: 3. Power Cost: 60Wh.
Are you sure? (Y/N): y
Operation completed on 3 drones.
Power Cost: 60Wh
New Power Level: 440Wh
```

### Behavior Notes

- Drone must be alive (not destroyed)
- Drone changes faction immediately
- AI behavior may adapt to new faction
- Drones already of target faction are skipped
- Operation requires confirmation

---

## `disabledrone` - Disable Drone

Destroy or disable a drone.

### Syntax
```bash
/rubberducky/tools/disabledrone <droneID>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `droneID` | Number/String | Drone ID or all drones | Any drone ID or `a` |

### Examples

```bash
# Disable drone 9012
/rubberducky/tools/disabledrone 9012

# Disable all accessible drones
/rubberducky/tools/disabledrone a
```

### Power Cost

**10 Wh per drone** (default, configurable via `ROOT_CYBERWARFARE_DRONE_DISABLE_COST`)

### Output

```
Power Cost: 10Wh.
Are you sure? (Y/N): y
Drone disabled.
Power Cost: 10Wh
New Power Level: 490Wh
```

### Behavior Notes

- Sets drone damage to 1 (fully destroyed)
- Irreversible operation
- Already disabled drones are skipped
- Requires confirmation prompt

---

## `download` - Download Database File

Download a file from the network to your laptop's filesystem.

### Syntax
```bash
/rubberducky/tools/download <fileID>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `fileID` | Number | File/database ID | Any database ID from `devices` |

### Example

```bash
# Download file 3456
/rubberducky/tools/download 3456
```

### Output

Shows animated progress bar:
```
Downloading File: 010%. [##......................]
Downloading File: 050%. [############............]
Downloading File: 100%. [########################]
File saved to: '/rubberducky/tools/Files/Secret_Intel.txt'
Exit the terminal and re-open to see the 'Files' directory updated.
```

### Reading Downloaded Files

```bash
# List files
ls /rubberducky/tools/Files

# Read file contents
cat /rubberducky/tools/Files/Secret_Intel.txt
```

### Power Cost

**0 Wh** (no power cost for downloading)

### Behavior Notes

- Download time = file size (in seconds)
- Progress bar updates every second
- File is saved to `/rubberducky/tools/Files/` directory
- Filename is sanitized (spaces replaced with underscores)
- If database has execution code, it runs after download
- No confirmation prompt required

---

## `custom` - Custom Device Control

Activate or deactivate custom hackable devices.

### Syntax
```bash
/rubberducky/tools/custom <deviceID> <state>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `deviceID` | Number | Custom device ID | Any custom device ID |
| `state` | String | Desired state | `activate`, `deactivate` |

### Examples

```bash
# Activate custom device 4444
/rubberducky/tools/custom 4444 activate

# Deactivate custom device 4444
/rubberducky/tools/custom 4444 deactivate
```

### Power Cost

**10 Wh** (default, configurable via `ROOT_CYBERWARFARE_CUSTOM_COST`)

### Output

```
Custom device 'Power Generator Overload' (ID: 4444) activated.
Power Cost: 10Wh
New Power Level: 490Wh
```

### Behavior Notes

- Custom devices are created by mission makers
- Activation/deactivation triggers custom scripts
- Use cases: explosions, spawn units, trigger events, etc.
- No confirmation prompt
- Device must exist and be accessible

---

## `gpstrack` - GPS Tracking

Start tracking a GPS tracker on the map.

### Syntax
```bash
/rubberducky/tools/gpstrack <trackerID>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `trackerID` | Number | GPS tracker ID | Any tracker ID from `devices` |

### Example

```bash
# Track target 7890
/rubberducky/tools/gpstrack 7890
```

### Power Cost

**2 Wh per tracking session** (default, configurable per-tracker by mission maker)

### Output

```
Power Cost: 2Wh.
Are you sure? (Y/N): y
Tracking started for: Target_Vehicle (ID: 7890)
Power Cost: 2Wh
New Power Level: 498Wh
```

### Map Markers

Two markers appear on your map:

1. **Active Tracker** (Blue):
   - Shows current position
   - Updates every N seconds (default: 5)
   - Active for N seconds (default: 60)
   - Format: `Target_Vehicle`

2. **Last Ping** (Red):
   - Shows final known position
   - Appears after tracking ends
   - Visible for N seconds (default: 30)
   - Format: `Target_Vehicle (Last Ping)`

### Tracking Status

Trackers have these states:
- **Untracked**: Ready to track
- **Tracking**: Currently being tracked
- **Completed**: Tracking finished, can retrack if allowed
- **Untrackable**: Cannot be tracked again (one-time use)

### Behavior Notes

- Tracking is client-side (only you see markers)
- Requires confirmation
- Power consumed at start of tracking
- Tracking time and frequency configurable per-tracker
- Retracking depends on mission maker settings
- Target must be alive

---

## `vehicle` - Vehicle Parameter Control

Remotely manipulate vehicle parameters.

### Syntax
```bash
/rubberducky/tools/vehicle <vehicleID> <action> <value>
```

### Arguments

| Argument | Type | Description | Valid Values |
|----------|------|-------------|--------------|
| `vehicleID` | Number | Vehicle ID | Any vehicle ID from `devices` |
| `action` | String | Action to perform | See actions table below |
| `value` | String/Number | Action parameter | See actions table below |

### Available Actions

| Action | Value Type | Range | Description |
|--------|------------|-------|-------------|
| `battery` | Number | 0-100+ | Set fuel/battery percentage |
| `speed` | Number | Any | Adjust velocity (m/s) |
| `brakes` | Any | - | Apply emergency brakes |
| `lights` | String | `on`, `off` | Toggle vehicle lights |
| `engine` | String | `on`, `off` | Toggle engine on/off |
| `alarm` | Number | 1-60 | Sound alarm for N seconds |

### Examples

```bash
# Set vehicle battery to 50%
/rubberducky/tools/vehicle 1111 battery 50

# Drain battery completely
/rubberducky/tools/vehicle 1111 battery 0

# Destroy vehicle (battery > 100)
/rubberducky/tools/vehicle 1111 battery 101

# Increase speed by 20 m/s
/rubberducky/tools/vehicle 1111 speed 20

# Decrease speed by 10 m/s
/rubberducky/tools/vehicle 1111 speed -10

# Apply brakes
/rubberducky/tools/vehicle 1111 brakes

# Turn on headlights
/rubberducky/tools/vehicle 1111 lights on

# Turn off headlights
/rubberducky/tools/vehicle 1111 lights off

# Start engine
/rubberducky/tools/vehicle 1111 engine on

# Stop engine
/rubberducky/tools/vehicle 1111 engine off

# Sound alarm for 10 seconds
/rubberducky/tools/vehicle 1111 alarm 10
```

### Power Cost

**2 Wh per action** (default, configurable per-vehicle by mission maker)

### Output

```
Are you sure? (Y/N): y
Power Cost: 2Wh
New Power Level: 498Wh
```

### Action Details

#### Battery
- **0-100**: Sets fuel/battery to percentage
- **0**: Empty tank/battery
- **101+**: Destroys vehicle

#### Speed
- Positive values: Accelerate forward
- Negative values: Decelerate or reverse
- Applied to current velocity vector

#### Brakes
- Emergency brake simulation
- Gradually reduces speed to 0
- Only works on ground vehicles

#### Lights
- Toggles headlights/running lights
- **Only works on empty vehicles** (no crew)
- Requires temporary network ownership transfer

#### Engine
- Remotely start/stop engine
- Works regardless of crew presence

#### Alarm
- Plays vehicle horn/siren sound
- Duration: 1-60 seconds
- Broadcasts to all nearby players

### Behavior Notes

- Vehicle must be alive and accessible
- Requires confirmation for each action
- Each action consumes power independently
- Some actions require specific vehicle types (e.g., brakes on land vehicles)
- Light control requires empty vehicle
- Mission maker configures which actions are available per-vehicle

---

## Error Messages

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Error! Invalid [Type]ID` | Invalid ID format | Use numeric ID from `devices` command |
| `Error! [Device] not found or access denied` | Device doesn't exist or no access | Check `devices` list and access permissions |
| `Error! Insufficient Power!` | Battery too low | Recharge laptop or use lower-cost operation |
| `Error! No accessible [devices] found` | No devices of this type available | Contact mission maker to add devices |
| `Error! Invalid Input` | Wrong parameter value | Check command syntax |

---

## Command Tips

### General
- Always run `devices` first to see what's available
- Check power costs before executing
- Use `a` (all) for batch operations
- Most commands require confirmation (`Y/N`)

### Efficiency
- Batch operations save time (e.g., `door 1234 a lock`)
- Light operations cost no power - use freely
- GPS tracking is one power cost per session, not per ping

### Tactical
- Lock doors after passing through for security
- Disable lights before stealth operations
- Change drone factions rather than destroying (saves resources)
- Track high-value targets with GPS
- Use vehicle battery drain to disable enemy escapes

---

## See Also

- [Player Guide](Player-Guide) - General gameplay instructions
- [Configuration Reference](Configuration) - Power costs and settings
- [Mission Maker Guide](Mission-Maker-Guide) - Adding devices via script

---

**Need help?** See [Troubleshooting](Troubleshooting) or contact your mission maker.
