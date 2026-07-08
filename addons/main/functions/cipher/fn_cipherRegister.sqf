#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Registers Root-owned cipher algorithms with AE3 extension registries and the
 *              Root desktop app launcher.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _algorithms = [
    ["morse", "Morse Code", false],
    ["spelling", "Spelling Alphabet", false],
    ["affine", "Affine", true],
    ["rot", "ROT", false],
    ["vigenere", "Vigenere", true],
    ["bacon", "Bacon", false],
    ["alpha_sub", "Alphabetical Substitution", true],
    ["railfence", "Railfence", true],
    ["base32", "Base32", false],
    ["base64", "Base64", false],
    ["ascii85", "Ascii85", false],
    ["unicode", "Unicode Notation", false],
    ["integer", "Integer", false]
];

missionNamespace setVariable ["ROOT_CYBERWARFARE_CIPHER_ALGORITHMS", _algorithms];

private _ae3Algorithms = missionNamespace getVariable ["AE3_filesystem_encryptionAlgorithms", [["caesar", "Caesar", true], ["columnar", "Columnar", true]]];
{
    private _id = _x select 0;
    _ae3Algorithms = _ae3Algorithms select {(_x select 0) isNotEqualTo _id};
    _ae3Algorithms pushBack _x;
} forEach _algorithms;
missionNamespace setVariable ["AE3_filesystem_encryptionAlgorithms", _ae3Algorithms];

private _handlers = missionNamespace getVariable ["AE3_filesystem_encryptionHandlers", createHashMap];
{
    private _id = _x select 0;
    _handlers set [_id, {
        params ["_algorithm", "_mode", "_row", "_key"];
        private _options = createHashMapFromArray [["key", _key], ["variant", _key]];
        [_algorithm, _mode, _row, _options] call FUNC(cipherProcess)
    }];
} forEach _algorithms;
missionNamespace setVariable ["AE3_filesystem_encryptionHandlers", _handlers];

if (!hasInterface || {isNil "AE3_desktop_fnc_registerExtApp"}) exitWith {};

private _extra = createHashMapFromArray [
    ["menu", "Hacking Tools"],
    ["icon", "terminal"],
    ["scriptPath", "\z\root_cyberwarfare\addons\main\ui\web\js\cipherapps.js"],
    ["factory", "RootCW_makeCipherApp"],
    ["requiresFunction", "Root_fnc_hasHackingToolsAvailable"],
    ["width", 940],
    ["height", 620]
];

private _cryptoExtra = +_extra;
_cryptoExtra set ["mode", "crypto"];
["RootCW_Crypto", "Crypto", "C", "script", _cryptoExtra] call AE3_desktop_fnc_registerExtApp;

private _crackExtra = +_extra;
_crackExtra set ["mode", "crack"];
["RootCW_Crack", "Crack", "K", "script", _crackExtra] call AE3_desktop_fnc_registerExtApp;
