# Eden Editor Guide

This guide covers setting up hackable devices in the Eden Editor for pre-mission configuration.

## Table of Contents

- [Overview](#overview)
- [Eden Modules](#eden-modules)
- [Setting Up Devices](#setting-up-devices)
- [Best Practices](#best-practices)

## Overview

Eden Editor modules allow you to configure hackable devices before the mission starts, unlike Zeus modules which are used during runtime.

### Advantages of Eden Setup

- **Pre-planned**: Configure everything before mission starts
- **Saved in mission**: Configuration persists in the mission file
- **Consistent**: Same setup every time the mission loads
- **Performance**: No runtime module placement overhead

## Eden Modules

Root's Cyber Warfare provides Eden Editor modules found in:
**Modules → Root Cyber Warfare**

Available modules:
- Add Hacking Tools (Laptop)
- Add Hackable Building/Light
- Add Hackable Vehicle
- Add Custom Device
- Add Power Generator

## Setting Up Devices

### Step 1: Place a Laptop

1. Place a laptop object in the editor (any laptop-class object)
2. Give it a variable name (e.g., `laptop1`)

### Step 2: Add Hacking Tools Module

1. Place "Add Hacking Tools" module
2. Sync the module to the laptop object (F5 key)
3. Configure module attributes:
   - **Subnet Path**: Network organization (default: "/network/default")
   - **User ID**: Leave as 0
   - **Laptop Name**: Display name
   - **Linked Computers**: Leave empty for single laptop

### Step 3: Add Hackable Devices

#### Buildings

1. Place building object
2. Give it a variable name (e.g., `building1`)
3. Place "Add Hackable Building/Light" module
4. Sync module to building
5. Configure:
   - **Available to Future Laptops**: Usually false for Eden setups
   - **Make Unbreachable**: True for high-security facilities
   - Laptop linking happens via sync lines

#### Vehicles

1. Place vehicle
2. Give it a variable name (e.g., `car1`)
3. Place "Add Hackable Vehicle" module
4. Sync module to vehicle
5. Configure vehicle features (fuel, speed, brakes, engine, etc.)

#### Custom Devices

1. Place any object (generator, computer, etc.)
2. Give it a variable name
3. Place "Add Custom Device" module
4. Sync module to object
5. Configure activation/deactivation code

### Linking Devices to Laptops

**Method 1: Sync Lines (Recommended)**
1. Place device module
2. Use F5 (sync mode)
3. Draw sync line from module to laptop
4. Device will be linked to that laptop only

**Method 2: Public Access**
1. Don't sync to any laptop
2. Set "Available to Future Laptops" = false
3. Device will be accessible to ALL laptops

## Best Practices

### Organization

- **Use Variable Names**: Name all objects logically (laptop1, enemyBase1, generator1)
- **Group Modules**: Keep modules near their target objects
- **Color Code**: Use Eden markers/colors to identify cyber warfare objectives
- **Comments**: Add comments to explain complex setups

### Performance

- **Limit Devices**: Don't over-register devices, only what players need
- **Strategic Placement**: Place laptops in mission-relevant locations
- **Power Consideration**: Don't make everything hackable, preserve challenge

### Mission Design

**Stealth Missions:**
- Limited laptop access
- Unbreachable doors
- High power costs
- GPS tracker objectives

**Assault Missions:**
- Multiple laptops
- Vehicle hacking emphasis
- Power generators as objectives

**Intel Gathering:**
- Database downloads
- GPS tracking assignments
- Custom device interactions

### Example Mission Setup

```
Laptop Setup:
1. laptop1 (BLUFOR HQ) - Variable name "bluforHQ"
   - Add Hacking Tools module
   - Name: "HQ Command Terminal"
   - Subnet: "/blufor/hq"

Enemy Base:
2. enemyBuilding1 - Variable name "enemyHQ"
   - Add Hackable Building module
   - Sync to laptop1
   - Make Unbreachable: YES

3. enemyVehicle1 - Variable name "enemyTransport"
   - Add Hackable Vehicle module
   - Sync to laptop1
   - Enable: Fuel, Engine, Brakes
   - Power Cost: 10 Wh

4. enemyGenerator - Variable name "powerStation"
   - Add Power Generator module
   - Sync to laptop1
   - Radius: 300m
   - Allow Explosion Deactivate: YES
```

### Testing in Eden

1. **Preview Mission**: Use Eden preview to test setup
2. **Check Access**: Verify laptops have hacking tools
3. **Test Commands**: Use terminal to test device access
4. **Verify Power**: Check power costs are reasonable
5. **Debug**: Use RPT log to check for errors

---

For more information, see:
- [Zeus Guide](Zeus-Guide) - Runtime setup
- [Mission Maker Guide](Mission-Maker-Guide) - Scripted setup
- [Player Guide](Player-Guide) - How players use devices
