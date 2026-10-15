---
topic: device-registry-and-access
status: verified
last-verified: 2026-07-08
confidence_score: 0.95
priority: core
rank: 1
tokens: 420
code-paths:
  - addons/main/functions/core/
  - addons/main/functions/utility/
  - addons/main/functions/zeus/
related-topics:
  - terminal-and-desktop
  - zeus-and-eden-setup
  - power-grid-control
  - vehicle-and-drone-control
  - gps-tracking
  - database-and-custom-devices
---

## overview
Server-authoritative registry and access model for all hackable devices. It is the shared layer that decides who can see a device, how laptops become stations, and when stale links are cleaned up.

## current behavior
- `ROOT_CYBERWARFARE_ALL_DEVICES` stores eight device categories in mission namespace.
- `ROOT_CYBERWARFARE_LINK_CACHE` tracks laptop-to-device links.
- `ROOT_CYBERWARFARE_PUBLIC_DEVICES` tracks devices exposed to current or future laptops, with per-laptop exclusions when needed.
- `Root_fnc_addComputerDeviceLinks` is used by registration functions to add links atomically.
- `Root_fnc_isDeviceAccessible` gates terminal actions by device type, command path, and link/public state.
- `Root_fnc_registerHackableLaptopZeusMain` marks a laptop as a hackable station and publishes its display name.
- `Root_fnc_addHackingToolsZeusMain` installs the toolset but does not itself make an object a station.
- `Root_fnc_syncHackingToolAvailability` publishes whether a laptop has tools locally or on a mounted USB drive.
- `Root_fnc_runDeviceLinkCleanup` removes stale links and device rows using a strike-based grace period.
- `Root_fnc_initBreachIntegration` blocks breach attempts against cyber-locked doors when the optional breach mod is present.

