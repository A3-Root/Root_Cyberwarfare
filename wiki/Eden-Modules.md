# Eden Modules Reference

This guide covers the 3DEN Editor modules provided by Root's Cyber Warfare for pre-mission device configuration.

## Overview

Root's Cyber Warfare provides **7 Eden (3DEN) Editor modules** for configuring hacking capabilities directly in the mission editor. These modules allow mission makers to set up devices, laptops, and configurations before the mission starts, without requiring scripting knowledge.

**Key Concept**: Eden modules create device links during mission initialization, but devices only become accessible after hacking tools are installed on laptops (either in Eden or via Zeus during the mission).

---

## Module List

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **Add Hacking Tools** | Install hacking tools on laptop | Custom paths, backdoor access, laptop naming |
| **Add Hackable Objects** | Make objects hackable | Doors, lights, drones, custom devices |
| **Add GPS Tracker** | Add GPS tracker to object | Configurable tracking time, update frequency |
| **Add Hackable Vehicle** | Make vehicles hackable | Battery, speed, brakes, lights, engine, alarm control |
| **Add Hackable File** | Create downloadable files | Custom content, execution code |
| **Add Custom Device** | Create custom hackable device | Custom activation/deactivation scripts |
| **Adjust Power Cost** | Modify per-device power cost | Individual device power consumption |

---

## Workflow: Two-Step Device Access

**Important**: Eden modules use a two-step workflow:

1. **In Eden Editor**: Synchronize devices to laptops to create device links
2. **In Mission**: Install hacking tools on laptops (via Eden module or Zeus) to enable access

**Example**:
```
Step 1 (Eden): Sync building with doors to laptop object → Creates device links
Step 2 (Eden or In-Game): Add hacking tools to laptop → Player can now hack the doors
```

This allows mission makers to pre-configure device access while maintaining control over when players gain hacking capabilities.

---

## Module 1: Add Hacking Tools

Installs hacking tools on a laptop, enabling hacking capabilities for devices linked to it.

### Usage

1. **Place module** in Eden Editor
2. **Synchronize** module to laptop object (line connection in Eden)
3. **Configure module attributes**:
   - **Installation Path**: Default `/rubberducky/tools`
   - **Custom Laptop Name**: Display name for device linking
   - **Backdoor Prefix**: Special prefix for admin access (optional)
4. **Preview/Play mission** - Tools are installed on mission start

### Module Attributes

| Attribute | Description | Default | Example |
|-----------|-------------|---------|---------|
| Installation Path | Filesystem path where tools are installed | `/rubberducky/tools` | `/network/tools` |
| Custom Laptop Name | Unique identifier for this laptop | Auto-generated | `HQ_Terminal` |
| Backdoor Prefix | Path prefix for admin access to all devices | Empty | `/admin` |

### Backdoor System

**Backdoor Access** grants full access to ALL devices, bypassing normal access control.

**How it works**:
- Set backdoor prefix (e.g., `/admin`)
- Any command executed from path starting with prefix has full access
- Example: Commands at `/admin/devices` see all devices

**Use cases**:
- Admin/GM laptops
- Special operator equipment
- Testing/debugging

### Example Setup

```
Scenario: Intel team laptop with normal access
1. Place laptop object named "laptop_intel"
2. Place "Add Hacking Tools" module
3. Sync module to laptop_intel
4. Set Custom Laptop Name: "Intel Team Terminal"
5. Leave backdoor empty

Result: Laptop has tools, can access linked devices only
```

### Notes

- Laptop must be compatible with AE3 (Land_Laptop_F, Land_Laptop_unfolded_F, etc.)
- Tools are virtual files in AE3 filesystem
- Multiple laptops can have different access levels
- Module auto-deletes after mission init

---

## Module 2: Add Hackable Objects

Makes an object hackable (auto-detects doors, lights, drones, or creates custom device).

### Usage

1. **Place module** in Eden Editor
2. **Synchronize** module to target object(s)
3. **Configure module attributes**:
   - Auto-detection vs custom device
   - Device linking (which laptops have access)
   - Public access settings
