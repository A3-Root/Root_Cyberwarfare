#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Downloads a database file to the computer's filesystem
 *
 * Arguments:
 * 0: _owner <NUMBER> - Machine ID (ownerID) of the client executing this command
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _databaseId <STRING> - Database ID to download
 * 4: _playerObject <OBJECT> - Object of the _owner
 * 5: _commandPath <STRING> - Command path for access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [123, _laptop, "var1", "1234", User1, "/tools/"] call Root_fnc_downloadDatabase;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_databaseId', '_playerObject', "_commandPath"];

scopeName "exit";

// Check for help request
if (_databaseId in ["-h", "help"]) exitWith {
    [_computer, [[["DOWNLOAD COMMAND HELP", "#8ce10b"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Description:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Download files from accessible database servers to your computer."]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Syntax:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["download <DatabaseID>"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Parameters:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  ", ""], ["DatabaseID", "#008DF8"], ["  - ID of the database to download", ""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Examples:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["  download 1234   - Download database file #1234"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[[""]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["Note:", "#FFD966"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Download time depends on file size"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Files are saved to /Files/ directory"]]]] call AE3_armaos_fnc_shell_stdout;
    [_computer, [[["- Some files may trigger automatic execution after download"]]]] call AE3_armaos_fnc_shell_stdout;
    missionNamespace setVariable [_nameOfVariable, true, true];
};

private _string = "";
private _databaseIdNum = parseNumber _databaseId;

if (_databaseIdNum != 0) then {
    private _pointer = _computer getVariable "AE3_filepointer";
    private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", []];
    private _allDatabases = _allDevices select 3;

    // Filter databases to only those accessible by this computer
    private _accessibleDatabases = _allDatabases select { 
        [_computer, 4, _x select 0, _commandPath] call Root_fnc_isDeviceAccessible 
    };

    if (_accessibleDatabases isEqualTo []) then {
        _string = "Error! No accessible databases found or access denied.";
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
        missionNamespace setVariable [_nameOfVariable, true, true];
        breakTo "exit";
    };

    private _foundDatabase = false;
    
    {
        private _idOfDatabase = _x select 0;
        private _DatabaseNetId = _x select 1;
        
        if (_databaseIdNum == _idOfDatabase) then {
            _foundDatabase = true;
            private _database = objectFromNetId _DatabaseNetId;
            private _databaseName = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_NAME_EDIT", ""];
            // Speed follows the operator: inside SSH the computer the session was opened from.
            ([_database, [_computer] call FUNC(getPowerComputer)] call FUNC(getDatabaseTransfer)) params ["_downloadTime", "_virtualBytes"];
            private _databaseContent = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_DATA_EDIT", ""];
            private _executionCode = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_EXECUTIONCODE", ""];
            private _loadingBarLength = 25;

            if (_virtualBytes >= 0) then {
                [_computer, format ["File size: %1", [_virtualBytes] call AE3_filesystem_fnc_formatSize]] call AE3_armaos_fnc_shell_stdout;
            };

            // Progress is reported on a time basis (about 50 updates however long the transfer takes).
            // Ctrl+C terminates the command and with it the download.
            private _start = CBA_missionTime;
            private _step = 1 max (_downloadTime / 50);
            while {(CBA_missionTime - _start) < _downloadTime} do {
                private _percentage = floor ((((CBA_missionTime - _start) / _downloadTime) * 100) min 100);
                private _filledCount = round (_loadingBarLength / 100 * _percentage);
                private _loadingBar = "";
                for "_c" from 1 to _loadingBarLength do {
                    _loadingBar = _loadingBar + (["." , "#"] select (_c <= _filledCount));
                };
                _string = format ['Downloading File: %1%%. [%2]', _percentage, _loadingBar];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                uiSleep _step;
            };

            private _fileName = (_databaseName splitString " ") joinString "_";
            private _newDirectory = "/" + (_pointer joinString "/") + format["/Files/%1.txt", _fileName];
            _newDirectory = _newDirectory regexReplace ["/+", "/"];
            _string = format ["File saved to: '%1'", _newDirectory];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            // Written to the authoritative filesystem copy, so the file shows up immediately in an open
            // terminal, desktop or SSH session and survives the session ending.
            [_computer, _newDirectory, _databaseContent, false, true, "root", [[true, true, true], [true, true, true]], _virtualBytes] call AE3_filesystem_fnc_device_writeFile;
            // Execute the custom code after successful download
            if (_executionCode != "") then {
                [_computer, _playerObject, _owner] spawn (compile _executionCode);
            };
        };
    } forEach _accessibleDatabases;
    
    if (!_foundDatabase) then {
        _string = format ["Error! Database ID %1 not found or access denied.", _databaseIdNum];
        [_computer, _string] call AE3_armaos_fnc_shell_stdout;
    };
};

if (_databaseIdNum == 0) then {
    _string = format ["Error! Invalid DatabaseID - %1.", _databaseId];
    [_computer, _string] call AE3_armaos_fnc_shell_stdout;
};

missionNamespace setVariable [_nameOfVariable, true, true];
