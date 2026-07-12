// File: fn_getVehicleDrivetrain.sqf
#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Measures how much drive a vehicle still has. Hitpoint names differ per vehicle, so the
 *              engine and the wheels are matched on keywords in getAllHitPointsDamage instead of fixed
 *              hitpoint names. The speed cap is the vehicle's configured top speed reduced by the
 *              surviving fraction of the drivetrain: damage lowers the speed a vehicle can be commanded
 *              to hold, it does not forbid commanding one. A vehicle counts as blocked only when nothing
 *              is left to turn the wheels - a dead engine, or no wheel with any tread on it - because a
 *              limping vehicle is still a driveable vehicle and should be driven at whatever it can make.
 *
 * Arguments:
 * 0: _vehicle <OBJECT> - Vehicle to inspect
 *
 * Return Value:
 * 0: _engineDamage <NUMBER> - Worst engine hitpoint damage (0-1)
 * 1: _wheelFactor <NUMBER> - Surviving wheel fraction (0-1), weighted towards the worst wheel, 1 when the
 *                            vehicle has no wheel hitpoints
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

(getAllHitPointsDamage _vehicle) params [["_hitPoints", []], ["_selections", []], ["_damages", []]];

private _engineDamage = 0;
private _wheelHealths = [];
{
    private _damage = _damages param [_forEachIndex, 0];
    private _name = toLower _x;

    // A vehicle's hitpoint list is the one its class inherits, not the one its model actually carries: a
    // four-wheeler still lists the eight wheel hitpoints of the family it comes from. The wheels it does
    // not have are bound to no selection and always read as fully destroyed, so counting them would strip
    // a healthy vehicle of most of its drivetrain. Only hitpoints bound to a selection are real, and an
    // unused one is sometimes blank rather than empty, so the name is trimmed before it is judged. What
    // survives this is exactly the wheels the vehicle has - four on a four-wheeler, eight on an eight.
    if ((trim (_selections param [_forEachIndex, ""])) isEqualTo "") then {continue};

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
    private _worst = 1;
    {
        _sum = _sum + _x;
        _worst = _worst min _x;
    } forEach _wheelHealths;
    private _average = _sum / (count _wheelHealths);

    // The engine drags a vehicle down to its worst wheel far more than to its average one: a single blown
    // tyre bleeds off speed through friction no matter how sound the others are, so a mean over the wheels
    // promises a speed the vehicle cannot actually make. The worst wheel therefore carries most of the
    // weight and the average only trims it, which puts the cap near what the vehicle really manages.
    _wheelFactor = ((_average * 0.3) + (_worst * 0.7)) max 0;
};

// Torque falls away faster than damage climbs, so the engine's share of the drivetrain is curved rather
// than counted straight.
private _effectiveness = (((1 - _engineDamage) ^ 1.2) * _wheelFactor) max 0;
// canMove reports a vehicle with wheels shot out as immobile although it will still pull away under its
// own power, so the drivetrain itself is the only thing asked: while any of it survives, the vehicle can
// be driven, and how much survives is what decides how fast.
private _blocked = (_effectiveness <= 0);

// The configured top speed is the ceiling an intact vehicle can reach; a damaged one keeps only its
// remaining fraction of it. Vehicles that declare no top speed are left uncapped and only derated.
private _configSpeed = getNumber (configOf _vehicle >> "maxSpeed");
private _speedCap = if (_configSpeed > 0) then {(_configSpeed * _effectiveness)} else {DRIVETRAIN_NO_SPEED_CAP};

[_engineDamage, _wheelFactor, _effectiveness, _blocked, _speedCap]
