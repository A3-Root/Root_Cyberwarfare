# Zeus Guide

This guide covers all Zeus modules provided by Root's Cyber Warfare, enabling Zeus curators to create dynamic cyber warfare scenarios during gameplay.

## Table of Contents

- [Introduction](#introduction)
- [Zeus Modules Overview](#zeus-modules-overview)
- [Module Reference](#module-reference)
  - [1. Add Hacking Tools](#1-add-hacking-tools)
  - [2. Add Hackable Object](#2-add-hackable-object)
  - [3. Add Custom Device](#3-add-custom-device)
  - [4. Add Hackable File](#4-add-hackable-file)
  - [5. Add GPS Tracker](#5-add-gps-tracker)
  - [6. Add Hackable Vehicle](#6-add-hackable-vehicle)
  - [7. Add Power Generator](#7-add-power-generator)
  - [8. Copy Device Links](#8-copy-device-links)
  - [9. Modify Power Costs](#9-modify-power-costs)
- [Access Control System](#access-control-system)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)

## Introduction

Root's Cyber Warfare provides 9 Zeus modules in the **ROOT_CYBERWARFARE** category. These modules allow you to dynamically add hacking capabilities, register hackable devices, and configure access control during active missions.

### Finding the Modules

1. Open Zeus interface (Y key by default)
2. Navigate to **Modules** → **ROOT_CYBERWARFARE**
3. Select the desired module and place it

All modules (except "Modify Power Costs") can be placed on specific objects or entities.

## Zeus Modules Overview

| Module Name | Purpose | Attach to Object? |
|-------------|---------|-------------------|
| Add Hacking Tools | Install hacking software on laptops | Yes |
| Add Hackable Object | Register doors/lights in buildings | Yes |
| Add Custom Device | Create scripted devices | Yes |
| Add Hackable File | Add downloadable files | No |
| Add GPS Tracker | Attach GPS tracker to objects | Yes |
| Add Hackable Vehicle | Register vehicles/drones | Yes |
| Add Power Generator | Create power grid control | Yes |
| Copy Device Links | Transfer laptop permissions | No |
| Modify Power Costs | Adjust power consumption | No |

---

## Module Reference

### 1. Add Hacking Tools

**Purpose:** Install hacking tools on AE3 laptops or USB sticks, enabling them to control devices.

**How to Use:**
1. Place module on an AE3 laptop object
2. Configure parameters in the dialog
3. Click OK

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Tool Path** | String | `/rubberducky/tools` | Virtual path where tools are installed. No trailing `/`. Use only letters, numbers, `_`, and `/`. |
| **Laptop Name** | String | (empty) | Custom display name for this laptop (optional). |
| **Backdoor Function Prefix** | String | (empty) | Debug/admin prefix for backdoor access. Leave empty for normal use. |

**Example Configuration:**
```
Tool Path: /network/hackertools
Laptop Name: MainHackingStation
Backdoor Function Prefix: (leave empty)
```

**What It Does:**
- Installs a virtual filesystem on the laptop with hacking commands
- Creates the tools directory at the specified path
- Enables terminal commands: `devices`, `door`, `light`, `changedrone`, `disabledrone`, `download`, `custom`, `gpstrack`, `vehicle`, `powergrid`
- Registers the laptop as a valid hacking device

**Notes:**
- Can be used on any AE3 laptop/USB object
- Multiple laptops can be configured independently
- Tool path must be unique per laptop (or can be shared)
- Backdoor prefix enables admin access (bypasses all permission checks)

**Feedback Message:**
```
Hacking tools installed successfully on laptop at /network/hackertools
```

---

### 2. Add Hackable Object

**Purpose:** Register buildings (with doors) or lights as hackable devices. **Note:** For drones, use the "Add Hackable Vehicle" module instead.

**How to Use:**
1. Place module on a building or lamp
2. Configure parameters in the dialog
3. Click OK

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Linked Computers** | Array | (empty) | List of specific laptops that should have access. Leave empty for none. |
| **Available to Future Laptops** | Checkbox | Unchecked | If checked, all laptops added AFTER this device will automatically have access. |
| **Make Unbreachable** | Checkbox | Unchecked | If checked, building doors cannot be breached with ACE explosives or lockpicking (doors only). |

**Auto-Detection:**
- **Buildings**: Automatically detects all doors and registers them
- **Lamps**: Registers as a single light device

**Device ID Assignment:**
- Automatically generates a unique 4-digit ID (1000-9999)

**Example Configuration:**
```
Linked Computers: (leave empty)
Available to Future Laptops: ✓ (checked)
Make Unbreachable: ✓ (checked)
```

**What It Does:**
- **For Buildings**: Registers all doors with unique door IDs
- **For Lights**: Registers the lamp object with on/off control
- If "Make Unbreachable" is checked (doors only), prevents ACE breaching/lockpicking

**Access Control:**
- If **Linked Computers** are specified: Only those laptops get access
- If **Available to Future Laptops** is checked: All laptops created AFTER this moment get access (laptops that already exist are excluded)
- If both are empty/unchecked: Device is private (no access unless linked later)

**Feedback Message:**
```
Building registered with ID: 1234
Available to future laptops: Yes
Unbreachable: Yes
```

**Notes:**
- For buildings, ALL doors are automatically detected (no need to specify door IDs)
- Lights can be building lights or standalone lamp objects
- For drones/UAVs, use the "Add Hackable Vehicle" module

---

### 3. Add Custom Device

**Purpose:** Create custom scripted devices with user-defined activation and deactivation code.

**How to Use:**
1. Place module on any object
2. Configure parameters in the dialog
3. Click OK

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Custom Device Name** | String | `Custom Device` | Display name shown in terminal listings. |
| **Linked Computers** | Array | (empty) | Specific laptops that should have access. |
| **Activation Code** | Multiline SQF | (empty) | SQF code executed when device is activated. |
| **Deactivation Code** | Multiline SQF | (empty) | SQF code executed when device is deactivated. |
| **Available to Future Laptops** | Checkbox | Unchecked | Auto-grant access to future laptops. |

**Code Context:**
In activation/deactivation code, `_this` is an array:
```sqf
_this = [_deviceObject, "activate"|"deactivate"]
```

Where:
- `_deviceObject` - The object the module was placed on
- `"activate"` or `"deactivate"` - The action being performed

**Example Configuration:**
```
Custom Device Name: Generator Alarm
Linked Computers: (leave empty or select specific laptops)
Activation Code:
    private _device = _this select 0;
    playSound3D ["a3\sounds_f\sfx\alarm.wss", _device, false, getPosASL _device, 5, 1, 300];
    hint "Alarm activated!";

Deactivation Code:
    hint "Alarm deactivated.";

Available to Future Laptops: ✓ (checked)
```

**What It Does:**
- Registers the object as a custom hackable device
- Stores activation and deactivation code
- Players use `custom <DeviceID> activate/deactivate` to trigger code

**Common Use Cases:**
- **Alarm systems**: Play sounds, trigger alerts
- **Generator control**: Enable/disable lights, power systems
- **Door mechanisms**: Open/close doors via scripted animations
- **Event triggers**: Spawn reinforcements, change objectives, activate scripts

**Notes:**
- Code executes in a scheduled environment
- Be cautious with infinite loops or performance-heavy code
- Code runs on the player machine executing the command
- Device object is passed to code, so you can reference its position, variables, etc.

**Feedback Message:**
```
Custom device 'Generator Alarm' registered with ID: 5678
Available to future laptops: Yes
```

---

### 4. Add Hackable File

**Purpose:** Create downloadable files that players can download via the terminal.

**How to Use:**
1. Place module (not on an object, or on a specific object)
2. Configure parameters in the dialog
3. Click OK

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Target Object** | Object | (selected) | Object that "stores" the file. |
| **File Name** | String | `secret_file.txt` | Name of the file (with or without extension). |
| **Download Time (seconds)** | Number | `10` | Time in seconds required to download the file. |
| **File Contents** | Multiline Text | (empty) | Contents displayed when using `cat` command on the file. |
| **Linked Computers** | Array | (empty) | Specific laptops that can access this file. |
| **Execution Code** | Multiline SQF | (empty) | Optional code executed upon successful download. |
| **Available to Future Laptops** | Checkbox | Unchecked | Auto-grant access to future laptops. |

**Example Configuration:**
```
Target Object: (select a laptop, server, or any object)
File Name: enemy_intel.txt
Download Time: 15
File Contents:
    CLASSIFIED INTEL
    ===============
    Enemy convoy departs 0800 hours
    Route: Highway 12 → Base Alpha
    Escort: 2x BTR-80, 1x T-100

Linked Computers: (select specific laptops)
Execution Code:
    hint "Intel downloaded! New objective added.";
    player createDiaryRecord ["Diary", ["New Intel", "Enemy convoy route discovered!"]];

Available to Future Laptops: (leave unchecked)
```

**What It Does:**
- Registers a file in the database system
- File is "stored" on the target object
- Players use `download <FileID>` to download
- File is saved to `/home/user/Downloads/<filename>` on the laptop
- Optional code executes after download completes

**Download Process:**
1. Player types `download <FileID>`
2. Download starts, taking the configured time (seconds)
3. Progress is shown in terminal
4. File is saved to laptop's Downloads folder
5. Execution code runs (if configured)

**Common Use Cases:**
- **Mission objectives**: Intel files that trigger new tasks
- **Secrets**: Hidden information for story/immersion
- **Code execution**: Trigger scripts, spawn events, unlock doors
- **Resource drops**: Call in support, reinforcements, etc.

**Notes:**
- Download time is literal seconds (e.g., 10 = 10 real seconds)
- File content supports newlines and special characters
- Execution code runs on the player machine executing the command.
- Players can read the file with `cat /home/user/Downloads/<filename>`

**Feedback Message:**
```
File 'enemy_intel.txt' registered with ID: 3456
Available to future laptops: No
```

---

### 5. Add GPS Tracker

**Purpose:** Attach a GPS tracker to an object, enabling real-time position tracking via the terminal.

**How to Use:**
1. Place module on any object (vehicle, player, crate, etc.)
2. Configure parameters in the dialog
3. Click OK

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Target Object** | Object | (selected) | Object to track (vehicle, unit, etc.). |
| **Linked Computers** | Array | (empty) | Specific laptops that can track this device. |
| **GPS Tracker Name** | String | `Target_GPS` | Display name in terminal listings and default marker name. |
| **Tracking Time (seconds)** | Number | `60` | Maximum duration tracking stays active. |
| **Update Frequency (seconds)** | Number | `5` | How often the position updates (e.g., every 5 seconds). |
| **Custom Marker Name** | String | (empty) | Optional custom name for map markers. If empty, uses GPS Tracker Name. |
| **Available to Future Laptops** | Checkbox | Checked | Auto-grant access to future laptops. |
| **Allow Retracking** | Checkbox | Unchecked | If checked, tracking can be restarted after completion. |
| **Last Ping Duration (seconds)** | Number | **REQUIRED** | How long the "last ping" marker remains visible after tracking ends. |
| **Power Cost to Track** | Number | **REQUIRED** | Power cost in Wh to start tracking. |
| **Show System Chat Message** | Checkbox | Checked | Show system chat notification when tracking starts. |
| **Marker Visibility (Owners)** | Array | `[[], [], []]` | Which sides/groups/players can see markers (advanced). Format: `[[sides], [groups], [players]]`. |

**Example Configuration:**
```
Target Object: (enemy vehicle)
Linked Computers: (leave empty)
GPS Tracker Name: Enemy_Commander_Vehicle
Tracking Time: 120
Update Frequency: 10
Custom Marker Name: (leave empty)
Available to Future Laptops: ✓ (checked)
Allow Retracking: (unchecked)
Last Ping Duration: 30
Power Cost to Track: 15
Show System Chat Message: ✓ (checked)
Marker Visibility: [[], [], []] (default - visible to all)
```

**What It Does:**
- Attaches a virtual GPS tracker to the target object
- Players use `gpstrack <TrackerID>` to start tracking
- Creates map markers showing object position:
  - **Active Ping**: Updates every X seconds (Update Frequency)
  - **Last Ping**: Shows final position after tracking ends
- Markers visible to configured owners (sides/groups/players)

**Tracking Flow:**
1. Player types `gpstrack <TrackerID>`
2. Power is consumed (Power Cost)
3. Confirmation prompt appears
4. Tracking starts for the configured duration
5. Map markers update at the configured frequency
6. Tracking ends after the duration expires or target is destroyed
7. Last ping marker remains visible for Last Ping Duration

**Marker Visibility (Owners Parameter):**
Format: `[[sides], [groups], [players]]`

Examples:
```sqf
[[], [], []]                    // Visible to everyone (default)
[[west], [], []]                // Only BLUFOR can see
[[], [group player], []]        // Only specific group can see
[[], [], [player1, player2]]    // Only specific players can see
[[west, independent], [], []]   // BLUFOR and Independent can see
```

**Common Use Cases:**
- **Enemy tracking**: Track high-value targets (HVTs), commanders, supply vehicles
- **Asset monitoring**: Keep tabs on friendly vehicles
- **Objective tracking**: Follow moving objectives
- **Counter-surveillance**: Players can physically search for and disable trackers

**Notes:**
- **IMPORTANT:** "Last Ping Duration" and "Power Cost to Track" are REQUIRED parameters with no defaults. You must specify values.
- Trackers can be physically searched for and disabled by players (see [Player Guide - GPS Tracker Mechanics](Player-Guide#gps-tracker-mechanics))
- If "Allow Retracking" is unchecked, tracker becomes single-use
- Marker colors are configurable via CBA settings (see [Configuration](Configuration))
- Tracking stops if target is destroyed (status changes to "Dead")

**Feedback Message:**
```
GPS Tracker 'Enemy_Commander_Vehicle' attached to target with ID: 2421
Tracking Time: 120s, Update Frequency: 10s, Power Cost: 15 Wh
Available to future laptops: Yes
```

---

### 6. Add Hackable Vehicle

**Purpose:** Register vehicles or drones as hackable, enabling control over fuel, speed, brakes, lights, engine, and alarms.

**How to Use:**
1. Place module on a vehicle or drone
2. Configure parameters in the dialog
3. Click OK

**Auto-Detection:**
- **Drones/UAVs**: Automatically detected and registered with simplified parameters
- **Vehicles**: Full parameter set for comprehensive control

**Parameters for Drones:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Linked Computers** | Array | (empty) | Specific laptops with access. |
| **Available to Future Laptops** | Checkbox | Unchecked | Auto-grant access to future laptops. |

Drones use the `changedrone` and `disabledrone` commands (see [Add Hackable Object](#2-add-hackable-object) for drone details).

**Parameters for Vehicles:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Linked Computers** | Array | (empty) | Specific laptops with access. |
| **Vehicle Name** | String | (auto-generated) | Display name in terminal. |
| **Allow Fuel/Battery Hacking** | Checkbox | Checked | Enable fuel/battery manipulation (0-100%). |
| **Allow Speed Hacking** | Checkbox | Checked | Enable max speed limitation (0-100%). |
| **Allow Brakes Hacking** | Checkbox | Unchecked | Enable brake disabling (0=disabled, 1=enabled). |
| **Allow Lights Hacking** | Checkbox | Checked | Enable light control (0=off, 1=on). |
| **Allow Engine Hacking** | Checkbox | Checked | Enable engine stop/start (0=off, 1=on). |
| **Allow Alarm Hacking** | Checkbox | Unchecked | Enable car alarm control (0=off, 1=on). |
| **Available to Future Laptops** | Checkbox | Unchecked | Auto-grant access to future laptops. |
| **Power Cost per Action** | Number | `2` | Power cost in Wh for each hacking action. |

**Example Configuration (Vehicle):**
```
Linked Computers: (select specific laptops or leave empty)
Vehicle Name: Enemy APC
Allow Fuel/Battery Hacking: ✓ (checked)
Allow Speed Hacking: ✓ (checked)
Allow Brakes Hacking: (unchecked)
Allow Lights Hacking: ✓ (checked)
Allow Engine Hacking: ✓ (checked)
Allow Alarm Hacking: (unchecked)
Available to Future Laptops: ✓ (checked)
Power Cost per Action: 5
```

**What It Does:**
- Registers the vehicle with a unique ID
- Enables selected hacking capabilities
- Players use `vehicle <VehicleID> <action> <value>` to control the vehicle
- Each action costs the configured power

**Vehicle Actions:**

| Action | Value Range | Example |
|--------|-------------|---------|
| `battery` | 0-100 | `vehicle 1337 battery 0` (empty tank) |
| `speed` | 0-100 | `vehicle 1337 speed 30` (limit to 30% max speed) |
| `brakes` | 0-1 | `vehicle 1337 brakes 0` (disable brakes) |
| `lights` | 0-1 | `vehicle 1337 lights 0` (disable lights) |
| `engine` | 0-1 | `vehicle 1337 engine 0` (stop engine) |
| `alarm` | 0-1 | `vehicle 1337 alarm 0` (disable car alarm) |

**Common Use Cases:**
- **Enemy immobilization**: Drain fuel, stop engine, disable brakes
- **Stealth operations**: Turn off lights for night infiltration
- **Sabotage**: Limit speed, disable alarms for vehicle theft
- **Friendly asset protection**: Secure vehicles against theft

**Notes:**
- Only enabled capabilities appear in `devices vehicles` listing
- Attempting disabled actions returns an error
- Power cost applies to each individual action
- Vehicle changes are visible to all players

**Feedback Message (Drone):**
```
Drone registered with ID: 9876
Available to future laptops: Yes
```

**Feedback Message (Vehicle):**
```
Vehicle 'Enemy APC' registered with ID: 1337
Features: Battery, Speed, Lights, Engine
Power Cost: 5 Wh per action
Available to future laptops: Yes
```

---

### 7. Add Power Generator

**Purpose:** Create a power generator that controls all lights within a configurable radius, with optional explosion effects.

**How to Use:**
1. Place module on an object (the "generator")
2. Configure parameters in the dialog
3. Click OK

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **Target Object** | Object | (selected) | Object representing the generator. |
| **Linked Computers** | Array | (empty) | Specific laptops with access. |
| **Generator Name** | String | `Power Generator` | Display name in terminal. |
| **Effect Radius (meters)** | Number | `50` | Radius in meters to affect lights. |
| **Allow Explosion on Overload** | Checkbox | Unchecked | If checked, the `overload` action creates an explosion and destroys the generator. |
| **Explosion Type** | String | `ClaymoreDirectionalMine_Remote_Ammo_Scripted` | Ammo classname for explosion (e.g., `HelicopterExploSmall`, `Bo_GBU12_LGB`, `Sh_155mm_AMOS`). |
| **Excluded Light Classnames** | Array | (empty) | Light classnames to exclude from control (comma-separated). |
| **Available to Future Laptops** | Checkbox | Unchecked | Auto-grant access to future laptops. |
| **Power Cost** | Number | `10` | Power cost in Wh per operation. |

**Example Configuration:**
```
Target Object: (select generator object)
Linked Computers: (leave empty or select specific laptops)
Generator Name: Main Power Grid
Effect Radius: 200
Allow Explosion on Overload: ✓ (checked)
Explosion Type: HelicopterExploSmall
Excluded Light Classnames: Land_LampDecor_F,Land_LampHalogen_F
Available to Future Laptops: ✓ (checked)
Power Cost: 15
```

**What It Does:**
- Registers a power generator that controls lights in radius
- Players use `powergrid <GridID> <on|off|overload>` to control
- Actions:
  - `on`: Turn on all lights in radius
  - `off`: Turn off all lights in radius
  - `overload`: Destroy generator and all lights (with optional explosion)

**Excluded Light Classnames:**
Use this to prevent specific light types from being controlled. Format: `Classname1,Classname2,Classname3`

Example classnames:
- `Land_LampDecor_F`
- `Land_LampHalogen_F`
- `Land_LampAirport_F`
- `Land_LampStreet_small_F`

**Explosion Types:**
Common ammo classnames for explosions:
- `HelicopterExploSmall` - Small explosion (default)
- `HelicopterExploBig` - Large explosion
- `Bo_GBU12_LGB` - Guided bomb explosion
- `Sh_155mm_AMOS` - Artillery shell explosion
- `M_Mo_82mm_AT_LG` - Mortar explosion

**Common Use Cases:**
- **Base blackouts**: Turn off all lights in an enemy base
- **Sabotage**: Overload generators to create chaos
- **Dynamic lighting**: Control entire areas for tactical advantage
- **Mission events**: Script generator failures, power restoration objectives

**Notes:**
- Overload action permanently destroys the generator object
- Explosion (if enabled) creates damage and visual/audio effects
- All lights in radius (except excluded) are affected simultaneously
- Number of affected lights is reported in the output

**Feedback Message:**
```
Power Generator 'Main Power Grid' registered with ID: 5000
Radius: 200m, Power Cost: 15 Wh
Explosion on overload: Yes (HelicopterExploSmall)
Available to future laptops: Yes
```

---

### 8. Copy Device Links

**Purpose:** Copy all device access permissions from one laptop to another.

**How to Use:**
1. Place module (not on an object)
2. Select source laptop (has permissions)
3. Select target laptop (will receive permissions)
4. Click OK

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| **Source Computer** | Object | Laptop to copy permissions FROM. |
| **Target Computer** | Object | Laptop to copy permissions TO. |

**Example Configuration:**
```
Source Computer: (select laptop1)
Target Computer: (select laptop2)
```

**What It Does:**
- Copies ALL device links from source to target
- Target laptop gains access to all devices the source laptop could access
- Does not remove existing permissions from target
- Additive operation (adds to target's existing permissions)

**Common Use Cases:**
- **Backup laptops**: Create redundant hacking stations
- **Team coordination**: Give multiple laptops the same permissions
- **Mission progression**: Grant new laptop access to previously accessible devices
- **Replacement**: Transfer permissions when a laptop is lost

**Notes:**
- Both laptops must have hacking tools installed
- Public devices don't need to be copied (already accessible)
- Only copies **private link access**, not backdoor access
- Source laptop permissions are unchanged

**Feedback Message:**
```
Copied device links from Source to Target
Devices copied: 15
```

---

### 9. Modify Power Costs

**Purpose:** Adjust global power costs for hacking operations during runtime.

**How to Use:**
1. Place module (not on an object)
2. Configure power cost sliders in the dialog
3. Click OK

**Parameters:**

| Parameter | Type | Range | Default | Description |
|-----------|------|-------|---------|-------------|
| **Door Lock/Unlock Cost** | Slider | 1-20 Wh | 2 Wh | Power cost per door operation. |
| **Drone Side Change Cost** | Slider | 1-100 Wh | 20 Wh | Power cost to change drone faction. |
| **Drone Disable Cost** | Slider | 1-50 Wh | 10 Wh | Power cost to disable (explode) drone. |
| **Custom Device Cost** | Slider | 1-100 Wh | 10 Wh | Power cost per custom device action. |
| **Power Grid Cost** | Slider | 1-100 Wh | 15 Wh | Power cost per power grid operation. |

**Example Configuration:**
```
Door Lock/Unlock Cost: 5 Wh
Drone Side Change Cost: 30 Wh
Drone Disable Cost: 15 Wh
Custom Device Cost: 20 Wh
Power Grid Cost: 25 Wh
```

**What It Does:**
- Overrides CBA settings for power costs
- Changes apply immediately to all future operations
- Affects all players and laptops
- Can be used multiple times to adjust costs dynamically

**Common Use Cases:**
- **Difficulty scaling**: Increase costs for harder missions
- **Mission phases**: Reduce costs as mission progresses
- **Balance adjustments**: Fine-tune gameplay during testing
- **Dynamic events**: Change costs based on mission events

**Notes:**
- Does NOT affect vehicle-specific power costs (set per vehicle)
- Does NOT affect GPS tracker power costs (set per tracker)
- Changes are global (all players affected)
- Can be combined with CBA settings (this overrides CBA)

**Feedback Message:**
```
Power costs updated:
Door: 5 Wh
Drone Faction Change: 30 Wh
Drone Disable: 15 Wh
Custom Device: 20 Wh
Power Grid: 25 Wh
```

---

## Access Control System

Root's Cyber Warfare uses a **3-tier access control system** with the following priority:

### 1. Backdoor Access (Highest Priority)
- Configured via "Backdoor Function Prefix" in Add Hacking Tools module
- Bypasses ALL permission checks
- Used for admin/debug access
- **Tip**: Leave empty for normal gameplay

### 2. Public Device Access
- Devices registered as "Available to Future Laptops"
- Automatically accessible to laptops added AFTER the device was registered
- Laptops that existed at registration time are excluded (unless manually linked)

### 3. Private Link Access (Lowest Priority)
- Devices linked to specific laptops via "Linked Computers" parameter
- Direct computer-to-device relationship
- Most restrictive access

### Access Control Scenarios

#### Scenario A: Public Device (All Current + Future)
```
Configuration:
- Linked Computers: (empty)
- Available to Future Laptops: ✓ (checked)

Result:
- All laptops (current and future) have access
```

#### Scenario B: Public Device (Future Only)
```
Configuration:
- Linked Computers: (empty)
- Available to Future Laptops: ✓ (checked)

Result:
- Laptops created AFTER registration have access
- Laptops that existed BEFORE registration are excluded
```

#### Scenario C: Private Device (Specific Laptops)
```
Configuration:
- Linked Computers: laptop1, laptop2
- Available to Future Laptops: (unchecked)

Result:
- Only laptop1 and laptop2 have access
- Future laptops have no access
```

#### Scenario D: Mixed Access (Specific + Future)
```
Configuration:
- Linked Computers: laptop1
- Available to Future Laptops: ✓ (checked)

Result:
- laptop1 has access (linked)
- Future laptops have access (public)
- Current laptops (except laptop1) are excluded
```

#### Scenario E: No Access (Private, Unlinked)
```
Configuration:
- Linked Computers: (empty)
- Available to Future Laptops: (unchecked)

Result:
- No laptops have access
- Must link later via scripting or Copy Device Links module
```

### Best Practices

- **Training missions**: Use public access (Scenario A) for easy setup
- **Competitive missions**: Use private access (Scenario C) for team-specific devices
- **Progressive missions**: Use future access (Scenario B) to grant access to new players joining mid-mission
- **Segmented access**: Use mixed access (Scenario D) for VIP laptops + public access

---

## Common Workflows

### Workflow 1: Basic Hacking Setup

**Goal**: Give a player laptop access to a building's doors.

**Steps**:
1. Place **Add Hacking Tools** module on an AE3 laptop
   - Tool Path: `/network/tools`
   - Click OK
2. Place **Add Hackable Object** module on a building
   - Linked Computers: (select the laptop)
   - Available to Future Laptops: (unchecked)
   - Click OK
3. Player accesses terminal, types `devices doors`, sees the building
4. Player uses `door <BuildingID> <DoorID> lock/unlock`

---

### Workflow 2: GPS Tracking Mission

**Goal**: Set up a tracking mission where players track an enemy vehicle.

**Steps**:
1. Place **Add Hacking Tools** module on player's laptop
2. Place **Add GPS Tracker** module on enemy vehicle
   - GPS Tracker Name: Enemy_HVT
   - Tracking Time: 120
   - Update Frequency: 5
   - Power Cost: 10
   - Available to Future Laptops: ✓ (checked)
   - Click OK
3. Player types `gpstrack <TrackerID>`
4. Map markers appear, updating every 5 seconds for 120 seconds

---

### Workflow 3: Vehicle Sabotage

**Goal**: Allow players to sabotage enemy vehicles.

**Steps**:
1. Place **Add Hacking Tools** module on laptop
2. Place **Add Hackable Vehicle** module on enemy vehicle
   - Vehicle Name: Enemy Transport
   - Allow Fuel: ✓
   - Allow Engine: ✓
   - Allow Lights: ✓
   - Power Cost: 3
   - Available to Future Laptops: ✓
   - Click OK
3. Player types `vehicle <VehicleID> battery 0` (drain fuel)
4. Player types `vehicle <VehicleID> engine 0` (stop engine)
5. Vehicle is immobilized

---

### Workflow 4: Base Blackout

**Goal**: Create a mission objective to black out an enemy base.

**Steps**:
1. Place **Add Hacking Tools** module on laptop
2. Place **Add Power Generator** module on a generator object at the base
   - Generator Name: Base Power Grid
   - Effect Radius: 300
   - Available to Future Laptops: ✓
   - Click OK
3. Player infiltrates, accesses laptop
4. Player types `powergrid <GridID> off`
5. All lights in 300m radius turn off
6. Mission objective complete

---

### Workflow 5: Custom Alarm System

**Goal**: Create a hackable alarm that players can activate/deactivate.

**Steps**:
1. Place **Add Hacking Tools** module on laptop
2. Place **Add Custom Device** module on an alarm object
   - Custom Device Name: Base Alarm
   - Activation Code:
     ```sqf
     private _device = _this select 0;
     playSound3D ["a3\sounds_f\sfx\alarm.wss", _device, false, getPosASL _device, 5, 1, 300];
     ```
   - Deactivation Code:
     ```sqf
     hint "Alarm deactivated.";
     ```
   - Available to Future Laptops: ✓
   - Click OK
3. Player types `custom <DeviceID> activate`
4. Alarm sound plays at the object's location

---

### Workflow 6: Sharing Access Between Laptops

**Goal**: Give a second laptop the same permissions as the first.

**Steps**:
1. Laptop1 already has access to multiple devices
2. Place **Add Hacking Tools** module on Laptop2
3. Place **Copy Device Links** module
   - Source Computer: Laptop1
   - Target Computer: Laptop2
   - Click OK
4. Laptop2 now has access to all devices Laptop1 could access

---

## Troubleshooting

### "Hacking tools not installed" error

**Cause**: Laptop does not have hacking tools.

**Solution**: Place **Add Hacking Tools** module on the laptop.

---

### Players can't access devices

**Cause**: Access control issue.

**Check**:
1. Is the device linked to the laptop? (Check "Linked Computers")
2. Is "Available to Future Laptops" checked?
3. Was the laptop created before or after the device was registered?

**Solution**:
- Link the device to the laptop via "Linked Computers"
- OR enable "Available to Future Laptops"
- OR use **Copy Device Links** to grant access

---

### GPS tracking doesn't show markers

**Cause**: Marker visibility configuration or wrong owner.

**Check**:
1. Is the player in the configured owner list?
2. Are marker colors configured correctly in CBA settings?

**Solution**:
- Adjust "Marker Visibility (Owners)" parameter
- Check CBA settings for GPS marker colors (see [Configuration](Configuration))

---

### "Insufficient power" errors

**Cause**: Laptop battery is too low.

**Check**: Use `battery` command in terminal to check level.

**Solution**:
- Recharge battery via AE3 interaction
- Swap battery
- Reduce power costs via **Modify Power Costs** module

---

### Doors won't unlock

**Cause**: Doors may be "unbreachable" or already unlocked.

**Check**: Use `devices doors` to see current lock status.

**Solution**:
- If already unlocked, no action needed
- If locked, use `door <BuildingID> <DoorID> unlock`
- Unlocking doesn't auto-open doors - press Space to open

---

### Custom device code doesn't execute

**Cause**: Syntax error or incorrect context.

**Check**:
1. Review RPT log for errors
2. Verify code syntax is correct SQF
3. Ensure `_this` is used correctly (`_this select 0` = device object)

**Solution**:
- Test code in debug console first
- Add `hint` or `systemChat` for debugging
- Check the intended recepient. The code by default runs on the player machine who executed the command.

---

### Power generator doesn't affect lights

**Cause**: Lights are outside radius or excluded.

**Check**:
1. Verify radius is large enough (use `Effect Radius`)
2. Check if light classnames are in "Excluded Light Classnames"

**Solution**:
- Increase radius
- Remove classnames from exclusion list
- Verify lights are actually near the generator

---

**Need more help?** Check the [Mission Maker Guide](Mission-Maker-Guide) for scripting solutions, or visit [GitHub Issues](https://github.com/A3-Root/Root_Cyberwarfare/issues) to report bugs, or ask in [Discord](https://discord.gg/77th-jsoc-official).
