/*
 * Author: Root
 * Description: Plays a 3D sound effect at a vehicle's location for a specified duration
 *              Used for vehicle alarms and other audio feedback. Client-side only.
 *
 * Arguments:
 * 0: _vehicleObject <OBJECT> - The vehicle to attach the sound to
 * 1: _value <NUMBER> - Duration in seconds for the sound to play
 *
 * Return Value:
 * None
 *
 * Example:
 * [_car, 10] remoteExec ["Root_fnc_localSoundBroadcast", 0];
 *
 * Public: No
 */

// Exit if running on dedicated server (no audio needed)
if !(hasInterface) exitWith {};

params ["_vehicleObject", "_value"];

// Get vehicle position
private _pos = getPosATL _vehicleObject;

// Create invisible helper object to emit sound
private _soundObject = createVehicleLocal ["Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE"];
_soundObject attachTo [_vehicleObject];

// Play car alarm sound (150m range, normal pitch)
_soundObject say3D ["root_cyberwarfare_car_alarm", 150, 1, 0, 0, false];

// Wait for duration then cleanup
uiSleep _value;
deleteVehicle _soundObject;
