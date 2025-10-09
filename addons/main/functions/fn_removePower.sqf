params['_computer', '_battery', '_changeWh'];

private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";

private _string = "";

private _newLevel = _batteryLevel - (_changeWh/1000);

_battery setVariable ["AE3_power_batteryLevel", _newLevel, true];
_batteryOwner = owner _battery;
[_battery, ["AE3_power_batteryLevel", _newLevel, true]] remoteExec ["setVariable", _batteryOwner];

_string = format ['Power Cost: %1Wh', _changeWh];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;
uiSleep 0.1;
_string = format ['New Power Level: %1Wh', _newLevel*1000];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;
uiSleep 0.1;
_string = format [' '];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;
uiSleep 0.1;
