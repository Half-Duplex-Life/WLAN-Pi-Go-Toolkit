# WLAN Pi Wireless Engineering Platform - Roadmap

## v1.0.0 - Initial Public Release

The first public release establishes the validated WLAN Pi Go wireless engineering platform.

### Core Platform

- Modular toolkit interface
- WLAN Pi Go deployment workflow
- Start-of-session preflight
- Client profiling
- RF survey
- Shared survey snapshot
- Channel analysis
- Security analysis
- Hidden-network analysis
- Enterprise-network inventory
- Neighbor inventory
- Survey export
- Client profile dashboard

### OTA Capture

The supported v1.0 OTA capture architecture is:

WLAN Pi Go -> MetaGeek App -> PCAPNG -> Wireshark

Validated capabilities include:

- WLAN Pi Go OTA collection
- MetaGeek App capture workflow
- PCAPNG export
- Radiotap metadata
- IEEE 802.11 management frames
- IEEE 802.11 control frames
- IEEE 802.11 data frames
- RSSI and channel metadata
- Wireshark packet analysis
- Capture-quality validation

### Documentation

- Public engineering Knowledge Base
- macOS installation workflow
- Windows installation procedure
- WLAN Pi Go setup
- Deployment procedure
- OTA capture workflow
- MetaGeek workflow
- Wireshark workflow
- Capture validation
- RF survey workflow
- Client profiler workflow
- Troubleshooting and engineering checklists

## v1.x - Platform Automation and Hardening

Planned improvements within the v1.x release family include:

- Automated capture validation
- Investigation/session management
- Standardized capture naming and metadata
- Automated engineering artifact organization
- Improved report generation
- Guided wireless investigation workflows
- Voice-validation workflow
- Installer improvements
- Cross-platform hardening
- Windows physical validation
- Additional regression testing
- Improved release automation

## v2.0.0 - Direct Wireshark OTA Capture

The planned v2.0 architecture is:

WLAN Pi Go -> Oscium ExtCap -> Wireshark

The goal of v2.0 is to remove the MetaGeek App as a required intermediary for OTA packet capture.

This transition will occur only after:

1. The current Oscium ARM64 Wireshark ExtCap compatibility issue is resolved by vendor engineering.
2. A corrected vendor implementation is available.
3. Direct WLAN Pi Go capture into Wireshark is independently validated.
4. Capture quality is verified against the v1.0 MetaGeek-based reference workflow.
5. Documentation, diagrams, installation procedures, and release packages are updated.

MetaGeek remains the supported and validated OTA capture path for v1.0 until those gates are complete.

## Long-Term Direction

The long-term objective is a guided wireless engineering platform where repetitive collection, validation, organization, and reporting tasks are automated while engineering interpretation and decision-making remain with the wireless engineer.
