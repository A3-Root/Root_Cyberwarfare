#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Zeus module dialog for processing text with Root cipher algorithms and optionally
 *              writing the result to the attached AE3 device filesystem.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Zeus logic module
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic"];

if !(hasInterface) exitWith {};

private _entity = attachedTo _logic;
deleteVehicle _logic;

private _algorithms = [
    ["morse", (localize "STR_ROOT_CYBERWARFARE_UI_MORSE_CODE")],
    ["spelling", (localize "STR_ROOT_CYBERWARFARE_UI_SPELLING_ALPHABET")],
    ["affine", (localize "STR_ROOT_CYBERWARFARE_UI_AFFINE")],
    ["rot", "ROT"],
    ["vigenere", (localize "STR_ROOT_CYBERWARFARE_UI_VIGENERE")],
    ["bacon", (localize "STR_ROOT_CYBERWARFARE_UI_BACON")],
    ["alpha_sub", (localize "STR_ROOT_CYBERWARFARE_UI_ALPHABETICAL_SUBSTITUTION")],
    ["railfence", (localize "STR_ROOT_CYBERWARFARE_UI_RAILFENCE")],
    ["base32", "Base32"],
    ["base64", "Base64"],
    ["ascii85", "Ascii85"],
    ["unicode", (localize "STR_ROOT_CYBERWARFARE_UI_UNICODE_NOTATION")],
    ["integer", (localize "STR_ROOT_CYBERWARFARE_UI_INTEGER")]
];

private _algorithmIds = _algorithms apply {_x select 0};
private _algorithmLabels = _algorithms apply {_x select 1};

[
    (localize "STR_ROOT_CYBERWARFARE_UI_CIPHER_TOOLS"),
    [
        ["COMBO", [(localize "STR_ROOT_CYBERWARFARE_UI_MODE"), (localize "STR_ROOT_CYBERWARFARE_UI_ENCRYPT_DECRYPT_TEXT_OR_ANALYZE_CIPHER_TEXT")], [["encrypt", "decrypt", "bruteforce"], [(localize "STR_ROOT_CYBERWARFARE_UI_ENCRYPT"), (localize "STR_ROOT_CYBERWARFARE_UI_DECRYPT"), (localize "STR_ROOT_CYBERWARFARE_UI_BRUTEFORCE_ANALYSE")], 0]],
        ["COMBO", [(localize "STR_ROOT_CYBERWARFARE_UI_ALGORITHM"), (localize "STR_ROOT_CYBERWARFARE_UI_CIPHER_ALGORITHM_TO_USE")], [_algorithmIds, _algorithmLabels, 0]],
        ["EDIT:MULTI", [(localize "STR_ROOT_CYBERWARFARE_UI_INPUT"), (localize "STR_ROOT_CYBERWARFARE_UI_TEXT_TO_PROCESS")], ["", {}, 7]],
        ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_KEY_VARIANT"), (localize "STR_ROOT_CYBERWARFARE_UI_PRIMARY_KEY_PASSWORD_KEYWORD_OR_VARIANT_EXAMPLES_ROT13_LEMON_3")], [""]],
        ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_OPTIONS"), (localize "STR_ROOT_CYBERWARFARE_UI_OPTIONAL_KEY_VALUE_PAIRS_EXAMPLES_A_5_B_8_RAILS_3_RADIX_2")], [""]],
        ["EDIT", [(localize "STR_ROOT_CYBERWARFARE_UI_WRITE_RESULT_PATH"), (localize "STR_ROOT_CYBERWARFARE_UI_OPTIONAL_PATH_ON_THE_ATTACHED_AE3_DEVICE_LEAVE_EMPTY_TO_SHOW_THE")], [""]]
    ],
    {
        params ["_results", "_args"];
        _results params ["_mode", "_algorithm", "_input", "_key", "_optionText", "_outputPath"];
        _args params ["_entity"];

        private _options = [_key, _optionText] call FUNC(cipherOptionsFromText);
        private _result = [_algorithm, _mode, _input, _options] call FUNC(cipherProcess);
        private _text = if (_result isEqualType []) then {_result joinString endl} else {_result};

        if (_outputPath isEqualTo "") exitWith {
            private _preview = _text;
            if ((count _preview) > 900) then { _preview = (_preview select [0, 900]) + endl + "..."; };
            [_preview] call zen_common_fnc_showMessage;
        };

        if (isNull _entity || {isNil {_entity getVariable "AE3_filesystem"}}) exitWith {
            [(localize "STR_ROOT_CYBERWARFARE_UI_ATTACH_THIS_MODULE_TO_AN_AE3_DEVICE_TO_WRITE_THE_RESULT_TO")] call zen_common_fnc_showMessage;
        };

        [
            {
                params ["_entity", "_outputPath", "_text", "_owner"];
                private _filesystem = _entity getVariable ["AE3_filesystem", []];
                if (_filesystem isEqualTo []) exitWith {
                    [(localize "STR_ROOT_CYBERWARFARE_UI_CIPHER_RESULT_WRITE_FAILED_FILESYSTEM_IS_NOT_INITIALIZED")] remoteExecCall ["systemChat", _owner];
                };

                try {
                    private _parts = _outputPath splitString "/";
                    _parts deleteAt ((count _parts) - 1);
                    private _dir = "/" + (_parts joinString "/");
                    if (_dir != "/") then { [[], _filesystem, _dir, "root", "root", [[true, true, true], [true, false, true]]] call AE3_filesystem_fnc_ensureDir; };
                    [[], _filesystem, _outputPath, "", "root", "root", [[true, true, true], [true, false, false]]] call AE3_filesystem_fnc_ensureFile;
                    [[], _filesystem, _outputPath, "root", _text, false] call AE3_filesystem_fnc_writeToFile;
                    _entity setVariable ["AE3_filesystem", _filesystem, true];
                    [format [(localize "STR_ROOT_CYBERWARFARE_UI_CIPHER_RESULT_WRITTEN_TO_1"), _outputPath]] remoteExecCall ["systemChat", _owner];
                } catch {
                    [format [(localize "STR_ROOT_CYBERWARFARE_UI_CIPHER_RESULT_WRITE_FAILED_1"), _exception]] remoteExecCall ["systemChat", _owner];
                };
            },
            [_entity, _outputPath, _text, clientOwner]
        ] remoteExecCall ["call", 2];
    },
    {
        [localize "STR_ROOT_CYBERWARFARE_ZEUS_ABORTED"] call zen_common_fnc_showMessage;
    },
    [_entity]
] call zen_dialog_fnc_create;
