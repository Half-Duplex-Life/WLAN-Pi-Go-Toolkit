# Changelog

All notable changes to the WLAN Pi Wireless Engineering Platform are documented here.

## 1.0.0 - Initial Public Release

### Post-Publication Maintenance

- Added WLAN Pi Go session-start clock synchronization using the workstation time.

- Corrected toolkit detection of the `iw` wireless utility when installed under `/usr/sbin` or `/sbin`.

### Post-Release Validation Fixes

- Corrected launcher action mappings for options 6 through 10.

- Updated Quick RF Survey to acquire a fresh RF snapshot before analysis instead of reusing an existing snapshot indefinitely.

- Validated the corrected launcher mappings and fresh RF survey workflow on WLAN Pi Go hardware.

### Platform

- Established the WLAN Pi Wireless Engineering Platform architecture.
- Added a modular menu-driven toolkit.
- Added workstation-to-WLAN-Pi-Go deployment workflow.
- Added start-of-session WLAN Pi Go preflight.
- Added configurable WLAN Pi Go host and user settings.

### Client Profiling

- Added 802.11ax / Wi-Fi 6 WPA2 client profiling workflow.

- Added 802.11ax / Wi-Fi 6/6E WPA3 client profiling workflow.
- Added 802.11be / Wi-Fi 7 WPA3 client profiling workflow.
- Added client profile dashboard.
- Added public-safe lab profiler configuration templates.

### RF Engineering

- Added Quick RF Survey.
- Added shared RF survey snapshot.
- Added channel analysis.
- Added security analysis.
- Added hidden-network analysis.
- Added enterprise-network inventory.
- Added neighbor inventory.
- Added RF survey export workflow.

### OTA Packet Capture

The validated v1.0 OTA workflow is:

WLAN Pi Go -> MetaGeek App -> PCAPNG -> Wireshark

Validated capabilities include:

- WLAN Pi Go OTA capture infrastructure.
- MetaGeek App WLAN Pi Go capture workflow.
- PCAPNG export.
- Wireshark Radiotap decoding.
- IEEE 802.11 management-frame analysis.
- IEEE 802.11 control-frame analysis.
- IEEE 802.11 data-frame analysis.
- RSSI and channel metadata validation.
- Capture-quality validation.

### Direct Wireshark Capture

Direct WLAN Pi Go capture through the Oscium ARM64 Wireshark ExtCap remains pending vendor engineering resolution and independent validation.

The planned v2.0 release will move to:

WLAN Pi Go -> Oscium ExtCap -> Wireshark

after the compatibility issue is resolved and the corrected implementation passes the project validation gates.

### Documentation

- Added a 20-document engineering Knowledge Base.
- Added macOS installation and first-use guidance.
- Added Windows installation guidance with an explicit physical-validation gate.
- Added WLAN Pi Go setup procedure.
- Added deployment procedure.
- Added OTA capture workflow.
- Added MetaGeek App workflow.
- Added Wireshark analysis workflow.
- Added capture-validation procedure.
- Added RF survey and client-profiler procedures.
- Added troubleshooting, release, roadmap, and engineering-checklist documentation.

### Public Release Hardening

- Added public-release ignore rules.
- Removed private vendor case identifiers.
- Removed operational captures and reports from the source boundary.
- Sanitized lab profiler credentials.
- Excluded vendor binaries from the public source repository.
- Kept third-party Wireshark profiles outside the public repository for attribution and redistribution safety.

## Planned

See ROADMAP.md for v1.x automation/hardening work and the planned v2.0 direct-Wireshark capture architecture.
