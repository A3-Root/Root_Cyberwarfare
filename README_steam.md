[h1]Root's Cyber Warfare[/h1]

[b]Advanced electronic-warfare and hacking gameplay for Arma 3.[/b]

Root's Cyber Warfare turns AE3 laptops into mission tools for recon, sabotage, infiltration, and control. Hack doors, lights, vehicles, drones, GPS trackers, databases, custom devices, and power grids through the ArmaOS terminal or the Hackerman Desktop.

Fully integrated with ACE3, AE3, ZEN, Zeus, and Eden. Both the server and every client must load this mod and its dependencies.

[b]Current version:[/b] 2.0.0.0

[img]https://i.imgur.com/EWy3dQc.gif[/img]

[hr]
[h2]Device Types[/h2]
[table]
[tr][th]Device[/th][th]Capabilities[/th][/tr]
[tr][td][b]Doors[/b][/td][td]Lock/unlock individual doors or buildings; optionally unbreachable.[/td][/tr]
[tr][td][b]Lights[/b][/td][td]Switch individual or bulk-accessible lights.[/td][/tr]
[tr][td][b]Drones[/b][/td][td]Change faction or permanently disable UAVs.[/td][/tr]
[tr][td][b]Vehicles[/b][/td][td]Control battery/fuel, speed, brakes, lights, engine, and alarm.[/td][/tr]
[tr][td][b]Databases[/b][/td][td]Download mission files and encrypted intel.[/td][/tr]
[tr][td][b]Custom Devices[/b][/td][td]Trigger mission-maker-defined scripts and effects.[/td][/tr]
[tr][td][b]GPS Trackers[/b][/td][td]Track targets, or find and disable hidden trackers through ACE.[/td][/tr]
[tr][td][b]Power Grids[/b][/td][td]Control nearby lights or overload configured generators.[/td][/tr]
[/table]
[hr]
[h2]For Players[/h2]
[h3]Getting Started[/h3]
[olist]
[*]Approach an AE3 laptop and open the ACE interaction menu.
[*]Use the terminal or desktop configured for that laptop.
[*]The laptop needs hacking tools—installed by Zeus/the mission maker or supplied by a connected Rubberducky USB.
[*]Use [code]devices[/code] to see the devices you can access, then select a terminal command or Desktop app.
[/olist]
[h3]Terminal and Desktop[/h3]
Every operation is available through ArmaOS or point-and-click Hackerman Desktop apps. Both use the same permissions, devices, confirmations, and battery.
[img]https://i.ibb.co/xqsVwFbD/RCW-Desktop.png[/img]
[img]https://i.ibb.co/VYCjpGKp/rcw-terminal.png[/img]
[b]The Desktop includes apps for:[/b] Doors, Lights, Drones, Vehicles, GPS, Databases, Custom Devices, Power Grid control, NetScan, Crypto, and Crack.
[h3]Terminal Commands[/h3]
Every command provides detailed syntax and examples through [b]help[/b], [b]-h[/b], or [b]--help[/b].
[b]Find accessible devices:[/b]
[code]
devices                         # List everything you can access
devices doors                   # Show registered buildings and door status
devices vehicles                # Show accessible vehicles and available features
devices gps                     # Show GPS trackers and tracking status
devices < type > < deviceID >   # Show detailed information for one device
[/code]
[h3]Rubberducky USB[/h3]
The [b]Rubberducky USB[/b] is a portable AE3-compatible hacking-tools drive. Plug it into an AE3 laptop to enable the terminal and Hackerman Desktop; its contents persist across pickup and reconnection.
[img]https://i.ibb.co/B5n1CccW/AE3-Arsenal.png[/img]
By default, it also adds the [code]quack / quack[/code] login. Mission makers can disable or change these credentials in CBA settings.
[h3]Power Management[/h3]
Every operation costs laptop power. Insufficient charge prevents the action; bulk actions require enough power for every target. Recharge through AE3 power sources.
[h3]GPS Tracker Gameplay[/h3]
[list]
[*]Attach configured tracker items and search targets through ACE interactions.
[*]Use [b]gpstrack <trackerID>[/b] for live and last-known-position map markers.
[*]Mission makers control visibility, duration, retracking, power cost, and detection chance; spectrum tools can improve searches.
[/list]
[img]https://i.postimg.cc/Tw4KZYkX/Root-Cyberwarfare-GPSContext.jpg[/img]
[img]https://i.postimg.cc/3RckPJL5/Root-Cyberwarfare-GPSAttach.jpg[/img]
[img]https://i.postimg.cc/7hJ5D8Rt/Root-Cyberwarfare-GPSDetect-Normal.jpg[/img]
[img]https://i.postimg.cc/MHfnx2Lr/Root-Cyberwarfare-GPSDetect-Tool.jpg[/img]
[hr]
[h2]For Zeus Curators[/h2]
[h3]Quick Setup[/h3]
[olist]
[*]Open Zeus and select [b]Modules → Root's Cyber Warfare[/b].
[*]Use [b]Register Hackable Laptop[/b] on an AE3 laptop to make it available for device links.
[*]Install tools with [b]Add Hacking Tools[/b], or let players bring a Rubberducky USB to the laptop.
[*]Place the appropriate device module on an object, or use a trigger/radius workflow where supported.
[*]Choose public access, specific laptop access, or future-laptop access when registering the device.
[/olist]
[b]Modules cover:[/b] hacking tools, laptop registration, doors, lights, vehicles, databases, GPS trackers, custom devices, power generators, cipher tools, device-link copying/cleanup, and power costs.
[h3]Access Control[/h3]
[list]
[*][b]Public:[/b] Every current and future registered laptop can access the device.
[*][b]Private:[/b] Only selected registered laptops receive access.
[*][b]Future access:[/b] The device becomes available to laptops registered later in the mission.
[*][b]Location privacy:[/b] Device modules can hide their grid location from terminal and Desktop listings.
[/list]
[hr]
[h2]For Mission Makers[/h2]
Root's Cyber Warfare modules are available in [b]Systems (F5) → Root's Cyber Warfare[/b]. Synchronize modules to objects to register them, or use compatible triggers to register groups of objects in an area.
[img]https://i.ibb.co/4gXJZGwf/RCW-3-DEN-Module.png[/img]
[b]Eden setup supports:[/b]
[list]
[*]Fixed IDs, ID ranges, door-ID overrides, and location-visibility controls.
[*]Per-device vehicle limits/costs, GPS behavior/access, and power-grid settings.
[*]Encrypted database files with a chosen algorithm, key/variant, and options.
[/list]
[h3]EWO Mode[/h3]
Optional [b]77th JSOC EWO Mode[/b] adds field laptop registration and EWO backpack charging, network, and power-source actions. Rates are configurable through CBA settings.
[hr]
[h2]CBA Settings[/h2]
Configure Root's Cyber Warfare from [b]Main Menu → Options → Addon Options[/b]. Settings include:
[list]
[*]Power costs, GPS tracker/detection behavior, and Rubberducky credentials.
[*]Broken-link cleanup, EWO mode/rates, debug, and mission-level controls.
[/list]
[hr]
[h2]Credits[/h2]
[b]Author:[/b] Root (xMidnightSnowx)
[b]Mister Adrian[/b] — author of the [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3454525813]original Cyber Warfare mod[/url].
[url=https://77th-jsoc.com][b]77th JSOC[/b][/url]
[hr]
[h2]License[/h2]
[b]APL-SA:[/b] Arma Public License Share Alike
[url=https://www.bohemia.net/community/licenses/arma-public-license-share-alike]Read Full License here[/url]
[img]https://i.postimg.cc/pTxntLMW/APL-SA.png[/img]
You may redistribute the mod publicly only with clear author credit and a link to this Workshop page. Do not redistribute it privately without credit or port it to games other than Arma without explicit permission from me.
[hr]
[h2]Links[/h2]
[url=https://github.com/A3-Root/Root_Cyberwarfare][img]https://i.imgur.com/lPLHihO.gif[/img][/url]
[url=https://discord.gg/77th-jsoc-official][img]https://i.imgur.com/8B7UcQ2.gif[/img][/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=3574138571]Development Build[/url]
[hr]
Tags: #Arma 3 #Steam #Workshop #Mod #Root #Script #Zeus #Editor #Eden
gaming,game,video,videos,epic,arma,arma 3,cod,call of duty,modern,warfare,drone,uav,terminal,uplink,connect,satcom,satellite,antenna,control,remote,tool,mod,modding,script,code,sqf,signal,targeting,virtual,reality,awesome,guidance,software,source,steam,workshop,mods,best,top,ten,new,manual,gps,Cyber,war,cyberwar,warfare,electronic,ewo,electronic warfare officer,hacking,terminal,armaos,linux,gui,hacknet,milsim,military,signals,officer
