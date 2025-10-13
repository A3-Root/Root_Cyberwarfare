# Zeus/Curator Guide

This guide covers using Root's Cyber Warfare Zeus modules for dynamic mission creation.

## Overview

Root's Cyber Warfare provides **7 Zeus modules** for adding hacking capabilities to your missions on-the-fly. All modules use ZEN (Zeus Enhanced) dialogs for configuration.

---

## Module List

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **Add Hacking Tools** | Install hacking tools on laptop | Custom paths, backdoor access, laptop naming |
| **Add Hackable Object** | Make objects hackable | Doors, lights, drones, custom devices |
| **Add GPS Tracker** | Add GPS tracker to object | Configurable tracking time, update frequency |
| **Add Hackable Vehicle** | Make vehicles hackable | Battery, speed, brakes, lights, engine, alarm control |
| **Add Hackable File** | Create downloadable files | Custom content, execution code |
| **Add Power Generator** | Control lights within radius | Configurable radius, explosions, light exclusion |
| **Modify Power** | Adjust hack costs for operations | Real-time cost modification |

---

## Module 1: Add Hacking Tools

Installs hacking tools on a laptop, turning it into a functional hacking platform.

### Usage

1. **Place Zeus module** on a laptop object (any laptop-class object)
2. **Configure in dialog**:
   - **Installation Path**: Default `/rubberducky/tools`
   - **Custom Laptop Name**: Display name for device linking
3. **Click OK**

### Dialog Options

| Option | Description | Default | Example |
|--------|-------------|---------|---------|
| Installation Path | Where tools are installed in filesystem | `/rubberducky/tools` | `/network/tools` |
| Custom Laptop Name | Unique identifier for this laptop | `HackingPlatform_N` | `HQ_Terminal` |

### Installed Commands

The module installs these commands:
- `/path/devices` - List devices
- `/path/guide` - Help file
- `/path/door` - Door control
- `/path/light` - Light control
- `/path/changedrone` - Drone faction change
- `/path/disabledrone` - Drone disable
- `/path/download` - File download
- `/path/custom` - Custom device control
- `/path/gpstrack` - GPS tracking
- `/path/vehicle` - Vehicle control

### Backdoor System

**Backdoor Access** grants full access to ALL devices, bypassing normal access control.

**How it works**:
- Set backdoor prefix (e.g., `backdoor`)
- Any command executed from path starting with prefix has full access
- Example: `backdoor_door` has access to all doors

**Use cases**:
- Admin/GM laptops
- Special operator equipment
- Testing/debugging

### Example Scenario

```
Laptop: "Intel Officer Terminal"
Path: /headquarters/tools
Backdoor: admin

Result:
- Player uses: /headquarters/tools/devices → sees only linked devices
- Admin uses: admin_devices → sees ALL devices
```

### Notes

- Laptop must be an item compatible with AE3
- Tools are virtual files in AE3 filesystem
- Multiple laptops can have tools with different access levels
- System chat confirms installation

---

## Module 2: Add Hackable Object

Makes an object hackable (doors, lights, drones, or custom devices).

### Usage

1. **Place Zeus module** on target object
2. **Configure in dialog**:
   - Choose object type (auto-detected or custom)
   - Link to specific laptops (optional)
   - Configure availability to future laptops
   - Set custom device parameters (if applicable)
3. **Click OK**

### Dialog Options

| Option | Description | Values |
|--------|-------------|--------|
| **Treat as Custom Device** | Use custom device instead of auto-detection | Yes/No |
| **Custom Device Name** | Display name for custom device | Any string |
| **Activation Code** | SQF code to run on activation | Code block |
| **Deactivation Code** | SQF code to run on deactivation | Code block |
| **Available to Future Laptops** | Available to laptops added later | Yes/No |
| **Link to Laptops** | Select specific laptops for access | Checkboxes |

### Auto-Detection

The module automatically detects:
- **Buildings with doors** → Door type
- **Lamps** (`Lamps_base_F`) → Light type
- **UAVs** (`unitIsUAV`) → Drone type

