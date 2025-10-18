# Player Guide

This guide covers everything players need to know about using Root's Cyber Warfare to hack and control devices in Arma 3.

## Table of Contents

- [Getting Started](#getting-started)
- [Terminal Commands](#terminal-commands)
- [Power Management](#power-management)
- [GPS Tracker Mechanics](#gps-tracker-mechanics)
- [Tips and Tricks](#tips-and-tricks)

## Getting Started

### Accessing the Terminal

1. Approach an AE3 laptop (black, olive, or sand colored laptop objects)
2. Open the ACE interaction menu:
   - Press **Windows key** (default) or
   - Use **ACE Self-Interact** key (default: Ctrl+Windows)
3. Select **Access Terminal**
4. The terminal interface will open, showing the ArmaOS command line

### Prerequisites

The laptop must have **hacking tools installed** by a Zeus curator or mission maker. You can verify this by typing `ls /` and checking for the tools directory (usually `/rubberducky/tools` or similar).

### Basic Navigation

Once in the terminal, you can use standard ArmaOS commands:
- `ls` - List files and directories
- `cd <directory>` - Change directory
- `cat <file>` - View file contents
- `help` - View available commands

The hacking tools add specialized commands for device control.

## Terminal Commands

### 1. devices - List Accessible Devices

**Syntax:**
```bash
devices [type]
```

**Description:**
Lists all devices you have access to hack. Optionally filter by device type.

**Type Filters:**
- `doors` - Show only doors
- `lights` - Show only lights
- `drones` - Show only drones/UAVs
- `files` - Show only downloadable files
- `custom` - Show only custom devices
- `gps` - Show only GPS trackers
- `vehicles` - Show only vehicles
- `powergrids` - Show only power generators
- `all` or `a` - Show all devices (default)

**Examples:**
```bash
devices              # List all accessible devices
devices doors        # List only doors
devices vehicles     # List only vehicles
devices a            # List all devices
```

**Output Format:**
- **Doors**: Building ID, display name, grid location, individual door IDs with lock status (locked/unlocked) and state (open/closed)
- **Lights**: Light ID, display name, grid location, status (ON/OFF)
- **Drones**: Drone ID, faction (color-coded), display name, grid location
- **Files**: File ID, filename, estimated transfer time (seconds)
- **Custom**: Device ID, custom name
- **GPS Trackers**: Tracker ID, name, track time, update frequency, power cost, status (Untracked/Tracking/Completed/Dead)
- **Vehicles**: Vehicle ID, name, display name, enabled features (Battery, Speed, Brakes, Lights, Engine, Alarm), grid location
- **Power Grids**: Grid ID, name, display name, radius, grid location, status (ON/OFF)

---

### 2. door - Control Building Doors

**Syntax:**
```bash
door <BuildingID> <DoorID|'a'> <lock|unlock>
```

**Description:**
Lock or unlock doors in registered buildings.

**Parameters:**
- `BuildingID` - The unique ID of the building (from `devices doors`)
- `DoorID` - Specific door ID, or `a` to target all doors
- `lock|unlock` - Desired door state

**Power Cost:** Configurable (default: **2 Wh per door**)

**Examples:**
```bash
door 1454 2881 lock      # Lock door 2881 in building 1454
door 1454 2881 unlock    # Unlock door 2881 in building 1454
door 1454 a lock         # Lock ALL doors in building 1454
door 1454 a unlock       # Unlock ALL doors in building 1454
```

**Confirmation Required:** Yes (for multiple doors when using `a`)

**Notes:**
- Doors marked as "unbreachable" cannot be opened with ACE explosives or lockpicking
- Locking a door does not automatically close it
- Door state (open/closed) is shown in `devices doors` output

---

### 3. light - Control Lights

**Syntax:**
```bash
light <LightID|'a'> <off|on>
```

**Description:**
Turn lights on or off.

**Parameters:**
- `LightID` - The unique ID of the light (from `devices lights`), or `a` to target all lights
- `off|on` - Desired light state

**Power Cost:** Included in CBA settings

**Examples:**
```bash
light 3 off         # Turn off light 3
light 3 on          # Turn on light 3
light a off         # Turn off ALL accessible lights
light a on          # Turn on ALL accessible lights
```

**Confirmation Required:** Yes (when using `a` for multiple lights)

**Notes:**
- Lights include both building lights and street lamps
- Light state changes are visible to all players
- Some lights may be controlled by power generators instead

---

### 4. changedrone - Change Drone Faction

**Syntax:**
```bash
changedrone <DroneID|'a'> <west|east|guer|civ>
```

**Description:**
Change the faction/side of a drone or UAV.

**Parameters:**
- `DroneID` - The unique ID of the drone (from `devices drones`), or `a` to target all drones
- `west|east|guer|civ` - Desired faction
  - `west` - NATO/BLUFOR
  - `east` - OPFOR
  - `guer` - Independent/AAF
  - `civ` - Civilian

**Power Cost:** Configurable (default: **20 Wh per drone**)

**Examples:**
```bash
changedrone 2 east     # Change drone 2 to OPFOR
changedrone 2 west     # Change drone 2 to NATO
changedrone a civ      # Change ALL drones to Civilian
```

**Confirmation Required:** Yes

**Notes:**
- Changing faction transfers control to that side
- Drones will engage targets based on their new faction
- Dead or destroyed drones cannot have their faction changed
- Current drone faction is shown in `devices drones` output (color-coded)

---

### 5. disabledrone - Disable Drones

**Syntax:**
```bash
disabledrone <DroneID|'a'>
```

**Description:**
Disable (destroy/explode) a drone or UAV.

**Parameters:**
- `DroneID` - The unique ID of the drone (from `devices drones`), or `a` to target all drones

**Power Cost:** Configurable (default: **10 Wh per drone**)

**Examples:**
```bash
disabledrone 2        # Disable drone 2
disabledrone a        # Disable ALL accessible drones
```

**Confirmation Required:** Yes

**Notes:**
- Disabling a drone causes it to explode and become destroyed
- This is a permanent, irreversible action
- Already destroyed drones will show an error message

---

### 6. download - Download Files

**Syntax:**
```bash
download <FileID>
```

**Description:**
Download a file from a database to the laptop's Downloads folder.

**Parameters:**
- `FileID` - The unique ID of the file (from `devices files`)

**Power Cost:** Time-based (depends on file size in seconds)

**Examples:**
```bash
download 1234        # Download file 1234
```

**Confirmation Required:** No

**Notes:**
- Download time equals the file's configured size (in seconds)
- Files are saved to `/home/user/Downloads/<filename>` on the laptop
- Use `cat /home/user/Downloads/<filename>` to view downloaded files
- Some files execute code automatically upon download completion
- Download progress is shown in the terminal

---

### 7. custom - Control Custom Devices

**Syntax:**
```bash
custom <CustomID> <activate|deactivate>
```

**Description:**
Activate or deactivate custom scripted devices.

**Parameters:**
- `CustomID` - The unique ID of the custom device (from `devices custom`)
- `activate|deactivate` - Desired device state

**Power Cost:** Configurable (default: **10 Wh per action**)

**Examples:**
```bash
custom 5 activate      # Activate custom device 5
custom 5 deactivate    # Deactivate custom device 5
```

**Confirmation Required:** Yes

**Notes:**
- Custom devices execute mission-maker-defined SQF code
- Effects depend entirely on the device's programmed behavior
- Examples: alarm systems, generator control, door mechanisms, scripted events

---

### 8. gpstrack - Track GPS Devices

**Syntax:**
```bash
gpstrack <TrackerID>
```

**Description:**
Track a GPS-tagged object in real-time, showing its position on the map.

**Parameters:**
- `TrackerID` - The unique ID of the GPS tracker (from `devices gps`)

**Power Cost:** Per tracker (configurable, default: **2-10 Wh**)

**Examples:**
```bash
gpstrack 2421         # Track GPS device 2421
```

**Confirmation Required:** Yes

**Notes:**
- Tracking creates map markers visible to configured players/groups/sides
- **Active Ping** marker updates at the configured frequency (e.g., every 5 seconds)
- **Last Ping** marker shows the last known position after tracking ends
- Tracking duration and update frequency are set by the mission maker
- If "Allow Retracking" is enabled, you can track the same device again after completion
- Power is consumed at the start of tracking
- Tracking statuses: `Untracked`, `Tracking`, `Completed`, `Dead`, `Disabled`

See [GPS Tracker Mechanics](#gps-tracker-mechanics) for more details.

---

### 9. vehicle - Control Vehicles

**Syntax:**
```bash
vehicle <VehicleID> <action> <value>
```

**Description:**
Manipulate various vehicle parameters remotely.

**Parameters:**
- `VehicleID` - The unique ID of the vehicle (from `devices vehicles`)
- `action` - The parameter to modify
- `value` - The new value for the parameter

**Actions and Values:**

| Action | Value Range | Description |
|--------|-------------|-------------|
| `battery` | 0-100 | Set fuel/battery percentage (0=empty, 100=full) |
| `speed` | 0-100 | Limit maximum speed percentage (0=immobile, 100=full speed) |
| `brakes` | 0-1 | Disable/enable brakes (0=disabled, 1=enabled) |
| `lights` | 0-1 | Disable/enable lights (0=disabled, 1=enabled) |
| `engine` | 0-1 | Stop/start engine (0=off, 1=on) |
| `alarm` | 0-1 | Disable/enable car alarm (0=disabled, 1=enabled) |

**Power Cost:** Per vehicle (configurable, default: **2 Wh per action**)

**Examples:**
```bash
vehicle 1337 battery 50    # Set fuel to 50%
vehicle 1337 battery 0     # Empty the tank
vehicle 1337 speed 30      # Limit speed to 30%
vehicle 1337 brakes 0      # Disable brakes
vehicle 1337 lights 0      # Disable lights
vehicle 1337 engine 0      # Stop engine
vehicle 1337 alarm 0       # Disable car alarm
```

**Confirmation Required:** Yes

**Notes:**
- Not all actions are available for all vehicles (depends on mission maker configuration)
- Check `devices vehicles` to see which features are enabled (e.g., "Battery, Speed, Lights, Engine")
- Setting battery to 0 completely drains the vehicle's fuel
- Disabling brakes makes the vehicle unable to slow down
- Stopping the engine forces the vehicle to turn off

---

### 10. powergrid - Control Power Generators

**Syntax:**
```bash
powergrid <GridID> <on|off|overload>
```

**Description:**
Control power generators that manage lights within a radius.

**Parameters:**
- `GridID` - The unique ID of the power grid (from `devices powergrids`)
- `on|off|overload` - Desired action

**Actions:**
- `on` - Turn on all lights within the generator's radius
- `off` - Turn off all lights within the generator's radius
- `overload` - Create explosion and destroy generator (if enabled by mission maker)

**Power Cost:** Configurable (default: **15 Wh per action**)

**Examples:**
```bash
powergrid 1234 on          # Turn on lights in radius
powergrid 1234 off         # Turn off lights in radius
powergrid 1234 overload    # Destroy generator and lights
```

**Confirmation Required:** Yes

**Notes:**
- Power grids control all lights within their configured radius
- Excluded light classnames (set by mission maker) are not affected
- **Overload** action may create an explosion if enabled (configurable explosion type)
- Overload permanently destroys the generator
- Number of affected lights is shown in the output

---

## Power Management

### Understanding Battery Consumption

Every hacking operation consumes power from the laptop's internal battery. The laptop uses **AE3's power system**, which measures battery capacity in **Kilowatt-hours (kWh)**.

Power costs for hacking operations are configured in **Watt-hours (Wh)**:
- 1 kWh = 1000 Wh
- Example: A laptop with 0.5 kWh battery has 500 Wh available

### Default Power Costs

| Operation | Default Cost (Wh) |
|-----------|-------------------|
| Lock/unlock door | 2 |
| Change drone faction | 20 |
| Disable drone | 10 |
| Custom device action | 10 |
| Power grid control | 15 |
| Vehicle action | 2 (configurable per vehicle) |
| GPS tracking | 2-10 (configurable per tracker) |
| Light control | Included in CBA settings |

All power costs can be adjusted via CBA settings (see [Configuration](Configuration.md)).

### Checking Battery Level

Use AE3's power management commands in the terminal:
```bash
battery              # Check current battery level
```

Or check the laptop's status indicator (if available in AE3).

### What Happens When Power Runs Out?

If you attempt an operation without sufficient power:
- You'll receive an error message: `Error! Insufficient Power!`
- The operation will **not** execute
- No power will be consumed
- You'll need to recharge or swap the battery

### Bulk Operation Costs

When using `a` to target multiple devices (e.g., `door 1234 a lock`), the total power cost is calculated **before** execution:
- **Total Cost = Single Cost × Number of Devices**
- Example: Locking 5 doors at 2 Wh each = **10 Wh total**
- You must have enough power for **all** devices, or the operation will fail

---

## GPS Tracker Mechanics

GPS trackers provide real-time position tracking of objects, vehicles, or players.

### How GPS Trackers Work

1. **Placement**: Mission makers or Zeus curators attach GPS trackers to objects
2. **Detection**: Players can physically search for trackers (see below)
3. **Tracking**: Use the `gpstrack <TrackerID>` command to activate tracking
4. **Visualization**: Map markers show the target's position

### Tracking Parameters

Each GPS tracker has configurable parameters:
- **Tracking Time**: How long tracking stays active (e.g., 60 seconds)
- **Update Frequency**: How often the position updates (e.g., every 5 seconds)
- **Power Cost**: Energy required to start tracking (e.g., 10 Wh)
- **Allow Retracking**: Whether you can track again after completion
- **Last Ping Duration**: How long the "last ping" marker remains visible

### Map Markers

Two types of markers are created:

1. **Active Ping Marker** (default: red)
   - Shows current position
   - Updates at the configured frequency
   - Disappears when tracking ends

2. **Last Ping Marker** (default: unknown/grey)
   - Shows the final known position
   - Remains for the configured duration after tracking ends
   - Helps locate the target even after tracking stops

Marker colors can be customized via CBA settings (see [Configuration](Configuration.md)).

### Physically Searching for GPS Trackers

Players can search for hidden GPS trackers on objects using ACE interactions:

1. Approach the object (vehicle, person, etc.)
2. Open **ACE Interaction Menu** on the object
3. Look for **GPS Tracker Detection** options (if available)

#### Using ESD (Electronic Spectrum Device) Tools

Detection success chance is higher when holding spectrum detection devices:
- **Normal detection chance**: 20% (default, configurable)
- **With ESD tool**: 80% (default, configurable)

Default ESD devices (configurable in CBA settings):
- `hgun_esd_01_antenna_01_F`
- `hgun_esd_01_antenna_02_F`
- `hgun_esd_01_antenna_03_F`
- `hgun_esd_01_base_F`
- `hgun_esd_01_F`

### Attaching GPS Trackers (Player Action)

If you have a GPS tracker item in your inventory (default: `ACE_Banana`, configurable):

1. Open **ACE Self-Interaction Menu**
2. Navigate to **Equipment** → **Attach GPS Tracker**
3. This attaches a tracker to yourself

Mission makers can configure which item acts as the GPS tracker (see [Configuration](Configuration.md)).

### Disabling GPS Trackers

Once discovered, GPS trackers can be disabled:
- Use ACE interaction on the tracker
- This prevents further tracking of that device

---

## Tips and Tricks

### 1. Use Bulk Operations Efficiently

When controlling multiple devices of the same type, use `a`:
```bash
door 1234 a unlock       # Unlock all doors in building
light a off              # Turn off all accessible lights
changedrone a civ        # Change all drones to civilian
```

**Tip**: The confirmation prompt shows how many devices will be affected and the total power cost. This helps avoid mistakes!

### 2. Check Power Before Major Operations

Before attempting bulk operations or expensive hacks:
```bash
battery                  # Check current power level
```

If power is low, consider:
- Swapping batteries (via AE3 interaction)
- Charging the laptop (if power sources available)
- Prioritizing critical targets

### 3. Use Device Listing Filters

Instead of scrolling through all devices, filter by type:
```bash
devices vehicles         # Only show vehicles
devices gps              # Only show GPS trackers
```

This is especially useful in missions with many hackable objects.

### 4. Read Confirmation Prompts Carefully

Confirmation prompts show:
- How many devices will be affected
- Total power cost
- 10-second timeout

**Example:**
```
This will affect 12 doors and consume 24 Wh.
Continue? (Y/N) [10s timeout]
```

Press `Y` to confirm, `N` to cancel. If you don't respond within 10 seconds, the operation is cancelled.

### 5. Monitor GPS Tracker Status

Check `devices gps` to see tracker statuses:
- **Untracked**: Ready to track
- **Tracking**: Currently active
- **Completed**: Tracking finished (can retrack if allowed)
- **Dead**: Target is destroyed
- **Disabled**: Tracker was disabled physically

### 6. Coordinate with Team

GPS tracking map markers can be configured to show for:
- Specific players
- Groups
- Entire sides (BLUFOR, OPFOR, etc.)

Ask your Zeus or mission maker who can see the markers!

### 7. Vehicle Hacking Strategies

When hacking enemy vehicles:
1. **Immobilize**: Set `battery 0` and `engine 0`
2. **Blind**: Set `lights 0` (for night operations)
3. **Trap**: Set `brakes 0` (vehicle can't slow down)
4. **Disable**: Set `speed 0` (vehicle can't move)

### 8. Power Grid Tactics

Power grids are useful for:
- **Blackouts**: Turn off entire base lighting (`powergrid X off`)
- **Diversions**: Turn lights on/off to create distractions
- **Sabotage**: Overload to destroy generators (if enabled)

### 9. Custom Device Experimentation

Custom devices are mission-specific. Try activating them to discover their effects:
```bash
custom 5 activate
```

Common custom device types:
- Alarm systems
- Automated doors
- Generator controls
- Scripted events (reinforcements, objectives, etc.)

### 10. Error Messages are Helpful

If you see an error, it usually explains the problem:
- `Error! Insufficient Power!` → Recharge battery
- `Error! Invalid BuildingID` → Check the ID with `devices doors`
- `Access denied to Vehicle ID: 1234` → You don't have permission for that device
- `Drone already of side WEST` → Drone is already the faction you're trying to set

---

## Troubleshooting

### I can't access the terminal

- Ensure the laptop is an **AE3 laptop** (black/olive/sand colored)
- Verify **hacking tools are installed** (ask Zeus or check mission briefing)
- Make sure you're using the **ACE interaction menu**, not the vanilla action menu

### No devices appear when I type `devices`

- You may not have **access** to any devices
- Ask your Zeus curator to link devices to your laptop
- Check if devices were registered as "public" or "available to future laptops"

### "Access denied" errors

You don't have permission for that device. Devices can be:
- **Private**: Only specific laptops have access
- **Public**: All laptops have access
- **Future only**: Only laptops added after device registration

Contact your Zeus or mission maker to grant access.

### Insufficient power errors

Your battery is low. Options:
- **Swap battery**: Via AE3 interaction menu
- **Recharge**: Connect to a power source (if available)
- **Conserve power**: Perform only critical operations

### GPS tracking doesn't show markers

Check:
- **Marker visibility**: Ask if you're in the configured owner list (sides/groups/players)
- **Tracker status**: Use `devices gps` - it should say "Untracked" or "Tracking", not "Dead" or "Disabled"
- **Map open**: Ensure your map is open to see markers

### Doors won't unlock

- Check door lock status: `devices doors`
- If marked "unbreachable", hacking is the **only** way to open them
- Unlocking doesn't auto-open doors - press your "open door" key (Space by default)

---

**Need more help?** Check the [Zeus Guide](Zeus-Guide.md) or [Mission Maker Guide](Mission-Maker-Guide.md) for setup information, or visit the [GitHub Issues](https://github.com/A3-Root/Root_Cyberwarfare/issues) page to report bugs.