4. **Preview/Play mission**

### Module Attributes

| Attribute | Description | Default |
|-----------|-------------|---------|
| **Treat as Custom Device** | Force custom device instead of auto-detection | No |
| **Custom Device Name** | Display name for custom device | Empty |
| **Activation Code** | SQF code executed on activation | Empty |
| **Deactivation Code** | SQF code executed on deactivation | Empty |
| **Public Device** | Available to all current laptops | Yes |

### Auto-Detection

The module automatically detects:
- **Buildings with doors** → Door device (locks/unlocks doors)
- **Lamps** (`Lamps_base_F` inheritance) → Light device (on/off control)
- **UAVs** (units with `unitIsUAV` true) → Drone device (faction change, disable)

If object doesn't match → Enable "Treat as Custom Device"

### Device Linking via Synchronization

**Synchronization** determines which laptops can access the device:

| Scenario | Public Device | Synced Laptops | Result |
|----------|---------------|----------------|--------|
| **1** | ✅ Yes | None | All laptops with hacking tools |
| **2** | ❌ No | None | No access (device unusable) |
| **3** | ❌ No | Some laptops | Only synced laptops |
| **4** | ✅ Yes | Some laptops | Synced laptops excluded, all others have access |

**Recommendation**: For most use cases, use Scenario 1 (Public = Yes) or Scenario 3 (Public = No, sync specific laptops).

### Custom Device Code

**Activation/Deactivation Code**:
- Runs in scheduled environment (`spawn`)
- Access device object via `objectFromNetId (netId _this)`
- Example use cases:
  - Trigger explosions
  - Spawn reinforcements
  - Open hidden doors
  - Start/stop timers

**Example Code**:
```sqf
// Activation: Create smoke
private _device = objectFromNetId (netId _this);
"SmokeShell" createVehicle (getPos _device);
hint "Smoke deployed!";

// Deactivation: Clear smoke
hint "Smoke cleared.";
```

### Examples

**Example 1: Building Doors (Public)**
```
Object: Multi-story building
Public Device: Yes
Synced: None
Result: All laptops with hacking tools can hack doors
```

**Example 2: Enemy Drone (Private)**
```
Object: AR-2 Darter (OPFOR)
Public Device: No
Synced: laptop_recon
Result: Only laptop_recon can hack this drone
```

**Example 3: Custom Generator**
```
Object: Land_dp_transformer_F
Treat as Custom: Yes
Name: "Backup Generator"
Activation: [power on script]
Deactivation: [power off script]
Public Device: Yes
Result: Custom device available to all laptops
```

### Notes

- Device gets random ID (1000-9999)
- Device links are preserved even before hacking tools are installed
- Use "Adjust Power Cost" module to modify individual device costs
- Module supports multiple objects synced to single module

---

## Module 3: Add GPS Tracker

Attaches a GPS tracker to an object for remote tracking via hacked laptops.

### Usage

1. **Place module** in Eden Editor
2. **Synchronize** module to target object (vehicle, unit, etc.)
3. **Configure module attributes**:
   - Tracker name, timing, power cost
   - Laptop linking
   - Retracking options
4. **Preview/Play mission**

### Module Attributes

| Attribute | Description | Default | Range |
|-----------|-------------|---------|-------|
| **Tracker Name** | Display name in terminal | `GPS_Tracker_N` | Any string |
| **Tracking Time** | Max tracking duration (seconds) | 60 | 1-3000 |
| **Update Frequency** | Time between position updates (seconds) | 5 | 1-3000 |
| **Last Ping Duration** | How long last ping marker shows (seconds) | 30 | 1-3000 |
| **Power Cost** | Power consumed to start tracking (Wh) | 10 | 1-30 |
| **Custom Marker** | Custom map marker name (optional) | Empty | Any string |
| **Allow Retracking** | Can track again after completion | No | Yes/No |

### Tracking Behavior

**Active Tracking**:
- Marker shows on map (color configurable via CBA settings)
- Updates every N seconds (Update Frequency)
- Shows real-time position
- Lasts for Tracking Time seconds

