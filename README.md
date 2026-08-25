# WLAN Pi Wireless Engineering Platform

A wireless engineering platform built around the WLAN Pi Go for repeatable RF analysis, client profiling, OTA packet capture, Wi-Fi packet analysis, capture validation, and engineering workflows.

## Current Release

**Version:** 1.0.0

### Validated OTA Capture Workflow

WLAN Pi Go -> MetaGeek App -> PCAPNG -> Wireshark

The v1.0 release uses the MetaGeek App as the validated OTA packet-capture client. Exported PCAPNG files are then opened in Wireshark for frame-level wireless analysis.

The validated workflow has been tested with WLAN Pi Go OTA captures containing Radiotap metadata and IEEE 802.11 management, control, and data traffic.

## Planned v2.0 Capture Architecture

WLAN Pi Go -> Oscium ARM64 ExtCap -> Wireshark

Version 2.0 is planned after the current Oscium/MetaGeek Wireshark ExtCap compatibility issue is resolved by the vendor engineering team and the corrected implementation is independently validated.

The v2.0 goal is to remove the MetaGeek App as a required intermediary in the OTA packet-capture workflow and allow direct capture into Wireshark.

## Platform Capabilities

- 802.11 client profiling
- RF survey and channel analysis
- Security analysis
- Hidden-network inventory
- Enterprise-network inventory
- Neighbor inventory
- OTA packet capture
- PCAPNG capture validation
- Wi-Fi packet analysis with Wireshark
- Survey and engineering exports
- WLAN Pi Go deployment and runtime preflight
- Engineering documentation and operational procedures

## Repository Structure

WLAN-Pi-Go-Toolkit/
- Toolkit_Source/
- Docs/
- Examples/
- Tools/
- README.md
- LICENSE
- .gitignore

Operational captures, reports, credentials, internal working material, and other generated artifacts are intentionally excluded from the public source repository.

## Getting Started

Start with:

1. docs/Knowledge_Base/01_Project_Overview.docx
2. docs/Knowledge_Base/02_Architecture.docx
3. docs/Knowledge_Base/04_macOS_Installation.docx
4. docs/Knowledge_Base/06_New_Machine_Setup.docx
5. docs/Knowledge_Base/07_WLAN_Pi_Go_Setup.docx
6. docs/Knowledge_Base/08_Deployment.docx
7. docs/Knowledge_Base/09_OTA_Capture_Workflow.docx
8. docs/Knowledge_Base/12_Capture_Validation.docx

## Platform Status

### Validated

- WLAN Pi Go runtime and deployment workflow
- RF survey workflow
- Client profiling workflow
- MetaGeek App OTA capture workflow
- PCAPNG export
- Wireshark Radiotap / IEEE 802.11 analysis
- Capture-quality validation
- Engineering Knowledge Base

### Vendor Dependency

Direct Wireshark capture through the Oscium ARM64 ExtCap remains pending vendor engineering resolution and validation.

The current v1.0 MetaGeek App workflow remains the supported OTA capture path.

## Project Philosophy

The goal is to make wireless engineering work more repeatable without replacing engineering judgment.

The platform automates:

- collection
- validation
- analysis preparation
- artifact organization
- reporting

The engineer remains responsible for defining the problem, interpreting evidence, and making the engineering decision.

## Acknowledgements

This project is a personal give-back to the Wi-Fi community that has contributed a tremendous amount of knowledge, education, discussion, and practical experience to the field.

Special thanks to:

- WLAN Pros and the broader Wi-Fi community for the education, best practices, and real-world wireless engineering knowledge that helped shape this project.
- Keith Parsons and the WLAN Pros community for continuing to make wireless engineering knowledge accessible to the community.
- Rasika Nayanajith for the RockstarWiFi Wireshark profile and for sharing useful Wi-Fi analysis resources with the community.
- Oscium / MetaGeek support for responsive support, reproducing the Wireshark ARM64 ExtCap issue, and engaging their engineering team on the compatibility problem.

## Contributing

Feedback, ideas, documentation improvements, engineering workflow improvements, and compatible feature contributions are welcome.

Please keep proprietary, confidential, customer-specific, or vendor-restricted material out of the repository.

## Community Access

This project is shared free of charge with the Wi-Fi community.

There is no fee or paid access required to view or use the project.

No separate software license is included with the v1.0 release. Copyright and other rights remain with their respective owners. Third-party software, tools, trademarks, and referenced resources remain subject to their own terms and licenses.
