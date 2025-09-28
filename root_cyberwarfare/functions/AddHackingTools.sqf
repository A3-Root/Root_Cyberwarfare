private ["_logic"];

waitUntil {time > 0};

private _string = "";

if (isNil "ROOT_customLaptopNameIndex") then { ROOT_customLaptopNameIndex = 1 };


private _module = _this select 0;
_syncedObjects = synchronizedObjects _module;

{

    if(typeOf _x in ["Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_Laptop_03_black_F_AE3"]) then {

        private _computerNetIdString = str (netId _x);

        _x setVariable ["ROOT_HackingTools", true, true];

        ROOT_customLaptopName = format ["HackingPlatform_%1", ROOT_customLaptopNameIndex];
        ROOT_customLaptopNameIndex = ROOT_customLaptopNameIndex + 1;

        _x setVariable ["ROOT_CustomName", ROOT_customLaptopName, true];

        private ["_content"];

        _content = "
            Table of content:

            Type 'devices' to list all devices you can hack into.
                    .
            Type 'door DoorID (ID or 'a' for all) lock/unlock' to lock/unlock doors. Ex: 'door 2881 lock' or 'door a unlock'
                    .
            Type 'light LightID (ID or 'a' for all) off/on' to turn lights off or on. Ex: 'light a on' or 'light 3 off'
                    .
            Type 'changedrone DroneID (ID or 'a' for all) side (west/east/guer/civ)' to switch the side of a drone. Ex: 'changedrone 2 east'
                    .
            Type 'disabledrone 'DroneID (ID or 'a' for all)' to disable (explode) the drones. Ex: 'disabledrone 2' or 'disabledrone a'
                    .
            Type 'download FileID' to download the File into the 'Downloads' folder. Ex: 'download 1234'
                    .
            Type 'custom customName activate/deactivate to activate or deactivate a custom device. Ex: 'custom myCustomDevice activate'
        ";

        [_x, "/rubberducky/tools/guide", _content, false, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


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
            [_owner, _computer, _nameOfVariable, _commandName] remoteExec ['Root_fnc_ListDevicesInSubnet', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, "/rubberducky/tools/devices", _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


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
            [_owner, _computer, _nameOfVariable, _buildingId, _doorId, _desiredState, _commandName] remoteExec ['Root_fnc_ChangeDoorState', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, "/rubberducky/tools/door", _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


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
            [_owner, _computer, _nameOfVariable, _lightId, _desiredState, _commandName] remoteExec ['Root_fnc_ChangeLightState', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, "/rubberducky/tools/light", _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


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
            [_owner, _computer, _nameOfVariable, _droneId, _commandName] remoteExec ['Root_fnc_DisableDrone', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, "/rubberducky/tools/disabledrone", _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


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
            [_owner, _computer, _nameOfVariable, _droneId, _desiredState, _commandName] remoteExec ['Root_fnc_ChangeDroneFaction', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, "/rubberducky/tools/changedrone", _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


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
            [_owner, _computer, _nameOfVariable, _databaseId, _commandName] remoteExec ['Root_fnc_DownloadDatabase', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, "/rubberducky/tools/download", _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;


        _content = "
            params['_computer', '_options', '_commandName'];

            private _commandOpts = [];
            private _commandSyntax =
            [
                [
                    ['command', _commandName, true, false],
                    ['path', 'customName', true, false],
                    ['path', 'customState', true, false]
                ]
            ];
            private _commandSettings = [_commandName, _commandOpts, _commandSyntax];

            [] params ([_computer, _options, _commandSettings] call AE3_armaos_fnc_shell_getOpts);

            if (!_ae3OptsSuccess) exitWith {};

            private _customName = (_ae3OptsThings select 0);
            private _customState = (_ae3OptsThings select 1);

            private _owner = clientOwner;

            private _nameOfVariable = 'ROOT-Custom-Device-' + "+ _computerNetIdString +";

            missionNamespace setVariable [_nameOfVariable, false, true];
            [_owner, _computer, _nameOfVariable, _customName, _customState, _commandName] remoteExec ['Root_fnc_CustomDevice', _owner];
            private _tStart = time;
            waitUntil { missionNamespace getVariable [_nameOfVariable, false] || ((time - _tStart) > 10) };
            if (!(missionNamespace getVariable [_nameOfVariable, false])) then {
                [_computer, 'Operation timed out!'] call AE3_armaos_fnc_shell_stdout;
            };
        ";
        [_x, "/rubberducky/tools/custom", _content, true, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] call AE3_filesystem_fnc_device_addFile;

    };
} forEach _syncedObjects;