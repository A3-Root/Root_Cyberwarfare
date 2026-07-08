# Root's Cyber Warfare - Wiki

Welcome to the official documentation for **Root's Cyber Warfare**, an advanced hacking mod for Arma 3 that enables players to control doors, lights, vehicles, drones, and more through laptop terminals.

## What is Root's Cyber Warfare?

Root's Cyber Warfare introduces a comprehensive cyber warfare system to Arma 3, allowing players to hack and control 8 different device types using terminal commands or the graphical **Hackerman Desktop** app suite. Built on top of AE3 ArmaOS, the mod provides a realistic hacking experience with power management, access control, network reconnaissance, classical-cipher encryption/decryption, and flexible deployment options for mission makers.

This is an improved adaptation and expansion of the original Cyber Warfare mod created by Mister Adrian.

## Device Types

The mod supports the following hackable devices:

| Device Type | Description | Terminal Command |
|-------------|-------------|------------------|
| **Doors** | Building doors - lock/unlock remotely | `door` |
| **Lights** | Building and street lights - on/off control | `light` |
| **Drones** | UAVs - change faction or disable | `changedrone`, `disabledrone` |
| **Vehicles** | Cars, tanks, aircraft - manipulate fuel, speed, brakes, lights, engine, alarms | `vehicle` |
| **Databases** | Downloadable files with optional code execution | `download` |
| **Custom Devices** | User-defined devices with SQF scripting | `custom` |
| **GPS Trackers** | Real-time position tracking with map markers | `gpstrack` |
| **Power Grids** | Generator-controlled lights in radius | `powergrid` |

Beyond controlling devices, hacking-tools-equipped laptops also gain:

| Feature | Description | Terminal Command |
|---------|-------------|------------------|
| **Network Scanner** | List subnet hosts, SSH exposure, and hackable device counts | `netscan` |
| **Cipher Tools** | Encrypt/decrypt/bruteforce text or files with 13 classical ciphers | `crypto`, `crack` |

All of the above (device control, network scanning, and cipher tools) are also available as graphical apps in the **Hackerman Desktop** - a launcher (`Hackerman.exe`) that appears on a laptop's desktop while hacking tools are available, giving point-and-click access alongside the text terminal.

## Documentation by User Type

### For Players

**[Player Guide](Player-Guide)** - Learn how to use the terminal and control devices

Topics covered:
- Accessing the terminal via ACE interaction menu, or the Hackerman Desktop GUI
- Complete terminal command reference (device commands, `netscan`, `crypto`, `crack`)
- Power management and battery consumption
- GPS tracker mechanics (attach, search, disable)
- Tips for bulk operations and confirmation prompts

### For Zeus Curators

**[Zeus Guide](Zeus-Guide)** - Use Zeus modules to set up cyber warfare scenarios

Topics covered:
- All Zeus modules with detailed parameters
- Adding hacking tools to laptops, registering laptops as hackable stations
- Registering hackable doors, lights, vehicles, files, trackers, custom devices
- Cipher Tools module and Clear Broken Device Links maintenance module
- Access control (public vs private devices)
- Common workflows and troubleshooting

### For Mission Makers

**[Mission Maker Guide](Mission-Maker-Guide)** - Programmatically create cyber warfare scenarios

Topics covered:
- Device registration functions for all 8 device types
- Access control patterns (linking, public access, backdoors)
- Practical examples (complete mission scripts)
- initServer.sqf templates
- Dynamic device registration during gameplay

**[Eden Editor Guide](Eden-Editor-Guide)** - Use 3DEN modules for visual mission editing

Topics covered:
- All 8 3DEN editor modules with attributes
- Module synchronization (laptops, devices, public access)
- Best practices for mission design
- Example mission setup walkthrough

**[API Reference](API-Reference)** - Complete function reference for scripters

Topics covered:
- All public functions with signatures and examples
- Data structures (device entries, caches, arrays)
- Constants and macros
- Return values and error handling

### Technical Documentation

**[Architecture](Architecture)** - Technical implementation details

Topics covered:
- Data storage architecture (3-tier hybrid system)
- Access control system (3-tier priority)
- Initialization flow (PreInit, PostInit)
- Power system mechanics (Wh/kWh conversion)
- Function patterns and network architecture

**[Configuration](Configuration)** - CBA settings reference

Topics covered:
- All 15 CBA settings with defaults
- Power cost settings (5 settings)
- GPS settings (5 settings)
- Cleanup settings (3 settings)
- Rubberducky settings (2 settings)
- Configuration best practices
- Mission parameter overrides

## Quick Reference Card

### Common Terminal Commands

```bash
# List all accessible devices
devices all

# List specific device types
devices doors
devices lights
devices vehicles
devices gps

# Lock/unlock doors
door 1234 2881 lock        # Lock specific door
door 1234 a unlock         # Unlock all doors in building

# Control lights
light 5678 off             # Turn off specific light
light a on                 # Turn on all accessible lights

# Control vehicles
vehicle 1337 battery 50    # Set fuel to 50%
vehicle 1337 engine 0      # Stop engine
vehicle 1337 lights 0      # Disable lights

# Track GPS targets
gpstrack 9999             # Track GPS device 9999

# Download files
download 4567             # Download file ID 4567

# Control drones
changedrone 2 east        # Change drone to OPFOR
disabledrone 2            # Disable (explode) drone

# Custom devices
custom 5 activate         # Activate custom device

# Power grids
powergrid 1234 on         # Turn on lights in radius
powergrid 1234 overload   # Destroy generator and lights

# Scan the network
netscan                   # List subnet hosts and hackable device counts
netscan -o /root/scan.txt # Export results to a file

# Cipher tools
crypto -m=encrypt -a=vigenere -k=LEMON "attack at dawn"
crack -a=all "some ciphertext to identify"
```

### Power Costs (Default Values)

| Operation | Default Cost (Wh) | Configurable |
|-----------|-------------------|--------------|
| Door lock/unlock | 2 | Yes (CBA) |
| Drone disable | 10 | Yes (CBA) |
| Drone faction change | 20 | Yes (CBA) |
| Custom device | 10 | Yes (CBA) |
| Power grid control | 15 | Yes (CBA) |
| Vehicle action | 2 | Per vehicle |
| GPS tracking | 2-10 | Per tracker |

## Getting Help

- **Questions?** Check the relevant guide pages above
- **Found a bug?** Report it on [GitHub Issues](https://github.com/A3-Root/Root_Cyberwarfare/issues)
- **Feature request?** Open an issue with the `enhancement` label
- **Need support?** Join our [Discord](https://discord.gg/77th-jsoc-official)

## Version Information

- **Current Version**: Check [Releases](https://github.com/A3-Root/Root_Cyberwarfare/releases)
- **License**: Arma Public License - Share Alike (APL-SA)
- **Repository**: [GitHub](https://github.com/A3-Root/Root_Cyberwarfare)

## Credits

- **Root** (xMidnightSnowx) - Development and maintenance
- **Mister Adrian** - Original Cyber Warfare mod creator
- **77th JSOC** - Bug reports, feature suggestions, and testing

---

**Ready to start?** Jump to the **[Player Guide](Player-Guide)** to learn the basics, or explore the **[Zeus Guide](Zeus-Guide)** if you're setting up missions!