**Last Ping**:
- Marker appears when tracking ends (color configurable via CBA settings)
- Shows final known position
- Visible for Last Ping Duration seconds
- Then marker disappears

**Retracking**:
- If allowed: Status becomes "Completed", can track again
- If not allowed: Status becomes "Untrackable", one-time use

### Marker Visibility

GPS tracker markers support OWNERS configuration for multi-client visibility:
- Side-based visibility (BLUFOR, OPFOR, etc.)
- Group-based visibility
- Player-based visibility

Configured via Zeus module or scripting API.

### Examples

**Example 1: Vehicle Tracker**
```
Object: Hunter MRAP
Tracker Name: "Supply_Truck_1"
Tracking Time: 120s
Update Frequency: 10s
Allow Retracking: Yes
Public Device: Yes
Result: 12 position updates over 2 minutes, reusable tracker
```

**Example 2: HVT Tracker (One-Time)**
```
Object: Enemy commander unit
Tracker Name: "HVT_Commander"
Tracking Time: 300s
Update Frequency: 15s
Allow Retracking: No
Last Ping: 60s
Synced: laptop_intel
Result: 20 updates over 5 minutes, intel team only, single use
```

**Example 3: Supply Cache**
```
Object: Supply box
Tracker Name: "Cache_Alpha"
Tracking Time: 30s
Update Frequency: 5s
Power Cost: 2
Public Device: Yes
Result: Quick 6-ping tracker, low power cost, available to all
```

### Notes

- Tracker ID randomly generated (1000-9999)
- Markers are client-side (only tracking computer sees them)
- Null object handling: Server tracks last known position if object destroyed
- Marker colors configurable via CBA settings (active/last ping)

---

## Module 4: Add Hackable Vehicle

Makes a vehicle hackable with configurable control features.

### Usage

1. **Place module** in Eden Editor
2. **Synchronize** module to vehicle object(s)
3. **Configure module attributes**:
   - Vehicle name
   - Enable/disable control features
   - Power cost
   - Laptop linking
4. **Preview/Play mission**

### Module Attributes

| Attribute | Description | Default |
|-----------|-------------|---------|
| **Vehicle Name** | Display name in terminal | Auto-generated |
| **Power Cost** | Cost per hacking action (Wh) | 2 |
| **Allow Battery Control** | Enable fuel/battery manipulation | Yes |
| **Allow Speed Control** | Enable velocity control | Yes |
| **Allow Brakes Control** | Enable emergency brakes | Yes |
| **Allow Lights Control** | Enable headlight toggle | Yes |
| **Allow Engine Control** | Enable engine on/off | Yes |
| **Allow Car Alarm** | Enable alarm sound | Yes |
| **Public Device** | Available to all laptops | Yes |

### Control Features

Each feature can be individually enabled/disabled:

| Feature | Terminal Command | Description | Restrictions |
|---------|------------------|-------------|--------------|
| **Battery** | `vehicle <id> battery <0-200>` | Set fuel level (>100 = explosion) | None |
| **Speed** | `vehicle <id> speed <number>` | Adjust velocity (+/-) | Vehicle must be moving |
| **Brakes** | `vehicle <id> brakes apply/release` | Emergency brake | Land vehicles only |
| **Lights** | `vehicle <id> lights on/off` | Toggle headlights | Empty vehicles only |
| **Engine** | `vehicle <id> engine on/off` | Start/stop engine | None |
| **Alarm** | `vehicle <id> alarm <1-60>` | Sound horn/siren (seconds) | None |

### Examples

**Example 1: Enemy Transport (Full Control)**
```
Vehicle: HEMTT Transport
Vehicle Name: "Supply_Convoy_Lead"
All Features: Enabled
Power Cost: 3 Wh
Public Device: No
Synced: laptop_ops
Result: Operations team has full vehicle control
```

**Example 2: Civilian Vehicle (Limited)**
```
Vehicle: Offroad
Vehicle Name: "Civilian_Car_01"
Features: Lights and Alarm only
Power Cost: 1 Wh
Public Device: Yes
Result: Low-impact control, available to all laptops
```

