[h1]Root's Cyber Warfare[/h1]

[b]Advanced hacking mod for Arma 3 with terminal-based control over doors, lights, vehicles, drones, and more.[/b]

Designed for tactical missions requiring infiltration, sabotage, and electronic warfare. Fully integrated with ACE3, AE3 ArmaOS terminal, and Zeus/Eden editors. Tested with 67+ players on dedicated servers. Requires both server and clients to have this mod.

[b]Current version - 1.0.0.0[/b]

[img]https://i.imgur.com/EWy3dQc.gif[/img]

[hr][/hr]

[h2]Device Types[/h2]

[table]
[tr]
[th]Device[/th]
[th]Capabilities[/th]
[/tr]
[tr]
[td][b]Doors[/b][/td]
[td]Lock/unlock, prevent breaching[/td]
[/tr]
[tr]
[td][b]Lights[/b][/td]
[td]Turn on/off buildings[/td]
[/tr]
[tr]
[td][b]Drones[/b][/td]
[td]Change faction, disable[/td]
[/tr]
[tr]
[td][b]Vehicles[/b][/td]
[td]Control battery, speed, brakes, lights, engine, alarm[/td]
[/tr]
[tr]
[td][b]Databases[/b][/td]
[td]Download files, execute code[/td]
[/tr]
[tr]
[td][b]Custom[/b][/td]
[td]Scripted devices (generators, alarms)[/td]
[/tr]
[tr]
[td][b]GPS Trackers[/b][/td]
[td]Real-time position tracking[/td]
[/tr]
[tr]
[td][b]Power Grids[/b][/td]
[td]Control lights in radius, explosions[/td]
[/tr]
[/table]

[hr][/hr]

[h2]For Players[/h2]

[h3]Terminal Access[/h3]
[olist]
[*]ACE Interact on AE3 laptop → ArmaOS → Use
[*]Laptop must have hacking tools (configured by Zeus/mission maker)
[/olist]

[img]https://i.postimg.cc/ncKcTqxP/Home-Screen.png[/img]

[h3]In-Game Guide[/h3]
A detailed terminal usage guide is available in-game for all players. Open your map and navigate to the [b]Cyberwarfare Guide[/b] section for comprehensive command reference and examples.

[h3]Commands[/h3]

[b]List Devices:[/b]
[code]
devices all              # List all accessible devices
devices doors            # List doors only
devices lights           # Lights only
devices drones           # Drones only
devices vehicles         # Vehicles only
devices gps              # GPS trackers
[/code]

[b]Control Devices:[/b]
[code]
# Doors
door <buildingID> <doorID> lock/unlock
door <buildingID> a lock             # Lock all doors

# Lights
light <lightID> on/off

# Vehicles
vehicle <ID> battery <0-100>         # Set battery (>100 = destroy)
vehicle <ID> speed <value>           # Modify speed
vehicle <ID> brakes                  # Apply brakes
vehicle <ID> lights on/off
vehicle <ID> engine on/off
vehicle <ID> alarm <seconds>

# Drones
drone <ID> side <west/east/guer/civ>
drone <ID> disable

# Power Grids
powergrid <ID> on/off
powergrid <ID> overload              # Destroy with explosion

# GPS Tracking
gpstrack <ID>                        # Start tracking (creates marker)

# Custom
custom <ID> on/off
[/code]

[img]https://i.postimg.cc/bN0NL1PH/20251020193947-1.jpg[/img]

[h3]Power Management[/h3]
Operations consume battery (Watt-hours). Commands fail if insufficient power. Recharge using AE3 power sources.

[h3]GPS Trackers[/h3]
[list]
[*]Attach via ACE Self-Interact → Equipment → Attach GPS Tracker
[*]Search others via ACE Interaction menu
[*]Detection is chance-based (improved with detection devices)
[/list]
[img]https://i.postimg.cc/zXYGn0sx/20251020193610-1.jpg[/img]
[img]https://i.postimg.cc/BQ5QN23g/20251020194006-1.jpg[/img]

[hr][/hr]

[h2]For Zeus Curators[/h2]

[h3]Quick Setup[/h3]
[olist]
[*]Zeus interface (Y key) → Modules → Root's Cyber Warfare
[*]Place [b]"Add Hacking Tools"[/b] on AE3 laptop
[*]Place device modules on objects to make hackable
[/olist]

[img]https://i.postimg.cc/8PdPwLG4/20251020194128-1.jpg[/img]

[h3]Zeus Modules[/h3]

[b]Add Hacking Tools[/b] - Enable laptop hacking capability

[b]Add Hackable Object[/b] - Buildings (auto-detects doors/lights), drones

