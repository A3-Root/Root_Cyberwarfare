// Redefine PREP macro for subdirectory: core
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\core\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(initSettings);
PREP(isDeviceAccessible);
PREP(cleanupDeviceLinks);
PREP(createDiaryEntry);

// Redefine PREP macro for subdirectory: utility
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\utility\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(cacheDeviceLinks);
PREP(getAccessibleDevices);
PREP(checkPowerAvailable);
PREP(consumePower);
PREP(getUserConfirmation);
PREP(removePower);
PREP(localSoundBroadcast);
PREP(powerGeneratorLights);

// Redefine PREP macro for subdirectory: devices
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\devices\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(changeDoorState);
PREP(changeLightState);
PREP(changeDroneFaction);
PREP(disableDrone);
PREP(customDevice);
PREP(changeVehicleParams);
PREP(listDevicesInSubnet);

// Redefine PREP macro for subdirectory: gps
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\gps\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(gpsTrackerClient);
PREP(gpsTrackerServer);
PREP(aceAttachGPSTracker);
PREP(searchForGPSTracker);
PREP(disableGPSTracker);
PREP(disableGPSTrackerServer);
PREP(displayGPSPosition);
PREP(revealLaptopLocations);

// Redefine PREP macro for subdirectory: database
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\database\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(downloadDatabase);

// Redefine PREP macro for subdirectory: zeus
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\zeus\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addDeviceZeus);
PREP(addDeviceZeusMain);
PREP(addDatabaseZeus);
PREP(addDatabaseZeusMain);
PREP(addGPSTrackerZeus);
PREP(addGPSTrackerZeusMain);
PREP(addVehicleZeus);
PREP(addVehicleZeusMain);
PREP(addPowerGeneratorZeus);
PREP(addPowerGeneratorZeusMain);
PREP(modifyPowerZeus);
PREP(addHackingToolsZeus);
PREP(addHackingToolsZeusMain);

// Redefine PREP macro for subdirectory: 3den
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\3den\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(3denAddHackingTools);
PREP(3denAdjustPowerCost);
PREP(3denAddDevices);
PREP(3denAddDatabase);
PREP(3denAddVehicle);
PREP(3denAddGPSTracker);
PREP(3denAddCustomDevice);
