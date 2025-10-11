# Troubleshooting

Solutions to common issues with Root's Cyber Warfare.

## Quick Diagnostics

### Check Mod Loaded

**Debug Console**:
```sqf
hint str (isClass (configFile >> "CfgPatches" >> "root_cyberwarfare_main"));
```
- **true** = Mod loaded correctly ✅
- **false** = Mod not loaded ❌

### Check RPT Log

**Location**: `C:\Users\YourName\AppData\Local\Arma 3\`

**Search for**: `Root_Cyberwarfare` or `root_cyberwarfare`

**Good output**:
```
[CBA] Root_Cyberwarfare: Settings initialized
[CBA] Root_Cyberwarfare: Functions compiled
```

**Bad output** (errors):
```
Error: Missing addon 'cba_main'
Error: Cannot find function 'Root_fnc_xxx'
```

---

## Installation Issues

### "Addon 'root_cyberwarfare_main' requires addon 'cba_main'"

**Cause**: CBA_A3 not installed or wrong load order

**Solutions**:
1. Install CBA_A3 from [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=450814997)
2. Ensure CBA loads before Root's Cyber Warfare
3. Check launch parameters: `-mod=@CBA_A3;@root_cyberwarfare`
4. Restart Arma 3

---

### "Missing addon 'ae3_filesystem'"

**Cause**: AE3 (Advanced Equipment) not installed

**Solutions**:
1. Install AE3 from [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=2974004286)
2. Verify AE3 in Expansions menu
3. Add to launch parameters: `-mod=@AE3`

---

### Zeus Modules Not Appearing

**Cause**: ZEN (Zeus Enhanced) not installed or outdated

**Solutions**:
1. Install ZEN from [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=1779063631)
2. Update ZEN to latest version
3. Verify Zeus role in mission
4. Check RPT for ZEN-related errors

---

### Mod Loads But No Effect

**Symptoms**: Mod shows in Expansions but nothing works

**Diagnose**:
```sqf
// Check functions compiled
hint str (!isNil "Root_fnc_isDeviceAccessible");
```

**If false (functions not found)**:
1. Check CBA cache: Delete `@CBA_A3\userconfig\cba_cache\*`
2. Restart Arma 3
3. Check for conflicting mods

**If true (functions exist) but still no effect**:
- Hacking tools not added to laptop (see below)

---

## Gameplay Issues

### No Hacking Tools Available

**Symptoms**: Can't open terminal or terminal has no commands

**Solutions**:

1. **Add tools via Zeus**:
   - Open Zeus
   - Place "Add Hacking Tools" module on laptop
   - Configure and click OK

2. **Add tools via script**:
   ```sqf
   [_laptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
   ```

3. **Verify tools installed**:
   ```sqf
   _laptop getVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", false];
   // Should return true
   ```

---

### "Insufficient Power" Error

**Symptoms**: Can't execute commands due to power

**Causes**:
- Laptop battery depleted
- Power costs too high

**Solutions**:

1. **Recharge laptop** (via AE3 battery system)
2. **Lower power costs** (see [Configuration](Configuration))
3. **Check current power**:
   ```sqf
   private _battery = uiNamespace getVariable "AE3_Battery";
   private _level = _battery getVariable "AE3_power_batteryLevel";
   hint format ["Battery: %1 kWh", _level];
   ```

---

### No Devices Found

**Symptoms**: `/tools/devices` shows empty or "No accessible devices"

**Causes**:
1. No devices registered
2. Device access denied
3. Device links broken

**Solutions**:

1. **Register devices** via Zeus or script:
   ```sqf
   [_building] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
   ```

2. **Check device count**:
   ```sqf
   private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
   hint format ["Doors: %1, Drones: %2", count (_allDevices select 0), count (_allDevices select 2)];
   ```

3. **Check access** (backdoor test):
   ```sqf
   // Grant backdoor access temporarily
   _laptop setVariable ["ROOT_CYBERWARFARE_BACKDOOR_PREFIX", "/admin", true];
   // Now try /admin_devices command
   ```

4. **Verify device linking**:
   ```sqf
   // Check link cache
   private _linkCache = missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap];
   hint str _linkCache;
   ```

---

### GPS Tracker Not Working

**Symptoms**: No marker appears on map after tracking

**Causes**:
1. Tracker not properly configured
2. Target object destroyed
3. Client-side scripting error

**Solutions**:

1. **Check tracker status**:
   ```sqf
   // Look at device data
   private _allGpsTrackers = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []]) select 5;
   hint str _allGpsTrackers;
   ```

2. **Verify target alive**:
   ```sqf
   private _target = objectFromNetId "<netId>";
   hint str (alive _target);
   ```

3. **Check RPT for errors** during tracking

4. **Manually test client function**:
   ```sqf
   [_target, "testMarker", 30, 5, "Test", 30] spawn Root_fnc_gpsTrackerClient;
   ```

---

### Commands Not Found in Terminal

**Symptoms**: `/tools/door` shows "command not found"

**Causes**:
1. Wrong installation path
2. AE3 filesystem issue
3. Tools not properly installed

**Solutions**:

1. **Check installation path**:
   ```sqf
   _laptop getVariable ["ROOT_CYBERWARFARE_INSTALL_PATH", ""]
   // Should show path like "/rubberducky/tools"
   ```

2. **List files** in AE3:
   ```bash
   ls /rubberducky/tools
   ```

3. **Reinstall tools**:
   ```sqf
   [_laptop] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
   ```

---

### Door Won't Lock/Unlock

**Symptoms**: Command executes but door doesn't change state

**Causes**:
1. Building doesn't have configurable doors
2. Door number incorrect
3. Door animation broken

**Solutions**:

1. **Check door configuration**:
   ```sqf
   private _config = configOf _building;
   private _anims = getArray (_config >> "SimpleObject" >> "animate");
   hint str _anims;
   // Should show door_* animations
   ```

2. **Test door manually**:
   ```sqf
   _building setVariable ["bis_disabled_Door_1", 1, true]; // Lock
   _building setVariable ["bis_disabled_Door_1", 0, true]; // Unlock
   ```

3. **Check door exists**:
   ```sqf
   _building animationPhase "Door_1_rot"; // Should return number
   ```

---

### Vehicle Hacking Doesn't Work

**Symptoms**: Vehicle commands have no effect

**Causes**:
1. Feature not enabled for this vehicle
2. Vehicle doesn't support the feature
3. Network locality issue

**Solutions**:

1. **Check enabled features**:
   ```sqf
   // Find vehicle in devices array
   private _vehicles = (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []]) select 6;
   hint str _vehicles;
   // Check _allowFuel, _allowSpeed, etc. booleans
   ```

2. **Test feature manually**:
   ```sqf
   // Battery
   _vehicle setFuel 0.5;

   // Speed
   _vehicle setVelocity [0, 10, 0];

   // Lights (only empty vehicles)
   if (crew _vehicle isEqualTo []) then {
       _vehicle setPilotLight true;
   };
   ```

---

## Multiplayer Issues

### Devices Don't Sync to Clients

**Symptoms**: Only server sees devices, clients don't

**Causes**:
- Variables not published globally
- JIP (Join In Progress) sync issue
- Network desync

**Solutions**:

1. **Verify publicVariable**:
   ```sqf
   // Check if global
   hint str (isNil {missionNamespace getVariable "ROOT_CYBERWARFARE_ALL_DEVICES"});
   // Should be false on all clients
   ```

2. **Force resync**:
   ```sqf
   // On server
   publicVariable "ROOT_CYBERWARFARE_ALL_DEVICES";
   publicVariable "ROOT_CYBERWARFARE_LINK_CACHE";
   ```

3. **Use CBA events** (automatic sync):
   ```sqf
   ["root_cyberwarfare_deviceStateChanged", [_type, _id, _state]] call CBA_fnc_globalEvent;
   ```

---

### GPS Markers Not Visible to Other Players

**Symptoms**: GPS tracking works but teammates don't see markers

**This is by design**: GPS markers are client-side (only the tracking player sees them).

**Workaround for shared tracking**:
```sqf
// Custom implementation - send position via CBA event
["myMission_gpsUpdate", [_trackerName, getPos _target]] call CBA_fnc_globalEvent;

