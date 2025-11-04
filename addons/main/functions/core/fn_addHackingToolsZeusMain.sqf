#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side function to install hacking tools on a computer by creating virtual
 *              filesystem entries for all hacking commands (door, light, drone, gpstrack, vehicle, etc.)
 *
 * Arguments:
 * 0: _entity <OBJECT> - The computer/laptop object
 * 1: _path <STRING> (Optional) - Installation path for tools, default: "/rubberducky/tools"
 * 2: _execUserId <NUMBER> (Optional) - User ID for feedback, default: 0
 * 3: _customLaptopName <STRING> (Optional) - Custom name for the laptop, default: ""
 * 4: _backdoorScriptPrefix <STRING> (Optional) - Backdoor prefix for special access, default: ""
 *
 * Return Value:
 * None
 *
 * Example:
 * [_laptop, "/network/tools", 0, "HQ_Terminal"] remoteExec ["Root_fnc_addHackingToolsZeusMain", 2];
 *
 * Public: No
 */

params ["_entity", ["_path", "/rubberducky/tools", [""]], ["_execUserId", 0, [0]], ["_customLaptopName", "", [""]], ["_backdoorScriptPrefix", "", [""]]];

private ["_guide", "_devices", "_door", "_light", "_changedrone", "_disabledrone", "_download", "_custom", "_gpstrack", "_vehicle", "_powergrid"];

// Validate _path is a string
if (_path isEqualType objNull || {_path isEqualType []}) exitWith {
    [format [localize "STR_ROOT_CYBERWARFARE_ZEUS_INVALID_PATH_TYPE", typeName _path]] remoteExec ["systemChat", _execUserId];
};

// Ensure _path is a string
_path = str _path;

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
_vehicle = _result + "/vehicle";
_powergrid = _result + "/powergrid";



if ((_execUserId == 0) && (_customLaptopName == "OPS_DEBUG")) then 
{
    private _currentBackdoorPaths = _entity getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", []];
    if (_backdoorScriptPrefix == "") then { _backdoorScriptPrefix = "backdoor_debug_" };
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "guide");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "devices");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "door");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "light");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "changedrone");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "disabledrone");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "download");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "custom");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "gpstrack");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "vehicle");
    _currentBackdoorPaths pushBackUnique (_backdoorScriptPrefix + "powergrid");
    _entity setVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", _currentBackdoorPaths, true];
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
    _vehicle = _result + "vehicle";
    _powergrid = _result + "powergrid";
} else {
    if (_execUserId == 0) then {
        _execUserId = owner _entity;
    };
    _entity setVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", true, true];
    _entity setVariable ["ROOT_CYBERWARFARE_PLATFORM_NAME", _customLaptopName, true];
};


private _computerNetIdString = str (netId _entity);

private _content = "
    Type 'devices <type>' to list devices. Use 'devices doors' for buildings, then 'devices doors <buildingId>' for door details.
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
    Type 'custom CustomID activate/deactivate to activate or deactivate a custom device. Ex: 'custom 5 activate'
            .
    Type 'gpstrack TrackerID' to start tracking a GPS target. Ex: 'gpstrack 2421'
            .
    Type 'vehicle VehicleID HackType Value' to hack a vehicle. Ex: 'vehicle 1337 battery 9000' or vehicle 1337 engine off'
            .
    Type 'powergrid GridID action' to control a power grid. Actions: on, off, overload. Ex: 'powergrid 1234 on' or 'powergrid 1234 overload'
";

[_entity, _guide, _content, false, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];