If not detected → Can mark as custom device

### Device Linking

**Linking** determines which laptops can access the device:

| Scenario | Future Laptops | Linked Laptops | Result |
|----------|----------------|----------------|--------|
| **1** | ❌ No | None selected | All current laptops |
| **2** | ❌ No | Some selected | Only selected laptops |
| **3** | ✅ Yes | None selected | Only future laptops (current excluded) |
| **4** | ✅ Yes | Some selected | Selected + all future laptops |

### Custom Device Code

**Activation/Deactivation Code**:
- Runs in scheduled environment (`spawn`)
- Use `(_this select 0)` to reference the laptop
- Example use cases:
  - Trigger explosions
  - Spawn reinforcements
  - Open hidden doors
  - Start timers

**Example Code**:
```sqf
// Activation: Create explosion
private _device = objectFromNetId (netId (_this select 0));
"Bo_Mk82" createVehicle (getPos _device);
hint "Generator exploded!";

// Deactivation: Disable explosion
hint "Generator stabilized.";
```

### Examples

**Example 1: Building Doors**
```
Object: Multi-story building
Linked: None (available to all)
Result: All doors hackable by all current laptops
```

**Example 2: Enemy Drone**
```
Object: AR-2 Darter (OPFOR)
Linked: "Recon Team Laptop"
Result: Only Recon Team can hack this drone
```

**Example 3: Custom Power Generator**
```
Treat as Custom: Yes
Name: "Power Generator Overload"
Activation Code: [explosion script]
Linked: None
Future Laptops: Yes
Result: Custom device available to all future laptops, triggers explosion on activation
```

### Notes

- Device gets random ID (1000-9999)
- Activation/deactivation code stored on object
- Door detection uses SimpleObject config animation parsing
- System chat shows device ID and availability

---

## Module 3: Add GPS Tracker

Attaches a GPS tracker to an object for remote tracking.

### Usage

1. **Place Zeus module** on target object
2. **Configure in dialog**:
   - Tracker name
   - Tracking time
   - Update frequency
   - Last ping duration
   - Power cost
   - Custom marker (optional)
   - Allow retracking
   - Link to laptops
   - Available to future laptops
3. **Click OK**

### Dialog Options

| Option | Description | Default | Range |
|--------|-------------|---------|-------|
| **Tracker Name** | Display name | `GPS_Tracker_N` | Any string |
| **Tracking Time** | Max tracking duration (seconds) | 60 | 1-3000 |
| **Update Frequency** | Time between pings (seconds) | 5 | 1-3000 |
| **Last Ping Duration** | How long last ping marker shows | 30 | 1-3000 |
| **Power Cost** | Power consumed to start tracking (Wh) | 10 | 1-30 |
| **Custom Marker** | Custom map marker name | Empty | Any string |
| **Allow Retracking** | Can track again after completion | No | Yes/No |
| **Available to Future Laptops** | Available to future laptops | No | Yes/No |
| **Link to Laptops** | Select laptops for access | All current | Checkboxes |

### Tracking Behavior

**Active Tracking**:
- Red marker on map
- Updates every N seconds
- Shows current position
- Lasts for tracking time

**Last Ping**:
- Purple marker on map
- Shows final known position
- Visible for last ping duration

**Retracking**:
- If allowed: Can track again after completion (status: "Completed")
- If not allowed: One-time use (status: "Untrackable")

### Examples

**Example 1: Vehicle Tracker**
```
Object: Hunter MRAP
Name: "Target_Vehicle"
Tracking Time: 120s
Frequency: 10s
Allow Retracking: Yes
Result: 12 position updates over 2 minutes, can retrack multiple times
```

**Example 2: VIP Tracker**
```
Object: Enemy commander unit
Name: "HVT_Commander"
Tracking Time: 300s
Frequency: 15s
Allow Retracking: No
Last Ping: 60s
Result: 20 updates over 5 minutes, one-time use, last position visible for 1 minute
```

