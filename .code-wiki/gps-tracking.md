---
topic: gps-tracking
status: verified
last-verified: 2026-07-08
confidence_score: 0.94
priority: core
rank: 6
tokens: 360
code-paths:
  - addons/main/functions/gps/
  - addons/main/functions/utility/fn_syncDeviceData.sqf
  - addons/main/functions/zeus/
related-topics:
  - device-registry-and-access
  - terminal-and-desktop
---

## overview
GPS tracker registration, detection, and live map tracking. The server owns tracker state, while clients render the marker and last-ping behavior locally.

## current behavior
- `Root_fnc_addGPSTrackerZeusMain` registers a tracker with time, update frequency, custom marker, retracking flag, last-ping timer, power cost, and owners selection.
- `Root_fnc_displayGPSPosition` starts the terminal tracking command, checks access, consumes power, and launches the server tracking loop.
- `Root_fnc_gpsTrackerServer` updates tracker status to `Tracking`, `Completed`, `Untrackable`, or `Dead` and sends the client marker updates.
- `Root_fnc_gpsTrackerClient` creates and updates the local map marker, then deletes it after the last-ping window.
- `Root_fnc_searchForGPSTracker` performs ACE search logic with optional spectrum-device detection support.
- `Root_fnc_aceAttachGPSTracker` wires the ACE interaction path for attaching trackers.

## decisions
- Store the current tracker status in the registry row so the server and clients both read the same state.
- Always include the initiating client in tracker updates, then add extra recipients from selected sides, groups, and individual players.
- Preserve the last known position when a tracker object disappears, because the tracking story should continue to the end of the timer.
- Make retracking a per-tracker option, not a global rule.

## gotchas
- If the tracker object vanishes mid-run, the server keeps the last known position and the client flips to a last-ping marker.
- Search uses a probability gate and can fail even when a tracker exists.
- Experimental device mode changes how GPS tracker visibility exclusions are computed.
- The tracker list can be marked dead on the client-side command path if the object no longer resolves at start time.

## references
- `addons/main/functions/gps/`
- `addons/main/functions/utility/fn_syncDeviceData.sqf`
- `addons/main/functions/zeus/`
- `addons/main/CfgFunctions.hpp`