**Example 3: HVT Transport (Restricted)**
```
Vehicle: Ifrit (OPFOR)
Vehicle Name: "HVT_Escort_Vehicle"
Features: Battery, Engine, Brakes
Power Cost: 5 Wh
Public Device: No
Synced: laptop_command
Result: High-value target, expensive, command access only
```

### Notes

- Vehicle ID randomly generated (1000-9999)
- Each action consumes power independently
- Light control only works on empty vehicles (no crew)
- Brake control only works on land vehicles
- Features shown in `devices` terminal command output
- Use "Adjust Power Cost" module to change per-vehicle power cost

---

## Module 5: Add Hackable File

Creates a downloadable database/file accessible through hacked laptops.

### Usage

1. **Place module** anywhere in Eden Editor (creates invisible helper object)
2. **Configure module attributes**:
   - File name, size, contents
   - Execution code (optional)
   - Laptop linking
3. **Preview/Play mission**

### Module Attributes

| Attribute | Description | Example |
|-----------|-------------|---------|
| **File Name** | Display name in terminal | `Intelligence_Report` |
| **File Hack Time** | Download time in seconds | 10 |
| **File Contents** | Text content of file | Mission briefing text |
| **Code to Execute on Download** | SQF code executed after download | Task completion script |
| **Public Device** | Available to all laptops | Yes |

### File Contents

Contents can include:
- Mission briefing text
- Intelligence reports
- Coordinates and waypoints
- Code words and passwords
- Story elements and lore
- Any plaintext information

Players access downloaded files via terminal:
```bash
cat /rubberducky/tools/Files/Intelligence_Report.txt
```

### Execution Code

Code runs in **scheduled environment** (`spawn`) after successful download.

**Available variables**:
- `_this select 0` - The laptop object

**Use cases**:
- Trigger next mission objective
- Complete tasks automatically
- Spawn reinforcements or events
- Display notifications
- Award points or rewards

**Example Code**:
```sqf
// Display notification and update task
private _computer = _this select 0;
hint "Intelligence downloaded! New objective assigned.";
["IntelTask", "SUCCEEDED"] call BIS_fnc_taskSetState;
["NextTask"] call BIS_fnc_taskSetCurrent;
```

### Examples

**Example 1: Mission Briefing**
```
File Name: "Operation_Orders"
Hack Time: 5 seconds
Contents: "Your mission is to infiltrate the compound at grid 124532..."
Execution Code: hint "Briefing acquired";
Public Device: Yes
Result: Quick download, all laptops, shows notification
```

**Example 2: Enemy Plans (Restricted)**
```
File Name: "Enemy_Patrol_Routes"
Hack Time: 15 seconds
Contents: [Detailed patrol schedule and routes]
Execution Code: ["PatrolIntelObtained", "SUCCEEDED"] call BIS_fnc_taskSetState;
Public Device: No
Synced: laptop_intel
Result: Intel team only, completes task on download
```

**Example 3: Trap File**
```
File Name: "Classified_Database"
Hack Time: 20 seconds
Contents: "ACCESS DENIED - SECURITY TRACE INITIATED"
Execution Code: hint "ALARM TRIGGERED!"; ["AlarmEvent"] call MyMod_fnc_triggerAlarm;
Public Device: Yes
Result: Trap file that triggers alarm when downloaded
```

### Notes

- File object is invisible helper object (Land_HelipadEmpty_F)
- File ID randomly generated (1000-9999)
- Download shows animated progress bar in terminal
- Files saved to `/rubberducky/tools/Files/` directory automatically
- Filename spaces replaced with underscores in filesystem

---

## Module 6: Add Custom Device

Creates a fully custom hackable device with user-defined activation/deactivation behavior.

### Usage

1. **Place module** in Eden Editor
2. **Synchronize** module to target object
3. **Configure module attributes**:
   - Device name
   - Activation script
   - Deactivation script
   - Power cost
   - Laptop linking
