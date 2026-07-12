// File: fn_getVehicleDrivetrain.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Measures how much drive a vehicle still has. Hitpoint names differ per vehicle, so the
 *              engine and the wheels are matched on keywords in getAllHitPointsDamage instead of fixed
 *              hitpoint names. The returned effectiveness scales any commanded speed, and the speed cap
 *              is the vehicle's configured top speed reduced by that same factor, so a vehicle running
 *              on shot-out wheels can no longer be pushed past what it could physically reach. A vehicle
 *              is reported as blocked once its engine is gone, its drivetrain drops below the minimum
 *              usable fraction, or the engine simply refuses to drive it.
 *
 * Arguments:
 * 0: _vehicle <OBJECT> - Vehicle to inspect
 *
 * Return Value:
 * 0: _engineDamage <NUMBER> - Worst engine hitpoint damage (0-1)
 * 1: _wheelFactor <NUMBER> - Mean wheel health (0-1), 1 when the vehicle has no wheel hitpoints
 * 2: _effectiveness <NUMBER> - Combined drivetrain fraction (0-1)
 * 3: _blocked <BOOLEAN> - The vehicle cannot be driven at all
 * 4: _speedCap <NUMBER> - Highest speed the drivetrain can still deliver, in km/h
 *
 * Example:
 * (_vehicle call Root_fnc_getVehicleDrivetrain) params ["_engine", "_wheels", "_eff", "_blocked", "_cap"];
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle || {!alive _vehicle}) exitWith {[1, 0, 0, true, 0]};

(getAllHitPointsDamage _vehicle) params [["_hitPoints", []], "", ["_damages", []]];

private _engineDamage = 0;
private _wheelHealths = [];
{
    private _damage = _damages param [_forEachIndex, 0];
    private _name = toLower _x;
    if ("engine" in _name || {"motor" in _name}) then {
        _engineDamage = _engineDamage max _damage;
    };
    if ("wheel" in _name) then {
        _wheelHealths pushBack (1 - _damage);
    };
} forEach _hitPoints;

// Vehicles without wheel hitpoints (helicopters, boats, drones) depend on the engine alone.
private _wheelFactor = 1;
if (_wheelHealths isNotEqualTo []) then {
    private _sum = 0;
    {_sum = _sum + _x} forEach _wheelHealths;
    _wheelFactor = (_sum / (count _wheelHealths)) max 0;
};

private _effectiveness = ((1 - _engineDamage) * _wheelFactor) max 0;
private _blocked = (_engineDamage >= 1)
    || {_effectiveness < DRIVETRAIN_MIN_EFFECTIVENESS}
    || {!(canMove _vehicle)};

// The configured top speed is the ceiling an intact vehicle can reach; a damaged one keeps only its
// remaining fraction of it. Vehicles that declare no top speed are left uncapped and only derated.
private _configSpeed = getNumber (configOf _vehicle >> "maxSpeed");
private _speedCap = if (_configSpeed > 0) then {_configSpeed * _effectiveness} else {DRIVETRAIN_NO_SPEED_CAP};

[_engineDamage, _wheelFactor, _effectiveness, _blocked, _speedCap]
