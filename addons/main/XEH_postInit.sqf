[{!isNull player}, {
    private _action = [
        "ROOT_AttachGPSTracker_Object",
        "Attach GPS Tracker",
        "",
        {
            params ["_target", "_player", "_params"];  
            if (isNull _target || {_target == _player}) exitWith {
                ["Cannot attach GPS Tracker!", 2] call ace_common_fnc_displayTextStructured;
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
                format ["Attaching GPS Tracker to %1 --", getText (configOf _target >> "displayName")],
                {
                    params ["_args"];
                    _args params ["_target", "_player"];
                    !isNull _target && {alive _player}
                },
                ["isNotInside"]
            ] call ace_common_fnc_progressBar;
        },
        {true}
    ] call ace_interact_menu_fnc_createAction;
    ["All", 0, ["ACE_MainActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
}, []] call CBA_fnc_waitUntilAndExecute;
