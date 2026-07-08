#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Processes Root-owned classical ciphers for CLI commands, filesystem encryption,
 *              and desktop tools.
 *
 * Arguments:
 * 0: _algorithm <STRING> - Cipher id
 * 1: _mode <STRING> - encrypt, decrypt, or bruteforce
 * 2: _text <STRING> - Input text
 * 3: _options <HASHMAP> - Cipher options
 *
 * Return Value:
 * <STRING|ARRAY> Processed text or candidate lines
 *
 * Public: Yes
 */

params [["_algorithm", "", [""]], ["_mode", "encrypt", [""]], ["_text", "", [""]], ["_options", createHashMap, [createHashMap]]];

private _chars = { params ["_value"]; _value splitString "" };
private _mod = {
    params ["_value", "_base"];
    private _result = _value mod _base;
    if (_result < 0) then { _result + _base } else { _result };
};
private _gcd = {
    params ["_a", "_b"];
    _a = abs _a;
    _b = abs _b;
    while {_b != 0} do {
        private _next = _a mod _b;
        _a = _b;
        _b = _next;
    };
    _a
};
private _inverse = {
    params ["_a", "_base"];
    private _result = -1;
    for "_i" from 1 to (_base - 1) do {
        if (((_a * _i) mod _base) == 1) exitWith { _result = _i; };
    };
    _result
};
private _padLeft = {
    params ["_value", "_size", ["_pad", "0"]];
    while {count _value < _size} do { _value = _pad + _value; };
    _value
};
private _toBase = {
    params ["_value", "_base"];
    private _digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    if (_value == 0) exitWith {"0"};
    private _result = "";
    private _work = floor abs _value;
    while {_work > 0} do {
        private _digit = _work mod _base;
        _result = (_digits select [_digit, 1]) + _result;
        _work = floor (_work / _base);
    };
    _result
};
private _fromBase = {
    params ["_value", "_base"];
    private _digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private _result = 0;
    {
        private _digit = _digits find (toUpper _x);
        if (_digit >= 0 && {_digit < _base}) then {
            _result = (_result * _base) + _digit;
        };
    } forEach ([_value] call _chars);
    _result
};
private _score = {
    params ["_value"];
    private _lower = toLower _value;
    private _scoreValue = 0;
    {
        private _char = _x;
        if (_char isEqualTo " ") then {
            _scoreValue = _scoreValue + 2;
        } else {
            if ("etaoinshrdlu" find _char >= 0) then {
                _scoreValue = _scoreValue + 3;
            } else {
                if ("abcdefghijklmnopqrstuvwxyz" find _char >= 0) then { _scoreValue = _scoreValue + 1; };
            };
        };
    } forEach ([_lower] call _chars);
    {
        if (_lower find _x >= 0) then { _scoreValue = _scoreValue + ((count _x) * 3); };
    } forEach ["the", "and", "that", "have", "you", "with", "this", "from", "message", "secret"];
    _scoreValue
};
private _sortCandidates = {
    params ["_candidates"];
    _candidates sort false;
    (_candidates apply {_x select 1}) select [0, 10]
};

private _morsePairs = [
    ["A", ".-"], ["B", "-..."], ["C", "-.-."], ["D", "-.."], ["E", "."], ["F", "..-."], ["G", "--."], ["H", "...."], ["I", ".."],
    ["J", ".---"], ["K", "-.-"], ["L", ".-.."], ["M", "--"], ["N", "-."], ["O", "---"], ["P", ".--."], ["Q", "--.-"], ["R", ".-."],
    ["S", "..."], ["T", "-"], ["U", "..-"], ["V", "...-"], ["W", ".--"], ["X", "-..-"], ["Y", "-.--"], ["Z", "--.."],
    ["0", "-----"], ["1", ".----"], ["2", "..---"], ["3", "...--"], ["4", "....-"], ["5", "....."], ["6", "-...."], ["7", "--..."], ["8", "---.."], ["9", "----."]
];
private _morse = createHashMapFromArray _morsePairs;
private _morseRev = createHashMap;
{ _morseRev set [_x select 1, _x select 0]; } forEach _morsePairs;

