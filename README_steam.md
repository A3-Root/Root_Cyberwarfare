# Root's Cyber Warfare

**An advanced hacking mod for Arma 3 that adds terminal-based control over doors, lights, vehicles, drones, and more.**

Designed for tactical missions requiring infiltration, sabotage, and electronic warfare. Fully integrated with ACE3, AE3 ArmaOS terminal system, and Zeus/Eden editors. 
Tested over multiple missions in a dedicated server with 67+ players.

---

## Requirements

All dependencies are mandatory:

- **[CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997)** - Community Base Addons
- **[ACE3](https://steamcommunity.com/workshop/filedetails/?id=463939057)** - Advanced Combat Environment 3
- **[AE3](https://steamcommunity.com/workshop/filedetails/?id=2224720390)** - Advanced Equipment 3 (provides ArmaOS terminal)
- **[ZEN](https://steamcommunity.com/workshop/filedetails/?id=1779063631)** - Zeus Enhanced

---

## Device Types

Root's Cyber Warfare supports 8 hackable device categories:

| Device Type | Capabilities | Power Cost |
|-------------|-------------|------------|
| **Building Doors** | Lock/unlock remotely, prevent ACE breaching | 2 Wh per door |
| **Lights** | Turn on/off individual lights or entire buildings | Configurable |
| **Drones (UAVs)** | Change faction allegiance, disable/destroy | 20 Wh (side change), 10 Wh (disable) |
| **Vehicles** | Control battery, speed, brakes, lights, engine, alarm | 2 Wh per action |
| **Databases** | Download files (text or executable code) | Configurable |
| **Custom Devices** | Mission-specific scripted devices (generators, alarms, etc.) | 10 Wh default |
| **GPS Trackers** | Real-time position tracking with map markers | Configurable |
| **Power Grids** | Control all lights in radius, optional explosion effects | 10 Wh default |

---

## For Players

**GIF of ACE interaction menu on laptop showing "Use" option**

### Accessing a Terminal

1. Interact with an AE3 laptop (ACE Self-Interact menu → ArmaOS → Use)
2. The laptop must have hacking tools installed (mission makers/Zeus would configure this)
3. Terminal interface opens with command prompt

### Basic Terminal Commands

**GIF of terminal showing `devices all` output with color-coded device list**

```
devices all              List all hackable devices you can access
devices doors            List only buildings with doors
devices lights           List only lights
devices drones           List only drones
devices files            List only downloadable files
devices vehicles         List only vehicles
devices gps              List only GPS trackers
devices powergrids       List only power generators
```

### Device Control Commands

**Doors:**
```
door <buildingID> <doorID> lock      Lock specific door
door <buildingID> <doorID> unlock    Unlock specific door
door <buildingID> a lock             Lock all doors in building
```

**Lights:**
```
light <lightID> on       Turn light on
light <lightID> off      Turn light off
```

**Vehicles:**
```
vehicle <vehicleID> battery <0-100>  Set fuel/battery level (>100 destroys vehicle)
vehicle <vehicleID> speed <value>    Modify speed (positive/negative values)
vehicle <vehicleID> brakes           Apply emergency brakes
vehicle <vehicleID> lights on/off    Control headlights
vehicle <vehicleID> engine on/off    Start/stop engine
vehicle <vehicleID> alarm <seconds>  Trigger car alarm
```

**Drones:**
```
drone <droneID> side <west/east/guer/civ>           Change faction
drone <droneID> disable                             Destroy drone
```

**Power Grids:**
```
powergrid <gridID> on         Activate grid (turns on all lights in radius)
powergrid <gridID> off        Deactivate grid (turns off all lights)
powergrid <gridID> overload   Destroy generator with explosion
```

**GPS Tracking:**
```
gpstrack <trackerID>     Start tracking target (creates map marker)
```

**Custom Devices:**
```
custom <customID> on     Activate custom device
custom <customID> off    Deactivate custom device
```

### Power Management

All hacking operations consume laptop battery power (measured in Watt-hours, Wh). Operations will fail if insufficient power is available. Battery capacity depends on the AE3 laptop model used.

### GPS Tracker Mechanics

**Physical GPS Trackers:**
- Items can be configured as GPS trackers (default: ACE Banana)
- GIF showing ACE self-interaction menu with "Attach GPS Tracker" option**
- Attach to targets via ACE Self-Interact → Equipment → Attach GPS Tracker
- Search others for trackers via ACE Interaction menu
- Detection chance configurable (improved with spectrum devices)

**Tracking from Terminal:**
- Use `gpstrack <trackerID>` to begin tracking
- Map markers update at configured intervals
- Tracking duration limited (configurable per tracker)
- Some trackers allow retracking after duration expires

---

## For Zeus Curators

**GIF of Zeus interface showing "Root's Cyber Warfare" module category**

### Quick Setup

1. Open Zeus interface (Y key)
2. Navigate to **Modules** → **Root's Cyber Warfare**
3. Place **"Add Hacking Tools"** module on an AE3 laptop
4. Place device modules (see below) on objects you want to make hackable
5. Players can now access those devices from the laptop

### Available Zeus Modules

**Add Hacking Tools**
- Makes a laptop capable of hacking
- Configure network path and optional backdoor access
- Place on: AE3 laptops or USB sticks

**Add Hackable Object**
- Auto-detects doors/lights in buildings
- Also works on drones
- Option: Make unbreachable (ACE explosives/lockpicking disabled)
- Option: Available to all future laptops vs. specific computers

**Add Hackable Vehicle**
- Configure which systems are hackable (battery, speed, brakes, lights, engine, alarm)
- Set per-action power cost
- Place on: Any vehicle

**Add Hackable File**
- Set file name, download time (seconds), file contents
- Optional: Execute SQF code on successful download
- Place on: Any object (represents database server)

**Add GPS Tracker**
- Configure tracking duration, update frequency, marker name
- Set power cost and retracking permission
- Place on: Any object/unit/vehicle to track

**Add Custom Device**
- Define custom activation/deactivation SQF code
- Useful for mission-specific objectives (sabotage generators, trigger alarms, etc.)
- Place on: Any object

**Add Power Generator**
- Controls all lights within configurable radius
- Optional explosion on activation/deactivation
- Exclude specific light classnames
- Place on: Generator objects or buildings

**Modify Power Costs**
- Adjust power consumption for all hacking operations
- Affects all device types globally

**Copy Device Links**
- Duplicate device access from one laptop to another
- Useful for quickly setting up multiple hacking stations

### Linking Devices to Specific Laptops

By default, devices can be made:
- **Public** - Accessible to all laptops (present and future)
- **Private** - Only accessible to specific laptops you select during module placement

When placing a device module, you can select which laptops should have access. If "Available to Future Laptops" is checked, any laptop added AFTER the device is registered will also have access.

---

## For Mission Makers

**GIF of code snippet in Eden editor's init field showing programmatic device registration**

### Programmatic Setup (SQF)

All Zeus modules have corresponding functions for scripted mission setup:

**Add Hacking Tools to Laptop:**
```sqf
[_laptop, "/network/tools", 0, "HackStation", ""] call Root_fnc_addHackingToolsZeusMain;
// Parameters: [laptop, toolPath, execUserId, laptopName, linkedComputerNetIds]
```

**Register Building with Doors:**
```sqf
[_building, 0, [_laptop1, _laptop2], false, "", "", "", false]
    call Root_fnc_addDeviceZeusMain;
// Parameters: [building, execUserId, linkedComputers[], treatAsCustom, customName, activationCode, deactivationCode, availableToFuture]
```

**Register Vehicle:**
```sqf
[_vehicle, 0, [_laptop1], "TargetCar", true, false, false, true, true, false, false, 2]
    call Root_fnc_addVehicleZeusMain;
// Parameters: [vehicle, execUserId, linkedComputers[], name, allowFuel, allowSpeed, allowBrakes, allowLights, allowEngine, allowAlarm, availableToFuture, powerCost]
```

**Register GPS Tracker:**
```sqf
[_target, 0, [_laptop1], "Enemy_Leader", 120, 5, "", false, true, 30, 5, true, [[], [], []]]
    call Root_fnc_addGPSTrackerZeusMain;
// Parameters: [target, execUserId, linkedComputers[], name, trackingTime, updateFrequency, markerName, retrackAllowed, markerAllowed, trackingTimeout, lastPingDuration, allowMarkerEdit, markerData]
```

**Register Custom Device (Example: Alarm System):**
```sqf
[_alarmBox, 0, [_laptop1], "Base_Alarm",
    "playSound3D ['a3\sounds_f\sfx\alarm.wss', _this select 0, false, getPosASL (_this select 0), 5, 1, 300];",
    "hint 'Alarm deactivated';",
    false]
    call Root_fnc_addCustomDeviceZeusMain;
// Activation/deactivation code receives: _this = [_device, "activate"|"deactivate"]
```

**Register Power Generator:**
```sqf
[_generator, 0, [_laptop1], "City_PowerGrid", 2000, false, true, "HelicopterExploSmall", [], false]
    call Root_fnc_addPowerGeneratorZeusMain;
// Parameters: [object, execUserId, linkedComputers[], name, radius, allowExplosionActivate, allowExplosionDeactivate, explosionType, excludedClassnames[], availableToFuture]
```

### Eden Editor Modules

**GIF of Eden editor showing Root's Cyber Warfare modules in Systems (F5) menu**

8 modules available in Eden Editor under **Systems (F5) → Root's Cyber Warfare**:

- **Add Hacking Tools** - Synchronize to AE3 laptops/USB sticks
- **Adjust Power Cost Settings** - Global power consumption configuration
- **Add Devices** - Synchronize to buildings/drones/lights
- **Add Hackable File** - Synchronize to objects (database servers)
- **Add Hackable Vehicle** - Synchronize to vehicles
- **Add GPS Tracker** - Synchronize to tracked objects
- **Add Custom Device** - Synchronize to any object
- **Add Power Generator** - Synchronize to generator objects

Module attributes are configured via the Eden Editor attributes panel. Synchronization (F5 key) links modules to target objects.

---

## CBA Settings

**GIF of CBA settings menu showing Root Cyber Warfare category**

Configure mod behavior in Main Menu → Options → Addon Options → Root Cyber Warfare:

**Power Cost Settings:**
- Door Lock/Unlock Power Cost (default: 2 Wh)
- Drone Side Change Power Cost (default: 20 Wh)
- Drone Disable Power Cost (default: 10 Wh)
- Custom Device Power Cost (default: 10 Wh)
- Power Grid Control Power Cost (default: 10 Wh)

**GPS Tracker Settings:**
- GPS Tracker Item (classname, default: ACE_Banana)
- GPS Search Success Chance - Normal (default: 0.3)
- GPS Search Success Chance - With Tool (default: 0.8)
- GPS Spectrum Detection Devices (comma-separated classnames)
- GPS Marker Color - Active Ping (default: ColorBlue)
- GPS Marker Color - Last Ping (default: ColorRed)

---

## Mission Design Examples

### Example 1: Infiltration Mission
Players must hack into an enemy compound, unlock doors remotely to avoid detection, disable security lights, and download intel files from a server.

**Setup:**
1. Place laptop outside compound
2. Add hacking tools to laptop
3. Register compound buildings (doors + lights)
4. Register database on server object with mission-critical intel
5. Optional: Make some doors unbreachable to force hacking route

### Example 2: Vehicle Sabotage
Special forces team must disable enemy convoy by draining vehicle batteries and locking brakes remotely.

**Setup:**
1. Place laptop at overwatch position
2. Register all convoy vehicles with battery + brakes enabled
3. Set tracking duration for GPS trackers on vehicles
4. Optional: Add alarm triggering to create distractions

### Example 3: Asymmetric Warfare
Resistance fighters can hack enemy drones to turn them against their operators or disable them.

**Setup:**
1. Provide resistance laptops with hacking tools
2. Register all enemy drones as hackable
3. Make drones public (accessible to all resistance laptops)
4. Balance power costs to prevent spam

### Example 4: Blackout Operation
Hackers must overload city power grid to create diversion for main assault.

**Setup:**
1. Place power generator object in city center
2. Configure large radius (2000m+) to affect entire city
3. Enable explosion on overload
4. Link to specific laptop to prevent accidental activation

---

## Troubleshooting

**"No accessible devices found"**
- Ensure laptop has hacking tools added via Zeus/Eden/script
- Verify devices are registered and linked to your specific laptop
- Check if devices are set to "Available to Future Laptops" (excludes laptops present at registration time)

**"Insufficient Power"**
- Laptop battery depleted - recharge using AE3 power sources
- Check CBA settings for power costs (may be configured too high)
- Use `devices all` to see power costs for each operation

**Commands not working**
- Verify exact syntax (case-sensitive for some parameters)
- Check device ID numbers using `devices all` command first
- Ensure target object still exists (not destroyed)

**GPS tracker not detected**
- Check CBA settings for GPS tracker item classname
- Verify item is in target's inventory (uniform/vest/backpack)
- Detection is chance-based - try multiple times or use spectrum device

---

## Credits

**Author:** Root (xMidnightSnowx)

**Original Cyber Warfare Mod:** Mister Adrian

**License:** Arma Public License - Share Alike (APL-SA)

[img]https://i.imgur.com/jUUdDUu.png[/img]

---

## Links

- **GitHub Repository:** https://github.com/A3-Root/Root_Cyberwarfare
- **Issue Tracker:** https://github.com/A3-Root/Root_Cyberwarfare/issues
- **Discord:** https://discord.gg/77th-jsoc-official

---
