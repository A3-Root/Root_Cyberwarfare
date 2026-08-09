#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Flattens the eight per-type device registries into one list of rows the curator dialogs
 *              can render. Each row carries the device's type and id, the object it was registered on,
 *              its mission-maker name, and a ready-made label combining all three, so a dialog never
 *              has to know that doors keep their display name one slot further along than every other
 *              device type. Rows whose object no longer exists are kept - a deleted object still holds
 *              a registry entry and links that a curator may want to clear - and carry objNull.
 *
 * Arguments:
 * 0: _deviceTypes <ARRAY> (Optional) - DEVICE_TYPE_* constants to include, [] = every type, default: []
 *
 * Return Value:
 * Device rows <ARRAY> - [[deviceType <NUMBER>, deviceId <NUMBER>, name <STRING>, object <OBJECT>, typeLabel <STRING>, label <STRING>], ...]
 *
 * Example:
 * private _rows = [] call Root_fnc_getRegisteredDevices;
 *
 * Public: No
 */

params [["_deviceTypes", [], [[]]]];

private _typeLabels = [
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_DOORS",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_LIGHTS",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_DRONES",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_DATABASES",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_CUSTOM",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_GPS",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_VEHICLES",
    localize "STR_ROOT_CYBERWARFARE_GUI_APP_POWERGRID"
];

private _allDevices = missionNamespace getVariable ["ROOT_CYBERWARFARE_ALL_DEVICES", [[], [], [], [], [], [], [], []]];
private _rows = [];

{
    private _deviceType = _forEachIndex + 1;

    if (_deviceTypes isEqualTo [] || {_deviceType in _deviceTypes}) then {
        private _typeLabel = _typeLabels select _forEachIndex;
        // Every registry row is [id, netId, ...]; the display name sits at index 2 except for doors,
        // which keep their door list there and their name one slot further along.
        private _nameIndex = [3, 2] select (_deviceType != DEVICE_TYPE_DOOR);

        {
            private _deviceId = _x select 0;
            private _deviceName = _x param [_nameIndex, ""];
            if !(_deviceName isEqualType "") then { _deviceName = ""; };

            private _netId = _x param [1, ""];
            private _object = if (_netId isEqualType "") then { objectFromNetId _netId } else { objNull };

            _rows pushBack [
                _deviceType,
                _deviceId,
                _deviceName,
                _object,
                _typeLabel,
                format ["%1 %2 - %3", _typeLabel, _deviceId, _deviceName]
            ];
        } forEach _x;
    };
} forEach _allDevices;

_rows