4. **Preview/Play mission**

### Module Attributes

| Attribute | Description | Default |
|-----------|-------------|---------|
| **Custom Device Name** | Display name in terminal | `Custom_Device_N` |
| **Activation Code** | SQF code executed on activation | Empty |
| **Deactivation Code** | SQF code executed on deactivation | Empty |
| **Power Cost** | Power consumed per action (Wh) | 10 |
| **Public Device** | Available to all laptops | Yes |

### Custom Scripts

**Activation/Deactivation Code**:
- Runs in scheduled environment (`spawn`)
- Access device object via: `objectFromNetId (netId _this)`
- Access laptop via: First parameter passed to script
- Can use any SQF commands

**Example Activation Script**:
```sqf
params ['_computer'];
private _deviceNetId = _this getVariable ['ROOT_CYBERWARFARE_CUSTOM_NETID', ''];
private _device = objectFromNetId _deviceNetId;

// Your custom behavior here
"SmokeShellGreen" createVehicle (getPos _device);
[_computer, "Smoke grenade deployed at device location!"] call AE3_armaos_fnc_shell_stdout;
```

### Use Cases

**Mission-Specific Devices**:
- Satellite uplinks (trigger events)
- Power generators (control lights in radius)
- Security systems (disable alarms)
- Communications equipment (unlock intel)
- Explosive devices (sabotage objectives)

### Examples

**Example 1: Alarm System**
```
Object: Land_SatelliteAntenna_01_F
Device Name: "Security_System"
Activation Code: hint "Alarms disabled"; {_x setSpeaker "NoVoice"} forEach allUnits;
Deactivation Code: hint "Alarms enabled"; {_x setSpeaker "Male01ENG"} forEach allUnits;
Power Cost: 15 Wh
Result: Toggle alarm system on/off
```

**Example 2: Bridge Control**
```
Object: Land_dp_mainFactory_F
Device Name: "Bridge_Control"
Activation Code: bridge_1 animate ["Ramp", 1]; hint "Bridge lowered";
Deactivation Code: bridge_1 animate ["Ramp", 0]; hint "Bridge raised";
Power Cost: 5 Wh
Result: Control bridge animation
```

**Example 3: Reinforcement Trigger**
```
Object: Land_DataTerminal_01_F
Device Name: "Comms_Jammer"
Activation Code: ["ReinforcementsBlocked", "SUCCEEDED"] call BIS_fnc_taskSetState;
Deactivation Code: ["ReinforcementsBlocked", "FAILED"] call BIS_fnc_taskSetState;
Power Cost: 20 Wh
Result: Mission-critical objective device
```

### Notes

- Device ID randomly generated (1000-9999)
- Scripts stored on device object globally
- Use `custom <id> activate` / `custom <id> deactivate` terminal commands
- Scripts have access to full Arma 3 command set
- Consider using localized strings for user feedback

---

## Module 7: Adjust Power Cost

Modifies the power cost for a specific device, overriding global CBA settings.

### Usage

1. **Place module** in Eden Editor
2. **Synchronize** module to hackable device (door, vehicle, GPS tracker, custom device, etc.)
3. **Configure module attributes**:
   - New power cost value
4. **Preview/Play mission**

### Module Attributes

| Attribute | Description | Default | Range |
|-----------|-------------|---------|-------|
| **Power Cost** | Power consumed per action (Wh) | Varies by device | 0-100 |

### When to Use

**Increase Cost**:
- High-value targets (HVT vehicles, critical doors)
- Hard mode missions
- Limited battery scenarios
- Late-game difficulty scaling

**Decrease Cost**:
- Training doors/devices
- Frequently-used devices
- Story-critical devices
- Accessibility improvements

**Set to Zero**:
- Free-use devices (tutorial, unlimited access)
- Environmental flavor devices
- Testing devices

### Important Notes

**This module adjusts the power cost required to HACK/USE the device. It does NOT adjust the laptop's battery level.**

**Correct Usage**:
- Adjust how much power it costs to hack a specific door
- Adjust how much power it costs to track a specific GPS device
- Adjust how much power it costs to hack a specific vehicle

