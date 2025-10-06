params ["_logic"];

if !(hasInterface) exitWith {};

_rootcwdatabaseFileObject = "Land_HelipadEmpty_F" createVehicle getPosATL _logic;
deleteVehicle _logic;

// Get all existing laptops with hacking tools
private _allComputers = [];
{
    if (_x getVariable ["ROOT_HackingTools", false]) then {
        private _computerName = _x getVariable ["ROOT_CustomName", ROOT_customLaptopName];
        private _netId = netId _x;
        private _position = getPosATL _x;
        private _gridPos = mapGridPosition _x;
        _allComputers pushBack [_netId, format ["%1 [Grid: %2]", _computerName, _gridPos]];
    };
} forEach (24 allObjects 1);

private _dialogControls = [
    ["EDIT", ["File Name", "Name of the File"], ["My Other Projects"]],
    ["SLIDER", ["File Hack Time (in seconds)", "Time taken to hack and download the file (in seconds)"], [0, 300, 10, 0]],
    ["EDIT:MULTI", ["File Contents", "Content of the file that could be read after downloading via the command 'cat <filename>"], ["Check out my other projects that could interest you here: https://github.com/A3-Root/", {}, 7]],
    ["EDIT:CODE", ["Code to Execute on Download", "Code that will be executed in a SCHEDULED environment (spawn) when file is successfully downloaded. Use (_this select 0) to reference the computer object."], ["// Example: Display Hint when triggered 
hint str format ['Code triggered'];", {}, 7]],
    ["TOOLBOX:ENABLED", ["Available to Future Laptops", "Should this database be available to laptops that are added later?"], false]
];

{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format ["Link File to this computer for download?"]], false];
} forEach _allComputers;

[
    "Add Hackable File", 
    _dialogControls,
    // Fix the dialog result handler section:
    {
        params ["_results", "_args"];
        _args params ["_fileObject", "_allComputers"];
        
        // First 5 results are the original controls + new code field + availability
        _results params ["_filename", "_filesize", "_filecontent", "_executionCode", "_availableToFutureLaptops"];
        
        // The rest are checkbox values for each computer
        private _linkedComputers = [];
        private _checkboxStartIndex = 5;
        
        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _linkedComputers pushBack (_x select 0); // Push the netId
            };
        } forEach _allComputers;

        // If available to future laptops, keep the selected computers but mark for future availability
        // If not available to future laptops and no computers selected, use all current computers
        if (!_availableToFutureLaptops && _linkedComputers isEqualTo []) then {
            _linkedComputers = _allComputers apply { _x select 0 };
        };
        
        private _allDevices = missionNamespace getVariable ["ROOT-All-Devices", [[], [], [], [], [], []]];
        private _allDoors = _allDevices select 0;
        private _allLamps = _allDevices select 1;
        private _allDrones = _allDevices select 2;
        private _allDatabases = _allDevices select 3;
        private _allCustom = _allDevices select 4;
        private _allGpsTrackers = _allDevices select 5;
        private _databaseId = 0;
        private _execUserId = clientOwner;
        [_allDatabases, _databaseId, _fileObject, _filename, _filesize, _filecontent, _allDevices, _allDoors, _allLamps, _allDrones, _allCustom, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
        ["Hackable File Added!"] call zen_common_fnc_showMessage;
    },  
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_rootcwdatabaseFileObject, _allComputers]
] call zen_dialog_fnc_create;
