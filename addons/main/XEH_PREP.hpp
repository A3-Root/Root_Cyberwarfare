// Core functions
PREP(initSettings);
PREP(isDeviceAccessible);
PREP(cleanupDeviceLinks);
PREP(createDiaryEntry);

// Utility functions (to be created)
PREP(checkPowerAvailable);
PREP(consumePower);
PREP(getUserConfirmation);
PREP(getAccessibleDevices);
PREP(cacheDeviceLinks);

// Device functions
PREP(changeDoorState);
PREP(changeLightState);
PREP(changeDroneFaction);
PREP(disableDrone);
PREP(customDevice);
PREP(changeVehicleParams);
PREP(listDevicesInSubnet);

// GPS functions
PREP(gpsTrackerClient);
PREP(gpsTrackerServer);
PREP(aceAttachGPSTrackerSelf);
PREP(aceAttachGPSTrackerObject);
PREP(searchForGPSTracker);
PREP(disableGPSTracker);
PREP(disableGPSTrackerServer);
PREP(displayGPSPosition);
PREP(revealLaptopLocations);

// Database functions
PREP(downloadDatabase);

// Zeus functions
PREP(addDeviceZeus);
PREP(addDeviceZeusMain);
PREP(addDatabaseZeus);
PREP(addDatabaseZeusMain);
PREP(addGPSTrackerZeus);
PREP(addGPSTrackerZeusMain);
PREP(addVehicleZeus);
PREP(addVehicleZeusMain);
PREP(modifyPowerZeus);
PREP(addHackingToolsZeus);
PREP(addHackingToolsZeusMain);

// Utility functions
PREP(removePower);
PREP(localSoundBroadcast);
