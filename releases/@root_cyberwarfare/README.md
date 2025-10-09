# To Do

call compile preprocessFileLineNumbers "root_cyberwarfare\functions\fn_removePower.sqf";
remoteExecCall ["Root_fnc_removePower", 2];
[_battery, ["AE3_power_batteryLevel", _newLevel, true]] remoteExec ["setVariable", _batteryOwner];



Vehicle:
- fuel / battery (overload / cutoff)
- speed (setVelocity)
- brakes
- lights
- alarm
- engine