**Example 3: Equipment Cache**
```
Object: Supply box
Name: "Supply_Cache_Alpha"
Tracking Time: 30s
Frequency: 5s
Power Cost: 2
Future Laptops: Yes
Result: 6 pings, very cheap, available to future laptops
```

### Notes

- Tracker ID is randomly generated (1000-9999)
- Markers are client-side (only tracker user sees them)
- Target must remain alive for tracking to work
- Tracking ends early if target is destroyed

---

## Module 4: Add Hackable Vehicle

Makes a vehicle hackable with various control options.

### Usage

1. **Place Zeus module** on vehicle
2. **Configure in dialog**:
   - Vehicle name
   - Power cost per action
   - Enable/disable control features
   - Link to laptops
   - Available to future laptops
3. **Click OK**

### Dialog Options

| Option | Description | Default |
|--------|-------------|---------|
| **Vehicle Name** | Display name | `Vehicle_N` |
| **Power Cost** | Cost per hacking action (Wh) | 2 |
| **Allow Battery Control** | Enable fuel/battery hacking | Yes |
| **Allow Speed Control** | Enable velocity manipulation | Yes |
| **Allow Brakes Control** | Enable emergency brakes | Yes |
| **Allow Lights Control** | Enable light toggle | Yes |
| **Allow Engine Control** | Enable engine on/off | Yes |
| **Allow Car Alarm** | Enable alarm sound | Yes |
| **Available to Future Laptops** | Available to future laptops | No |
| **Link to Laptops** | Select laptops for access | All current |

### Control Features

Each feature can be individually enabled/disabled:

| Feature | Function | Use Case |
|---------|----------|----------|
| **Battery** | Set fuel 0-100%, or destroy (101+) | Disable enemy vehicles, drain fuel |
| **Speed** | Adjust velocity (+/-) | Stop fleeing vehicles, accelerate/decelerate |
| **Brakes** | Apply emergency brakes | Force stop, prevent escape |
| **Lights** | Toggle headlights on/off | Stealth operations, signal allies |
| **Engine** | Start/stop engine | Disable without destruction |
| **Alarm** | Sound horn/siren (1-60s) | Distraction, alert allies |

### Examples

**Example 1: Enemy Transport**
```
Vehicle: HEMTT Transport
Name: "Supply_Convoy_Lead"
Features: Battery, Speed, Brakes, Engine
Power Cost: 3
Result: Can disable or slow enemy logistics
```

**Example 2: Civilian Vehicle**
```
Vehicle: Offroad
Name: "Civilian_Car_01"
Features: Lights, Alarm only
Power Cost: 1
Future Laptops: Yes
Result: Low-impact control, available to all future laptops
```

**Example 3: High-Value Target**
```
Vehicle: Ifrit (OPFOR)
Name: "HVT_Transport"
Features: All enabled
Power Cost: 5
Linked: "Ops Center Terminal" only
Result: Full control, high power cost, restricted access
```

### Notes

- Vehicle ID randomly generated (1000-9999)
- Each action consumes power independently
- **Light control only works on empty vehicles (no crew)**
- **Brakes only work on land vehicles**
- Features shown in `devices` command output

---

## Module 5: Add Hackable File

Creates a downloadable database/file in the network.

### Usage

1. **Place Zeus module anywhere** (creates invisible object)
2. **Configure in dialog**:
   - File name
   - File size (download time)
   - File contents
   - Execution code (optional)
   - Link to laptops
   - Available to future laptops
3. **Click OK**

### Dialog Options

| Option | Description | Example |
|--------|-------------|---------|
| **File Name** | Display name | `Secret Intel` |
| **File Hack Time** | Download time in seconds | 10 |
| **File Contents** | Text content of file | `Mission briefing...` |
| **Code to Execute on Download** | SQF code to run after download | `hint "Intel acquired!";` |
| **Available to Future Laptops** | Available to future laptops | No |
| **Link to Laptops** | Select laptops for access | All current |

