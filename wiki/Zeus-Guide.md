# Zeus Guide

This guide explains how to set up and manage hackable devices as a Zeus (Game Master) in real-time during a mission.

## Table of Contents

- [Getting Started](#getting-started)
- [Adding Hacking Tools](#adding-hacking-tools)
- [Registering Devices](#registering-devices)
- [Access Control](#access-control)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Prerequisites

1. Zeus Enhanced (ZEN) mod installed and loaded
2. Root's Cyber Warfare mod installed and loaded
3. Zeus privileges in the mission
4. All required dependencies (CBA, ACE3, AE3, ZEN)

### Accessing Cyber Warfare Modules

1. Open Zeus interface (default: Y key)
2. Navigate to the modules section
3. Look for "Root Cyber Warfare" category
4. Available modules will be listed

## Adding Hacking Tools

Before players can hack anything, you need to give them a laptop with hacking tools.

### Steps to Add Hacking Tools

1. Open Zeus interface
2. Find or place a laptop object (any laptop-type object)
3. Select "Modules" → "Root Cyber Warfare" → "Add Hacking Tools"
4. Place the module on the laptop
5. Configure the dialog:
   - **Subnet Path**: Network subnet for organization (e.g., "/network/subnet1")
   - **User ID**: Execution user ID (usually leave as 0)
   - **Laptop Name**: Display name for the laptop (e.g., "MainHackingStation")
   - **Linked Computers**: NetIDs of other computers to link (advanced, usually leave empty)

The laptop will now have hacking tools installed and players can access it via ACE interaction.

## Registering Devices

### Buildings (Doors/Lights)

**Module**: "Add Hackable Building/Light"

1. Place module on a building or streetlamp
2. Configure dialog:
   - **Available to Future Laptops**: Make device accessible to laptops added later
   - **Make Unbreachable** (buildings only): Prevent ACE breaching/lockpicking
   - **Computer Checkboxes**: Select which specific laptops can access this device

**What happens:**
- Buildings: All doors in the building become hackable
- Lights: The lamp becomes controllable (on/off/toggle)

**Notes:**
- Buildings must have animated doors in their config
- Only works with objects of class "House", "Building", or "Lamps_base_F"

### Vehicles

**Module**: "Add Hackable Vehicle"

1. Place module on a vehicle (car, truck, boat, etc.)
2. Configure dialog:
   - **Vehicle Name**: Display name in terminal
   - **Power Cost**: Energy required per hacking action (1-30 Wh)
   - **Allow Battery (Fuel) Control**: Enable fuel/battery hacking
   - **Allow Speed Control**: Enable speed limitation hacking
   - **Allow Brakes Control**: Enable brake hacking
   - **Allow Lights Control**: Enable light control (empty vehicles only)
   - **Allow Engine Control**: Enable engine on/off hacking
   - **Allow Car Alarm**: Enable alarm trigger
   - **Available to Future Laptops**: Make accessible to future laptops
   - **Computer Checkboxes**: Select which laptops can access this vehicle

**Recommended Configurations:**

*Enemy Transport:*
- Enable: Fuel, Speed, Brakes, Engine
- Power Cost: 5-10 Wh

*Civilian Vehicle:*
- Enable: Lights, Engine, Alarm
- Power Cost: 2-5 Wh

*High-Value Target:*
- Enable: All features
- Power Cost: 15-30 Wh

### Drones (UAVs)

**Module**: "Add Hackable Vehicle" (same module, auto-detects drones)

1. Place module on a drone/UAV
2. Dialog will be simplified for drones:
   - **Available to Future Laptops**: Make accessible to future laptops
   - **Computer Checkboxes**: Select which laptops can access this drone

**Drone Capabilities:**
- Change faction (BLUFOR/OPFOR/INDEPENDENT/CIVILIAN)
- Permanently disable the drone

**Notes:**
- Automatically detected via `unitIsUAV` check
- No vehicle-specific options for drones

### Custom Devices

**Module**: "Add Custom Device"

1. Place module on any object
2. Configure dialog:
   - **Custom Device Name**: Display name in terminal
   - **Activation Code**: SQF code to run when activated
   - **Deactivation Code**: SQF code to run when deactivated
   - **Available to Future Laptops**: Make accessible to future laptops
   - **Computer Checkboxes**: Select which laptops can access this device

**Code Environment:**
- Runs in SCHEDULED environment (spawn)
- Code executes on the player who triggered the action
- Default parameters: `_this = [_computer, _customObject, _playerNetID]`
  - `_computer`: The hacking laptop object
  - `_customObject`: The custom device object
  - `_playerNetID`: Network ID of the player

**Example Activation Codes:**

*Simple Hint:*
```sqf
hint "Generator Activated!";
```

*Set Variable and Global Effect:*
```sqf
params ["_computer", "_generator", "_player"];
_generator setVariable ["isActive", true, true];
hint format ["Generator activated by %1", name _player];
```

*Trigger Explosion:*
```sqf
params ["_computer", "_bomb", "_player"];
"Bo_Mk82" createVehicle (getPos _bomb);
deleteVehicle _bomb;
```

*Enable Power Grid (Custom):*
```sqf
params ["_computer", "_powerStation", "_player"];
private _radius = 200;
private _lights = nearestObjects [_powerStation, ["Lamps_base_F"], _radius];
{_x switchLight "ON"} forEach _lights;
```

### Power Generators

**Module**: "Add Power Generator"

1. Place module on an object (usually a generator or power station)
2. Configure dialog:
   - **Generator Name**: Display name
   - **Radius**: Area of effect for controlling lights (meters)
   - **Allow Explosion to Activate**: Can be activated by explosions
   - **Allow Explosion to Deactivate**: Can be deactivated by explosions
   - **Explosion Type**: Type of explosion to create (e.g., "HelicopterExploSmall")
   - **Excluded Classnames**: Light classnames to exclude from control
   - **Available to Future Laptops**: Make accessible to future laptops
   - **Computer Checkboxes**: Select which laptops can access this generator

**Use Cases:**
- Control power grid in a town
- Create mission objectives (restore power)
- Add environmental effects (explosions damage power infrastructure)

### GPS Trackers

GPS trackers are added via ACE interactions, not Zeus modules. However, Zeus can:

1. Ensure players have laptops with hacking tools
2. Configure GPS tracker update intervals in CBA settings
3. Monitor tracker activity during the mission

**Player Usage:**
- Players use ACE interaction on target → "Attach GPS Tracker"
- Trackers appear in terminal via `gps list` command

## Access Control

### Understanding Access Modes

#### Scenario 1: All Current Laptops Only
- **Available to Future Laptops**: ☐ Unchecked
- **Selected Computers**: None
- **Result**: All existing laptops get access, future laptops do not

#### Scenario 2: Selected Laptops Only
- **Available to Future Laptops**: ☐ Unchecked
- **Selected Computers**: Computer 1, Computer 2
- **Result**: Only Computer 1 and Computer 2 get access

#### Scenario 3: Future Laptops Only
- **Available to Future Laptops**: ☑ Checked
- **Selected Computers**: None
- **Result**: All current laptops excluded, only future laptops get access

#### Scenario 4: Selected + Future Laptops
- **Available to Future Laptops**: ☑ Checked
- **Selected Computers**: Computer 1
- **Result**: Computer 1 gets access now, all future laptops get access, other current laptops excluded

### Best Practices

**For Open Missions:**
- Use Scenario 1 (all current laptops) or Scenario 3 (future laptops only)
- Ensures all players can participate

**For Restricted Access:**
- Use Scenario 2 (selected laptops only)
- Good for stealth missions, special ops

**For Progressive Missions:**
- Use Scenario 3 (future laptops only)
- Add laptops as players progress/unlock areas

**For Mixed Access:**
- Use Scenario 4 (selected + future)
- Give certain teams immediate access, others get it later

## Advanced Features

### Unbreachable Doors

When adding a building with the "Make Unbreachable" option:
- Doors CANNOT be breached with ACE explosives
- Doors CANNOT be lockpicked with ACE lockpicks
- Doors can ONLY be opened via hacking
- Forces players to use cyber warfare instead of kinetic methods

**Use Cases:**
- High-security facilities
- Mission-critical objectives
- Forcing stealth gameplay

### Backdoor Access

You can manually give a laptop backdoor access via debug console:

```sqf
_laptop setVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", "/admin/root", true];
```

**Effects:**
- Bypasses ALL access control checks
- Can access ANY device on the network
- Useful for admin/debugging
- Not recommended for normal gameplay

### Manual Device Linking

You can manually link devices to laptops via debug console:

```sqf
private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
private _computerNetId = netId _laptop;
private _existingLinks = _linkCache getOrDefault [_computerNetId, []];
_existingLinks pushBack [1, 1234]; // [deviceType, deviceId]
// Device types: 1=door, 2=light, 3=drone, 4=database, 5=custom, 6=gps, 7=vehicle
_linkCache set [_computerNetId, _existingLinks];
missionNamespace setVariable ["ROOT_CYBERWARFARE_LINK_CACHE", _linkCache, true];
```

### Public Device Management

View all public devices via debug console:

```sqf
hint str (missionNamespace getVariable ["ROOT_CYBERWARFARE_PUBLIC_DEVICES", []]);
// Format: [[deviceType, deviceId, [excludedComputerNetIds]], ...]
```

## Troubleshooting

### Module Not Appearing

**Problem**: Cyber Warfare modules don't show up in Zeus interface

**Solutions:**
- Verify Root's Cyber Warfare mod is loaded
- Check ZEN (Zeus Enhanced) is loaded
- Restart mission
- Check RPT log for errors

### Player Can't See Device

**Problem**: Device is registered but doesn't appear in player's terminal

**Solutions:**
- Check access control settings
- Verify laptop has hacking tools (ACE interaction → "Access Terminal" exists)
- Ensure device wasn't destroyed
- Check if device is in excluded computer list (future laptops setting)
- Try re-registering the device

### Device Not Working

**Problem**: Player can see device but commands don't work

**Solutions:**
- Check player has enough power/battery
- Verify device object still exists (not destroyed)
- Check command syntax in terminal
- For vehicles: Some features only work on empty/non-AI controlled vehicles
- For doors: Check building has animated doors

### Power Issues

**Problem**: Players immediately run out of power

**Solutions:**
- Check CBA settings for power costs (may be too high)
- Ensure AE3 power system is working
- Give players access to power sources/generators
- Adjust power costs in CBA settings

### Custom Device Not Executing Code

**Problem**: Custom device activation/deactivation does nothing

**Solutions:**
- Check SQF code syntax in the activation/deactivation fields
- Test code in debug console first
- Check RPT log for script errors
- Verify code has proper `params` handling
- Ensure code doesn't have syntax errors (missing semicolons, brackets, etc.)

### Unbreachable Flag Not Working

**Problem**: Doors can still be breached despite unbreachable flag

**Solutions:**
- This feature prevents ACE breaching, not vanilla Arma door opening
- Check ACE is loaded and configured
- Verify flag was set correctly (check building variable)
- Some buildings may not be compatible

## Quick Reference

### Module Summary

| Module | Use For | Key Settings |
|--------|---------|--------------|
| Add Hacking Tools | Give players hacking capability | Laptop name, subnet |
| Add Hackable Building/Light | Buildings with doors, streetlamps | Future access, unbreachable |
| Add Hackable Vehicle | Vehicles (cars, trucks, boats) or Drones | Features, power cost, future access |
| Add Custom Device | Any scripted device | Name, activation code, deactivation code |
| Add Power Generator | Power grids, environmental control | Radius, explosion triggers |

### Device Type Codes

For manual scripting/debugging:

- `1` = Door (Building)
- `2` = Light
- `3` = Drone
- `4` = Database
- `5` = Custom
- `6` = GPS Tracker
- `7` = Vehicle

---

For more information, see:
- [Mission Maker Guide](Mission-Maker-Guide.md) - Scripted setup
- [Player Guide](Player-Guide.md) - How players use devices
- [API Reference](API-Reference.md) - Function reference
