// Root_fnc_revealLaptopLocations
// Reveals the location of linked laptops on the map
// Parameters: [_linkedComputers, _player, _permanent, _aliveTimer]

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

        private _gridPos = mapGridPosition _computer;
        _marker setMarkerTextLocal format ["Laptop_%1", _forEachIndex + 1];
        
        _createdMarkers pushBack _marker;
    };
} forEach _linkedComputers;

// If not permanent, delete markers after _aliveTimer seconds
if (!_permanent) then {
    [_createdMarkers, _aliveTimer] spawn {
        params ["_markers", "_aliveTimer"];
        uiSleep _aliveTimer;
        {
            deleteMarkerLocal _x;
        } forEach _markers;
    };
    
    [format ["Laptop locations will disappear in %1 seconds.", _aliveTimer], true, 1.5, 2] call ace_common_fnc_displayText;
} else {
    ["Marking active pings to this tracker in the map.", true, 1.5, 2] call ace_common_fnc_displayText;
};

format ["Revealed %1 laptop location(s) on map.", count _createdMarkers]
