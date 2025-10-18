# Player Guide

This guide explains how to use Root's Cyber Warfare mod as a player in-game.

## Table of Contents

- [Getting Started](#getting-started)
- [Accessing the Terminal](#accessing-the-terminal)
- [Basic Terminal Commands](#basic-terminal-commands)
- [Hacking Devices](#hacking-devices)
- [Power Management](#power-management)
- [GPS Tracking](#gps-tracking)
- [Tips and Tricks](#tips-and-tricks)

## Getting Started

### Prerequisites

Before you can start hacking, you need:

1. **A Laptop with Hacking Tools** - Your mission maker or Zeus must add hacking tools to a laptop
2. **Access to the Laptop** - Physical proximity to interact with it
3. **Power** - The laptop must have battery charge (managed by AE3)

### Checking if a Laptop Has Hacking Tools

Not all laptops have hacking tools installed. To check:

1. Approach the laptop
2. Use ACE interaction menu (default: Windows key)
3. Look for "Access Terminal" option
4. If available, the laptop has hacking tools

## Accessing the Terminal

1. Approach a laptop with hacking tools installed
2. Open ACE interaction menu (default: Windows key)
3. Select "Access Terminal"
4. The AE3 ArmaOS terminal will open

## Basic Terminal Commands

### Viewing Available Devices

```
devices all
```

Lists all hackable devices accessible from your current laptop. Devices are organized by type:
- Doors (Buildings)
- Lights
- Vehicles
- Drones
- Custom Devices
- GPS Trackers
- Databases

Each device shows:
- Device ID (used for hacking)
- Device name/description
- Current status (where applicable)

For larger list, devices can be filtered by specific type
```
devices <all|doors|lights|vehicles|gps|files|custom>
```
Example: `devices gps` will show only GPS devices linked to the laptop.

### Getting Help

```
cat guide
```

Shows available cyberwarfare commands and their descriptions.

## Hacking Devices

### Buildings (Doors)

**Unlock a door:**
```
door <building_id> <door_id> unlock
```

**Lock a door:**
```
door <building_id> <door_id> lock
```

**Note**: Some doors may be marked as "UNBREACHABLE" meaning they cannot be breached with ACE explosives or lockpicks - only hacking works.

### Lights

**Turn light on:**
```
light <device_id> on
```

**Turn light off:**
```
light <device_id> off
```

**Toggle light:**
```
light <device_id> toggle
```

### Vehicles

Vehicles can have multiple hackable features depending on how they were configured:

**Control battery:**
```
vehicle <device_id> battery <value>
```
Example: `vehicle 1234 battery 50` sets fuel to 50%. Values more than 100 will cause the vehicle to explode.

**Control speed:**
```
vehicle <device_id> speed <value>
```
Example: `vehicle 1234 speed 30` **adds** 30 to vehicle's velocity

**Control brakes:**
```
vehicle <device_id> brakes <on|off>
```
Example: `vehicle 1234 brakes on` applies brakes

**Control lights:**
```
vehicle <device_id> lights <on|off>
```
Example: `vehicle 1234 lights on` turns on the lights

**Control engine:**
```
vehicle <device_id> engine <on|off>
```
Example: `vehicle 1234 engine off` turns off engine

**Trigger alarm:**
```
vehicle <device_id> alarm <value>
```
Activates the vehicle's alarm sound for the duration specified

### Drones (UAVs)

**Change drone faction:**
```
changedrone <device_id> <west|east|guer|civ>
```
Example: `changedrone 5678 east` changes drone to OPFOR faction

**Disable drone:**
```
disabledrone <device_id>
```
Permanently disables the drone (causes it to explode)

### Custom Devices

Custom devices have unique activation/deactivation commands set by the mission maker:

**Activate device:**
```
custom <device_id> activate
```

**Deactivate device:**
```
custom <device_id> deactivate
```

The actual effect depends on the script configured by the mission maker.

### Databases

**Download file:**
```
database <device_id> download
```

### Power Grids

**Turn off lights:**
```
powergrid <device_id> off
```
Example: `powergrid 5678 off` turns off all lights in the configured radius.

**Turn on lights:**
```
powergrid <device_id> on
```
Example: `powergrid 5678 off` turns on all lights in the configured radius.

**Overload Powergrid:**
```
powergrid <device_id> overload
```
Example: `powergrid 5678 overload` overloads the powergrid and turns of all lights in the configured radius.

**Note:** The overload option creates an explosion (if configured) and will prevent the grid to be useable by laptop to turn on / off again.

## Power Management

### Checking Battery Level

The terminal typically shows your current battery level. All hacking operations consume power.

### Power Costs

Different operations have different power costs (configurable by server):
- **Door operations**: ~2 Wh (default)
- **Light operations**: ~2 Wh (default)
- **Vehicle operations**: Varies (2-30 Wh depending on feature)
- **Drone faction change**: ~20 Wh (default)
- **Drone disable**: ~10 Wh (default)
- **Custom devices**: ~10 Wh (default)

### What Happens When Battery Dies

If your laptop runs out of power:
- You cannot perform any hacking operations
- You need to recharge the laptop (via AE3 power management)
- Already hacked devices remain in their current state

## GPS Tracking

### Attaching a GPS Tracker

1. Approach the target unit/vehicle
2. Use ACE interaction menu
3. Select "Attach GPS Tracker" (if available)
4. The tracker will be registered in your network

### Viewing Tracker Locations

```
devices gps
```

Shows all active GPS trackers with:
- Device ID
- Target name
- Last known position
- Last update time
- Active status

### Locating a Specific Tracker

```
gpstrack <device_id>
```

Shows detailed position information for a specific tracker.

### Managing Trackers

GPS trackers update automatically at configured intervals. If a tracked unit is destroyed, the tracker will stop updating.

## Tips and Tricks

### Efficient Power Usage

- Plan your hacking operations to minimize power consumption
- Prioritize critical targets
- Check battery level before starting complex operations

### Device ID Management

- Write down important device IDs for quick access
- Use the `devices` command to refresh the device list
- Device IDs are unique 4-digit numbers (1000-9999)

### Access Control

- Some devices may not be visible in your device list if they're not linked to your laptop
- Ask your Zeus/mission maker if you're missing expected devices
- "Public" devices are available to all laptops
- "Private" devices are linked to specific laptops only

### Coordination with Team

- Share device IDs with teammates using the same network
- Coordinate vehicle hacks to disable enemy transport
- Use GPS trackers on high-value targets

### Troubleshooting

**"Device not found" error:**
- Check the device ID is correct
- Ensure the device is still accessible
- The device may have been destroyed

**"Insufficient power" error:**
- Your laptop battery is too low
- Recharge the laptop via AE3 power management

**"Access denied" error:**
- Your laptop doesn't have permission to access this device
- Contact your Zeus/mission maker for access

**Command not working:**
- Check command syntax (use `help` command)
- Ensure all parameters are correct
- Some features may be disabled on specific devices

## Advanced Usage

### Backdoor Access

Some laptops may have "backdoor" access configured, allowing them to bypass normal access controls and access all devices on the network. This is typically used for admin/debug purposes.

### Network Subnets

Devices are organized into network subnets. Your laptop is assigned to a specific subnet and can only access devices in the same subnet (unless backdoor access is enabled).

### Future Laptop Access

Some devices may be configured as "Available to Future Laptops," meaning they become accessible to new laptops added after the device registration, but not to existing laptops (unless explicitly linked).

---

For more information, see:
- [Terminal Commands](Terminal-Commands) - Complete command reference
- [Zeus Guide](Zeus-Guide) - How devices are set up
- [Configuration Guide](Configuration) - Server settings and customization
