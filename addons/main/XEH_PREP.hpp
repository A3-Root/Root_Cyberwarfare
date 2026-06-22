// Redefine PREP macro for subdirectory: 3den
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\3den\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(3denAddHackingTools);
PREP(3denAdjustPowerCost);
PREP(3denAddDevices);
PREP(3denAddDoors);
PREP(3denAddLights);
PREP(3denAddDatabase);
PREP(3denAddVehicle);
PREP(3denAddGPSTracker);
PREP(3denAddCustomDevice);
PREP(3denAddPowerGenerator);

// Redefine PREP macro for subdirectory: core
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\core\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addHackingToolsZeusMain);
PREP(cleanupDeviceLinks);
PREP(createDiaryEntry);
PREP(initBreachIntegration);
PREP(initSettings);
PREP(isDeviceAccessible);
PREP(gridLabel);
PREP(listDevicesInSubnet);

// Redefine PREP macro for subdirectory: custom
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\custom\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addCustomDeviceZeusMain);
PREP(customDevice);

// Redefine PREP macro for subdirectory: database
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\database\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addDatabaseZeusMain);
PREP(downloadDatabase);

// Redefine PREP macro for subdirectory: devices
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\devices\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addDeviceZeusMain);
PREP(addDoorsZeusMain);
PREP(addLightsZeusMain);
PREP(changeDoorState);
PREP(changeLightState);

// Redefine PREP macro for subdirectory: gps
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\gps\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(aceAttachGPSTracker);
PREP(addGPSTrackerZeusMain);
PREP(disableGPSTracker);
PREP(disableGPSTrackerServer);
PREP(displayGPSPosition);
PREP(gpsTrackerClient);
PREP(gpsTrackerServer);
PREP(revealLaptopLocations);
PREP(searchForGPSTracker);

// Redefine PREP macro for subdirectory: powergenerator
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\powergenerator\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addPowerGeneratorZeusMain);
PREP(powerGeneratorLights);
PREP(powerGridControl);

// Redefine PREP macro for subdirectory: utility
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\utility\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(cacheDeviceLinks);
PREP(syncDeviceData);
PREP(checkPowerAvailable);
PREP(consumePower);
PREP(copyDeviceLinksZeusMain);
PREP(detectBuildingDoors);
PREP(getAccessibleDevices);
PREP(getBatteryStatus);
PREP(getComputerIdentifier);
PREP(getObjectsInTriggerArea);
PREP(getPlayerFromComputer);
PREP(getUserConfirmation);
PREP(localSoundBroadcast);
PREP(removePower);

// Redefine PREP macro for subdirectory: vehicle
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\vehicle\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addVehicleZeusMain);
PREP(changeDroneFaction);
PREP(changeVehicleParams);
PREP(disableDrone);

// Redefine PREP macro for subdirectory: gui
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\gui\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(gui_registerApps);
PREP(gui_requestDevices);
PREP(gui_sendDeviceList);
PREP(gui_buildListApp);
PREP(gui_doorAction);
PREP(gui_lightAction);
PREP(gui_droneAction);
PREP(gui_powergridAction);
PREP(gui_databaseAction);
PREP(gui_customAction);
PREP(gui_vehicleAction);
PREP(gui_gpsAction);
PREP(gui_appDoors);
PREP(gui_appLights);
PREP(gui_appDrones);
PREP(gui_appPowergrid);
PREP(gui_appDatabases);
PREP(gui_appCustom);
PREP(gui_appVehicles);
PREP(gui_appGps);
PREP(gui_appGpsMap);

// Redefine PREP macro for subdirectory: zeus
#undef PREP
#define PREP(fncName) [QPATHTOF(functions\zeus\DOUBLES(fn,fncName).sqf),QFUNC(fncName)] call CBA_fnc_compileFunction

PREP(addCustomDeviceZeus);
PREP(addDatabaseZeus);
PREP(addDeviceZeus);
PREP(addDoorsZeus);
PREP(addLightsZeus);
PREP(addGPSTrackerZeus);
PREP(addHackingToolsZeus);
PREP(addPowerGeneratorZeus);
PREP(addVehicleZeus);
PREP(copyDeviceLinksZeus);
PREP(modifyPowerZeus);
