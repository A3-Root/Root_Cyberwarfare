# Changelog

## Update 7 (v1.1.4.2)

### Added
- N/A

### Removed
- N/A

### Changed
- Doors will now be compatible with CUP and Cytech Assets
- Added GPS Tracker Icon whitelist / blacklist in the CBA settings

## Update 6 (v1.1.4.1)

### Added
- Added separate Doors and Lights zeus modules which were previously missing due to a commented line I forgot to 'uncomment'
- **Customizable Vehicle Operation Limits** - Mission makers can now configure min/max ranges for all vehicle operations:
  - Battery/Fuel: Min/Max percentage limits (0-100%)
  - Speed: Min/Max boost values in km/h (supports negative for slowdown)
  - Brakes: Min/Max deceleration rate in m/s² with configurable braking strength
  - Lights: Maximum toggle count and cooldown timer between toggles
  - Engine: Maximum toggle count and cooldown timer between toggles
  - Alarm: Min/Max duration in seconds
- 12 new slider controls in Zeus "Add Hackable Vehicle" module for setting operation limits
- 12 new attribute fields in 3DEN "Add Hackable Vehicle" module for setting operation limits
- Runtime validation that rejects operations outside configured limits with detailed error messages
- Persistent toggle counters and cooldown timers for lights and engine operations

### Removed
- N/A

### Changed
- Vehicle data structure expanded from 12 to 30 elements (18 new limit parameters + 6 reserved slots)
- Brakes operation now uses configurable deceleration rate instead of hardcoded 6 m/s²
- `fn_addVehicleZeusMain` now accepts 24 parameters for vehicles (was 12)
- All vehicle operation functions now validate against configured limits before execution
- Updated SQFdoc headers for all modified functions to reflect new parameters

## Update 5 (v1.1.3.1)

### Added
- N/A

### Removed
- N/A

### Changed
- Optimizations and bugfixes

## Update 4 (v1.1.2.1)

### Added
- Seperate 3DEN Modules for Doors and Lights

### Removed
- Deprecated "Add Devices" module in lieu of Add Doors and Add Lights module. For backwards compatibility, this module is kept in the mod for the next 6 months giving ample time for people to safely switch to the new modules.

### Changed
- Even more fixes (FFS) on GPS Search interfering with ACE Interaction
- Proper trigger shape detection for synchronized objects in 3DEN Editor

## Update 3 (v1.1.1.1)

### Added
- N/A

### Removed
- N/A

### Changed
- Search for GPS Tracker and Attach GPS Trackers are now hardcoded to exclude all ACE items (https://ace3.acemod.org/wiki/class-names)

## Update 2 (v1.1.0.1)

### Added
- Built-in help system for all terminal commands - Type `<command> help`, `<command> -h`, or `<command> --help` to display detailed syntax, available actions, examples, and usage notes with color-coded formatting
- Direct placement of zeus modules on terrain objects like buildings, streetlamps, etc will select the nearest object of the module for linking.
- Added 'Radius' mode for bulk registration for Hackable Objects, Custom Devices, and Vehicles zeus modules when placing the module on an empty ground.

### Removed
- N/A

### Changed
- Added an additional 5 seconds of wait time before GPS functions are initialized in the server. Only when the uiTime and serverTime are atleast 10 seconds are the GPS functions initialized on players and objects.
- Added blacklist of 'WeaponHolder' and 'WeaponHolderSimulated' object types to be ignored by the GPS search/attach function.
- Modified the dive listings to show a high level list with optional command to show detailed list. Helps prevent the display from being cut off.
- ACE GPS Seach/Attach interaction to use a more whitelist based object class identification before adding its functions.

## Update 1 (v1.0.2.1)

### Added
- N/A

### Removed
- N/A

### Changed
- Add Hackable File and Add Hacking Tools 3DEN Modules to be initialized after 10 seconds of mission start to prevent issues of filesystem permission from AE3
- ACE GPS Seach/Attach interaction messing with weapon holders, ground items, and explosives interaction

## Hotfix 1 (v1.0.1.1)

### Added
- N/A

### Removed
- N/A

### Changed
- Added player object as additional reference to activation/deactivation blocks in File download and Custom devices
- Power Generator in 3DEN not initializing
- All Devices array initialized incorrectly with wrong number of parameters

## Initial Public Release (v1.0.0.0)

### Added
- 8 zeus and 3den modules.

### Removed
- N/A

### Changed
- N/A

## Draft Private Release (v0.5.0.0)

### Added
- 3 zeus modules

### Removed
- N/A

### Changed
- N/A

#### Archive
https://postimg.cc/gallery/CYmFPSG