- **Remote sessions, two kinds, one union.** `getSessionComputers [_computer]` returns the computer plus (a) the operator's computer when this one is the target of an **AE3 terminal** session (`AE3_stdoutRedirect`, which AE3 sets without a public flag, so it resolves **on the operator's client only**) and (b) the **Hackerman SSH** target when this one is the operator (`ROOT_CYBERWARFARE_HACK_SESSIONS`, a server-only map mirrored on the operator computer as `ROOT_CYBERWARFARE_hackSession`, so it resolves on the server *and* on clients). `isDeviceAccessible` unions backdoor paths, tool availability and link identifiers over all of them, so the operator's tools drive a target's links. The backdoor prefix check returns `true` properly (the old `exitWith` inside `forEach` was discarded).
  - **Why the second kind had to exist:** every desktop device list and action is built on the **server** (`fn_gui_sendDeviceList.sqf`, the eight `fn_gui_*Action`), where the AE3 redirect is invisible - so terminal-only remoting meant the desktop could never reach a remote laptop's devices. Anything that needs to work from the desktop must not depend on a client-local variable.
  - Session gates mirror `fnc_os_ssh.sqf` (route via `AE3_network_fnc_resolve`, `AE3_cap_hasTerminal`, `AE3_ssh_enabled`, powered, credentials against the target's own `AE3_Userlist` + root policy) but credentials are compared **on the server**, which already holds the authoritative list. The target's `AE3_computer_mutex` is deliberately **not** claimed, unlike AE3's `ssh`, so the target's own user is not locked out. Attempts append to the target's `/var/log/auth.log` through `AE3_filesystem_fnc_device_writeFile`. `fn_hackSessionSweep` (10 s, registered only while a session exists) re-tests the same conditions and closes dead sessions.
- **Who pays:** the computer the device is **linked to**. `getDevicePowerComputer [_computer, _type, _id]` asks `hasDeviceLink` for the operator first (so a device both ends can reach, or one neither owns a route to, bills the operator) and otherwise bills the session partner. `getPowerComputer` is now only the operator's own machine, for costs that belong to no device. `checkPowerAvailable`/`consumePower`/`getUserConfirmation`/`getBatteryStatus` take an optional trailing `_deviceType, _deviceId` and every device action passes them; `consumePower` names the payer in the `root_cyberwarfare_consumePower` event while the cost text still goes to the operator's screen.
- **Device identifiers (non-GPS):** `applyDeviceAccess` auto-registers an 8-char code per device (`registerDeviceIdentifier`, server-only maps `ROOT_CYBERWARFARE_DEVICE_IDENTIFIERS` code->[type,id,grants] and `..._INDEX` "type:id"->code; generator shared with GPS so codes never collide) and appends it to the curator feedback. `setDeviceIdentifier` (API, Zeus/Eden *Device Identifier* module, by type+id or object) sets a custom code / alias-only. Tool templates call `resolveDeviceArg` before each command: non-numeric args go to server event `root_cyberwarfare_resolveIdentifier`; a granting code adds a client-local grant (`ROOT_CYBERWARFARE_IDENTIFIER_GRANTS`, checked in `isDeviceAccessible` after the tools check) cleared by `clearIdentifierGrants` after the command. Online rule reuses `SETTING_GPS_IDENTIFIER_ONLINE`.
- **Codes reach the desktop too, not just the terminal.** Every device app carries a **By identifier** whole-app action (added to `_globals` for every hacking-tools app but the scanner and GPS in `fn_gui_registerApps`, `flow = "prompt"`), and `dev_action` short-circuits `byid` to `root_cyberwarfare_gui_identifierAdd` -> `fn_gui_resolveIdentifier` -> `fn_gui_sendDeviceList`: the code is resolved, the laptop is left a grant, and the list comes back with the device in it, so every ordinary row action then works unchanged. The native fallback apps get the same reach from a shared identifier box built by `fn_gui_buildListApp` (`ROOT_gui_idEdit_<type>`, read back by `fn_gui_identifierText`), whose text each action sends as a last argument for the seven `fn_gui_*Action` handlers to resolve. GPS keeps its own `trackid` action, because a hidden tracker opens a map instead of joining a list.
- **Grants are keyed two ways** (`GVAR_IDENTIFIER_GRANTS`, `IDENTIFIER_GRANT_DURATION` seconds): `"type:id"` written on the operator's own machine by `resolveDeviceArg` for a terminal command, and `"laptopNetId:type:id"` written on the server for a desktop one. The server key has to name the laptop - a desktop app resolves on the server, where the plain key would hand the device to every laptop in the mission. `isDeviceAccessible` checks the plain key plus one per session computer.
- **`exitWith` inside a `then` block leaves the block, not the function**, so the identifier resolve in each `fn_gui_*Action` sets the device id to -1 and the guard that aborts sits after the block.
- Tool templates call `Root_fnc_*` directly (same scheduled thread) instead of remoteExec + 10 s flag wait; Ctrl+C now kills the operation. Only `netscan` still round-trips the server with the flag.

## decisions
- Keep station registration separate from tool installation, so a laptop can be named and linked before it has a toolset. Supersedes the older implied-coupling behavior where install and station status were treated as one action.
- Support both simple and experimental device setup modes, because the mod can identify laptops by netId in one mode and by player UID in the other.
- Store public device exclusions for current laptops when a device is meant for future laptops, so access does not retroactively appear on machines already in the mission.
- Use strike-based cleanup for missing objects because object references can disappear briefly during replication or player join timing.
- Treat a resolved object as the strongest existence signal. A missing network flag alone is not enough to delete registry data.

## gotchas
- Cleanup must not trust `ROOT_CYBERWARFARE_HACKABLE_LAPTOP` by itself; that flag can lag replication.
- Public devices and link cache both need to stay synchronized with mission namespace, or terminal access will drift from the registry.
- Device IDs are generated randomly and must remain unique across the per-type arrays.
- The simple mode depends on laptop netIds resolving on the server, so null resolution can happen transiently before the grace limit expires.

## references
- `addons/main/functions/core/`
- `addons/main/functions/utility/`
- `addons/main/functions/zeus/`
- `addons/main/CfgFunctions.hpp`
- `addons/main/config.cpp`
