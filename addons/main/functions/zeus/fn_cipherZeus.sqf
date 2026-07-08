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
    ["morse", "Morse Code"],
    ["spelling", "Spelling Alphabet"],
    ["affine", "Affine"],
    ["rot", "ROT"],
    ["vigenere", "Vigenere"],
    ["bacon", "Bacon"],
    ["alpha_sub", "Alphabetical Substitution"],
    ["railfence", "Railfence"],
    ["base32", "Base32"],
    ["base64", "Base64"],
    ["ascii85", "Ascii85"],
    ["unicode", "Unicode Notation"],
    ["integer", "Integer"]
];

private _algorithmIds = _algorithms apply {_x select 0};
private _algorithmLabels = _algorithms apply {_x select 1};

[
    "Cipher Tools",
    [
        ["COMBO", ["Mode", "Encrypt/decrypt text or analyze cipher text."], [["encrypt", "decrypt", "bruteforce"], ["Encrypt", "Decrypt", "Bruteforce / Analyse"], 0]],
        ["COMBO", ["Algorithm", "Cipher algorithm to use."], [_algorithmIds, _algorithmLabels, 0]],
        ["EDIT:MULTI", ["Input", "Text to process."], ["", {}, 7]],
        ["EDIT", ["Key / Variant", "Primary key, password, keyword, or variant. Examples: rot13, LEMON, 3"], [""]],
        ["EDIT", ["Options", "Optional key=value pairs. Examples: a=5 b=8, rails=3, radix=16 width=8 signed=0, alphabet=ZYXWVUTSRQPONMLKJIHGFEDCBA"], [""]],
        ["EDIT", ["Write Result Path", "Optional path on the attached AE3 device. Leave empty to show the result only."], [""]]
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
            ["Attach this module to an AE3 device to write the result to a file."] call zen_common_fnc_showMessage;
        };

        [
            {
                params ["_entity", "_outputPath", "_text", "_owner"];
                private _filesystem = _entity getVariable ["AE3_filesystem", []];
                if (_filesystem isEqualTo []) exitWith {
                    ["Cipher result write failed: filesystem is not initialized."] remoteExecCall ["systemChat", _owner];
                };

                try {
                    private _parts = _outputPath splitString "/";
                    _parts deleteAt ((count _parts) - 1);
                    private _dir = "/" + (_parts joinString "/");
                    if (_dir != "/") then { [[], _filesystem, _dir, "root", "root", [[true, true, true], [true, false, true]]] call AE3_filesystem_fnc_ensureDir; };
                    [[], _filesystem, _outputPath, "", "root", "root", [[true, true, true], [true, false, false]]] call AE3_filesystem_fnc_ensureFile;
                    [[], _filesystem, _outputPath, "root", _text, false] call AE3_filesystem_fnc_writeToFile;
                    _entity setVariable ["AE3_filesystem", _filesystem, true];
                    [format ["Cipher result written to %1", _outputPath]] remoteExecCall ["systemChat", _owner];
                } catch {
                    [format ["Cipher result write failed: %1", _exception]] remoteExecCall ["systemChat", _owner];
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
