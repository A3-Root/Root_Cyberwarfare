A comprehensive cyber warfare and hacking system for Arma 3 that allows players to hack and control various devices using in-game laptops and terminals.

Found under tabs "Root's Cyber Warfare" in the "Modules" section.

Project is now open sourced with APL-SA Licence! Check out the [url=https://github.com/A3-Root/Root_Cyberwarfare]GitHub page here![/url]

[b]Current version - 1.0.0.0[/b]

[b]REQUIRED ADDITIONAL ADDONS/DEPENDENCIES:[/b]
[list] [*] [url=https://steamcommunity.com/workshop/filedetails/?id=450814997]CBA A3[/url]
[*] [url=https://steamcommunity.com/workshop/filedetails/?id=463939057]ACE3[/url]
[*] [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2909066065]Advanced Equipment (AE3)[/url]
[*] [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1779063631]Zeus Enhanced (ZEN)[/url]
[/list]

Signed and tested for dedicated servers.

[b] Requires EVERYONE (Client, Server, and all connected Machines/Players) to have this addon installed and loaded. [/b]

Useful for Modern Warfare, Cyber Ops, Special Operations, Intelligence, Espionage, Stealth, Reconnaissance, or any other themed Missions requiring electronic warfare and device control.

[hr] [/hr]

[h1][b]++++ OVERVIEW ++++[/b][/h1]

Root's Cyber Warfare transforms Arma 3 into a cyber operations playground. Players can use laptops equipped with hacking tools to remotely control doors, lights, vehicles, drones, and more through an immersive terminal interface. Mission makers have full control over what devices are hackable and who has access to them.

[b]Key Features:[/b]
[list]
[*] Terminal-based hacking system using ArmaOS
[*] Power management system - all operations consume laptop battery
[*] Flexible access control - link devices to specific computers or make them public
[*] Zeus and Eden Editor modules for easy mission creation
[*] 7 different device types with unique capabilities
[*] Programmatic API for advanced mission scripting
[/list]

[hr] [/hr]

[h1][b]++++ HACKABLE DEVICES ++++[/b][/h1]

All devices can be registered via Zeus modules during gameplay or through Eden Editor for pre-configured missions. Each device can be linked to specific laptops or made available to all/future laptops.

[h2] [b]Door Control[/b] [/h2]
[list]
[*] Lock/unlock building doors remotely
[*] Automatically detects all doors in a building
[*] Individual door control or mass lock/unlock
[*] Perfect for base security and infiltration missions
[/list]

[b]Example Terminal Commands:[/b]
[code]
devices                    # List all accessible devices
door -list 1234           # List all doors in building device #1234
door -lock 1234 0         # Lock door #0 in building #1234
door -unlock 1234 all     # Unlock all doors in building #1234
[/code]

[h2] [b]Light Control[/b] [/h2]
[list]
[*] Turn building lights on/off remotely
[*] Automatically detects all lights in a building
[*] Individual light control or mass on/off
[*] Create blackouts or light-based distractions
[/list]

[b]Example Terminal Commands:[/b]
[code]
light -list 1234          # List all lights in building #1234
light -on 1234 0          # Turn on light #0 in building #1234
light -off 1234 all       # Turn off all lights in building #1234
[/code]

[h2] [b]Vehicle Control[/b] [/h2]
[list]
[*] Drain fuel remotely
[*] Reduce maximum speed
[*] Disable brakes
[*] Control lights (on/off/toggle)
[*] Disable engine
[*] Trigger alarm system
[*] Configurable power cost per operation
[/list]

[b]Example Terminal Commands:[/b]
[code]
vehicle -fuel 1234        # Drain all fuel from vehicle #1234
vehicle -speed 1234       # Reduce vehicle speed to 0
vehicle -brakes 1234      # Disable vehicle brakes
vehicle -lights 1234      # Toggle vehicle lights
vehicle -engine 1234      # Disable vehicle engine
vehicle -alarm 1234       # Trigger vehicle alarm
[/code]

[h2] [b]Drone Control[/b] [/h2]
[list]
[*] Change drone faction (make it friendly/hostile)
[*] Disable drone completely
[*] Useful for turning enemy drones against them
[*] Works with all UAV types
[/list]

[b]Example Terminal Commands:[/b]
[code]
drone -faction 1234 west  # Change drone to BLUFOR
drone -faction 1234 east  # Change drone to OPFOR
drone -disable 1234       # Disable drone completely
[/code]

[h2] [b]Database Access[/b] [/h2]
[list]
[*] Download files from hackable databases
[*] Configurable file names, sizes, and content
[*] Files are saved to the laptop's filesystem
[*] Perfect for intelligence gathering missions
[/list]

[b]Example Terminal Commands:[/b]
[code]
database -download 1234   # Download file from database #1234
[/code]

[h2] [b]GPS Tracking[/b] [/h2]
[list]
[*] Attach GPS trackers to units or vehicles
[*] Real-time position updates
[*] Configurable update intervals
[*] ACE interaction menu for physical tracker attachment
[*] Search and locate tracked targets
[/list]

[b]Example Terminal Commands:[/b]
[code]
gps -list                 # List all GPS trackers
gps -search 1234          # Get current position of tracker #1234
gps -ping 1234            # Force position update
[/code]

[b]Physical Tracker Attachment:[/b]
[list]
[*] Use ACE interaction menu on target
[*] Select "Attach GPS Tracker"
[*] Tracker appears in terminal device list
[*] Can be removed via interaction menu
[/list]

[h2] [b]Custom Devices[/b] [/h2]
[list]
[*] Create custom hackable devices with scripted behavior
[*] Define activation and deactivation code
[*] Full access to Arma 3 scripting commands
[*] Unlimited possibilities for mission design
[/list]

[b]Example Use Cases:[/b]
[list]
[*] Hackable generators that control power grids
[*] Explosive devices that can be remotely detonated
[*] Security systems with custom effects
[*] Interactive mission objectives
[/list]

[hr] [/hr]

[h1][b]++++ POWER MANAGEMENT ++++[/b][/h1]

Every hacking operation consumes power from the laptop's battery. Power is managed through the AE3 (Advanced Equipment) system.

[b]Power System Features:[/b]
[list]
[*] All operations have configurable power costs (in Watt-hours)
[*] Vehicle operations can have custom power costs (default: 2 Wh)
[*] Operations fail if insufficient power available
[*] Recharge laptops using AE3 power management
[*] CBA settings to adjust global power costs
[/list]

[hr] [/hr]

[h1][b]++++ ACCESS CONTROL ++++[/b][/h1]

The mod uses a sophisticated 3-tier access control system:

[h2] [b]1. Backdoor Access (Admin)[/b] [/h2]
[list]
[*] Bypasses all access checks
[*] Configured via "Backdoor Path" in Zeus module
[*] Perfect for admin/debug access
[/list]

[h2] [b]2. Public Device Access[/b] [/h2]
[list]
[*] Devices marked "Available to Future Laptops"
[*] Accessible to all laptops added AFTER device registration
[*] Laptops existing at registration time are excluded (unless explicitly linked)
[/list]

[h2] [b]3. Private Link Access[/b] [/h2]
[list]
[*] Direct computer-to-device relationships
[*] Configured via "Linked Computers" in Zeus modules
[*] Most restrictive access level
[/list]

[hr] [/hr]

[h1][b]++++ MISSION MAKER GUIDE ++++[/b][/h1]

[h2] [b]Zeus Modules (Runtime)[/b] [/h2]

All modules found under "Root's Cyber Warfare" → "Modules - Root's Cyber Warfare"

[b]1. Add Hacking Tools to Laptop[/b]
[list]
[*] Makes a laptop hackable
[*] Configure laptop name, backdoor access, and linked computers
[*] Required before accessing terminal
[/list]

[b]2. Add Hackable Device[/b]
[list]
[*] Register buildings with doors/lights
[*] Can also be used for custom devices
[*] Auto-detects all doors and lights in building
[/list]

[b]3. Add Hackable Vehicle[/b]
[list]
[*] Register vehicles for remote control
[*] Choose which operations are available (fuel, speed, brakes, lights, engine, alarm)
[*] Configure power cost per operation
[/list]

[b]4. Add Hackable Drone[/b]
[list]
[*] Register drones/UAVs for faction change or disable
[*] Works with all UAV types
[/list]

[b]5. Add Hackable Database[/b]
[list]
[*] Create downloadable databases
[*] Configure file name, size, and content
[/list]

[b]6. Add Power Generator[/b]
[list]
[*] Create generators that control lights in radius
[*] Configure explosion activation/deactivation
[*] Exclude specific building types
[/list]

[h2] [b]Eden Editor Modules[/b] [/h2]

All modules found under "Root's Cyber Warfare" in the Modules section.

[list]
[*] Pre-configure devices before mission starts
[*] Synchronized objects automatically linked
[*] Useful for complex pre-configured scenarios
[/list]

[h2] [b]Programmatic API[/b] [/h2]

Advanced mission makers can register devices via scripting:

[code]
// Add hacking tools to laptop
[_laptop, "/network/subnet1", 0, "MainHackingStation", ""]
    call Root_fnc_addHackingToolsZeusMain;

// Register building with doors
[_building, 0, [], false, "", "", "", false]
    call Root_fnc_addDeviceZeusMain;

// Register vehicle
[_vehicle, 0, [_laptop1, _laptop2], "Car1", true, false, false, false, true, false, false, 2]
    call Root_fnc_addVehicleZeusMain;

// Register custom device
[_generator, 0, [], true, "Generator",
    "hint 'Activated'",
    "hint 'Deactivated'",
    false] call Root_fnc_addDeviceZeusMain;

// Register power generator
[_generator, 0, [], "Power Grid", 2000, false, true, "HelicopterExploSmall", [], false]
    call Root_fnc_addPowerGeneratorZeusMain;
[/code]

[hr] [/hr]

[h1][b]++++ TERMINAL COMMANDS ++++[/b][/h1]

Access the terminal via ACE Interaction Menu → "Access Terminal" on a laptop with hacking tools.

[b]Core Commands:[/b]
[code]
devices                   # List all accessible devices
help                      # Show available commands
[/code]

[b]Device Control Commands:[/b]
[code]
door -list <deviceId>     # List doors in building
door -lock <deviceId> <doorId|all>    # Lock door(s)
door -unlock <deviceId> <doorId|all>  # Unlock door(s)

light -list <deviceId>    # List lights in building
light -on <deviceId> <lightId|all>    # Turn on light(s)
light -off <deviceId> <lightId|all>   # Turn off light(s)

vehicle -fuel <deviceId>     # Drain fuel
vehicle -speed <deviceId>    # Reduce speed
vehicle -brakes <deviceId>   # Disable brakes
vehicle -lights <deviceId>   # Toggle lights
vehicle -engine <deviceId>   # Disable engine
vehicle -alarm <deviceId>    # Trigger alarm

drone -faction <deviceId> <west|east|independent>  # Change faction
drone -disable <deviceId>    # Disable drone

database -download <deviceId>  # Download file

gps -list                 # List GPS trackers
gps -search <deviceId>    # Get tracker position
gps -ping <deviceId>      # Force position update
[/code]

[hr] [/hr]

[h1][b]++++ EXAMPLE SCENARIOS ++++[/b][/h1]

[h2] [b]Scenario 1: Base Infiltration[/b] [/h2]
[list]
[*] Mission maker places enemy base with multiple buildings
[*] Zeus registers all buildings as hackable devices
[*] Player receives laptop with access to base security system
[*] Player remotely unlocks doors and disables lights for stealth entry
[*] Player can lock doors behind them to slow pursuers
[/list]

[h2] [b]Scenario 2: Vehicle Sabotage[/b] [/h2]
[list]
[*] Enemy convoy approaching checkpoint
[*] Player has laptop with access to lead vehicle
[*] Player drains fuel from lead vehicle
[*] Player disables brakes on second vehicle
[*] Convoy disabled without firing a shot
[/list]

[h2] [b]Scenario 3: Drone Takeover[/b] [/h2]
[list]
[*] Enemy UAV patrolling area
[*] Player hacks drone and changes faction to friendly
[*] Drone now provides friendly reconnaissance
[*] Can be disabled if no longer needed
[/list]

[h2] [b]Scenario 4: Intelligence Gathering[/b] [/h2]
[list]
[*] Mission requires gathering intel from enemy computers
[*] Player infiltrates enemy base
[*] Player physically attaches GPS tracker to HVT
[*] Player accesses database terminal and downloads classified files
[*] Player tracks HVT position in real-time via GPS
[/list]

[h2] [b]Scenario 5: Power Grid Control[/b] [/h2]
[list]
[*] Mission maker places power generator controlling city lights
[*] Player must disable generator to create blackout
[*] Two options: hack generator remotely or destroy with explosives
[*] Blackout allows team to infiltrate under cover of darkness
[/list]

[hr] [/hr]

[h1][b]++++ CBA SETTINGS ++++[/b][/h1]

Customize the mod behavior via CBA Settings:

[b]Available Settings:[/b]
[list]
[*] Power costs for all operations
[*] GPS tracker update intervals
[*] Device registration limits
[*] Debug logging options
[/list]

[hr] [/hr]

[h1][b]++++ LICENSE ++++[/b][/h1]

[img]https://i.imgur.com/jUUdDUu.png[/img]
Project is now open sourced with APL-SA Licence! Check out the [url=https://github.com/A3-Root/Root_Cyberwarfare]GitHub page here![/url]

[hr] [/hr]

[h1][b]++++ CREDITS ++++[/b][/h1]

[b]Created by Root[/b]

Special thanks to:
[list]
[*] CBA Team - For the comprehensive framework
[*] ACE3 Team - For the interaction system
[*] AE3 Team - For the ArmaOS terminal system
[*] ZEN Team - For enhanced Zeus modules
[*] Arma 3 Community - For continued support and feedback
[/list]

For bug reports, feature requests, or contributions, visit the [url=https://github.com/A3-Root/Root_Cyberwarfare]GitHub repository[/url].

[hr] [/hr]
