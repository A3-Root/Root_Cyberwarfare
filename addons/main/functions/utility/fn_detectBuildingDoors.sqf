#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Detects all doors in a building by checking both SimpleObject animate
 * entries (vanilla) and UserActions (modded buildings like Cytech, CUP).
 *
 * Arguments:
 * 0: _building <OBJECT> - The building object to scan for doors
 *
 * Return Value:
 * <ARRAY> - Array of door numbers found in the building (e.g., [1, 2, 3])
 *
 * Example:
 * private _doors = [_building] call Root_fnc_detectBuildingDoors;
 *
 * Public: No
 */

params [
    ["_building", objNull, [objNull]]
];

if (isNull _building) exitWith {
    DEBUG_LOG("Invalid building object passed to fn_detectBuildingDoors");
    []
};

private _buildingDoors = [];
private _config = configOf _building;

// ========================================================================
// METHOD 1: Check SimpleObject >> animate (Vanilla Arma 3 buildings)
// ========================================================================
private _simpleObjects = getArray (_config >> "SimpleObject" >> "animate");
{
    if (count _x == 2) then {
        private _objectName = _x select 0;
        if (_objectName regexMatch "door_.*") then {
            // Extract door number from animation name (e.g., "door_1" -> 1)
            private _regexFinds = _objectName regexFind ["door_([0-9]+)"];
            if (count _regexFinds > 0) then {
                private _doorNumber = parseNumber (((_regexFinds select 0) select 1) select 0);

                if (!(_doorNumber in _buildingDoors)) then {
                    _buildingDoors pushBack _doorNumber;
                    DEBUG_LOG_2("Found door %1 via SimpleObject in %2",_doorNumber,typeOf _building);
                };
            };
        };
    };
} forEach _simpleObjects;

// ========================================================================
// METHOD 2: Check UserActions (Modded buildings: Cytech, CUP, etc.)
// ========================================================================
private _userActionsConfig = _config >> "UserActions";

if (isClass _userActionsConfig) then {
    DEBUG_LOG_1("Checking UserActions for building %1",typeOf _building);

    // Iterate through all user action entries
    for "_i" from 0 to (count _userActionsConfig - 1) do {
        private _actionConfig = _userActionsConfig select _i;

        if (isClass _actionConfig) then {
            private _actionName = configName _actionConfig;
            private _statement = getText (_actionConfig >> "statement");
            private _condition = getText (_actionConfig >> "condition");

            // Look for door animations in statement (e.g., "this animate ['door_1', 1]")
            // or condition (e.g., "this animationPhase 'door_1' < 0.5")
            private _searchText = _statement + " " + _condition;

            // Pattern 1: animate ['door_X', ...]
            private _animateMatches = _searchText regexFind ["(?:animate\s*\[\s*['""]door_([0-9]+)['""])"];
            {
                private _doorNumber = parseNumber (((_x select 1) select 0));
                if (!(_doorNumber in _buildingDoors)) then {
                    _buildingDoors pushBack _doorNumber;
                    DEBUG_LOG_3("Found door %1 via UserAction '%2' in %3",_doorNumber,_actionName,typeOf _building);
                };
            } forEach _animateMatches;

            // Pattern 2: animationPhase 'door_X' or animationPhase "door_X"
            private _phaseMatches = _searchText regexFind ["(?:animationPhase\s*['""]door_([0-9]+)['""])"];
            {
                private _doorNumber = parseNumber (((_x select 1) select 0));
                if (!(_doorNumber in _buildingDoors)) then {
                    _buildingDoors pushBack _doorNumber;
                    DEBUG_LOG_3("Found door %1 via UserAction '%2' (animationPhase) in %3",_doorNumber,_actionName,typeOf _building);
                };
            } forEach _phaseMatches;

            // Pattern 3: animateSource ['door_X', ...]
            private _sourceMatches = _searchText regexFind ["(?:animateSource\s*\[\s*['""]door_([0-9]+)['""])"];
            {
                private _doorNumber = parseNumber (((_x select 1) select 0));
                if (!(_doorNumber in _buildingDoors)) then {
                    _buildingDoors pushBack _doorNumber;
                    DEBUG_LOG_3("Found door %1 via UserAction '%2' (animateSource) in %3",_doorNumber,_actionName,typeOf _building);
                };
            } forEach _sourceMatches;
        };
    };
};

// ========================================================================
// METHOD 3: Check AnimationSources (Alternative modded door system)
// ========================================================================
private _animSourcesConfig = _config >> "AnimationSources";

if (isClass _animSourcesConfig) then {
    DEBUG_LOG_1("Checking AnimationSources for building %1",typeOf _building);

    for "_i" from 0 to (count _animSourcesConfig - 1) do {
        private _sourceConfig = _animSourcesConfig select _i;

        if (isClass _sourceConfig) then {
            private _sourceName = configName _sourceConfig;

            // Check if source name matches door pattern
            if (_sourceName regexMatch "door_[0-9]+") then {
                private _regexFinds = _sourceName regexFind ["door_([0-9]+)"];
                if (count _regexFinds > 0) then {
                    private _doorNumber = parseNumber (((_regexFinds select 0) select 1) select 0);

                    if (!(_doorNumber in _buildingDoors)) then {
                        _buildingDoors pushBack _doorNumber;
                        DEBUG_LOG_2("Found door %1 via AnimationSources in %2",_doorNumber,typeOf _building);
                    };
                };
            };
        };
    };
};

// Sort door numbers for consistency
_buildingDoors sort true;

DEBUG_LOG_2("Total doors detected in %1: %2",typeOf _building,_buildingDoors);

_buildingDoors