### File Contents

Contents can be:
- Mission briefing text
- Coordinates
- Code words
- Story elements
- Lore/background information

Players read files using:
```bash
cat /rubberducky/tools/Files/Secret_Intel.txt
```

### Execution Code

Code runs in **scheduled environment** (`spawn`) after successful download.

**Use cases**:
- Trigger next objective
- Spawn reinforcements
- Update task states
- Display notifications
- Award points

**Example Code**:
```sqf
// Display hint and trigger task
private _computer = _this select 0;
hint "Intel acquired! New objective assigned.";
["NewTask"] call BIS_fnc_taskSetCurrent;

// Award points (if using scoring system)
[player, 100] call YourScoringFunction;
```

### Examples

**Example 1: Mission Briefing**
```
Name: "Operation Orders"
Size: 5 seconds
Contents: "Your mission is to infiltrate the compound..."
Code: hint "Briefing downloaded";
Result: Quick download, displays notification
```

**Example 2: Enemy Plans**
```
Name: "Enemy_Patrol_Routes"
Size: 15 seconds
Contents: [Detailed patrol information]
Code: ["PatrolRoutesObtained", true] call BIS_fnc_taskSetState;
Linked: "Intel Team" only
Result: Longer download, completes task, restricted access
```

**Example 3: Trap File**
```
Name: "Classified_Data"
Size: 20 seconds
Contents: "ACCESS DENIED - TRACE INITIATED"
Code: [player, -50] call ScorePenalty; hint "ALARM TRIGGERED!";
Result: Trap file that triggers alarm and penalties
```

### Notes

- File object is invisible helper object
- File ID randomly generated (1000-9999)
- Download shows animated progress bar
- File saved to `/rubberducky/tools/Files/` directory
- Filename spaces replaced with underscores

---

## Module 6: Add Power Generator

Creates a power generator device that controls all lights within a configurable radius with optional explosion effects.

### Usage

1. **Place Zeus module** on a target object (generator, building, power equipment)
2. **Configure in dialog**:
   - Generator name
   - Effect radius (lights within range)
   - Explosion options (activation/deactivation)
   - Explosion type selection
   - Excluded light classnames
   - Link to specific laptops (optional)
   - Configure availability to future laptops
3. **Click OK**

### Dialog Options

| Option | Description | Default | Range |
|--------|-------------|---------|-------|
| **Generator Name** | Display name in terminal | `Power Generator` | Any string |
| **Effect Radius** | Radius in meters to affect lights | 1000 | 100-25000 |
| **Allow Explosion on Activation** | Create explosion when activated | No | Yes/No |
| **Allow Explosion on Deactivation** | Create explosion when deactivated | No | Yes/No |
| **Explosion Type** | Type of explosion to create | 40mm HE | 9 options |
| **Excluded Light Classnames** | Comma-separated classnames to exclude | Empty | Text field |
| **Available to Future Laptops** | Available to laptops added later | No | Yes/No |
| **Link to Laptops** | Select specific laptops for access | All current | Checkboxes |

### Explosion Types

| Type | Classname | Description |
|------|-----------|-------------|
| 40mm High Explosive | `G_40mm_HE` | Small grenade explosion |
| 82mm High Explosive | `M_Mo_82mm_AT_LG` | Medium mortar explosion |
| 120mm APFSDS Tank Shell | `Sh_120mm_APFSDS` | Tank shell impact |
| 120mm HE Shell | `Sh_120mm_HE` | High-explosive tank round |
| 155mm HE Shell | `Sh_155mm_AMOS` | Artillery shell |
| Small Helicopter Explosion | `HelicopterExploSmall` | Light aircraft explosion |
| Large Helicopter Explosion | `HelicopterExploBig` | Heavy aircraft explosion |
| 500lb GBU-12 (Type I) | `Bo_GBU12_LGB` | Precision bomb (variant 1) |
| 500lb GBU-12 (Type II) | `Bo_GBU12_LGB_MI10` | Precision bomb (variant 2) |

