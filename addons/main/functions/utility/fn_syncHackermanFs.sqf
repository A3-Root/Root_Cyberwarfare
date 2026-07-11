#include "\z\root_cyberwarfare\addons\main\script_component.hpp"
/*
 * Author: Root
 * Description: Server-side, serialized update of a computer's virtual filesystem so that every user's
 *              Desktop carries exactly one Hackerman.exe launcher while the hacking toolset is
 *              available, and none when it is not. Runs on the server only: the filesystem is a
 *              read-modify-write on a single object variable, so doing it on clients let two desktops
 *              race and duplicate the ~/Desktop entries. Also removes any duplicate launcher entries
 *              left behind by earlier races.
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

if (!isServer) exitWith {};
if (isNull _computer || {isNil "AE3_filesystem_fnc_fsObjExists"}) exitWith {};

private _filesystem = _computer getVariable ["AE3_filesystem", []];
if (_filesystem isEqualTo []) exitWith {};

private _catalogPath = "/usr/share/applications/RootCW_Hackerman.app";
private _launcherName = "Hackerman.exe";
private _legacyLauncherNames = ["Hackerman.app"];
private _launcherContent = "app=RootCW_Hackerman";
private _appPerms = [[true, true, true], [true, false, true]];

// True when the filesystem object is one of this mod's launcher entries (symlink to the catalog file
// or a plain file carrying the launcher content).
private _isLauncherObj = {
    params ["_path"];
    if (!([[], _filesystem, _path, "root"] call AE3_filesystem_fnc_fsObjExists)) exitWith { false };
    private _obj = [(_path splitString "/"), _filesystem] call AE3_filesystem_fnc_resolvePntr;
    private _target = [(_obj select 0)] call AE3_filesystem_fnc_symlinkTarget;
    private _content = _obj select 0;
    _target isEqualTo _catalogPath || {_content isEqualTo _launcherContent}
};

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

        [[], _filesystem, _desktop, "root", _user, _appPerms] call AE3_filesystem_fnc_ensureDir;

        // Drop every launcher entry this mod may have written under any of its names, then re-create
        // only the wanted one. This also heals desktops that show two icons because both the current
        // and a legacy launcher name are present.
        {
            private _link = _desktop + "/" + _x;
            if ([_link] call _isLauncherObj) then {
                [[], _filesystem, _link, "root"] call AE3_filesystem_fnc_delObj;
            };
        } forEach ([_launcherName] + _legacyLauncherNames);

        if (_available) then {
            private _link = _desktop + "/" + _launcherName;
            if (!([[], _filesystem, _link, "root"] call AE3_filesystem_fnc_fsObjExists)) then {
                [[], _filesystem, _link, _catalogPath, "root", _user, _appPerms] call AE3_filesystem_fnc_symlink;
            };
        };
    } forEach _users;

    // Broadcast the canonical filesystem so every client viewing this computer sees the same desktop.
    _computer setVariable ["AE3_filesystem", _filesystem, true];
} catch {
    diag_log text format ["[ROOT_CYBERWARFARE WARNING] Hackerman desktop sync failed: %1", _exception];
};
