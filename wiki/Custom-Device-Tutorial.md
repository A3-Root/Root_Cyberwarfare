# Custom Device Tutorial

Learn how to create custom hackable devices with unique behaviors.

## Overview

Custom devices allow you to trigger any SQF code when activated/deactivated via hacking. This enables creative gameplay mechanics like:
- Remote explosions
- Spawn systems
- Environmental effects
- Quest triggers
- Dynamic events

---

## Basic Concept

A custom device consists of:
1. **Physical object** - Any game object
2. **Device ID** - Unique identifier (auto-generated)
3. **Activation code** - SQF that runs when "activated"
4. **Deactivation code** - SQF that runs when "deactivated"
5. **Access control** - Which laptops can hack it

---

## Example 1: Simple Explosion

### Scenario
Player hacks a power generator, causing it to explode.

### Implementation

```sqf
// init.sqf or Zeus module

private _generator = generator1; // Object variable name

[_generator, 0, [], true, "Power Generator Overload",
    // Activation code
    "
    private _computer = _this select 0;
    private _generator = objectFromNetId (netId _computer);

    // Create explosion at generator
    'Bo_Mk82' createVehicle (getPos _generator);

    // Optional: Delete generator
    deleteVehicle _generator;

    // Feedback
    hint 'GENERATOR DESTROYED!';
    ",
    // Deactivation code (not used)
    "",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

### Usage
```bash
# In terminal
/rubberducky/tools/devices
# Shows: Power Generator Overload (ID: 1234)

/rubberducky/tools/custom 1234 activate
# Result: Explosion at generator location
```

---

## Example 2: Door Unlock Trigger

### Scenario
Hacking a security system unlocks a hidden door.

### Implementation

```sqf
private _securityPanel = securityPanel1;
private _hiddenDoor = hiddenDoor1;

