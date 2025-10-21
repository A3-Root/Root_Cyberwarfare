# Eden Editor Guide

This guide covers all 3DEN editor modules provided by Root's Cyber Warfare, enabling mission makers to set up cyber warfare scenarios in the Eden Editor.

## Table of Contents

- [Introduction](#introduction)
- [3DEN Modules Overview](#3den-modules-overview)
- [Module Reference](#module-reference)
  - [1. Add Hacking Tools](#1-add-hacking-tools)
  - [2. Adjust Power Cost Settings](#2-adjust-power-cost-settings)
  - [3. Add Devices](#3-add-devices)
  - [4. Add Hackable File](#4-add-hackable-file)
  - [5. Add Hackable Vehicle](#5-add-hackable-vehicle)
  - [6. Add GPS Tracker](#6-add-gps-tracker)
  - [7. Add Custom Device](#7-add-custom-device)
  - [8. Add Power Generator](#8-add-power-generator)
- [Synchronization Guide](#synchronization-guide)
- [Best Practices](#best-practices)
- [Example Mission Setup](#example-mission-setup)

## Introduction

Root's Cyber Warfare provides **8 modules for the 3DEN Editor** (Arma 3's built-in mission editor). These modules allow you to visually configure cyber warfare scenarios before the mission starts.

### Advantages of 3DEN Modules

- **No scripting required**: Visual configuration in the editor
- **Persistent setup**: Configuration saved with the mission file
- **Preview-friendly**: Test in editor preview mode
- **Synchronization system**: Link devices to laptops visually

### Finding the Modules

1. Open Eden Editor (Tools → Eden Editor from main menu)
2. Press **F5** to open Modules browser
3. Navigate to **ROOT_CYBERWARFARE** category
4. Drag modules into the scene

## 3DEN Modules Overview

| Module Name | Purpose | Synchronize To |
|-------------|---------|----------------|
| Add Hacking Tools | Install hacking software on laptops | AE3 Laptops/USB |
| Adjust Power Cost Settings | Set global power costs | None (mission-wide) |
| Add Devices | Register doors/lights/drones | Buildings, Lights, Drones, Laptops |
| Add Hackable File | Create downloadable files | Laptops (optional) |
| Add Hackable Vehicle | Register hackable vehicles | Vehicles, Laptops (optional) |
| Add GPS Tracker | Attach GPS trackers | Any object, Laptops (optional) |
| Add Custom Device | Create custom scripted devices | Any object, Laptops (optional) |
| Add Power Generator | Create power grid control | Any object, Laptops (optional) |

---

## Module Reference

### 1. Add Hacking Tools

**Purpose:** Install hacking tools on AE3 laptops or USB sticks placed in the editor.

**How to Use:**
1. Place AE3 laptop/USB objects in the scene
2. Place **Add Hacking Tools** module (F5 → ROOT_CYBERWARFARE)
3. **Synchronize** the module to laptop/USB objects (F5 drag line)
4. Configure module attributes

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **Tool Path** | String | `/rubberducky/tools` | Virtual path for tools. No trailing `/`. Use only: letters, numbers, `_`, `/`. |
| **Backdoor Function Prefix** | String | (empty) | Admin/debug backdoor prefix. Leave empty for normal gameplay. |

**Synchronization:**
- **Required**: Sync to one or more AE3 laptop objects
- **Compatible objects**: `Land_Laptop_03_black_F_AE3`, `Land_Laptop_03_olive_F_AE3`, `Land_Laptop_03_sand_F_AE3`, `Land_USB_Dongle_01_F_AE3`

**Example Setup:**
```
1. Place laptop1 in scene
2. Place "Add Hacking Tools" module
3. Sync module to laptop1
4. Set Tool Path: /network/hackertools
5. Leave Backdoor Function Prefix empty
```

**What It Does:**
- Installs hacking tools on all synchronized laptops when mission starts
- Creates virtual filesystem at the specified path
- Enables terminal commands: `devices`, `door`, `light`, `changedrone`, `disabledrone`, `download`, `custom`, `gpstrack`, `vehicle`, `powergrid`

**Notes:**
- Can sync to multiple laptops (all get the same tool path)
- Tool path can be different for each module instance
- Backdoor bypasses all access control (use for testing only)

---

### 2. Adjust Power Cost Settings

**Purpose:** Configure global power costs for hacking operations.

**How to Use:**
1. Place **Adjust Power Cost Settings** module (F5 → ROOT_CYBERWARFARE)
2. Configure attributes
3. **No synchronization required** (mission-wide settings)

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **Door Lock/Unlock Cost** | Number | `2` | Power cost in Wh per door operation. |
| **Drone Side Change Cost** | Number | `20` | Power cost in Wh to change drone faction. |
| **Drone Disable Cost** | Number | `10` | Power cost in Wh to disable (explode) drone. |
| **Custom Device Cost** | Number | `10` | Power cost in Wh per custom device action. |

**Example Setup:**
```
Door Lock/Unlock Cost: 5
Drone Side Change Cost: 30
Drone Disable Cost: 15
Custom Device Cost: 20
```

**What It Does:**
- Sets global power costs that override CBA settings
- Applies to all hacking operations in the mission
- Changes take effect when mission loads

**Notes:**
- Only one instance of this module should exist per mission
- Does NOT affect vehicle-specific power costs (set per vehicle module)
- Does NOT affect GPS tracker power costs (set per tracker module)
- Does NOT include Power Grid cost (set per generator module)

---

### 3. Add Devices

**Purpose:** Register buildings (doors), lights, or drones as hackable devices.

**How to Use:**
1. Place buildings, lamps, or drones in the scene
2. Place **Add Devices** module (F5 → ROOT_CYBERWARFARE)
3. **Synchronize** the module to target objects
4. Optionally synchronize to laptops for private access
5. Configure attributes

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **Add to Public Device List** | Checkbox | ✓ Checked | If checked, devices are accessible by all laptops (current and future). |
| **Make Unbreachable** | Checkbox | Unchecked | If checked, building doors cannot be breached with ACE explosives, lockpicking, or other means except using the linked laptop. |

**Synchronization:**

| Sync Target | Effect |
|-------------|--------|
| **Buildings** | Registers all doors in the building |
| **Lamps** | Registers as controllable lights |
| **Drones/UAVs** | Registers for faction change/disable |
| **Laptops** | Grants those laptops private access (if "Add to Public Device List" is unchecked) |

**Example Setup 1: Public Building (All Laptops)**
```
1. Place building1 in scene
2. Place "Add Devices" module
3. Sync module to building1
4. Set "Add to Public Device List": ✓ (checked)
5. Set "Make Unbreachable": ✓ (checked)
Result: All laptops can access this building's doors, which cannot be breached
```

**Example Setup 2: Private Drone (Specific Laptops)**
```
1. Place drone1 and laptop1 in scene
2. Place "Add Devices" module
3. Sync module to drone1 AND laptop1
4. Set "Add to Public Device List": (unchecked)
Result: Only laptop1 can change drone1's faction or disable it
```

**What It Does:**
- **Buildings**: Auto-detects all doors, registers with unique door IDs
- **Lights**: Registers lamp with on/off control
- **Drones**: Registers for `changedrone` and `disabledrone` commands
- **Unbreachable** (if checked): Prevents ACE explosive breaching and lockpicking on doors

**Public vs Private Access:**
- **Public** (checkbox checked): All laptops have access
- **Private** (checkbox unchecked + sync to laptops): Only synced laptops have access
- **Private** (checkbox unchecked + no laptop sync): No access (can be linked later via scripting)

**Notes:**
- One module can be synced to multiple objects (all get the same settings)
- Buildings auto-detect all doors (no manual door ID specification needed)
- Drones are auto-detected based on vehicle type

---

### 4. Add Hackable File

**Purpose:** Create downloadable files that players can access via the `download` command.

**How to Use:**
1. Place **Add Hackable File** module (F5 → ROOT_CYBERWARFARE)
2. Optionally synchronize to laptops for private access
3. Configure attributes

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **File Name** | String | `Secret Database` | Name of the file (with or without extension). |
| **Download Time (seconds)** | Number | `10` | Time in seconds required to download. |
| **File Contents** | Multiline Text | (example) | Contents shown when using `cat` command. Uses code editor for formatting. |
| **Execution Code (Optional)** | Multiline SQF | (empty) | Code executed upon successful download. Uses code editor. |
| **Add to Public Device List** | Checkbox | ✓ Checked | If checked, file is accessible by all laptops. |

**Synchronization:**
- **Optional**: Sync to laptops for private access (if "Add to Public Device List" is unchecked)
- **Compatible objects**: AE3 laptops

**Example Setup:**
```
File Name: enemy_locations.txt
Download Time: 15
File Contents:
    ENEMY INTEL - CLASSIFIED
    ========================
    Alpha Team: Grid 045-182
    Bravo Team: Grid 112-209
    Charlie Team: Grid 073-155

Execution Code:
    hint "New objective: Eliminate enemy teams!";
    player createDiaryRecord ["Diary", ["Intel", "Enemy positions downloaded."]];

Add to Public Device List: (unchecked)
Sync to: laptop1, laptop2
```

**What It Does:**
- Registers a downloadable file in the database system
- File appears in `devices files` listing
- Players use `download <FileID>` to download
- File saved to `/home/user/Downloads/<filename>` on laptop
- Execution code runs after download completes (if configured)

**Common Use Cases:**
- Mission intel and story documents
- Objective triggers (code execution on download)
- Resource unlocks (equipment, support, reinforcements)
- Easter eggs and hidden content

**Notes:**
- Download time is real seconds (e.g., 10 = 10 actual seconds)
- File contents support newlines and special characters
- Execution code runs on the server (use `remoteExec` for client-side effects)
- Players read downloaded files with `cat /home/user/Downloads/<filename>`

---

### 5. Add Hackable Vehicle

**Purpose:** Register vehicles or drones as hackable, enabling control over fuel, speed, brakes, lights, engine, and alarms.

**How to Use:**
1. Place vehicles or drones in the scene
2. Place **Add Hackable Vehicle** module (F5 → ROOT_CYBERWARFARE)
3. **Synchronize** the module to vehicle(s)
4. Optionally synchronize to laptops for private access
5. Configure attributes

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **Vehicle Name** | String | `Target Vehicle` | Display name in terminal listings. |
| **Power Cost per Action** | Number | `2` | Power cost in Wh for each hacking action. |
| **Allow Fuel/Battery Hacking** | Checkbox | ✓ Checked | Enable fuel/battery manipulation (0-100%). |
| **Allow Speed Hacking** | Checkbox | ✓ Checked | Enable max speed limitation (0-100%). |
| **Allow Brakes Hacking** | Checkbox | Unchecked | Enable brake control (0=off, 1=on). |
| **Allow Lights Hacking** | Checkbox | ✓ Checked | Enable light control (0=off, 1=on). |
| **Allow Engine Hacking** | Checkbox | ✓ Checked | Enable engine stop/start (0=off, 1=on). |
| **Allow Alarm Hacking** | Checkbox | Unchecked | Enable car alarm control (0=off, 1=on). |
| **Add to Public Device List** | Checkbox | ✓ Checked | If checked, vehicle is accessible by all laptops. |

**Synchronization:**

| Sync Target | Effect |
|-------------|--------|
| **Vehicles** | Registers those vehicles as hackable |
| **Laptops** | Grants those laptops private access (if public checkbox is unchecked) |

**Example Setup:**
```
1. Place enemyAPC in scene
2. Place "Add Hackable Vehicle" module
3. Sync module to enemyAPC
4. Configure:
   Vehicle Name: Enemy APC
   Power Cost per Action: 5
   Allow Fuel: ✓
   Allow Speed: ✓
   Allow Brakes: (unchecked)
   Allow Lights: ✓
   Allow Engine: ✓
   Allow Alarm: (unchecked)
   Add to Public Device List: ✓
```

**What It Does:**
- Registers vehicle(s) with unique IDs
- Enables selected hacking capabilities
- Players use `vehicle <VehicleID> <action> <value>` to control
- Only enabled actions work (disabled actions return errors)

**Vehicle Actions:**

| Action | Value | Example Command |
|--------|-------|-----------------|
| `battery` | 0-100 | `vehicle 1337 battery 0` |
| `speed` | 0-100 | `vehicle 1337 speed 30` |
| `brakes` | 0-1 | `vehicle 1337 brakes 0` |
| `lights` | 0-1 | `vehicle 1337 lights 0` |
| `engine` | 0-1 | `vehicle 1337 engine 0` |
| `alarm` | 0-1 | `vehicle 1337 alarm 0` |

**Drones:**
- If synchronized object is a UAV/drone, it's registered with simplified parameters
- Drones use `changedrone` and `disabledrone` commands instead of `vehicle`

**Notes:**
- Power cost applies to each individual action
- Only enabled features appear in `devices vehicles` listing
- Can sync one module to multiple vehicles (all get the same settings)

---

### 6. Add GPS Tracker

**Purpose:** Attach GPS trackers to objects for real-time position tracking.

**How to Use:**
1. Place objects in the scene (vehicles, units, crates, etc.)
2. Place **Add GPS Tracker** module (F5 → ROOT_CYBERWARFARE)
3. **Synchronize** the module to target object(s)
4. Optionally synchronize to laptops for private access
5. Configure attributes

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **GPS Tracker Name** | String | `Target_GPS` | Display name and default marker name. |
| **Tracking Time (seconds)** | Number | `60` | Maximum duration tracking stays active. |
| **Update Frequency (seconds)** | Number | `5` | How often position updates (e.g., every 5 seconds). |
| **Last Ping Duration (seconds)** | Number | `5` | How long "last ping" marker remains visible after tracking ends. |
| **Power Cost to Track** | Number | `10` | Power cost in Wh to start tracking. |
| **Custom Marker Name (Optional)** | String | (empty) | Custom map marker name. If empty, uses GPS Tracker Name. |
| **Allow Retracking** | Checkbox | Unchecked | If checked, tracking can be restarted after completion. |
| **Add to Public Device List** | Checkbox | ✓ Checked | If checked, tracker is accessible by all laptops. |

**Synchronization:**

| Sync Target | Effect |
|-------------|--------|
| **Any object** | Attaches GPS tracker to that object |
| **Laptops** | Grants those laptops private access (if public checkbox is unchecked) |

**Example Setup:**
```
1. Place enemyCommander (unit) in scene
2. Place laptop1 in scene
3. Place "Add GPS Tracker" module
4. Sync module to enemyCommander AND laptop1
5. Configure:
   GPS Tracker Name: HVT_Tracker
   Tracking Time: 180
   Update Frequency: 10
   Last Ping Duration: 30
   Power Cost: 15
   Custom Marker Name: (empty)
   Allow Retracking: (unchecked)
   Add to Public Device List: (unchecked)
Result: Only laptop1 can track enemyCommander
```

**What It Does:**
- Attaches virtual GPS tracker to synchronized object(s)
- Players use `gpstrack <TrackerID>` to start tracking
- Creates two map markers:
  - **Active Ping**: Updates at configured frequency
  - **Last Ping**: Shows final position after tracking ends

**Marker Visibility:**
- Configured globally via CBA settings (see [Configuration](Configuration))
- Can be set to specific sides, groups, or players

**Common Use Cases:**
- Track high-value targets (HVTs)
- Monitor enemy vehicle movements
- Follow moving objectives
- Counter-surveillance scenarios (players can search for and disable trackers)

**Notes:**
- Tracking stops if target is destroyed
- If "Allow Retracking" is unchecked, tracker is single-use
- Marker colors configured via CBA settings
- Players can physically search for and disable trackers (see [Player Guide](Player-Guide#gps-tracker-mechanics))

---

### 7. Add Custom Device

**Purpose:** Create custom scripted devices with user-defined activation and deactivation code.

**How to Use:**
1. Place objects in the scene
2. Place **Add Custom Device** module (F5 → ROOT_CYBERWARFARE)
3. **Synchronize** the module to target object(s)
4. Optionally synchronize to laptops for private access
5. Configure attributes

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **Custom Device Name** | String | `Custom Device` | Display name in terminal listings. |
| **Activation Code** | Multiline SQF | (example) | SQF code executed when device is activated. Uses code editor. |
| **Deactivation Code** | Multiline SQF | (example) | SQF code executed when device is deactivated. Uses code editor. |
| **Add to Public Device List** | Checkbox | ✓ Checked | If checked, device is accessible by all laptops. |

**Code Context:**
In activation/deactivation code, `_this` is an array:
```sqf
_this = [_deviceObject, "activate"|"deactivate"]

// Access object:
private _device = _this select 0;

// Access action:
private _action = _this select 1; // "activate" or "deactivate"
```

**Synchronization:**

| Sync Target | Effect |
|-------------|--------|
| **Any object** | That object becomes the custom device |
| **Laptops** | Grants those laptops private access (if public checkbox is unchecked) |

**Example Setup:**
```
1. Place alarmBox (object) in scene
2. Place "Add Custom Device" module
3. Sync module to alarmBox
4. Configure:
   Custom Device Name: Base Alarm System

   Activation Code:
   private _device = _this select 0;
   private _soundSource = createSoundSource ["Sound_Alarm", getPosASL _device, [], 0];
   _device setVariable ["AlarmSound", _soundSource, true];
   hint "ALARM ACTIVATED!";

   Deactivation Code:
   private _device = _this select 0;
   private _soundSource = _device getVariable ["AlarmSound", objNull];
   if (!isNull _soundSource) then { deleteVehicle _soundSource; };
   hint "Alarm deactivated.";

   Add to Public Device List: ✓
```

**What It Does:**
- Registers object as a custom hackable device
- Players use `custom <DeviceID> activate/deactivate` to trigger code
- Code executes on the server in a scheduled environment

**Common Use Cases:**
- **Alarm systems**: Sound effects, visual alerts
- **Generator control**: Enable/disable lights, power grids
- **Door mechanisms**: Complex door systems with animations
- **Event triggers**: Spawn units, change objectives, activate scripts
- **Environmental control**: Weather, time of day, ambient effects
- **Mission logic**: Progression triggers, fail states, win conditions

**Code Execution Notes:**
- Runs on the server
- Scheduled environment (can use `sleep`, `waitUntil`, etc.)
- Use `remoteExec` for client-side effects (hints, sounds, etc.)
- Device object is available, so you can:
  - Get position: `getPosASL _device`
  - Set variables: `_device setVariable ["key", value, true]`
  - Attach effects: `createVehicle`, `createSoundSource`, etc.

---

### 8. Add Power Generator

**Purpose:** Create power generators that control lights within a configurable radius.

**How to Use:**
1. Place objects in the scene (representing generators)
2. Place **Add Power Generator** module (F5 → ROOT_CYBERWARFARE)
3. **Synchronize** the module to generator object(s)
4. Optionally synchronize to laptops for private access
5. Configure attributes

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| **Generator Name** | String | `Power Generator` | Display name in terminal listings. |
| **Effect Radius (meters)** | Number | `1000` | Radius in meters to affect lights. |
| **Allow Explosion on Activation** | Checkbox | Unchecked | If checked, `on` action creates explosion. |
| **Allow Explosion on Deactivation** | Checkbox | Unchecked | If checked, `off` or `overload` action creates explosion. |
| **Explosion Type** | String | `HelicopterExploSmall` | Ammo classname for explosion. |
| **Excluded Light Classnames** | String | (empty) | Comma-separated list of light classnames to exclude from control. |
| **Power Cost** | Number | `10` | Power cost in Wh per operation. |
| **Add to Public Device List** | Checkbox | ✓ Checked | If checked, generator is accessible by all laptops. |

**Synchronization:**

| Sync Target | Effect |
|-------------|--------|
| **Any object** | That object becomes the power generator |
| **Laptops** | Grants those laptops private access (if public checkbox is unchecked) |

**Example Setup:**
```
1. Place generatorObject in scene
2. Place "Add Power Generator" module
3. Sync module to generatorObject
4. Configure:
   Generator Name: Main Base Power
   Effect Radius: 500
   Allow Explosion on Activation: (unchecked)
   Allow Explosion on Deactivation: ✓ (checked)
   Explosion Type: HelicopterExploSmall
   Excluded Light Classnames: Land_LampDecor_F,Land_LampHalogen_F
   Power Cost: 20
   Add to Public Device List: ✓
```

**What It Does:**
- Registers object as a power generator
- Players use `powergrid <GridID> <on|off|overload>` to control
- Actions:
  - `on`: Turn on all lights in radius
  - `off`: Turn off all lights in radius
  - `overload`: Destroy generator and all lights (with optional explosion)

**Excluded Light Classnames:**
Comma-separated list to prevent specific light types from being controlled.

Example classnames:
```
Land_LampDecor_F,Land_LampHalogen_F,Land_LampAirport_F
```

**Explosion Types:**
Common ammo classnames:
- `HelicopterExploSmall` - Small explosion (default)
- `HelicopterExploBig` - Large explosion
- `Bo_GBU12_LGB` - Guided bomb explosion
- `Sh_155mm_AMOS` - Artillery shell explosion
- `M_Mo_82mm_AT_LG` - Mortar explosion

**Common Use Cases:**
- **Base blackouts**: Turn off entire base lighting
- **Sabotage missions**: Overload generators as objectives
- **Dynamic events**: Script generator failures, power restoration
- **Tactical advantage**: Control lighting for stealth or visibility

**Notes:**
- Overload permanently destroys generator object
- Explosion (if enabled) creates damage, visual, and audio effects
- All lights in radius (except excluded) are affected
- Number of affected lights is reported in command output

---

## Synchronization Guide

Understanding how to synchronize modules is key to using 3DEN modules effectively.

### How to Synchronize

1. Press **F5** to enter module placement mode
2. Click a module to select it
3. Press **F5** again and **drag a line** from module to target object(s)
4. Blue sync lines appear connecting module to targets

### Synchronization Rules

| Module | Required Sync | Optional Sync | Effect |
|--------|---------------|---------------|--------|
| Add Hacking Tools | AE3 Laptops | None | Installs tools on synced laptops |
| Adjust Power Costs | None | None | Mission-wide settings |
| Add Devices | Buildings/Lights/Drones | Laptops | Links devices to synced laptops (if not public) |
| Add Hackable File | None | Laptops | Links file to synced laptops (if not public) |
| Add Hackable Vehicle | Vehicles | Laptops | Links vehicles to synced laptops (if not public) |
| Add GPS Tracker | Objects to track | Laptops | Links trackers to synced laptops (if not public) |
| Add Custom Device | Device objects | Laptops | Links devices to synced laptops (if not public) |
| Add Power Generator | Generator objects | Laptops | Links generators to synced laptops (if not public) |

### Public vs Private Access

**Public Access** (checkbox checked):
- All laptops can access the device
- No need to sync to laptops
- Simplest setup for open missions

**Private Access** (checkbox unchecked):
- MUST sync to laptops for access
- Only synced laptops can use the device
- Best for team-specific or restricted devices

### Multiple Synchronizations

You can sync one module to multiple objects:

**Example: One module, multiple buildings**
```
1. Place buildings: house1, house2, house3
2. Place "Add Devices" module
3. Sync module to house1, house2, and house3
Result: All three buildings get the same settings
```

**Example: One module, specific laptops**
```
1. Place laptops: laptop1, laptop2
2. Place vehicle1
3. Place "Add Hackable Vehicle" module
4. Sync module to vehicle1, laptop1, and laptop2
5. Set "Add to Public Device List": (unchecked)
Result: Only laptop1 and laptop2 can control vehicle1
```

---

## Best Practices

### 1. Organize Modules by Function

Group modules logically in the editor:
- Keep all "Add Hacking Tools" modules together
- Place device modules near their target objects
- Use meaningful module names (can rename in attributes)

### 2. Use Public Access for Training Missions

For missions focused on teaching players, use public access:
- Check "Add to Public Device List" on all devices
- Players can access everything without complex setup
- Easier to test and troubleshoot

### 3. Use Private Access for Competitive Missions

For PvP or team-based missions:
- Uncheck "Add to Public Device List"
- Sync devices to specific team laptops
- Creates asymmetric gameplay and strategic choices

### 4. Test in Editor Preview

Before publishing:
1. Press Preview button (Play icon)
2. Test terminal commands (`devices`, `door`, etc.)
3. Verify synchronizations work correctly
4. Check power costs are balanced

### 5. Only One "Adjust Power Costs" Module

- Place only ONE instance of "Adjust Power Costs" per mission
- Multiple instances may cause conflicts
- If you need different costs, use scripting instead

### 6. Name Devices Clearly

Use descriptive names:
- ❌ Bad: "Vehicle 1", "Device 2"
- ✅ Good: "Enemy Commander APC", "Main Generator", "Intel Database"

Players see these names in the terminal!

### 7. Balance Tracking Parameters

For GPS trackers:
- **Short missions**: 60s tracking, 5s updates
- **Long missions**: 180s tracking, 10s updates
- **Stealth missions**: Higher power costs (15-20 Wh)
- **Action missions**: Lower power costs (5-10 Wh)

### 8. Use Custom Devices for Mission Logic

Instead of complex scripting in `init.sqf`, use custom devices:
- Trigger objectives via activation code
- Control mission flow with device states
- Create interactive elements (alarms, switches, terminals)

### 9. Document Your Setup

Add comments in the editor:
- Use Eden Editor's comment markers
- Document which laptops have what access
- Note special configurations or sequences

---

## Example Mission Setup

### Scenario: Infiltration Mission

**Goal**: Players must infiltrate an enemy base, disable alarms, and download intel.

**Setup Steps:**

#### Step 1: Place Player Assets
```
1. Place player unit (BluFor)
2. Place laptop1 (AE3 laptop, near player spawn)
```

#### Step 2: Add Hacking Tools
```
1. F5 → ROOT_CYBERWARFARE → Add Hacking Tools
2. Sync to laptop1
3. Attributes:
   - Tool Path: /infiltration/tools
   - Backdoor: (empty)
```

#### Step 3: Register Base Buildings
```
1. Identify 3 buildings in enemy base: barracks, hq, warehouse
2. F5 → ROOT_CYBERWARFARE → Add Devices
3. Sync to barracks, hq, warehouse, and laptop1
4. Attributes:
   - Add to Public Device List: (unchecked)
   - Make Unbreachable: ✓ (checked)
Result: Only laptop1 can access doors, ACE breaching disabled
```

#### Step 4: Create Alarm System
```
1. Place alarmBox object in base
2. F5 → ROOT_CYBERWARFARE → Add Custom Device
3. Sync to alarmBox and laptop1
4. Attributes:
   - Custom Device Name: Base Alarm
   - Activation Code:
     playSound3D ["a3\sounds_f\sfx\alarm.wss", _this select 0, false, getPosASL (_this select 0), 5, 1, 500];
   - Deactivation Code:
     hint "Alarm disabled.";
   - Add to Public Device List: (unchecked)
```

#### Step 5: Add Intel File
```
1. F5 → ROOT_CYBERWARFARE → Add Hackable File
2. Sync to laptop1
3. Attributes:
   - File Name: base_intel.txt
   - Download Time: 20
   - File Contents:
     TOP SECRET INTEL
     ===============
     Next convoy: 1200 hours
     Route: Highway 7
   - Execution Code:
     hint "Objective complete: Intel downloaded!";
     "IntelObjective" call BIS_fnc_taskSetState "SUCCEEDED";
   - Add to Public Device List: (unchecked)
```

#### Step 6: Add Enemy Vehicle Tracking
```
1. Place enemyAPC in base
2. F5 → ROOT_CYBERWARFARE → Add GPS Tracker
3. Sync to enemyAPC and laptop1
4. Attributes:
   - GPS Tracker Name: Enemy_APC_Tracker
   - Tracking Time: 120
   - Update Frequency: 10
   - Power Cost: 10
   - Add to Public Device List: (unchecked)
```

#### Step 7: Add Base Blackout
```
1. Place generatorObject in base
2. F5 → ROOT_CYBERWARFARE → Add Power Generator
3. Sync to generatorObject and laptop1
4. Attributes:
   - Generator Name: Base Power
   - Effect Radius: 300
   - Allow Explosion on Deactivation: ✓
   - Explosion Type: HelicopterExploSmall
   - Power Cost: 15
   - Add to Public Device List: (unchecked)
```

#### Step 8: Set Power Costs
```
1. F5 → ROOT_CYBERWARFARE → Adjust Power Cost Settings
2. Attributes:
   - Door Cost: 3
   - Drone Side Change: 25
   - Drone Disable: 15
   - Custom Device: 5
```

### Mission Flow

1. Player spawns, accesses laptop1
2. Player infiltrates base, uses laptop to:
   - Unlock building doors (`door <ID> a unlock`)
   - Disable alarm (`custom <ID> deactivate`)
   - Turn off base lights (`powergrid <ID> off`)
3. Player downloads intel (`download <ID>`)
4. Objective triggers, mission complete
5. Optional: Track enemy APC (`gpstrack <ID>`)

### Testing Checklist

- [ ] Player can access terminal on laptop1
- [ ] `devices` shows all expected devices
- [ ] Doors can be unlocked
- [ ] Alarm can be deactivated
- [ ] File can be downloaded
- [ ] Power grid controls lights
- [ ] GPS tracker works
- [ ] Power costs are balanced
- [ ] Objective triggers on download

---

**Need more advanced scripting?** Check the [Mission Maker Guide](Mission-Maker-Guide) for programmatic device registration and the [API Reference](API-Reference) for function documentation, or ask in [Discord](https://discord.gg/77th-jsoc-official).
