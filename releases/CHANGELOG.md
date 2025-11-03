# Changelog

## Update 2 (v1.0.3.1)

### Added
- Direct placement of zeus modules on terrain objects like buildings, streetlamps, etc will select the nearest object of the module for linking.
- Added 'Radius' mode for bulk registration for Hackable Objects, Custom Devices, and Vehicles zeus modules when placing the module on an empty ground.

### Fixed
- ACE GPS Seach/Attach interaction to use a more whitelist based object class identification before adding its functions.

### Changed
- Added an additional 5 seconds of wait time before GPS functions are initialized in the server. Only when the uiTime and serverTime are atleast 10 seconds are the GPS functions initialized on players and objects.
- Added blacklist of 'WeaponHolder' and 'WeaponHolderSimulated' object types to be ignored by the GPS search/attach function.

## Update 1 (v1.0.2.1)

### Added
- N/A

### Fixed
- ACE GPS Seach/Attach interaction messing with weapon holders, ground items, and explosives interaction

### Changed
- Add Hackable File and Add Hacking Tools 3DEN Modules to be initialized after 10 seconds of mission start to prevent issues of filesystem permission from AE3

## Hotfix 1 (v1.0.1.1)

### Added
- N/A

### Fixed
- Power Generator in 3DEN not initializing
- All Devices array initialized incorrectly with wrong number of parameters

### Changed
- Added player object as additional reference to activation/deactivation blocks in File download and Custom devices

## Initial Public Release (v1.0.0.0)

### Added
- 8 zeus and 3den modules.

### Fixed
- N/A

### Changed
- N/A

## Draft Private Release (v0.5.0.0)

### Added
- 3 zeus modules

### Fixed
- N/A

### Changed
- N/A

#### Archive
https://postimg.cc/gallery/CYmFPSG
