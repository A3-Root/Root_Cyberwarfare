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
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_FILE_NAME"), (localize "STR_ROOT_CYBERWARFARE_UI_NAME_OF_THE_FILE")], ["My Other Projects"]],
    ["SLIDER", [(localize "STR_ROOT_CYBERWARFARE_UI_FILE_HACK_TIME_IN_SECONDS"), (localize "STR_ROOT_CYBERWARFARE_UI_TIME_TAKEN_TO_HACK_AND_DOWNLOAD_THE_FILE_IN_SECONDS")], [1, 300, 10, 0]],
    ["EDIT:MULTI", [(localize "STR_ROOT_CYBERWARFARE_UI_FILE_CONTENTS"), (localize "STR_ROOT_CYBERWARFARE_UI_CONTENT_OF_THE_FILE_THAT_COULD_BE_READ_AFTER_DOWNLOADING_VIA_THE")], ["Check out my other projects that could interest you here: https://github.com/A3-Root/", {}, 7]],
    ["EDIT:CODE", [(localize "STR_ROOT_CYBERWARFARE_UI_CODE_TO_EXECUTE_ON_DOWNLOAD"), (localize "STR_ROOT_CYBERWARFARE_UI_CODE_THAT_WILL_BE_EXECUTED_IN_A_SCHEDULED_ENVIRONMENT_SPAWN_WHEN_FILE")], ["hint str format ['File Downloaded ON: %1 ---- BY %2 (Client ID: %3)', getText (configOf (_this select 0) >> 'displayName'), name (_this select 1), _this select 2];", {}, 7]],
    ["COMBO", [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_DESC"], [
        [ACCESS_MODE_UNASSIGNED, ACCESS_MODE_LINKED, ACCESS_MODE_PUBLIC],
        [localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_UNASSIGNED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_LINKED", localize "STR_ROOT_CYBERWARFARE_ACCESS_MODE_PUBLIC"],
        0
    ]],
    ["TOOLBOX:ENABLED", [(localize "STR_ROOT_CYBERWARFARE_ACCESS_FUTURE"), (localize "STR_ROOT_CYBERWARFARE_UI_ONLY_APPLIES_TO_LINKED_COMPUTERS_ONLY_THE_LINKED_COMPUTERS_KEEP_ACCESS_AND")], false],
    ["CHECKBOX", [(localize "STR_ROOT_CYBERWARFARE_UI_ENCRYPT_FILE_CONTENTS"), (localize "STR_ROOT_CYBERWARFARE_UI_ENCRYPT_THE_STORED_FILE_CONTENTS_BEFORE_IT_IS_ADDED_TO_THE_HACKABLE")], false],
    ["COMBO", [(localize "STR_ROOT_CYBERWARFARE_UI_ENCRYPTION_ALGORITHM"), (localize "STR_ROOT_CYBERWARFARE_UI_CIPHER_USED_WHEN_ENCRYPTION_IS_ENABLED_2")], [["morse", "spelling", "affine", "rot", "vigenere", "bacon", "alpha_sub", "railfence", "base32", "base64", "ascii85", "unicode", "integer"], [(localize "STR_ROOT_CYBERWARFARE_UI_MORSE_CODE"), (localize "STR_ROOT_CYBERWARFARE_UI_SPELLING_ALPHABET"), (localize "STR_ROOT_CYBERWARFARE_UI_AFFINE"), "ROT", (localize "STR_ROOT_CYBERWARFARE_UI_VIGENERE"), (localize "STR_ROOT_CYBERWARFARE_UI_BACON"), (localize "STR_ROOT_CYBERWARFARE_UI_ALPHABETICAL_SUBSTITUTION"), (localize "STR_ROOT_CYBERWARFARE_UI_RAILFENCE"), "Base32", "Base64", "Ascii85", (localize "STR_ROOT_CYBERWARFARE_UI_UNICODE_NOTATION"), (localize "STR_ROOT_CYBERWARFARE_UI_INTEGER")], 0]],
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_KEY_VARIANT"), (localize "STR_ROOT_CYBERWARFARE_UI_PRIMARY_KEY_PASSWORD_KEYWORD_OR_VARIANT_EXAMPLES_ROT13_LEMON_3")], [""]],
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_ENCRYPTION_OPTIONS"), (localize "STR_ROOT_CYBERWARFARE_UI_OPTIONAL_KEY_VALUE_PAIRS_EXAMPLES_A_5_B_8_RAILS_3_RADIX")], [""]],
    ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_DEVICE_ID_0_AUTO"), (localize "STR_ROOT_CYBERWARFARE_UI_FIXED_ID_FOR_THIS_FILE_0_AUTO_ASSIGN_A_FREE_ID")], ["0"]]
];

{
    _x params ["_netId", "_computerName"];
    _dialogControls pushBack ["CHECKBOX", [_computerName, format [(localize "STR_ROOT_CYBERWARFARE_UI_LINK_FILE_TO_THIS_COMPUTER_FOR_DOWNLOAD")]], false];
} forEach _allComputers;

[
    (localize "STR_ROOT_CYBERWARFARE_UI_ADD_HACKABLE_FILE"),
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
        [(localize "STR_ROOT_CYBERWARFARE_UI_HACKABLE_FILE_ADDED")] call zen_common_fnc_showMessage;

        // Linked access with nothing ticked registers a file no laptop can reach, which the success
        // message above does not convey on its own.
        [_accessMode, _linkedComputers, _availableToFutureLaptops] call FUNC(warnUnreachableDevice);
    },  
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, 
    [_rootcwdatabaseFileObject, _allComputers]
] call zen_dialog_fnc_create;