private _natoPairs = [
    ["A", "Alpha"], ["B", "Bravo"], ["C", "Charlie"], ["D", "Delta"], ["E", "Echo"], ["F", "Foxtrot"], ["G", "Golf"], ["H", "Hotel"],
    ["I", "India"], ["J", "Juliett"], ["K", "Kilo"], ["L", "Lima"], ["M", "Mike"], ["N", "November"], ["O", "Oscar"], ["P", "Papa"],
    ["Q", "Quebec"], ["R", "Romeo"], ["S", "Sierra"], ["T", "Tango"], ["U", "Uniform"], ["V", "Victor"], ["W", "Whiskey"], ["X", "Xray"],
    ["Y", "Yankee"], ["Z", "Zulu"], ["0", "Zero"], ["1", "One"], ["2", "Two"], ["3", "Three"], ["4", "Four"], ["5", "Five"],
    ["6", "Six"], ["7", "Seven"], ["8", "Eight"], ["9", "Nine"]
];
private _nato = createHashMapFromArray _natoPairs;
private _natoRev = createHashMap;
{ _natoRev set [toLower (_x select 1), _x select 0]; } forEach _natoPairs;

private _rot = {
    params ["_value", "_variant", "_decrypt"];
    private _shift = switch (_variant) do {
        case "rot5": {5};
        case "rot13": {13};
        case "rot18": {13};
        default {47};
    };
    private _sign = [1, -1] select _decrypt;
    private _out = "";
    {
        private _code = (toArray _x) select 0;
        if (_variant isEqualTo "rot47" && {_code >= 33 && {_code <= 126}}) then {
            _out = _out + toString [33 + ([(_code - 33) + (_sign * _shift), 94] call _mod)];
        } else {
            if (_variant in ["rot5", "rot18"] && {_code >= 48 && {_code <= 57}}) then {
                _out = _out + toString [48 + ([(_code - 48) + (_sign * 5), 10] call _mod)];
            } else {
                if (_variant in ["rot13", "rot18"] && {(_code >= 65 && {_code <= 90}) || {_code >= 97 && {_code <= 122}}}) then {
                    private _base = [65, 97] select (_code >= 97);
                    _out = _out + toString [_base + ([(_code - _base) + (_sign * 13), 26] call _mod)];
                } else {
                    _out = _out + _x;
                };
            };
        };
    } forEach ([_value] call _chars);
    _out
};

private _vigenere = {
    params ["_value", "_key", "_decrypt"];
    private _clean = "";
    {
        private _code = (toArray (toUpper _x)) select 0;
        if (_code >= 65 && {_code <= 90}) then { _clean = _clean + toUpper _x; };
    } forEach ([_key] call _chars);
    if (_clean isEqualTo "") exitWith {""};
    private _out = "";
    private _index = 0;
    {
        private _code = (toArray _x) select 0;
        if ((_code >= 65 && {_code <= 90}) || {_code >= 97 && {_code <= 122}}) then {
            private _base = [65, 97] select (_code >= 97);
            private _k = ((toArray (_clean select [_index mod (count _clean), 1])) select 0) - 65;
            private _delta = [_k, -_k] select _decrypt;
            _out = _out + toString [_base + ([(_code - _base) + _delta, 26] call _mod)];
            _index = _index + 1;
        } else {
            _out = _out + _x;
        };
    } forEach ([_value] call _chars);
    _out
};

private _base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
private _base64 = {
    params ["_value", "_decrypt"];
    if (!_decrypt) exitWith {
        private _bytes = toArray _value;
        private _out = "";
        for "_i" from 0 to ((count _bytes) - 1) step 3 do {
            private _b1 = _bytes select _i;
            private _b2 = if (_i + 1 < count _bytes) then {_bytes select (_i + 1)} else {0};
            private _b3 = if (_i + 2 < count _bytes) then {_bytes select (_i + 2)} else {0};
            private _n = (_b1 * 65536) + (_b2 * 256) + _b3;
            _out = _out + (_base64Alphabet select [floor (_n / 262144), 1]);
            _out = _out + (_base64Alphabet select [floor ((_n mod 262144) / 4096), 1]);
            _out = _out + (if (_i + 1 < count _bytes) then {_base64Alphabet select [floor ((_n mod 4096) / 64), 1]} else {"="});
            _out = _out + (if (_i + 2 < count _bytes) then {_base64Alphabet select [_n mod 64, 1]} else {"="});
        };
        _out
    };
    private _clean = _value regexReplace ["\s+", ""];
    private _outBytes = [];
    for "_i" from 0 to ((count _clean) - 1) step 4 do {
        private _c1 = _base64Alphabet find (_clean select [_i, 1]);
        private _c2 = _base64Alphabet find (_clean select [_i + 1, 1]);
        private _c3Char = _clean select [_i + 2, 1];
        private _c4Char = _clean select [_i + 3, 1];
        private _c3 = if (_c3Char isEqualTo "=") then {0} else {_base64Alphabet find _c3Char};
        private _c4 = if (_c4Char isEqualTo "=") then {0} else {_base64Alphabet find _c4Char};
        if (_c1 >= 0 && {_c2 >= 0}) then {
            private _n = (_c1 * 262144) + (_c2 * 4096) + (_c3 * 64) + _c4;
            _outBytes pushBack (floor (_n / 65536));
            if (_c3Char isNotEqualTo "=") then { _outBytes pushBack (floor ((_n mod 65536) / 256)); };
            if (_c4Char isNotEqualTo "=") then { _outBytes pushBack (_n mod 256); };
        };
    };
    toString _outBytes
};

