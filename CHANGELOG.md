# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-03-09

### Fixed
- Added validation to `disks` variable ensuring `unit_number` and `label` are unique across all disk entries, preventing runtime vSphere API errors.
- Added validation to `network_interfaces` variable ensuring at least one interface is specified.
- Added validation to `ip_settings` variable for valid IPv4 address format and netmask range (1–30).
- Fixed `linux_options.domain` falling back to an empty string `""` when `var.domain` is `null`; now passes `null` directly to avoid unintended guest customization behaviour.

## [1.0.0] - 2025-03-09

### Added
- Initial release of the `module-vmware-virtual-machine` Terraform module.
- Support for cloning from a vSphere template or OVA/OVF deployment.
- Configurable CPU, memory, disks, network interfaces, and SCSI controller.
- Guest customization for both Linux and Windows (Sysprep).
- Windows domain join support with optional OU placement.
- vApp properties support for OVA deployments.
- CD-ROM support.
- CPU and memory resource allocation (shares, reservations, limits).
- Tag assignment via `vsphere_tag`.
- Support for datastore clusters via Storage DRS.
- 16 lifecycle preconditions covering common misconfiguration scenarios.
- 71 input variables with descriptions, types, and defaults.
- 18 outputs covering VM identity, networking, and hardware details.
- Examples for Linux, Windows, and OVA deployments.
