if !(hasInterface) exitWith {};

params ["_vehicleObject", "_value"];
private _pos = getPosATL _vehicleObject;
private _soundObject = createVehicleLocal ["Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE"];
_soundObject attachTo [_vehicleObject];
_soundObject say3D ["root_car_alarm", 150, 1, 0, 0, false];
uiSleep _value;
deleteVehicle _soundObject;