// All clients listen
["myMission_gpsUpdate", {
    params ["_name", "_pos"];
    // Create marker for everyone
}] call CBA_fnc_addEventHandler;
```

---

### Commands Execute Twice

**Symptoms**: Actions happen multiple times

**Cause**: Client and server both executing (locality issue)

**Solution**: Ensure commands run on correct machine:
```sqf
// Server-only execution
if (!isServer) exitWith {};

// Client-only execution
if (isDedicated) exitWith {};

// Use remoteExec properly
[...] remoteExec ["function", 2]; // Server only
[...] remoteExec ["function", 0]; // Everyone
[...] remoteExec ["function", owner _player]; // Specific client
```

---

## Performance Issues

### High CPU Usage

**Causes**:
- Too many active GPS trackers
- Complex custom device code
- Inefficient access checks

**Solutions**:

1. **Limit GPS trackers**: Max 5-10 active at once
2. **Optimize custom code**: Avoid long loops, use sleep
3. **Use cached access checks**: Don't call `Root_fnc_isDeviceAccessible` repeatedly

---

### Lag When Listing Devices

**Causes**:
- Large number of devices (100+)
- Array iteration overhead (2.x issue)

**Solutions**:

1. **Upgrade to 3.0+** (hashmap performance improvements)
2. **Reduce device count**: Only register necessary devices
3. **Use filtered queries**: Check access before listing

---

## Script Errors

### "Error: Cannot find function 'Root_fnc_xxx'"

**Cause**: Function not compiled or wrong name

**Solutions**:

1. **Check function name** (case-sensitive):
   ```sqf
   Root_fnc_isDeviceAccessible // Correct
   Root_fnc_isdeviceaccessible // Wrong
   ```

2. **Verify function exists**:
   ```sqf
   hint str (!isNil "Root_fnc_functionName");
   ```

3. **Check CBA cache**: Delete and rebuild

---

### "Error: Zero divisor"

**Cause**: Division by zero in power calculation

**Solution**: Ensure power costs are > 0:
```sqf
// Check costs
private _costs = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []];
hint str _costs; // No zeros allowed
```

---

### "Error: Type OBJECT, expected STRING"

**Cause**: Passing object instead of netId

**Solution**: Use `netId` for network operations:
```sqf
// Wrong
[_laptop] call someFunction;

