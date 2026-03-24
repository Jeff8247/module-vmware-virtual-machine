# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `guest_id` is now optional; when `null`, the value is inherited from the source template rather than requiring an explicit value.

### Fixed
- Corrected `windows_options` block to use `domain_ou` instead of `organizational_unit` to match the vSphere provider attribute name for AD OU placement.

## [1.0.6] - 2026-03-11

### Added
- `efi_secure_boot_enabled` variable to enable or disable EFI Secure Boot on the virtual machine.
- `linux_script_text` variable for providing an inline shell script run during Linux guest customization.

## [1.0.5] - 2026-03-11

### Added
- `windows_domain_ou` variable for specifying the Active Directory OU in which the computer object is placed during domain join.

## [1.0.4] - 2026-03-11

### Changed
- `num_cores_per_socket` now defaults to `null`, causing the module to use `num_cpus` (single-socket topology) when no explicit value is provided. Previously defaulted to `1`.
- Updated examples and README to reflect the new single-socket default for `num_cores_per_socket`.

## [1.0.3] - 2026-03-11

### Added
- `tools_upgrade_policy` variable to control VMware Tools upgrade behaviour (e.g. `upgradeAtPowerCycle`).

## [1.0.2] - 2026-03-09

### Fixed
- Reverted `ip_settings.ipv4_netmask` validation range from 1–30 back to 1–32 to correctly support /31 (RFC 3021 point-to-point) and /32 (host route) prefix lengths.

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
