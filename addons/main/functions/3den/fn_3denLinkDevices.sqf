#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * 3DEN Editor module that grants synchronized laptops access to devices that other modules have
 * already registered. Devices are named by "deviceType:deviceId" pairs so a mission can register
 * devices as unassigned and hand access out from a separate module, keeping placement and access
 * control apart. The module runs after a short delay so the add-device modules have finished
 * assigning their IDs first.
 *
 * Arguments:
 * 0: _logic <OBJECT> - Module logic object
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call Root_fnc_3denLinkDevices;
 *
 * Public: No
 */

params ["_logic"];

if (!isServer) exitWith {};

private _syncedObjects = synchronizedObjects _logic;
private _laptops = _syncedObjects select {
    typeOf _x in ["Land_Laptop_03_black_F_AE3", "Land_Laptop_03_olive_F_AE3", "Land_Laptop_03_sand_F_AE3", "Land_USB_Dongle_01_F_AE3"]
};

if (_laptops isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("3DEN Link Devices: No laptops synchronized to this module!");
    deleteVehicle _logic;
};

private _deviceListText = _logic getVariable ["ROOT_CYBERWARFARE_3DEN_LINKDEVICES_LIST", ""];
private _action = floor (_logic getVariable ["ROOT_CYBERWARFARE_3DEN_LINKDEVICES_ACTION", ACCESS_ACTION_LINK]);

// Parse "4:1003, 1:1001" into [[deviceType, deviceId], ...]. Malformed pairs are dropped so one typo
// does not stop the rest of the list from being applied.
private _deviceEntries = [];
{
    private _pair = _x splitString ":";
    if (count _pair == 2) then {
        private _deviceType = floor (parseNumber (_pair select 0));
        private _deviceId = floor (parseNumber (_pair select 1));
        if (VALIDATE_DEVICE_TYPE(_deviceType) && {_deviceId > 0}) then {
            _deviceEntries pushBackUnique [_deviceType, _deviceId];
        } else {
            ROOT_CYBERWARFARE_LOG_ERROR_1("3DEN Link Devices: Ignoring malformed entry %1",_x);
        };
    };
} forEach (_deviceListText splitString ", ");

if (_deviceEntries isEqualTo []) exitWith {
    ROOT_CYBERWARFARE_LOG_ERROR("3DEN Link Devices: No valid deviceType:deviceId entries configured!");
    deleteVehicle _logic;
};

private _linkedComputers = _laptops apply { netId _x };

// Wait until the mission has settled and the add-device modules have registered their IDs, otherwise
// the entries would be rejected as unknown devices.
[
    {
        params ["_linkedComputers", "_deviceEntries", "_action"];

        [_linkedComputers, _deviceEntries, _action, 2] call FUNC(setDeviceLinksMain);

        if (serverCommandAvailable "#kick") then {
            systemChat "[ROOT Cyberwarfare] Link Devices module applied";
        };
    },
    [_linkedComputers, _deviceEntries, _action],
    10
] call CBA_fnc_waitAndExecute;

deleteVehicle _logic;