_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_LIST_DEVICES-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, _commandName, 'help', ''] remoteExec ['Root_fnc_listDevicesInSubnet', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'type', true, false]
        ],
        [
            ['command', _commandName, true, false],
            ['path', 'type', true, false],
            ['path', 'deviceId', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _type = if (count _ae3OptsThings > 0) then { _ae3OptsThings select 0 } else { '' };
    private _deviceId = if (count _ae3OptsThings > 1) then { _ae3OptsThings select 1 } else { '' };

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT_CYBERWARFARE_LIST_DEVICES-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _commandName, _type, _deviceId] remoteExec ['Root_fnc_listDevicesInSubnet', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _devices, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];


_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_DOOR-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', '', '', _commandName] remoteExec ['Root_fnc_changeDoorState', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

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

    private _nameOfVariable = 'ROOT_CYBERWARFARE_DOOR-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _buildingId, _doorId, _desiredState, _commandName] remoteExec ['Root_fnc_changeDoorState', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _door, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];


_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_LIGHT-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', '', _commandName] remoteExec ['Root_fnc_changeLightState', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

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

    private _nameOfVariable = 'ROOT_CYBERWARFARE_LIGHT-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _lightId, _desiredState, _commandName] remoteExec ['Root_fnc_changeLightState', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _light, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];


_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_DISABLE_DRONE>-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', _commandName] remoteExec ['Root_fnc_disableDrone', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

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

    private _nameOfVariable = 'ROOT_CYBERWARFARE_DISABLE_DRONE>-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _droneId, _commandName] remoteExec ['Root_fnc_disableDrone', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _disabledrone, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];


_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_CHANGE_DRONE-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', '', _commandName] remoteExec ['Root_fnc_changeDroneFaction', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

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

    private _nameOfVariable = 'ROOT_CYBERWARFARE_CHANGE_DRONE-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _droneId, _desiredState, _commandName] remoteExec ['Root_fnc_changeDroneFaction', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _changedrone, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];


_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _playerObject = player;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_DOWNLOAD_DATABASE-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', _playerObject, _commandName] remoteExec ['Root_fnc_downloadDatabase', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

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
    private _playerObject = player;

    private _nameOfVariable = 'ROOT_CYBERWARFARE_DOWNLOAD_DATABASE-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _databaseId, _playerObject, _commandName] remoteExec ['Root_fnc_downloadDatabase', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _download, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];


_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _playerObject = player;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_CUSTOM_DEVICE-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', '', _playerObject, _commandName] remoteExec ['Root_fnc_customDevice', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

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
    private _playerObject = player;

    private _nameOfVariable = 'ROOT_CYBERWARFARE_CUSTOM_DEVICE-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _customId, _customState, _playerObject, _commandName] remoteExec ['Root_fnc_customDevice', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _custom, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];

_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_GPS_TRACK-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', _commandName] remoteExec ['Root_fnc_displayGPSPosition', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

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

    private _nameOfVariable = 'ROOT_CYBERWARFARE_GPS_TRACK-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _trackerId, _commandName] remoteExec ['Root_fnc_displayGPSPosition', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _gpstrack, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];

_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_VEHICLE-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', '', '', _commandName] remoteExec ['Root_fnc_changeVehicleParams', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'vehicleID', true, false],
            ['path', 'action', true, false],
            ['path', 'value', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _vehicleID = (_ae3OptsThings select 0);
    private _action = (_ae3OptsThings select 1);
    private _value = (_ae3OptsThings select 2);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT_CYBERWARFARE_VEHICLE-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _vehicleID, _action, _value, _commandName] remoteExec ['Root_fnc_changeVehicleParams', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _vehicle, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];

_content = "
    params['_computer', '_options', '_commandName'];

    if ((count _options > 0) && {(_options select 0) in ['-h', '--help', 'help']}) exitWith {
        private _owner = clientOwner;
        private _nameOfVariable = 'ROOT_CYBERWARFARE_POWERGRID-' + "+ _computerNetIdString +";
        missionNamespace setVariable [_nameOfVariable, false, true];
        [_owner, _computer, _nameOfVariable, 'help', '', _commandName] remoteExec ['Root_fnc_powerGridControl', _owner];
        private _tStart = time;
        waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
        if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
            [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
        };
    };

    private _commandOpts = [];
    private _commandSyntax =
    [
        [
            ['command', _commandName, true, false],
            ['path', 'gridId', true, false],
            ['path', 'action', true, false]
        ]
    ];
    private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

    [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

    if (!_ae3OptsSuccess) exitWith {};

    private _gridId = (_ae3OptsThings select 0);
    private _action = (_ae3OptsThings select 1);

    private _owner = clientOwner;

    private _nameOfVariable = 'ROOT_CYBERWARFARE_POWERGRID-' + "+ _computerNetIdString +";

    missionNamespace setVariable [_nameOfVariable, false, true];
    [_owner, _computer, _nameOfVariable, _gridId, _action, _commandName] remoteExec ['Root_fnc_powerGridControl', _owner];
    private _tStart = time;
    waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
    if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
        [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
    };
";
[_entity, _powergrid, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExec ["AE3_filesystem_fnc_device_addFile", 2];

[format [localize "STR_ROOT_CYBERWARFARE_ZEUS_HACKING_TOOLS_ADDED", _result]] remoteExec ["systemChat", _execUserId];
