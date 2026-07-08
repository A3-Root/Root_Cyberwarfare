#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Root-owned crypto command for encrypting and decrypting text with Root cipher
 *              algorithms. Reads from files when the input matches a filesystem path.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Computer object
 * 1: _options <ARRAY> - Command options and input
 * 2: _commandName <STRING> - Command name
 *
 * Return Value:
 * None
 *
 * Public: Yes
 */

params ["_computer", "_options", ["_commandName", "crypto"]];

private _stdout = { params ["_message"]; [_computer, _message] call AE3_armaos_fnc_shell_stdout; };

if ((count _options > 0) && {(_options select 0) in ["-h", "--help", "help"]}) exitWith {
    ["Crypto - encrypt or decrypt text with Root Cyberwarfare ciphers."] call _stdout;
    ["Usage: crypto -m=<encrypt|decrypt> -a=<algorithm> [options] [-o=<output>] <input|file>"] call _stdout;
    ["Algorithms: morse, spelling, affine, rot, vigenere, bacon, alpha_sub, railfence, base32, base64, ascii85, unicode, integer."] call _stdout;
    ["Options: -k=<key>, --variant=<variant>, --a=<num>, --b=<num>, --rails=<num>, --radix=<2|8|10|16>, --width=<8|16|32>, --signed=1."] call _stdout;
    ["Examples: crypto -m=encrypt -a=morse ""THE"", crypto -m=decrypt -a=rot --variant=rot13 ""GUR"", crypto -m=encrypt -a=vigenere -k=LEMON message.txt"] call _stdout;
};

private _mode = "encrypt";
private _algorithm = "morse";
private _output = "";
private _input = [];
private _cipherOptions = createHashMap;

{
    private _part = _x;
    if (_part select [0, 1] isEqualTo "-") then {
        private _eq = _part find "=";
        private _name = if (_eq >= 0) then {_part select [0, _eq]} else {_part};
        private _value = if (_eq >= 0) then {_part select [_eq + 1]} else {"1"};
        if (_name in ["-m", "--mode"]) then {
            _mode = toLower _value;
        } else {
            if (_name in ["-a", "--algorithm"]) then {
                _algorithm = toLower _value;
            } else {
                if (_name in ["-k", "--key"]) then {
                    _cipherOptions set ["key", _value];
                } else {
                    if (_name in ["-o", "--output"]) then {
                        _output = _value;
                    } else {
                        switch (_name) do {
                            case "--variant": { _cipherOptions set ["variant", toLower _value]; };
                            case "--a": { _cipherOptions set ["a", parseNumber _value]; };
                            case "--b": { _cipherOptions set ["b", parseNumber _value]; };
                            case "--rails": { _cipherOptions set ["rails", parseNumber _value]; };
                            case "--alphabet": { _cipherOptions set ["alphabet", _value]; };
                            case "--radix": { _cipherOptions set ["radix", parseNumber _value]; };
                            case "--width": { _cipherOptions set ["width", parseNumber _value]; };
                            case "--signed": { _cipherOptions set ["signed", _value in ["1", "true", "yes"]]; };
                            default { _input pushBack _part; };
                        };
                    };
                };
            };
        };
    } else {
        _input pushBack _part;
    };
} forEach _options;

if !(_mode in ["encrypt", "decrypt"]) exitWith { ["Error: -m must be encrypt or decrypt."] call _stdout; };
if (_input isEqualTo []) exitWith { [format ["Error: %1 requires input text or a file path.", _commandName]] call _stdout; };

private _inputRaw = _input joinString " ";
private _message = _inputRaw;
private _pointer = _computer getVariable ["AE3_filepointer", []];
private _filesystem = _computer getVariable ["AE3_filesystem", []];
private _terminal = _computer getVariable ["AE3_terminal", createHashMap];
private _username = _terminal getOrDefault ["AE3_terminalLoginUser", "root"];

try {
    private _fileContent = [_pointer, _filesystem, _inputRaw, _username, 0] call AE3_filesystem_fnc_getFile;
    if (_fileContent isEqualType "") then { _message = _fileContent; };
} catch {};

private _result = [_algorithm, _mode, _message, _cipherOptions] call FUNC(cipherProcess);
if !(_result isEqualType "") exitWith { ["Error: crypto produced an invalid result."] call _stdout; };

if (_output isNotEqualTo "") exitWith {
    try {
        try {
            [_pointer, _filesystem, _output, "", _username, _username, [[true, true, false], [true, true, false]]] call AE3_filesystem_fnc_createFile;
        } catch {};
        [_pointer, _filesystem, _output, _username, _result, false] call AE3_filesystem_fnc_writeToFile;
        [format ["Results written to %1", _output]] call _stdout;
    } catch {
        [_exception] call _stdout;
    };
};

[_result] call _stdout;
