#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Zeus module to add a hackable database/file
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_addDatabaseZeus;
 *
 * Public: No
 */

params ["_logic"];

if !(hasInterface) exitWith {};

private _rootcwdatabaseFileObject = "Land_HelipadEmpty_F" createVehicle getPosATL _logic;
deleteVehicle _logic;

// Every laptop the file can be linked to. Without one the dialog still works, but only the Unassigned
// and Public access modes can do anything, so the curator is told before spending time on the form.
private _allComputers = call FUNC(getRegisteredLaptops);
if (_allComputers isEqualTo []) then {
    [localize "STR_ROOT_CYBERWARFARE_ZEUS_NO_LAPTOPS_WARN"] call zen_common_fnc_showMessage;
};

private _dialogControls = [
    ["EDIT", ["File Name", "Name of the File"], ["My Other Projects"]],
    ["SLIDER", ["File Hack Time (in seconds)", "Time taken to hack and download the file (in seconds)"], [1, 300, 10, 0]],
    ["EDIT:MULTI", ["File Contents", "Content of the file that could be read after downloading via the command 'cat <filename>"], ["Check out my other projects that could interest you here: https://github.com/A3-Root/", {}, 7]],
    ["EDIT:CODE", ["Code to Execute on Download", "Code that will be executed in a SCHEDULED environment (spawn) when file is successfully downloaded. The code is run on the player who downloaded the file. Default parameters ['_computer', '_playerNetID']"], ["hint str format ['File Downloaded ON: %1 ---- BY %2 (Client ID: %3)', getText (configOf (_this select 0) >> 'displayName'), name (_this select 1), _this select 2];", {}, 7]],
    ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
        [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
        [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"],
        0
    ]],
    ["TOOLBOX:ENABLED", ["Available to Future Laptops", "Only applies to 'Linked computers only': the linked computers keep access and laptops added later gain it too."], false],
    ["CHECKBOX", ["Encrypt File Contents", "Encrypt the stored file contents before it is added to the hackable file list."], false],
    ["COMBO", ["Encryption Algorithm", "Cipher used when encryption is enabled."], [["morse", "spelling", "affine", "rot", "vigenere", "bacon", "alpha_sub", "railfence", "base32", "base64", "ascii85", "unicode", "integer"], ["Morse Code", "Spelling Alphabet", "Affine", "ROT", "Vigenere", "Bacon", "Alphabetical Substitution", "Railfence", "Base32", "Base64", "Ascii85", "Unicode Notation", "Integer"], 0]],
    ["EDIT", ["Key / Variant", "Primary key, password, keyword, or variant. Examples: rot13, LEMON, 3"], [""]],
    ["EDIT", ["Encryption Options", "Optional key=value pairs. Examples: a=5 b=8, rails=3, radix=16 width=8 signed=0"], [""]],
    ["EDIT", ["Device ID (0 = auto)", "Fixed ID for this file. 0 = auto-assign a free ID."], ["0"]]
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
        
        // Dialog values before the per-computer link checkboxes.
        _results params ["_filename", "_filesize", "_filecontent", "_executionCode", "_accessMode", "_availableToFutureLaptops", "_isEncrypted", "_encryptionAlgorithm", "_encryptionKey", "_encryptionOptions", "_requestedIdText"];
        private _requestedId = parseNumber _requestedIdText;

        // The rest are checkbox values for each computer
        private _linkedComputers = [];
        private _checkboxStartIndex = 11;

        {
            if (_results select (_checkboxStartIndex + _forEachIndex)) then {
                _linkedComputers pushBack (_x select 0); // Push the netId
            };
        } forEach _allComputers;

        if (_filesize < 1) then {_filesize = 1};

        private _execUserId = clientOwner;
        [_fileObject, _filename, _filesize, _filecontent, _execUserId, _linkedComputers, _executionCode, _availableToFutureLaptops, _isEncrypted, _encryptionAlgorithm, _encryptionKey, _encryptionOptions, _requestedId, _accessMode] remoteExec ["Root_fnc_addDatabaseZeusMain", 2];
        ["Hackable File Added!"] call zen_common_fnc_showMessage;
    },  
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_rootcwdatabaseFileObject, _allComputers]
] call zen_dialog_fnc_create;