**Incorrect Assumption**:
- ❌ This does NOT modify the laptop's battery capacity
- ❌ This does NOT recharge or drain laptop batteries
- ❌ This does NOT affect global power generation

**To modify laptop battery levels**: Use AE3's power system or script commands directly on the laptop object.

### Examples

**Example 1: High-Value Door**
```
Device: Main vault door (building entrance)
Synced: door_device_module
Power Cost: 20 Wh (vs default 2 Wh)
Reason: Critical objective, should be expensive
```

**Example 2: Training Vehicle**
```
Device: Training ground vehicle
Synced: vehicle_device_module
Power Cost: 0 Wh (free)
Reason: Training scenario, focus on learning not resource management
```

**Example 3: Expensive GPS Tracker**
```
Device: Enemy commander GPS tracker
Synced: gps_tracker_module
Power Cost: 25 Wh (vs default 10 Wh)
Reason: High-value target, tracking should be costly
```

**Example 4: Cheap Custom Device**
```
Device: Light switch custom device
Synced: custom_device_module
Power Cost: 1 Wh (vs default 10 Wh)
Reason: Simple environmental control, low impact
```

### Notes

- Only affects the specific synced device(s)
- Does not override global CBA settings for other devices
- Can sync multiple devices to single module to apply same cost
- Power cost displayed in `devices` terminal command
- Module can be applied to any hackable device type

---

## Complete Mission Setup Example

### Scenario: Intel Gathering Operation

**Objective**: Infiltrate enemy base, hack buildings, track HVT, download intel.

**Setup Steps**:

1. **Place Laptops**:
   - Intel team laptop: `laptop_intel`
   - Field operative laptop: `laptop_field`

2. **Add Hacking Tools (2 modules)**:
   - Module 1 → Sync to laptop_intel
     - Name: "Intel Team Terminal"
     - Path: `/intel/tools`
   - Module 2 → Sync to laptop_field
     - Name: "Field Operative Terminal"
     - Path: `/field/tools`

3. **Add Enemy Buildings (1 module for all)**:
   - Module: "Add Hackable Objects"
   - Sync to: building1, building2, building3
   - Public Device: No
   - Sync to: laptop_intel (intel team only)

4. **Add Enemy Commander GPS Tracker**:
   - Module: "Add GPS Tracker"
   - Sync to: enemy_commander
   - Tracker Name: "HVT_Commander"
   - Tracking Time: 120s
   - Update Frequency: 15s
   - Power Cost: 15 Wh
   - Public Device: No
   - Sync to: laptop_intel (intel team only)

5. **Adjust GPS Tracker Power Cost**:
   - Module: "Adjust Power Cost"
   - Sync to: GPS tracker module from step 4
   - Power Cost: 25 Wh (make it expensive, high-value target)

6. **Add Enemy Plans File**:
   - Module: "Add Hackable File"
   - File Name: "Enemy_Operations"
   - Hack Time: 20 seconds
   - Contents: "Patrol schedules and supply routes..."
   - Execution Code:
     ```sqf
     hint "Intel acquired! Objective complete.";
     ["IntelTask", "SUCCEEDED"] call BIS_fnc_taskSetState;
     ```
   - Public Device: Yes (both laptops can access)

7. **Add Enemy Drone**:
   - Module: "Add Hackable Objects"
   - Sync to: enemy_drone (AR-2 Darter)
   - Public Device: No
   - Sync to: laptop_field (field operative only)

8. **Add Custom Alarm System**:
   - Module: "Add Custom Device"
   - Sync to: alarm_terminal
   - Device Name: "Base Security System"
   - Activation Code:
     ```sqf
     params ['_computer'];
     hint "Security system disabled!";
     {_x disableAI "AUTOTARGET"} forEach allUnits;
     [_computer, "All base security disabled."] call AE3_armaos_fnc_shell_stdout;
     ```
   - Deactivation Code:
     ```sqf
     params ['_computer'];
     hint "Security system enabled!";
     {_x enableAI "AUTOTARGET"} forEach allUnits;
     [_computer, "Security system reactivated."] call AE3_armaos_fnc_shell_stdout;
     ```
   - Power Cost: 30 Wh
   - Public Device: No
   - Sync to: laptop_intel

