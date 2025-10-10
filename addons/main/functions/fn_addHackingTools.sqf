private ["_logic"];

waitUntil {time > 0};

private _string = "";

if (isNil "ROOT_CYBERWARFARE_HACK_TOOL_INDEX") then { ROOT_CYBERWARFARE_HACK_TOOL_INDEX = 1 };


private _module = _this select 0;
_syncedObjects = synchronizedObjects _module;
private _path = _module getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_LOCATION_EDIT", "/rubberducky/tools"];
private _backdoor = _module getVariable ["ROOT_CYBERWARFARE_HACK_TOOL_BACKDOOR_EDIT", ""];
private _currentBackdoorPaths = _module getVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", []];


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

if (_backdoor != "") then {
    _currentBackdoorPaths pushBackUnique (_backdoor + "guide");
    _currentBackdoorPaths pushBackUnique (_backdoor + "devices");
    _currentBackdoorPaths pushBackUnique (_backdoor + "door");
    _currentBackdoorPaths pushBackUnique (_backdoor + "light");
    _currentBackdoorPaths pushBackUnique (_backdoor + "changedrone");
    _currentBackdoorPaths pushBackUnique (_backdoor + "disabledrone");
    _currentBackdoorPaths pushBackUnique (_backdoor + "download");
    _currentBackdoorPaths pushBackUnique (_backdoor + "custom");
    _result = _result + "/" + _backdoor;
    _guide = _result + "guide";
    _devices = _result + "devices";
    _door = _result + "door";
    _light = _result + "light";
    _changedrone = _result + "changedrone";
    _disabledrone = _result + "disabledrone";
    _download = _result + "download";
    _custom = _result + "custom";
} else {
    _guide = _result + "/guide";
    _devices = _result + "/devices";
    _door = _result + "/door";
    _light = _result + "/light";
    _changedrone = _result + "/changedrone";
    _disabledrone = _result + "/disabledrone";
    _download = _result + "/download";
    _custom = _result + "/custom";
};




{
    if(typeOf _x in ["Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_Laptop_03_black_F_AE3"]) then {
        if (_backdoor != "") then {
            _x setVariable ["ROOT_CYBERWARFARE_BACKDOOR_FUNCTION", _currentBackdoorPaths, true];
        } else {
            _x setVariable ["ROOT_CYBERWARFARE_HACKINGTOOLS_INSTALLED", true, true];
        };
        private _computerNetIdString = str (netId _x);
        _content = "
            Type 'devices' to list all devices you can hack into.
                    .
            Type 'door BuildingID DoorID (ID or 'a' for all) lock/unlock' to lock/unlock doors. Ex: 'door 1544 2881 lock' or 'door 1544 a unlock'
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
        ";
        [_x, _guide, _content, false, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

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
            private _nameOfVariable = 'ROOT_CYBERWARFARE_LIST_DEVICES-' + "+ _computerNetIdString +";
            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _commandName] remoteExec ['Root_fnc_listDevicesInSubnet', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, _devices, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

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
            private _nameOfVariable = 'ROOT_CYBERWARFARE_DOOR-' + "+ _computerNetIdString +";
            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _buildingId, _doorId, _desiredState, _commandName] remoteExec ['Root_fnc_changeDoorState', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, _door, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


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
            private _nameOfVariable = 'ROOT_CYBERWARFARE_LIGHT-' + "+ _computerNetIdString +";
            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _lightId, _desiredState, _commandName] remoteExec ['Root_fnc_changeLightState', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, _light, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

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
            private _nameOfVariable = 'ROOT_CYBERWARFARE_DISABLE_DRONE>-' + "+ _computerNetIdString +";
            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _droneId, _commandName] remoteExec ['Root_fnc_disableDrone', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, _disabledrone, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

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
            private _nameOfVariable = 'ROOT_CYBERWARFARE_CHANGE_DRONE-' + "+ _computerNetIdString +";
            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _droneId, _desiredState, _commandName] remoteExec ['Root_fnc_changeDroneFaction', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, _changedrone, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

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
            private _nameOfVariable = 'ROOT_CYBERWARFARE_DOWNLOAD_DATABASE-' + "+ _computerNetIdString +";
            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _databaseId, _commandName] remoteExec ['Root_fnc_downloadDatabase', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, _download, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

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
            private _nameOfVariable = 'ROOT_CYBERWARFARE_CUSTOM_DEVICE-' + "+ _computerNetIdString +";
            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _customId, _customState, _commandName] remoteExec ['Root_fnc_customDevice', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, _custom, _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

    };
} forEach _syncedObjects;
