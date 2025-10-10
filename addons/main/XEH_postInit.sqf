[{!isNull player}, {
    private _actionAttach = [
        "ROOT_AttachGPSTracker_Object",
        "Attach GPS Tracker",
        "",
        {
            params ["_target", "_player", "_params"];  
            if (isNull _target || {_target == _player}) exitWith {
                ["Unable to attach GPS Tracker!", true, 1.5, 2] call ace_common_fnc_displayText;
            };        
            [
                5,
                [_target, _player], 
                {
                    params ["_args"];
                    _args params ["_target", "_player"];
                    [_target, _player] call ROOT_fnc_aceAttachGPSTrackerObject;
                },
                {},
                format ["Attaching GPS Tracker to %1     ", getText (configOf _target >> "displayName")],
                {
                    params ["_args"];
                    _args params ["_target", "_player"];
                    !isNull _target && {alive _player}
                },
                ["isNotInside"]
            ] call ace_common_fnc_progressBar;
        },
        {
            private _gpsTrackerClass = missionNamespace getVariable ['ROOT_CYBERWARFARE_GPS_TRACKER_DEVICE', 'ACE_Banana'];
            _gpsTrackerClass in (uniformItems _player + vestItems _player + backpackItems _player + items _player);
        }
    ] call ace_interact_menu_fnc_createAction;
    ["All", 0, ["ACE_MainActions"], _actionAttach, true] call ace_interact_menu_fnc_addActionToClass;

    private _actionSearch = [
        "ROOT_SearchGPSTracker_Object",
        "Search for GPS Tracker",
        "",
        {
            params ["_target", "_player", "_params"];  
            if (isNull _target || {_target == _player}) exitWith {
                ["Cannot search yourself!", true, 1.5, 2] call ace_common_fnc_displayText;
            };
            
            [
                10,
                [_target, _player], 
                {
                    params ["_args"];
                    _args params ["_target", "_player"];
                    [_target, _player] call Root_fnc_searchForGPSTracker;
                },
                {},
                format ["Searching %1 for GPS Tracker     ", getText (configOf _target >> "displayName")],
                {
                    params ["_args"];
                    _args params ["_target", "_player"];
                    !isNull _target && {alive _player}
                },
                ["isNotInside"]
            ] call ace_common_fnc_progressBar;
        },
        {
            true
        }
    ] call ace_interact_menu_fnc_createAction;
    ["All", 0, ["ACE_MainActions"], _actionSearch, true] call ace_interact_menu_fnc_addActionToClass;

}, []] call CBA_fnc_waitUntilAndExecute;
