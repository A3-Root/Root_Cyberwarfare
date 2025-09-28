params['_computer', '_battery', '_changeWh'];

private _batteryLevel = _battery getVariable "AE3_power_batteryLevel";

private _string = "";

private _newLevel = _batteryLevel - (_changeWh/1000);

_battery setVariable ["AE3_power_batteryLevel", _newLevel];

_string = format ['Power Cost: %1Wh', _changeWh];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;

_string = format ['New Power Level: %1Wh', _newLevel*1000];
[_computer, _string] call AE3_armaos_fnc_shell_stdout;