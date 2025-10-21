#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Downloads a database file to the computer's filesystem
 *
 * Arguments:
 * 0: _owner <ANY> - Owner parameter (legacy compatibility)
 * 1: _computer <OBJECT> - The laptop/computer object
 * 2: _nameOfVariable <STRING> - Variable name for completion flag
 * 3: _databaseId <STRING> - Database ID to download
 * 4: _commandPath <STRING> - Command path for access checking
 *
 * Return Value:
 * None
 *
 * Example:
 * [nil, _laptop, "var1", "1234", "/tools/"] call Root_fnc_downloadDatabase;
 *
 * Public: No
 */

params['_owner', '_computer', '_nameOfVariable', '_databaseId', "_commandPath"];

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
            private _databaseSize = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_SIZE_EDIT", ""];
            private _databaseContent = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_DATA_EDIT", ""];
            private _executionCode = _database getVariable ["ROOT_CYBERWARFARE_DATABASE_EXECUTIONCODE", ""];
            private _paddingZeroes = "0000000000";
            private _formatTotalLength = 3;
            private _loadingBar1 = "#";
            private _loadingBar2 = ".";
            private _loadingBarLength = 25;
            
            for "_i" from 1 to _databaseSize do {
                private _percentage = ceil((100/ _databaseSize) * _i);
                private _formattedStringOfPercentage =  (_paddingZeroes select [0, (_formatTotalLength - (count (str _percentage)))]) + (str _percentage);
                private _filledCount = round (_loadingBarLength/100*_percentage);
                private _emptyCount = _loadingBarLength - _filledCount;
                private _filledPart = "";
                private _emptyPart = "";
                
                for "_i" from 1 to _filledCount do {
                    _filledPart = _filledPart + _loadingBar1;
                };
                for "_i" from 1 to _emptyCount do {
                    _emptyPart = _emptyPart + _loadingBar2;
                };
                
                private _loadingBar = _filledPart + _emptyPart;
                _string = format ['Downloading File: %1%%. [%2]', _formattedStringOfPercentage, _loadingBar];
                [_computer, _string] call AE3_armaos_fnc_shell_stdout;
                uiSleep 1;
            };
            
            private _fileName = (_databaseName splitString " ") joinString "_";
            private _newDirectory = (_pointer joinString "/") + format["/Files/%1.txt", _fileName];
            _string = format ["File saved to: '%1'", _newDirectory];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            [_computer, _newDirectory, _databaseContent, false, "root", [[true, true, true], [true, true, true]], false, "caesar", "1"] remoteExecCall ["AE3_filesystem_fnc_device_addFile", 2];
            _string = format ["Exit the terminal and re-open to see the 'Files' directory updated with the new file."];
            [_computer, _string] call AE3_armaos_fnc_shell_stdout;
            // Execute the custom code after successful download
            if (_executionCode != "") then {
                [_computer, _owner] spawn (compile _executionCode);
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

scopeName "exit";
missionNamespace setVariable [_nameOfVariable, true, true];
