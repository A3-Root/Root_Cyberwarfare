#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Builds cipher option data from dialog/API key and option text.
 *
 * Arguments:
 * 0: _key <STRING> - Primary key, password, keyword, or variant
 * 1: _optionText <STRING|HASHMAP> - Comma, semicolon, or whitespace separated key=value options
 *
 * Return Value:
 * <HASHMAP> Cipher options
 *
 * Public: Yes
 */

params [["_key", "", [""]], ["_optionText", "", ["", createHashMap]]];

if (_optionText isEqualType createHashMap) exitWith {
    private _options = +_optionText;
    if (_key isNotEqualTo "") then {
        _options set ["key", _key];
        if !("variant" in _options) then { _options set ["variant", toLower _key]; };
    };
    _options
};

private _options = createHashMap;
if (_key isNotEqualTo "") then {
    _options set ["key", _key];
    _options set ["variant", toLower _key];
};

{
    private _token = _x;
    private _eq = _token find "=";
    if (_eq > 0) then {
        private _name = toLower (_token select [0, _eq]);
        private _value = _token select [_eq + 1];
        if (_name in ["key", "keyword"]) then {
            _options set ["key", _value];
            _options set ["keyword", _value];
        } else {
            switch (_name) do {
                case "variant": { _options set ["variant", toLower _value]; };
                case "alphabet": { _options set ["alphabet", _value]; _options set ["manualAlphabet", _value]; };
                case "a": { _options set ["a", parseNumber _value]; };
                case "b": { _options set ["b", parseNumber _value]; };
                case "rails": { _options set ["rails", parseNumber _value]; };
                case "radix": { _options set ["radix", parseNumber _value]; };
                case "width": { _options set ["width", parseNumber _value]; };
                case "signed": { _options set ["signed", (toLower _value) in ["1", "true", "yes"]]; };
                case "wordlist": { _options set ["wordlist", _value]; };
                default {};
            };
        };
    };
} forEach (_optionText splitString " ,;");

_options
