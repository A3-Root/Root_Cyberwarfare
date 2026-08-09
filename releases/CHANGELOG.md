# Changelog

## Hotfix 9 (v2.0.0.2)

### Added

- A Zeus **Manage Device Access** module for rewiring device access during play, working device-first where the existing Manage Device Links module works laptop-first. Placed on a registered object it opens that object's devices; placed on open ground it asks for a radius, reports how many devices of which types it found inside it, and then walks them one dialog at a time. Each dialog shows the device's current access mode and a checkbox per laptop, already ticked wherever that laptop reaches the device, so the existing wiring is visible before it is changed. Confirming sets that device's access to exactly what the dialog shows - unticking a laptop removes its access - and cancelling leaves the device alone and moves on to the next.
- A scriptable `Root_fnc_setDeviceAccessMain` behind the module, for missions that want to set a device's complete access state from a trigger or script rather than adding and removing links one at a time.
- A **Messages** input source in the Cryptography app. It lists the laptop's inbox, sent mail, and chat messages, and loads the body of the one you pick straight into the input box, so intercepted traffic can be decrypted without copying it out by hand.
- A **Send to Cryptography** entry in the Email and Messenger right-click menus, on a message in the list, an open email, a single chat bubble, and a whole conversation. It opens Cryptography with that text already loaded. The entry only appears on laptops that have the hacking toolset.
- CBA settings for the Hackerman intro video: one to switch it off entirely, and a cooldown slider controlling how soon it may play again on the same laptop (0 plays it on every connection). The previous fixed two-minute cooldown is now the slider's default.
- CBA settings for drive audio: separate on/off switches for the Rubberducky sound and the standard flash drive sound, plus a shared volume slider for both. Muting a drive silences it on disconnect as well as on connect.
- A CBA setting listing the backpack classnames treated as **77th JSOC EWO** packs. Missions can point EWO mode at their own pack; clearing the box restores the default list rather than disabling the mode.
- A server-forced CBA setting, *List All Laptops In Device Modules*, on by default. On, every laptop on the map is offered as a link target in the Zeus and device modules, including bare ones with no hacking tools yet, so a mission can wire devices during setup and deliver the toolset later. Off, only laptops that are already registered stations or already carry the tools are listed, which suits missions that place unrelated laptops as scenery. Clients cannot override it, and it takes effect on the next dialog opened - no mission restart.
- An AE3 setting, *Sudoers act as root at the terminal*, on by default. Accounts in `/etc/sudoers` can now read and write any file from the terminal, the way they already could from the desktop file manager. Turn it off for strict Unix semantics, where a sudoer must use `sudo` or `su` first.

### Removed
- N/A

### Changed

- **Fixed:** the laptop checkbox list in the Zeus device modules was empty unless a laptop had been through the Register Hackable Laptop module, leaving Public as the only way to grant any access. Every module now lists laptops according to the new *List All Laptops In Device Modules* setting, which by default includes bare laptops that have not received the hacking toolset yet - a mission can wire devices to a laptop during setup and deliver the tools later, and the link starts working the moment they arrive. Laptops that cannot hack yet are marked in the list rather than hidden, and the Add Hacking Tools module registers the laptop it installs onto as a station. USB drives are still not link targets - they deliver the tools rather than run them.
- The Zeus device modules warn up front when a mission has no laptops at all, instead of opening a form with no laptops in it.
- The future-laptop exclusion list is built from the same laptop roster the module dialogs offer, so a laptop that could be ticked is a laptop the access mode accounts for.
- The Rubberducky login account is now a superuser. It can open other users' files and home directories on the laptop instead of being turned away with a missing-permissions error, both in the desktop file browser and, with the new AE3 setting on, at the terminal. An account that already exists is raised to superuser without its password being changed.
- Cryptography results from an "All" or Bruteforce run are separated by blank lines and given a header per cipher, so a result that spans several lines can still be traced to the cipher that produced it. Multi-file runs are broken up the same way. The terminal `crack` command follows the same layout.

## Hotfix 8 (v2.0.0.1)

### Added

- A **Device Access** setting on every Zeus and Eden device module (Doors, Lights, Vehicles, Files, GPS Trackers, Custom Devices, Power Grids). It replaces the old "Add to Public Device List" checkbox with explicit options: *Unassigned*, *Linked computers only*, *Linked computers + all future laptops* (Eden), and *Public*. Unassigned registers the device on the network without granting any laptop access to it, so mission makers can place devices up front and hand out access later.
- A Zeus **Manage Device Links** module. Placed on a registered laptop it lists every registered device with its type, ID, name, and current link state; placed on the ground it first asks which laptop to work on. Ticked devices can be linked, unlinked, published to all laptops, or unassigned again during play.
- An Eden **Link Devices** module. Synchronize laptops to it and list the devices as `deviceType:deviceId` pairs to link, unlink, publish, or unassign them at mission start, after the add-device modules have handed out their IDs.
- A scriptable `Root_fnc_setDeviceLinksMain` behind both modules, for missions that want to grant or revoke device access from triggers and scripts.

### Removed
- N/A

### Changed

- **Breaking:** a device with no linked laptops is no longer silently treated as public. Access is now always stated by the module's Device Access setting, and the Zeus device dialogs no longer select every laptop for you when none are ticked.
- **Breaking:** the `Root_fnc_add*ZeusMain` functions take an additional trailing access-mode argument. Scripts and triggers calling them through `remoteExec` should pass it; callers that omit it now register the device as Unassigned.
- Eden missions saved before this release are migrated automatically: the legacy "Add to Public Device List" checkbox is carried forward to the equivalent Device Access value, so existing missions behave as they did in 2.0.0.0.
- Device access application - private links, public registration, and the future-laptop exclusion list - is consolidated into one shared routine used by every device type, so all access modes behave identically across the modules.
- The "Make Unbreachable" option now reaches the buildings registered by the Zeus Add Hackable Doors module in radius mode, which previously discarded it.
- Granting a laptop access to a device raises the device-linked event consistently, whichever module or script performed the linking.

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