[b]Add Hackable Vehicle[/b] - Configure controllable systems

[b]Add Hackable File[/b] - Downloadable databases

[b]Add GPS Tracker[/b] - Real-time position tracking

[b]Add Custom Device[/b] - Mission-specific scripted devices

[b]Add Power Generator[/b] - Control lights in radius

[b]Modify Power Costs[/b] - Adjust global power consumption

[h3]Device Linking[/h3]
[list]
[*][b]Public:[/b] Accessible to all laptops
[*][b]Private:[/b] Select specific laptops during placement
[*][b]Future Access:[/b] "Available to Future Laptops" checkbox
[/list]

[hr][/hr]

[h2]For Mission Makers[/h2]

[h3]SQF Examples[/h3]

[b]Add Hacking Tools:[/b]
[code]
[_laptop, "/network/tools", 0, "HackStation", ""]
    call Root_fnc_addHackingToolsZeusMain;
[/code]

[b]Register Building:[/b]
[code]
[_building, 0, [_laptop1, _laptop2], false, "", "", "", false]
    call Root_fnc_addDeviceZeusMain;
[/code]

[b]Register Vehicle:[/b]
[code]
[_vehicle, 0, [_laptop1], "TargetCar", true, false, false, true, true, false, false, 2]
    call Root_fnc_addVehicleZeusMain;
[/code]

[b]Custom Device (Alarm):[/b]
[code]
[_alarmBox, 0, [_laptop1], "Base_Alarm",
    "playSound3D ['a3\sounds_f\sfx\alarm.wss', _this select 0];",
    "hint 'Alarm off';",
    false]
    call Root_fnc_addCustomDeviceZeusMain;
[/code]

[b]Power Grid:[/b]
[code]
[_generator, 0, [_laptop1], "City_Grid", 2000, false, true, "HelicopterExploSmall", [], false]
    call Root_fnc_addPowerGeneratorZeusMain;
[/code]

[h3]Eden Editor[/h3]
8 modules available under [b]Systems (F5) → Root's Cyber Warfare[/b]. Use synchronization (F5) to link modules to objects.

[hr][/hr]

[h2]CBA Settings[/h2]

[img]https://i.postimg.cc/VLPkjDxR/20251020192844-1.jpg[/img]

Configure in Main Menu → Options → Addon Options → Root Cyber Warfare:
[list]
[*]Power costs for all device types
[*]GPS tracker item classname (default: ACE_Banana)
[*]GPS detection tool (default: Spectrum Device)
[*]GPS detection chances (with/without detection tool)
[*]GPS marker colors (active/last ping)
[/list]

[hr][/hr]

[h2]Credits[/h2]

[b]Author:[/b] Root (xMidnightSnowx)
[b]Mister Adrian[/b] - Author of the [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3454525813]original Cyber Warfare mod[/url]
[url=77th-jsoc.com][b]77th JSOC[/b][/url]

[hr][/hr]

[h2]License[/h2]
[b]APL-SA:[/b] Arma Public License Share Alike
[url=https://www.bohemia.net/community/licenses/arma-public-license-share-alike]Read Full License here[/url]
[img]https://www.bohemia.net/assets/img/licenses/APL-SA.png[/img]

TL;DR - What am I allowed to do?
✔️ Redistribute this mod in part or whole publicly [b]ONLY[/b] with clear credit towards the author and with credits linking to this page.
❌ Redistribute this mod in part or whole privately / within a unit [b]WITHOUT[/b] giving any credit.
❌ Port this mod in part or whole to games other than ArmA.

If you have any issues with the content presented in this mod, PLEASE CONTACT ME FIRST!

[hr][/hr]

[h2]Links[/h2]
[url=https://github.com/A3-Root/Root_Cyberwarfare][img]https://i.imgur.com/lPLHihO.gif[/img][/url]
[url=https://discord.gg/77th-jsoc-official][img]https://i.imgur.com/8B7UcQ2.gif[/img][/url]

[hr][/hr]

[b]Tags:[/b] #Arma 3 #Steam #Workshop #Mod #Root #Script #Zeus #Editor #Eden
gaming,game,video,videos,epic,arma,arma 3,cod,call of duty,modern,warfare,drone,uav,terminal,uplink,connect,satcom,satellite,antenna,control,remote,tool,mod,modding,script,code,sqf,signal,targeting,virtual,reality,awesome,guidance,software,source,steam,workshop,mods,best,top,ten,new,manual,gps,Cyber,war,cyberwar,warfare,electronic,ewo,electronic warfare officer,hacking,terminal,armaos,linux,gui,hacknet,milsim,military,signals,officer