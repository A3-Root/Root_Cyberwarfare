#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Synchronizes the Hackerman.exe launcher across every AE3 user desktop on a computer.
 *
 * Arguments:
 * 0: _computer <OBJECT> - Computer object whose filesystem is updated
 * 1: _available <BOOL> - Whether the launcher should exist
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_computer", objNull, [objNull]], ["_available", false, [false]]];

if (isNull _computer || {isNil "AE3_filesystem_fnc_fsObjExists"}) exitWith {};

if (isMultiplayer) then {
    [_computer, "AE3_filesystem"] call AE3_main_fnc_getRemoteVar;
    [_computer, "AE3_Userlist"] call AE3_main_fnc_getRemoteVar;
};

private _filesystem = _computer getVariable ["AE3_filesystem", []];
if (_filesystem isEqualTo []) exitWith {};

private _catalogPath = "/usr/share/applications/RootCW_Hackerman.app";
private _launcherName = "Hackerman.exe";
private _legacyLauncherNames = ["Hackerman.app"];
private _launcherContent = "app=RootCW_Hackerman";
private _appPerms = [[true, true, true], [true, false, true]];

try {
    [[], _filesystem, "/usr/share/applications", "root", "root", _appPerms] call AE3_filesystem_fnc_ensureDir;
    if ([[], _filesystem, _catalogPath, "root"] call AE3_filesystem_fnc_fsObjExists) then {
        private _catalogFile = [(_catalogPath splitString "/"), _filesystem] call AE3_filesystem_fnc_resolvePntr;
        if ((_catalogFile select 0) isEqualType []) then {
            (_catalogFile select 0) set [0, _launcherContent];
        };
    } else {
        [[], _filesystem, _catalogPath, _launcherContent, "root", "root", _appPerms] call AE3_filesystem_fnc_createFile;
    };

    private _users = ["root"];
    private _userList = _computer getVariable ["AE3_Userlist", createHashMap];
    if (_userList isEqualType createHashMap) then {
        {
            if (_users find _x < 0) then {
                _users pushBack _x;
            };
        } forEach keys _userList;
    };

    {
        private _user = _x;
        private _home = ["/home/" + _user, "/root"] select (_user isEqualTo "root");
        private _desktop = _home + "/Desktop";
        private _launcherNames = [_launcherName] + _legacyLauncherNames;

        [[], _filesystem, _desktop, "root", _user, _appPerms] call AE3_filesystem_fnc_ensureDir;

        if (_available) then {
            {
                private _legacyLink = _desktop + "/" + _x;
                if ([[], _filesystem, _legacyLink, "root"] call AE3_filesystem_fnc_fsObjExists) then {
                    private _obj = [(_legacyLink splitString "/"), _filesystem] call AE3_filesystem_fnc_resolvePntr;
                    private _target = [(_obj select 0)] call AE3_filesystem_fnc_symlinkTarget;
                    private _content = _obj select 0;
                    if (_target isEqualTo _catalogPath || {_content isEqualTo _launcherContent}) then {
                        [[], _filesystem, _legacyLink, "root"] call AE3_filesystem_fnc_delObj;
                    };
                };
            } forEach _legacyLauncherNames;

            private _link = _desktop + "/" + _launcherName;
            if (!([[], _filesystem, _link, "root"] call AE3_filesystem_fnc_fsObjExists)) then {
                [[], _filesystem, _link, _catalogPath, "root", _user, _appPerms] call AE3_filesystem_fnc_symlink;
            };
        } else {
            {
                private _link = _desktop + "/" + _x;
                if ([[], _filesystem, _link, "root"] call AE3_filesystem_fnc_fsObjExists) then {
                    private _obj = [(_link splitString "/"), _filesystem] call AE3_filesystem_fnc_resolvePntr;
                    private _target = [(_obj select 0)] call AE3_filesystem_fnc_symlinkTarget;
                    private _content = _obj select 0;
                    if (_target isEqualTo _catalogPath || {_content isEqualTo _launcherContent}) then {
                        [[], _filesystem, _link, "root"] call AE3_filesystem_fnc_delObj;
                    };
                };
            } forEach _launcherNames;
        };
    } forEach _users;

    // Broadcast globally (not just to the desktop's current owner) so the server's canonical
    // filesystem always reflects the launcher removal, even when the sync is triggered by a
    // remote client on a dedicated server.
    _computer setVariable ["AE3_filesystem", _filesystem, true];
} catch {
    diag_log text format ["[ROOT_CYBERWARFARE WARNING] Hackerman desktop sync failed: %1", _exception];
};
