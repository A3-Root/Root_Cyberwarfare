// Root_fnc_cleanupDeviceLinks
// Cleans up device links for deleted computers

if (!hasInterface) exitWith {};

player createDiaryRecord ["Diary", ["Root's Cyberwarfare 101",
    "This cheat sheet is intended to help you use the cyberwarfare terminal. !!! ALL COMMANDS ARE CASE SENSITIVE! !!!
    <br/><br/>
    Default Tool Location:
    <br/>
    /rubberducky/tools
    <br/><br/>
    Type 'cat guide' to view the contents of the file / guide on the functions available:
    <br/>
    (Only available to execute in the folder where the tools are installed.)
    <br/><br/>
    Type 'cd' to move into and out of folders:
    <br/>
    Ex: cd Files (to move into the 'Files' directory inside the CURRENT directory where you are at).
    <br/>
    So if you are inside the '/rubberducky/tools' directory and you want to move into the 'Files' directory you would type: cd Files
    <br/><br/>
    cd .. (to move out of the CURRENT directory to the PARENT directory)
    <br/>
    So if you are inside the '/rubberducky/tools/Files' directory and you want to move out to the 'tools' directory you would type: cd ..
    <br/><br/>
    Type 'ls' to list files and folders in the current directory.
    <br/>
    You can also use 'ls -la' to view more detailed information about files and folders (including hidden files and folders).
    <br/><br/>
    Type 'devices' to list all devices you can hack into.
    <br/><br/>
    Type 'door BuildingID DoorID (ID or 'a' for all) lock/unlock' to lock/unlock doors. Ex: 'door 4514 2 lock' or 'door 4514 a unlock’
    <br/><br/>
    Type 'light LightID (ID or 'a' for all) off/on' to turn lights off or on. Ex: 'light a on' or 'light 3 off’
    <br/><br/>
    Type 'changedrone DroneID (ID or 'a' for all) side (west/east/guer/civ)' to switch the side of a drone. Ex: 'changedrone 2 east’
    <br/><br/>
    Type 'disabledrone 'DroneID (ID or 'a' for all)' to disable (explode) the drones. Ex: 'disabledrone 2' or 'disabledrone a’
    <br/><br/>
    Type 'download FileID' to download the File into the folder 'Files'. Ex: 'download 1234'
    <br/><br/>
    Type 'custom customID activate' to activate a custom. Ex: 'custom 2312 activate'
    <br/><br/>
    Clear the screen and view history:
    <br/><br/>
    Type 'clear' to clear the terminal screen. Type 'history' to view command history."
]];

true
