# Changelog

## Major Update 2 (v2.0.0.0)

### Added

- A full **Hackerman Desktop** interface for AE3 laptops. Players can now use point-and-click applications for Doors, Lights, Vehicles, Drones, GPS, Databases, Custom Devices, Power Grid control, NetScan, Crypto, and Crack; the applications operate on the same accessible-device list and power economy as the terminal.
- A **NetScan** feature in both the terminal and desktop. It reports the laptop-visible subnet, including host IP address, device type, external SSH exposure, network interface, and the accessible hackable devices associated with each host. Scan reports can also be exported into the laptop filesystem.
- Terminal and desktop **cryptography tools**:
  - `crypto` encrypts or decrypts text and laptop files, and can save results to a chosen path.
  - `crack` attempts to identify or brute-force supported ciphers and ranks likely plaintext candidates.
  - Supported algorithms include Morse, spelling alphabet, Affine, ROT, Vigenere, Bacon, alphabetical substitution, Rail Fence, Base32, Base64, Ascii85, Unicode notation, and integer encodings.
- Mission-makers can now create encrypted database content directly from Eden and configure its cipher, key/variant, and options. The cipher options are also available when using AE3's Add File module, and a new Zeus **Cipher Tools** module supports cipher setup during play.
- The **Rubberducky USB**, a placeable and Arsenal-available AE3-compatible flash drive preloaded with the hacking toolset. Plugging it into a laptop makes the tools available, preserves the drive's unique contents across pickup and reconnection, and presents the Hackerman launcher while connected.
- Configurable Rubberducky login seeding. By default, connecting a tools USB creates the `quack` / `quack` account if it is absent; mission makers can disable this behavior or set their own credentials.
- An optional **77th JSOC EWO Mode** with ACE actions for registering and renaming hackable laptops in the field.
- EWO backpack support: operators can charge carried laptops, inspect charging status, broadcast a configurable password-protected wireless network, and connect the pack to nearby active AE3 power sources to recharge it. Network broadcast, charging, and recharge rates are mission-configurable.
- A dedicated Eden **Register Hackable Laptop** module and a matching Zeus workflow. Laptops can be registered without automatically receiving hacking tools, allowing missions to separate access points from the tool delivery method.
- A Zeus **Clear Broken Device Links** module and an optional scheduled cleanup system for purging links whose laptop or device no longer exists. Cleanup timing and grace behavior are configurable.
- Mission-maker controls for stable four-digit device IDs. Doors, lights, databases, vehicles, GPS trackers, custom devices, and power grids can use fixed IDs; trigger-based registration modules can also distribute IDs through configured ranges.
- Per-device **Allow Location View** controls for doors, lights, vehicles, custom devices, and power grids. When disabled, terminal and desktop listings hide the device grid reference.
- New configurable default power costs for vehicle actions and GPS tracker pings, with per-device costs still able to override the mission default.
- Vehicle-control improvements: configurable remote braking, drivetrain-aware speed changes, automatic engine start for speed control, damage-based speed limiting, and release of held speed when a vehicle can no longer be driven.
- Additional vehicle status support for detailed device listings, including drivetrain information and remote speed-lock release handling.
- New audiovisual assets for the Rubberducky/Hackerman experience, including connection audio and a desktop loading/intro video.

### Removed

- The deprecated **Add Devices** Eden module has been removed. Missions should register the appropriate device type with the dedicated Doors, Lights, Vehicle, Database, GPS, Custom Device, or Power Grid module instead.
- The deprecated generic **Add Hackable Object** Zeus module has been removed and replaced by **Register Hackable Laptop** for laptop registration.

### Changed

- Hacking-tool availability now follows the mounted USB state: a laptop provisioned through a tools USB gains the terminal and desktop tools when the drive is connected and loses USB-provisioned tools when the final tools drive is removed. Directly installed mission tools remain intact.
- The Hackerman launcher and desktop app group now appear only when hacking tools are available, and are refreshed for active desktop users after USB-volume changes.
- Device access, desktop requests, and desktop actions are validated on the server before their results are sent to the requesting player, improving multiplayer synchronization and authority over door, light, vehicle, drone, GPS, database, custom-device, and power-grid operations.
- Device-registry synchronization is consolidated and debounced, including server-authoritative GPS tracker status updates. This reduces unnecessary broadcasts while keeping client lists current.
- Device-link maintenance now handles invalid or deleted objects more reliably; mission makers may clear broken links manually or enable periodic cleanup with a configurable grace period.
- Eden registration modules now expose more precise setup controls: triggers can distribute IDs through a range, door IDs can be overridden individually, and module synchronization targets have been narrowed where appropriate to make placement less error-prone.
- Vehicle hacking consumes the configured global vehicle cost unless an individual vehicle supplies its own cost, and all vehicle operations use the common power-check and confirmation flow.
- Speed hacking now applies requested speed in km/h relative to the vehicle's current forward motion, clamps it to the capability of the remaining engine and wheels, and reports when damage reduces the requested effect.
- Remote braking is performed through the shared braking routine, giving braking actions consistent deceleration and a brief stopped hold.
- Power consumption handling has been standardized across the new and existing operations, so insufficient-power checks and battery deductions are consistent.
- Database, device, and laptop setup workflows now distinguish between registering a hackable station, granting device access, and installing hacking tools; this makes staged mission progression and physical tool delivery easier to build.

## Update 7 (v1.1.4.2)

### Added
- Added GPS Tracker Icon whitelist / blacklist in the CBA settings
- Added "Enable GPS Tracker Search" option to enable/disable search for GPS on objects (configurable via CBA settings)

### Removed
- N/A

### Changed
- Doors will now be compatible with CUP and Cytech Assets

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