### Behavior

**Activation** (`custom <id> activate`):
- Turns ON all lights within radius (class: `Lamps_base_F`)
- Excludes lights with classnames in exclusion list
- Creates explosion at generator position (if enabled)
- Reports number of lights affected

**Deactivation** (`custom <id> deactivate`):
- Turns OFF all lights within radius (class: `Lamps_base_F`)
- Excludes lights with classnames in exclusion list
- Creates explosion at generator position (if enabled)
- Reports number of lights affected

### Exclusion List

**Format**: Comma-separated classnames (spaces trimmed automatically)

**Example**:
```
Lamp_Street_small_F, Land_LampHalogen_F, Land_LampSolar_F
```

**Use cases**:
- Exclude critical lights (helipad markers, runway lights)
- Exclude specific lamp types
- Preserve certain areas from power control

### Examples

**Example 1: Town Power Grid**
```
Object: Power substation building
Generator Name: "Town_Power_Grid"
Effect Radius: 5000m
Explosion on Activation: No
Explosion on Deactivation: No
Excluded: Empty
Linked: None (available to all)
Result: Controls all town lights within 5km, safe operation
```

**Example 2: Military Base with Sabotage**
```
Object: Generator unit
Generator Name: "Base_Generator"
Effect Radius: 2000m
Explosion on Activation: Yes
Explosion on Deactivation: Yes
Explosion Type: 155mm HE Shell
Excluded: "Land_LampHalogen_F" (exclude important helipad lights)
Linked: "Saboteur_Laptop" only
Result: Controls base lights, explosions on use, preserves helipad, restricted access
```

**Example 3: Compound Blackout**
```
Object: Power box
Generator Name: "Compound_Power"
Effect Radius: 500m
Explosion on Activation: No
Explosion on Deactivation: Yes (alarm effect)
Explosion Type: Small Helicopter Explosion
Excluded: Empty
Future Laptops: Yes
Result: Small radius, deactivation triggers alarm, available to future laptops
```

**Example 4: City-Wide Infrastructure**
```
Object: Central power station
Generator Name: "City_Central_Power"
Effect Radius: 15000m
Explosion on Activation: No
Explosion on Deactivation: No
Excluded: "Lamp_Street_small_F, Land_LampSolar_F"
Linked: "Infrastructure_Control_Laptop"
Result: Massive 15km radius, excludes small/solar lights, restricted to infrastructure team
```

### Device Linking

Power generator uses standard device linking:

| Scenario | Future Laptops | Linked Laptops | Result |
|----------|----------------|----------------|--------|
| **1** | ❌ No | None selected | All current laptops |
| **2** | ❌ No | Some selected | Only selected laptops |
| **3** | ✅ Yes | None selected | Only future laptops (current excluded) |
| **4** | ✅ Yes | Some selected | Selected + all future laptops |

### Technical Details

**Light Detection**:
- Uses `nearObjects ['Lamps_base_F', _radius]` to find lights
- Checks `typeOf _light` against exclusion list
- Uses `switchLight 'ON'` / `switchLight 'OFF'` commands

**State Tracking**:
- Generator stores current state: `ROOT_CYBERWARFARE_GENERATOR_STATE`
- `false` = OFF (lights can be turned on)
- `true` = ON (lights can be turned off)

**Performance Considerations**:
- Very large radii (>10km) may cause brief performance impact
- Limit to reasonable radius for your mission area
- Exclusion list uses exact classname matching (fast)

### Notes

- Generator object does not need to be actual generator (can be any object)
- Radius shown on map during configuration (visual helper)
- Explosion occurs at generator object position
- Terminal output shows number of lights affected
- Device registered as custom device type
- Power cost uses global custom device cost setting

---

## Module 7: Modify Power

Adjusts global power costs (the amount of power required to perform hacking operations) for all hacking operations in real-time.

