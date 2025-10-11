#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Reveals the location of linked laptops on the map with temporary or permanent markers
 *
 * Arguments:
 * 0: _linkedComputers <ARRAY> - Array of computer netIds to reveal
 * 1: _player <OBJECT> - The player who will see the markers
 * 2: _permanent <BOOLEAN> (Optional) - Make markers permanent, default: true
 * 3: _aliveTimer <NUMBER> (Optional) - Time in seconds before markers disappear (if not permanent), default: 60
 *
 * Return Value:
 * <STRING> - Status message with count of revealed laptops
 *
 * Example:
 * [_linkedComputers, player, false, 60] call Root_fnc_revealLaptopLocations;
 *
 * Public: No
 */

params ["_linkedComputers", "_player", ["_permanent", true], ["_aliveTimer", 60]];

if (_linkedComputers isEqualTo []) exitWith {
    ["No linked laptops found.", true, 1.5, 2] call ace_common_fnc_displayText;
};

private _markerPrefix = format ["ROOT_RevealedLaptop_%1_", getPlayerUID _player];
private _createdMarkers = [];

{
    private _computerNetId = _x;
    private _computer = objectFromNetId _computerNetId;
    
    if (!isNull _computer) then {
        private _pos = getPosATL _computer;
        private _markerName = format ["%1%2", _markerPrefix, _forEachIndex];
        
        // Create marker
        private _marker = createMarkerLocal [_markerName, _pos];
        _marker setMarkerTypeLocal "mil_dot";
        _marker setMarkerColorLocal "ColorRed";
        _marker setMarkerTextLocal format ["Laptop_%1", _forEachIndex + 1];
        
        _createdMarkers pushBack _marker;
    };
} forEach _linkedComputers;

// If not permanent, delete markers after _aliveTimer seconds
if (_permanent) then {
    ["Marking active pings to this tracker in the map.", true, 1.5, 2] call ace_common_fnc_displayText;
} else {
    [_createdMarkers, _aliveTimer] spawn {
        params ["_markers", "_aliveTimer"];
        uiSleep _aliveTimer;
        {
            deleteMarkerLocal _x;
        } forEach _markers;
    };

    [format ["Laptop locations will disappear in %1 seconds.", _aliveTimer], true, 1.5, 2] call ace_common_fnc_displayText;
};

format ["Revealed %1 laptop location(s) on map.", count _createdMarkers]
