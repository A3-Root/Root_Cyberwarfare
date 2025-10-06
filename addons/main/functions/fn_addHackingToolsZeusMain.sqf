params ["_entity", "_path", ["_execUserId", 0], ["_customLaptopName", ""], ["_backdoorScriptPrefix", ""]];

private ["_guide", "_devices", "_door", "_light", "_changedrone", "_disabledrone", "_download", "_custom"];

private _result = "";
private _allowed = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_/";
for "_i" from 0 to (count _path - 1) do {
    private _char = _path select [_i, 1];
    if (_allowed find _char != -1) then {
        _result = _result + _char;
    };
};
while {[_result, "/"] call BIS_fnc_inString && {_result select [count _result - 3] == "/"}} do {
    _result = _result select [0, count _result - 3];
};

_guide = _result + "/guide";
_devices = _result + "/devices";
_door = _result + "/door";
_light = _result + "/light";
_changedrone = _result + "/changedrone";
_disabledrone = _result + "/disabledrone";
_download = _result + "/download";
_custom = _result + "/custom";
_gpstrack = _result + "/gpstrack";



if ((_execUserId == 0) && (_customLaptopName == "OPS_DEBUG")) then 
{
    private _currentBackdoorPaths = _entity getVariable ["ROOT_BackdoorFunction", []];
    if (_backdoorScriptPrefix == "") then { _backdoorScriptPrefix = "backdoor_debug_" };
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "guide");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "devices");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "door");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "light");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "changedrone");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "disabledrone");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "download");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "custom");
    _entity setVariable ["ROOT_BackdoorFunction", _currentBackdoorPaths, true];
    _result = _result + "/" + _backdoorScriptPrefix;
    _guide = _result + "guide";
    _devices = _result + "devices";
    _door = _result + "door";
    _light = _result + "light";
    _changedrone = _result + "changedrone";
    _disabledrone = _result + "disabledrone";
    _download = _result + "download";
    _custom = _result + "custom";
    _gpstrack = _result + "gpstrack";
} else {
    if (_execUserId == 0) then {
        _execUserId = owner _entity;
    };
    _entity setVariable ["ROOT_HackingTools", true, true];
    _entity setVariable ["ROOT_CustomName", _customLaptopName, true];
};


private _computerNetIdString = str (netId _entity);

_content = "
    Type 'devices' to list all devices you can hack into.
            .
    Type 'door BuildingID DoorID (ID or 'a' for all) lock/unlock' to lock/unlock doors. Ex: 'door 1454 2881 lock' or 'door 1454 a unlock'
            .
    Type 'light LightID (ID or 'a' for all) off/on' to turn lights off or on. Ex: 'light a on' or 'light 3 off'
            .
    Type 'changedrone DroneID (ID or 'a' for all) side (west/east/guer/civ)' to switch the side of a drone. Ex: 'changedrone 2 east'
            .
    Type 'disabledrone 'DroneID (ID or 'a' for all)' to disable (explode) the drones. Ex: 'disabledrone 2' or 'disabledrone a'
            .
    Type 'download FileID' to download the File into the 'Downloads' folder. Ex: 'download 1234'
            .
    Type 'custom customId activate/deactivate to activate or deactivate a custom device. Ex: 'custom 5 activate'
            .
    Type 'gpstrack TrackerID' to start tracking a GPS target. Ex: 'gpstrack 2421'
'
";

[_entity, _guide, _content, false, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


private _content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-List-Devices-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _commandName] remoteExec ['Root_fnc_listDevicesInSubnet', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _devices, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


_content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'buildingId', true, false],
            ['path', 'doorId', true, false],
            ['path', 'state', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _buildingId = (_ae3OptsThings select 0);
    private _doorId = (_ae3OptsThings select 1);
    private _desiredState = (_ae3OptsThings select 2);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-Door-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _buildingId, _doorId, _desiredState, _commandName] remoteExec ['Root_fnc_changeDoorState', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _door, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


_content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'lightId', true, false],
            ['path', 'state', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _lightId = (_ae3OptsThings select 0);
    private _desiredState = (_ae3OptsThings select 1);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-Light-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _lightId, _desiredState, _commandName] remoteExec ['Root_fnc_changeLightState', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _light, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


_content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'droneId', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _droneId = (_ae3OptsThings select 0);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-Disable-Drone>-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _droneId, _commandName] remoteExec ['Root_fnc_disableDrone', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _disabledrone, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


_content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'droneId', true, false],
            ['path', 'faction', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _droneId = (_ae3OptsThings select 0);
    private _desiredState = (_ae3OptsThings select 1);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-Change-Drone-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _droneId, _desiredState, _commandName] remoteExec ['Root_fnc_changeDroneFaction', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _changedrone, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


_content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'databaseId', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _databaseId = (_ae3OptsThings select 0);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-Download-Database-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _databaseId, _commandName] remoteExec ['Root_fnc_downloadDatabase', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _download, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


_content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'customId', true, false],
            ['path', 'customState', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _customId = (_ae3OptsThings select 0);
    private _customState = (_ae3OptsThings select 1);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-Custom-Device-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _customId, _customState, _commandName] remoteExec ['Root_fnc_customDevice', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _custom, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

_content = "
    params['_computer', '_options', '_commandName'];

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'trackerId', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _trackerId = (_ae3OptsThings select 0);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT-GpsTrack-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _trackerId, _commandName] remoteExec ['Root_fnc_displayGPSPosition', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _gpstrack, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;



[format ["Root Cyber Warfare: Added Hacking Tools to Path: %1", _result]] remoteExec ["systemChat", _execUserId];