private _base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
private _base32 = {
    params ["_value", "_decrypt"];
    if (!_decrypt) exitWith {
        private _out = "";
        {
            _out = _out + ([[_x, 2] call _toBase, 8] call _padLeft);
        } forEach (toArray _value);
        private _encoded = "";
        for "_i" from 0 to ((count _out) - 1) step 5 do {
            private _chunk = _out select [_i, 5];
            while {count _chunk < 5} do { _chunk = _chunk + "0"; };
            _encoded = _encoded + (_base32Alphabet select [[_chunk, 2] call _fromBase, 1]);
        };
        while {(count _encoded) mod 8 != 0} do { _encoded = _encoded + "="; };
        _encoded
    };
    private _bits = "";
    {
        private _idx = _base32Alphabet find (toUpper _x);
        if (_idx >= 0) then { _bits = _bits + ([[_idx, 2] call _toBase, 5] call _padLeft); };
    } forEach ([_value] call _chars);
    private _bytes = [];
    for "_i" from 0 to ((count _bits) - 8) step 8 do {
        _bytes pushBack ([_bits select [_i, 8], 2] call _fromBase);
    };
    toString _bytes
};

private _ascii85 = {
    params ["_value", "_decrypt"];
    if (!_decrypt) exitWith {
        private _bytes = toArray _value;
        private _out = "<~";
        for "_i" from 0 to ((count _bytes) - 1) step 4 do {
            private _remain = ((count _bytes) - _i) min 4;
            private _chunk = [0, 0, 0, 0];
            for "_j" from 0 to (_remain - 1) do { _chunk set [_j, _bytes select (_i + _j)]; };
            private _n = (((_chunk select 0) * 16777216) + ((_chunk select 1) * 65536) + ((_chunk select 2) * 256) + (_chunk select 3));
            private _digits = ["", "", "", "", ""];
            for "_j" from 4 to 0 step -1 do {
                _digits set [_j, toString [33 + (_n mod 85)]];
                _n = floor (_n / 85);
            };
            _out = _out + ((_digits joinString "") select [0, _remain + 1]);
        };
        _out + "~>"
    };
    private _clean = (_value regexReplace ["<~|~>", ""]) regexReplace ["\s+", ""];
    private _bytes = [];
    private _group = "";
    {
        if (_x isEqualTo "z") then {
            _bytes append [0, 0, 0, 0];
        } else {
            _group = _group + _x;
            if (count _group == 5) then {
                private _n = 0;
                { _n = (_n * 85) + (((toArray _x) select 0) - 33); } forEach ([_group] call _chars);
                _bytes append [floor (_n / 16777216), floor ((_n mod 16777216) / 65536), floor ((_n mod 65536) / 256), _n mod 256];
                _group = "";
            };
        };
    } forEach ([_clean] call _chars);
    if (_group isNotEqualTo "") then {
        private _pad = 5 - (count _group);
        while {count _group < 5} do { _group = _group + "u"; };
        private _n = 0;
        { _n = (_n * 85) + (((toArray _x) select 0) - 33); } forEach ([_group] call _chars);
        _bytes append ([floor (_n / 16777216), floor ((_n mod 16777216) / 65536), floor ((_n mod 65536) / 256), _n mod 256] select [0, 4 - _pad]);
    };
    toString _bytes
};

private _decrypt = _mode isEqualTo "decrypt";

