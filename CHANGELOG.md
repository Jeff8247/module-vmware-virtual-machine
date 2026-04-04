# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.21] - 2026-04-04

### Documentation
- README: corrected `firmware` default to `"efi"`, added `windows_domain_netbios` and `proxy_url` to inputs table, updated Linux domain join note to reflect module-native support, added Linux AD domain join to features list.
- CHANGELOG: consolidated v1.0.0–v1.0.15 history into a single summary block.

## [1.0.20] - 2026-04-04

### Fixed
- `linux_script_combined`: Added `systemctl enable --now oddjobd` before SSSD restart so that `pam_oddjob_mkhomedir` (enabled by `authselect with-mkhomedir`) can create home directories for AD users on first login.

## [1.0.19] - 2026-04-04

### Fixed
- `linux_script_combined`: `realm join` now targets the FQDN (`windows_domain`) instead of the NetBIOS/short name, ensuring DNS can resolve the KDC.
- `linux_script_combined`: `-U` flag now passes just the username (no `@NETBIOS_NAME` suffix) to prevent double-domain UPN errors when the user is already supplied as a full UPN.
- `linux_script_combined`: Added `oddjob-mkhomedir` and `krb5-workstation` to the `dnf install` line — required by `authselect with-mkhomedir` and `adcli`/`realm` on RHEL.

## [1.0.18] - 2026-04-04

### Fixed
- `linux_script_combined`: replaced `coalesce(var.linux_script_text, "")` with a null-check ternary to prevent "no non-null, non-empty-string arguments" plan error when `linux_script_text` is not set.
- `linux_script_combined`: `--computer-ou` argument is now omitted from the `realm join` command when `windows_domain_ou` is null, preventing a failed join caused by passing an empty string to `--computer-ou`.

## [1.0.17] - 2026-04-04

### Changed
- Linux domain join package install now targets RHEL-family systems only (`dnf`). The `apt-get` branch has been removed.

## [1.0.16] - 2026-04-04

### Added
- Linux AD domain join via `realmd`/`sssd` script generated and run during VMware guest customization. Activated when `is_windows = false` and both `windows_domain` and `windows_domain_password` are set. The script installs required packages, performs an idempotent realm join with 5 retries, configures SSSD and Kerberos, and hardens PAM. Targets RHEL-family systems.
- `windows_domain_netbios` variable — NetBIOS/short domain name for the Linux realm join command. Falls back to `windows_domain` when null.
- `proxy_url` variable — HTTP/HTTPS proxy URL set as `HTTP_PROXY`/`HTTPS_PROXY` for the package install step only; unset immediately after. Null disables proxy.
- `linux_script_text` is appended after the domain join script when both are set.
- Precondition requiring `windows_domain_user` and `windows_domain_password` when `windows_domain` is set for Linux VMs.

## [1.0.0–1.0.15] - 2025-03-09 – 2026-04-02

Initial release through early iterations. Key capabilities established:

- Clone from vSphere template with full Linux and Windows (Sysprep) guest customization.
- Configurable CPU, memory, multi-disk, multi-NIC, SCSI controller, firmware (EFI default), and VMware Tools upgrade policy.
- Windows domain join via Sysprep with optional OU placement (`windows_domain_ou`).
- `linux_script_text` variable for inline first-boot shell scripts.
- `efi_secure_boot_enabled`, `guest_id` (optional, inherits from template), `tools_upgrade_policy` variables added.
- `nullable = false` on all boolean variables; null guard on `windows_auto_logon_count`.
- vApp properties, CDROM, Storage DRS, tag management, and extra VMX config support.
- Input validation: unique disk labels/unit numbers, at least one NIC, valid IPv4 format and netmask range.
- 16 lifecycle preconditions, 71 input variables, 18 outputs.