// Correct
[netId _laptop] call someFunction;
```

---

## CBA Settings Issues

### Settings Not Applying

**Symptoms**: Changed CBA settings but no effect

**Solutions**:

1. **Use "force" keyword** (server config):
   ```sqf
   force root_cyberwarfare_drone_hack_cost = 10;
   ```

2. **Restart server** after editing `cba_settings.sqf`

3. **Check file location**: `userconfig/cba_settings.sqf`

4. **Verify settings loaded**:
   ```sqf
   hint str (missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []]);
   ```

---

### Settings Reset After Mission

**Cause**: Mission scripts override CBA settings

**Solution**: Don't use `setVariable` in mission init:
```sqf
// Bad: Overrides CBA
missionNamespace setVariable ["ROOT_CYBERWARFARE_ALL_COSTS", [1,2,3,4], true];

// Good: Use CBA settings menu or server config
```

---

## Getting Help

### Gather Diagnostic Info

Before asking for help, collect:

1. **RPT Log** (`AppData\Local\Arma 3\*.rpt`)
2. **Mod list** (from Expansions menu)
3. **CBA settings** (run diagnostic script)
4. **Reproduction steps**

### Diagnostic Script

```sqf
// Run in debug console
private _diag = format [
    "=== Root's Cyber Warfare Diagnostics ===\n
    Mod Loaded: %1\n
    Functions Compiled: %2\n
    CBA Version: %3\n
    Device Count: %4 doors, %5 drones\n
    Settings: %6\n
    Link Cache Size: %7",
    isClass (configFile >> "CfgPatches" >> "root_cyberwarfare_main"),
    !isNil "Root_fnc_isDeviceAccessible",
    getText (configFile >> "CfgPatches" >> "cba_main" >> "version"),
    count ((missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []]) param [0, []]),
    count ((missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []]) param [2, []]),
    missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_COSTS", []],
    count (missionNamespace getVariable ["ROOT_CYBERWARFARE_LINK_CACHE", createHashMap])
];

copyToClipboard _diag;
hint "Diagnostics copied to clipboard";
```

### Where to Get Help

- **GitHub Issues**: [Report bugs](https://github.com/A3-Root/Root_Cyberwarfare/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/A3-Root/Root_Cyberwarfare/discussions)
- **Discord**: Community servers (check README for links)

---

## Known Issues

### Issue: GPS tracking stops if target destroyed

**Status**: By design
**Workaround**: Check target health before tracking

### Issue: Door locks don't prevent AI from opening

**Status**: Engine limitation
**Workaround**: Use custom scripting to block AI door access

### Issue: Light control doesn't work on placed lights

**Status**: Only affects Zeus-placed objects
**Workaround**: Use editor-placed lights with `Lamps_base_F` class

---

## See Also

- [Installation Guide](Installation) - Setup instructions
- [Configuration Reference](Configuration) - Settings documentation
- [Architecture](Architecture) - Technical details

---

**Still having issues?** Open an issue on [GitHub](https://github.com/A3-Root/Root_Cyberwarfare/issues) with diagnostic info.
