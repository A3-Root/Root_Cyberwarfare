#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Reads back the identifier box of a desktop list app. The box's own prompt text counts
 *              as empty. Client side.
 *
 * Arguments:
 * 0: _deviceType <NUMBER> - DEVICE_TYPE_* constant of the app
 *
 * Return Value:
 * <STRING> - The identifier as typed, or "" when the box is empty
 *
 * Example:
 * private _code = [DEVICE_TYPE_DOOR] call Root_fnc_gui_identifierText;
 *
 * Public: No
 */

params [["_deviceType", 0, [0]]];

private _edit = uiNamespace getVariable [format ["ROOT_gui_idEdit_%1", _deviceType], controlNull];

if (isNull _edit) exitWith {""};

private _text = [ctrlText _edit] call CBA_fnc_trim;

if (_text isEqualTo (localize "STR_ROOT_CYBERWARFARE_GUI_IDENTIFIER_PROMPT")) exitWith {""};

_text