**Important**: This module modifies how much power it COSTS to hack devices. It does NOT modify laptop battery levels or capacity.

### Usage

1. **Place Zeus module anywhere**
2. **Configure in dialog** - Adjust sliders for each cost type
3. **Click OK** - Costs update immediately

### Dialog Options

| Setting | Description | Default | Range |
|---------|-------------|---------|-------|
| **Cost to Lock/Unlock Doors** | Power per door operation (Wh) | 2 | 0-20 |
| **Cost to Switch Drone Sides** | Power to change drone faction (Wh) | 20 | 0-100 |
| **Cost to Disable Drone** | Power to destroy drone (Wh) | 10 | 0-50 |
| **Cost to Activate/Deactivate Custom Devices** | Power for custom devices (Wh) | 10 | 0-100 |

### When to Use

**Increase costs** for:
- Hard mode missions
- Limited battery scenarios
- High-value targets
- Forcing resource management

**Decrease costs** for:
- Training missions
- Casual gameplay
- Testing
- Story-focused missions

### Examples

**Example 1: Hard Mode**
```
Door Cost: 5
Drone Side Cost: 50
Drone Disable Cost: 30
Custom Cost: 20
Result: Forces careful planning and resource management
```

**Example 2: Easy Mode**
```
All costs: 0
Result: Free hacking, focus on tactics not resources
```

**Example 3: Progressive Difficulty**
```
Start: Default costs
After 20 mins: Increase all by 50%
After 40 mins: Increase all by 100%
Result: Difficulty scales with mission progression
```

### Notes

- **This module adjusts hack operation costs, NOT laptop battery levels**
- Changes affect all laptops immediately
- Does not affect per-device costs (GPS trackers, vehicles with custom costs)
- Stored globally in `ROOT_CYBERWARFARE_ALL_COSTS`
- Can be called multiple times during mission
- To modify laptop battery: Use AE3's power system or direct scripting

---

## General Module Notes

### Module Placement

- Modules auto-delete after configuration
- Some modules require objects (laptop, vehicle, etc.)
- File module works anywhere

### Multiplayer Considerations

- All modules execute on server
- Changes sync to all clients
- Only Zeus can place modules
- Players see system chat confirmations

### Access Control Summary

**Public Devices** (no laptops selected, future = no):
- Available to all current laptops

**Linked Devices** (some laptops selected, future = no):
- Only selected laptops

**Future Only** (no laptops selected, future = yes):
- Only laptops added after this device
- Current laptops excluded

**Future + Linked** (some laptops selected, future = yes):
- Selected current laptops + all future laptops

### Testing Workflow

1. Place laptop
2. Add hacking tools to laptop
3. Add devices (doors, drones, etc.)
4. Test access via laptop terminal
5. Adjust linking/costs as needed
6. Use modify power for difficulty tuning

---

## Common Zeus Scenarios

### Scenario 1: Intel Gathering Mission

```
1. Place 2 laptops at BLUFOR base
2. Add hacking tools to both
3. Add GPS tracker to enemy commander
4. Add file with enemy plans to network
5. Link GPS and file to laptop 1 only (intel team)
6. Set moderate power costs
```

### Scenario 2: Infiltration Mission

```
1. Place laptop on operative
2. Add hacking tools
3. Add hackable buildings (doors)
4. Add lights in compound
5. Link all devices to operative's laptop
6. Set low power costs (stealth focus)
```

### Scenario 3: Dynamic Objectives

```
1. Create custom devices with execution code
2. Link to specific laptops
3. Activation triggers next objective
4. Use files to provide hints/intel
5. GPS trackers for target tracking
6. Scale difficulty with power module
```

---

## See Also

- [Mission Maker Guide](Mission-Maker-Guide) - Scripting integration
- [Configuration Reference](Configuration) - CBA settings
- [Custom Device Tutorial](Custom-Device-Tutorial) - Advanced custom devices
- [API Reference](API-Reference) - Function documentation

---

**Need help?** Join discord or raise an issue in GitHub.