[_securityPanel, 0, [], true, "Security System",
    // Activation: Unlock door
    "
    private _door = hiddenDoor1;
    _door setVariable ['bis_disabled_Door_1', 0, true];
    _door animate ['Door_1_rot', 1];
    hint 'Security bypassed - hidden door unlocked!';
    ",
    // Deactivation: Re-lock door
    "
    private _door = hiddenDoor1;
    _door setVariable ['bis_disabled_Door_1', 1, true];
    _door animate ['Door_1_rot', 0];
    hint 'Security restored - door locked.';
    ",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Example 3: Spawn Reinforcements

### Scenario
Triggering alarm spawns enemy reinforcements.

### Implementation

```sqf
private _alarmBox = alarmBox1;

[_alarmBox, 0, [], true, "Base Alarm System",
    // Activation: Spawn enemies
    "
    hint 'ALARM TRIGGERED - REINFORCEMENTS INCOMING!';

    // Spawn position
    private _spawnPos = getMarkerPos 'enemySpawn';

    // Create enemy group
    private _group = createGroup east;
    for '_i' from 1 to 5 do {
        private _unit = _group createUnit ['O_Soldier_F', _spawnPos, [], 10, 'FORM'];
    };

    // Order them to attack
    _group move (getMarkerPos 'playerBase');

    // Play alarm sound
    playSound3D ['a3\\sounds_f\\sfx\\alarm.wss', alarmBox1, false, getPosASL alarmBox1, 5, 1, 200];
    ",
    // Deactivation: Cancel alarm (doesn't despawn units)
    "
    hint 'Alarm deactivated.';
    ",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Example 4: Environmental Effect

### Scenario
Hacking weather station changes weather.

### Implementation

```sqf
private _weatherStation = weatherStation1;

[_weatherStation, 0, [], true, "Weather Control System",
    // Activation: Create fog
    "
    0 setFog [0.8, 0.1, 50];
    0 setOvercast 0.9;
    hint 'Weather manipulation active - fog deployed.';
    ",
    // Deactivation: Clear weather
    "
    0 setFog 0;
    0 setOvercast 0;
    hint 'Weather normalized.';
    ",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Example 5: Quest Progression

### Scenario
Downloading enemy plans advances mission objective.

### Implementation

```sqf
private _computer = enemyComputer1;

[_computer, 0, [], true, "Enemy Communications Hub",
    // Activation: Complete objective
    "
    hint 'Communications hub hacked - intel acquired!';

    // Update task
    ['ObjectiveHacked', 'SUCCEEDED'] call BIS_fnc_taskSetState;

    // Trigger next objective
    ['NextObjective'] call BIS_fnc_taskSetCurrent;

    // Award points (if using scoring)
    player addScore 100;
    ",
    "",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Example 6: Toggle System

### Scenario
Light switch that can be toggled multiple times.

### Implementation

```sqf
private _lightSwitch = lightSwitch1;

// Store state
_lightSwitch setVariable ["lightsOn", false, true];

[_lightSwitch, 0, [], true, "Base Lighting Control",
    // Activation: Turn on lights
    "
    private _switch = lightSwitch1;
    _switch setVariable ['lightsOn', true, true];

    // Turn on all nearby lights
    private _lights = nearestObjects [_switch, ['Lamps_base_F'], 100];
    {
        _x switchLight 'ON';
    } forEach _lights;

    hint 'Lights activated.';
    ",
    // Deactivation: Turn off lights
    "
    private _switch = lightSwitch1;
    _switch setVariable ['lightsOn', false, true];

    // Turn off all nearby lights
    private _lights = nearestObjects [_switch, ['Lamps_base_F'], 100];
    {
        _x switchLight 'OFF';
    } forEach _lights;

    hint 'Lights deactivated.';
    ",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Example 7: Timed Event

### Scenario
Start a 60-second countdown timer.

### Implementation

```sqf
private _detonator = detonator1;

[_detonator, 0, [], true, "Explosive Detonator",
    // Activation: Start countdown
    "
    hint 'COUNTDOWN STARTED - 60 SECONDS!';

    [{
        params ['_timeLeft'];

        if (_timeLeft > 0) then {
            hint format ['%1 seconds until detonation', _timeLeft];
        } else {
            hint 'DETONATION!';
            'Bo_Mk82' createVehicle (getMarkerPos 'explosionPos');
        };
    }, [60], 60] call CBA_fnc_waitAndExecute;
    ",
    // Deactivation: Cancel countdown (doesn't work after activated)
    "
    hint 'Detonator disabled - countdown cannot be stopped!';
    ",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Example 8: Access-Restricted Device

### Scenario
Only specific team can hack high-security device.

### Implementation

```sqf
private _vault = vault1;
private _opsTeamLaptop = laptop2;

[_vault, 0, [netId _opsTeamLaptop], true, "Vault Security System",
    "
    hint 'VAULT UNLOCKED!';
    vault1 animate ['Door_1_rot', 1];
    ",
    "",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// Only laptop2 can hack this vault
```

---

## Example 9: Multi-Stage System

### Scenario
Require hacking three systems in sequence.

### Implementation

```sqf
// Initialize progress
missionNamespace setVariable ["hackProgress", 0, true];

// System 1
[system1, 0, [], true, "Security Node Alpha",
    "
    private _progress = missionNamespace getVariable ['hackProgress', 0];
    missionNamespace setVariable ['hackProgress', _progress + 1, true];
    hint format ['Security node hacked: %1/3', _progress + 1];
    ",
    "", false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// System 2
[system2, 0, [], true, "Security Node Bravo",
    "
    private _progress = missionNamespace getVariable ['hackProgress', 0];
    missionNamespace setVariable ['hackProgress', _progress + 1, true];
    hint format ['Security node hacked: %1/3', _progress + 1];
    ",
    "", false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];

// System 3 (final)
[system3, 0, [], true, "Security Node Charlie",
    "
    private _progress = missionNamespace getVariable ['hackProgress', 0];
    if (_progress >= 2) then {
        hint 'ALL NODES HACKED - OBJECTIVE COMPLETE!';
        ['AllNodesHacked', 'SUCCEEDED'] call BIS_fnc_taskSetState;
    } else {
        hint format ['Security node hacked: %1/3 - Hack remaining nodes!', _progress + 1];
    };
    ",
    "", false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

---

## Code Best Practices

### 1. Reference the Computer

```sqf
// Correct: Use _this
private _computer = _this select 0;

// Get device object via variables
private _device = objectFromNetId (netId _computer);
```

### 2. Use Global Variables for Persistence

```sqf
// Store state globally
missionNamespace setVariable ["systemHacked", true, true];

// Check state later
if (missionNamespace getVariable ["systemHacked", false]) then {
    // System was hacked
};
```

### 3. Handle Multiplayer

```sqf
// Use remoteExec for global effects
["hint", "All players see this!"] remoteExec ["call", 0];

// Use publicVariable for sync
systemState = "hacked";
publicVariable "systemState";
```

### 4. Error Handling

```sqf
// Check object exists
private _device = objectFromNetId (_this select 0);
if (isNull _device) exitWith {
    hint 'Error: Device not found';
};

// Check conditions
if (player distance _device > 100) exitWith {
    hint 'Too far from device';
};
```

### 5. Use Scheduled Environment

Code runs in `spawn` (scheduled), so you can use:
- `sleep` / `uiSleep`
- Long loops
- `waitUntil`
- Time-based operations

```sqf
// This works (scheduled)
for '_i' from 3 to 1 step -1 do {
    hint format ['%1...', _i];
    sleep 1;
};
hint 'GO!';
```

---

## Testing Your Custom Device

### Quick Test

1. Place device object in editor
2. Place laptop with hacking tools
3. Run code in debug console:

```sqf
[cursorObject, 0, [], true, "Test Device",
    "hint 'Activated!';",
    "hint 'Deactivated!';",
    false
] remoteExec ["Root_fnc_addDeviceZeusMain", 2];
```

4. Open laptop terminal
5. Run `/path/devices` to find device ID
6. Run `/path/custom <ID> activate`

### Debug Output

Add debug hints to your code:

```sqf
"
hint 'Code started';
diag_log 'Custom device activated';

// Your code here

hint 'Code finished';
"
```

---

## Common Pitfalls

### ❌ Wrong: Local Variables

```sqf
// This doesn't persist
"
private _hasActivated = true;
"
```

### ✅ Correct: Global Variables

```sqf
// This persists
"
missionNamespace setVariable ['deviceActivated', true, true];
"
```

### ❌ Wrong: Hardcoded Object References

```sqf
// Breaks if object is deleted/recreated
"
private _door = door1;
"
```

### ✅ Correct: Network ID References

```sqf
// Robust reference
"
private _doorNetId = missionNamespace getVariable ['door1NetId', ''];
private _door = objectFromNetId _doorNetId;
if (!isNull _door) then {
    // Use door
};
"
```

---

## Advanced Techniques

### Using CBA Events

```sqf
// Activation: Fire custom CBA event
"
['myMod_deviceHacked', [player, 'Generator']] call CBA_fnc_globalEvent;
"

// Elsewhere in mission
["myMod_deviceHacked", {
    params ["_player", "_deviceName"];
    hint format ['%1 hacked %2', name _player, _deviceName];
}] call CBA_fnc_addEventHandler;
```

### Integration with Other Mods

```sqf
// ACE3 integration
"
[player, 'AinvPknlMstpSnonWnonDnon_medicOther', 1] call ace_common_fnc_doAnimation;
"

// Advanced Equipment integration
"
[_computer, '/data/intel.txt', 'Enemy positions...', false, 'root', [[true,true,true],[true,true,true]], false, 'caesar', '1'] remoteExec ['AE3_filesystem_fnc_device_addFile', 2];
"
```

---

## See Also

- [Zeus Guide](Zeus-Guide) - Using Zeus module for custom devices
- [Mission Maker Guide](Mission-Maker-Guide) - Scripting integration
- [API Reference](API-Reference) - Function documentation

---

**Need inspiration?** Check community-created custom devices in the GitHub discussions!