**Result**:
- Intel team can: hack buildings, track HVT (expensive), download intel, disable security
- Field operative can: hack drone, download intel
- Both laptops functional from mission start
- Progressive difficulty via power costs

---

## Best Practices

### For Mission Makers

1. **Plan Device Access**:
   - Map out which teams need access to which devices
   - Use Public Device for shared resources
   - Use synced laptops for restricted access

2. **Balance Power Costs**:
   - Critical devices: Higher costs (15-30 Wh)
   - Common devices: Default costs (2-10 Wh)
   - Environmental devices: Low/free costs (0-2 Wh)

3. **Use Meaningful Names**:
   - Device names: Descriptive and unique (`"HQ_Vault_Door"` not `"Door_1"`)
   - Laptop names: Team/role-based (`"Intel_Terminal"` not `"Laptop"`)

4. **Test Device Links**:
   - Preview mission and test terminal access
   - Verify laptops can see expected devices
   - Check power costs are appropriate

5. **Document Your Setup**:
   - Add comments in mission.sqm or separate notes
   - Explain custom device behaviors
   - Note any special configuration

### For Server Admins

1. **Configure CBA Settings**:
   - Set global power costs before mission
   - Configure GPS tracker items
   - Test settings in local environment

2. **Educate Players**:
   - Explain hacking system to new players
   - Provide guide to terminal commands
   - Clarify power management mechanics

3. **Monitor Performance**:
   - Limit GPS trackers (max 10-15 active)
   - Avoid excessive custom device scripts
   - Clean up unused devices

---

## Troubleshooting

### Devices Not Showing in Terminal

**Symptom**: `devices` command shows empty list or missing devices

**Causes & Solutions**:

1. **Hacking tools not installed**:
   - Ensure "Add Hacking Tools" module synced to laptop
   - Check laptop has `ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED` variable set

2. **Device not linked**:
   - Verify device module synced to laptop (or Public Device = Yes)
   - Check device was properly created on mission init

3. **Wrong laptop**:
   - Confirm you're using correct laptop object
   - Verify laptop name matches expected device links

4. **Module placement error**:
   - Ensure modules synced correctly (blue lines in Eden)
   - Verify module attributes saved before preview

### Debug Commands

```sqf
// Check if laptop has hacking tools
laptop_intel getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false];
// Should return: true

// Check device storage
private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
hint format ["Doors: %1, Drones: %2, GPS: %3",
    count (_allDevices select 0),
    count (_allDevices select 2),
    count (_allDevices select 5)
];

// Check link cache
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
hint str (_linkCache get (netId laptop_intel));
// Should return: array of [deviceType, deviceId] pairs
```

---

## Comparison: Eden vs Zeus vs Scripting

| Feature | Eden Modules | Zeus Modules | Direct Scripting |
|---------|--------------|--------------|------------------|
| **Setup Time** | Pre-mission | During mission | Pre-mission |
| **Flexibility** | Medium | High | Highest |
| **Ease of Use** | Easy | Easy | Advanced |
| **Persistence** | Permanent | Permanent | Permanent |
| **Dynamic Changes** | No | Yes | Yes |
| **Best For** | Pre-planned missions | Dynamic scenarios | Complex systems |

**Recommendation**: Use Eden modules for pre-planned content, Zeus modules for dynamic mission adaptation, and scripting for advanced custom behaviors.

---

## See Also

- [Zeus Guide](Zeus-Guide) - Dynamic in-mission modules
- [Mission Maker Guide](Mission-Maker-Guide) - Scripting integration
- [Configuration Reference](Configuration) - CBA settings
- [Custom Device Tutorial](Custom-Device-Tutorial) - Advanced custom devices
- [API Reference](API-Reference) - Function documentation

---

**Need help?** Join discord or raise an issue on GitHub.