if (_mode isEqualTo "bruteforce") exitWith {
    private _targets = if (_algorithm isEqualTo "all") then {
        ["morse", "spelling", "affine", "rot", "vigenere", "bacon", "alpha_sub", "railfence", "base32", "base64", "ascii85", "unicode", "integer"]
    } else {
        [_algorithm]
    };
    private _lines = [];
    {
        private _candidateAlgo = _x;
        if (count _targets > 1) then { _lines pushBack format ["[%1]", _candidateAlgo]; };
        private _candidates = [];
        switch (_candidateAlgo) do {
            case "rot": {
                {
                    private _plain = [_text, _x, true] call _rot;
                    _candidates pushBack [[_plain] call _score, format ["%1 | %2", _x, _plain]];
                } forEach ["rot5", "rot13", "rot18", "rot47"];
            };
            case "affine": {
                for "_a" from 1 to 25 do {
                    if ([_a, 26] call _gcd == 1) then {
                        for "_b" from 0 to 25 do {
                            private _opts = createHashMapFromArray [["a", _a], ["b", _b]];
                            private _plain = ["affine", "decrypt", _text, _opts] call FUNC(cipherProcess);
                            _candidates pushBack [[_plain] call _score, format ["a=%1 b=%2 | %3", _a, _b, _plain]];
                        };
                    };
                };
            };
            case "railfence": {
                for "_rails" from 2 to 12 do {
                    private _opts = createHashMapFromArray [["rails", _rails]];
                    private _plain = ["railfence", "decrypt", _text, _opts] call FUNC(cipherProcess);
                    _candidates pushBack [[_plain] call _score, format ["rails=%1 | %2", _rails, _plain]];
                };
            };
            case "vigenere": {
                private _words = (_options getOrDefault ["wordlist", "the and that have secret password root cipher"]) splitString " ,;";
                {
                    if (_x isNotEqualTo "") then {
                        private _plain = ["vigenere", "decrypt", _text, createHashMapFromArray [["key", _x]]] call FUNC(cipherProcess);
                        _candidates pushBack [[_plain] call _score, format ["key=%1 | %2", _x, _plain]];
                    };
                } forEach _words;
            };
            default {
                private _plain = [_candidateAlgo, "decrypt", _text, _options] call FUNC(cipherProcess);
                if (_plain isEqualType "" && {_plain isNotEqualTo ""}) then {
                    _candidates pushBack [[_plain] call _score, format ["%1 | %2", _candidateAlgo, _plain]];
                };
            };
        };
        _lines append ([_candidates] call _sortCandidates);
        if (count _targets > 1) then { _lines pushBack ""; };
    } forEach _targets;
    _lines
};

