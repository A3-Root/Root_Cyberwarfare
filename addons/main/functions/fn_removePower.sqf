params['_computer', '_battery', '_newLevel'];
_battery setVariable ["AE3_power_batteryLevel", _newLevel, true];
_batteryOwner = owner _battery;
[_battery, ["AE3_power_batteryLevel", _newLevel, true]] remoteExec ["setVariable", _batteryOwner];