switch (_algorithm) do {
    case "morse": {
        if (!_decrypt) exitWith {
            (([_text] call _chars) apply { if (_x isEqualTo " ") then {"/"} else {_morse getOrDefault [toUpper _x, _x]} }) joinString " "
        };
        ((_text splitString " ") apply { if (_x in ["/", "|"]) then {" "} else {_morseRev getOrDefault [_x, ""]} }) joinString ""
    };
    case "spelling": {
        if (!_decrypt) exitWith {
            (([_text] call _chars) apply { if (_x isEqualTo " ") then {"/"} else {_nato getOrDefault [toUpper _x, _x]} }) joinString " "
        };
        ((_text splitString " ") apply { if (_x in ["/", "|"]) then {" "} else {_natoRev getOrDefault [toLower _x, ""]} }) joinString ""
    };
    case "affine": {
        private _a = parseNumber str (_options getOrDefault ["a", 1]);
        private _b = parseNumber str (_options getOrDefault ["b", 0]);
        if ([_a, 26] call _gcd != 1) exitWith {""};
        if (_decrypt) then {
            private _inv = [_a, 26] call _inverse;
            if (_inv < 0) exitWith {""};
            _a = _inv;
            _b = -_a * _b;
        };
        private _out = "";
        {
            private _code = (toArray _x) select 0;
            if ((_code >= 65 && {_code <= 90}) || {_code >= 97 && {_code <= 122}}) then {
                private _base = [65, 97] select (_code >= 97);
                _out = _out + toString [_base + ([(_a * (_code - _base)) + _b, 26] call _mod)];
            } else {
                _out = _out + _x;
            };
        } forEach ([_text] call _chars);
        _out
    };
    case "rot": { [_text, _options getOrDefault ["variant", "rot13"], _decrypt] call _rot };
    case "vigenere": { [_text, _options getOrDefault ["key", ""], _decrypt] call _vigenere };
    case "bacon": {
        private _alphabet = ["ABCDEFGHIKLMNOPQRSTUWXYZ", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"] select ((_options getOrDefault ["variant", "standard"]) isEqualTo "extended");
        if (!_decrypt) exitWith {
            (([_text] call _chars) apply {
                private _u = toUpper _x;
                if (_u isEqualTo "J" && {count _alphabet == 24}) then {_u = "I";};
                if (_u isEqualTo "V" && {count _alphabet == 24}) then {_u = "U";};
                private _idx = _alphabet find _u;
                if (_idx < 0) then {_x} else {([[_idx, 2] call _toBase, 5] call _padLeft) regexReplace ["0", "A"] regexReplace ["1", "B"]}
            }) joinString " "
        };
        private _bits = (toUpper _text regexReplace ["[^AB]", ""]) regexReplace ["A", "0"] regexReplace ["B", "1"];
        private _out = "";
        for "_i" from 0 to ((count _bits) - 5) step 5 do {
            private _idx = [_bits select [_i, 5], 2] call _fromBase;
            if (_idx < count _alphabet) then { _out = _out + (_alphabet select [_idx, 1]); };
        };
        _out
    };
    case "alpha_sub": {
        private _plain = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        private _subst = toUpper (_options getOrDefault ["alphabet", _options getOrDefault ["manualAlphabet", _plain]]);
        if (count _subst < 26) then { _subst = _plain; };
        private _from = [_plain, _subst] select _decrypt;
        private _to = [_subst, _plain] select _decrypt;
        private _out = "";
        {
            private _idx = _from find (toUpper _x);
            _out = _out + (if (_idx < 0) then {_x} else {_to select [_idx, 1]});
        } forEach ([_text] call _chars);
        _out
    };
    case "railfence": {
        private _rails = 2 max floor parseNumber str (_options getOrDefault ["rails", 2]);
        private _letters = [_text] call _chars;
        private _len = count _letters;
        if (_rails >= _len) exitWith {_text};
        private _pattern = [];
        private _rail = 0;
        private _dir = 1;
        for "_i" from 0 to (_len - 1) do {
            _pattern pushBack _rail;
            if (_rail == 0) then {_dir = 1;};
            if (_rail == _rails - 1) then {_dir = -1;};
            _rail = _rail + _dir;
        };
        if (!_decrypt) exitWith {
            private _rows = [];
            for "_i" from 0 to (_rails - 1) do { _rows pushBack []; };
            { (_rows select (_pattern select _forEachIndex)) pushBack _x; } forEach _letters;
            (_rows apply {_x joinString ""}) joinString ""
        };
        private _counts = [];
        for "_i" from 0 to (_rails - 1) do { _counts pushBack ({_x == _i} count _pattern); };
        private _slices = [];
        private _pos = 0;
        { _slices pushBack (_letters select [_pos, _x]); _pos = _pos + _x; } forEach _counts;
        private _used = [];
        for "_i" from 0 to (_rails - 1) do { _used pushBack 0; };
        private _out = "";
        {
            private _row = _x;
            private _idx = _used select _row;
            _out = _out + ((_slices select _row) select _idx);
            _used set [_row, _idx + 1];
        } forEach _pattern;
        _out
    };
    case "base32": { [_text, _decrypt] call _base32 };
    case "base64": { [_text, _decrypt] call _base64 };
    case "ascii85": { [_text, _decrypt] call _ascii85 };
    case "unicode": {
        if (!_decrypt) exitWith {
            ((toArray _text) apply { "U+" + ([[_x, 16] call _toBase, 4] call _padLeft) }) joinString " "
        };
        private _out = "";
        {
            private _token = _x regexReplace ["U\+|\\u", ""];
            if (_token isNotEqualTo "") then { _out = _out + toString [[_token, 16] call _fromBase]; };
        } forEach (_text splitString " ");
        _out
    };
    case "integer": {
        private _radix = parseNumber str (_options getOrDefault ["radix", 16]);
        private _width = parseNumber str (_options getOrDefault ["width", 8]);
        private _signed = _options getOrDefault ["signed", false];
        if (!_decrypt) exitWith {
            ((toArray _text) apply {
                private _n = _x;
                private _max = 2 ^ _width;
                private _half = 2 ^ (_width - 1);
                if (_signed && {_n >= _half}) then { _n = _n - _max; };
                private _prefix = ["", "-"] select (_n < 0);
                private _s = [abs _n, _radix] call _toBase;
                if (_radix in [2, 8, 16]) then {
                    private _size = switch (_radix) do { case 2: {_width}; case 8: {ceil (_width / 3)}; default {ceil (_width / 4)}; };
                    _s = [_s, _size] call _padLeft;
                };
                _prefix + _s
            }) joinString " "
        };
        private _bytes = [];
        {
            private _neg = _x select [0, 1] isEqualTo "-";
            private _token = [_x, _x select [1]] select _neg;
            private _n = [_token, _radix] call _fromBase;
            if (_neg) then { _n = -_n; };
            if (_signed && {_n < 0}) then { _n = (2 ^ _width) + _n; };
            _bytes pushBack ([round _n, 2 ^ _width] call _mod);
        } forEach (_text splitString " ,;");
        toString _bytes
    };
    default {""};
}
