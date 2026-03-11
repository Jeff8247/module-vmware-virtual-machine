# terraform-module-vmware-virtual-machine

Terraform module for provisioning VMware vSphere virtual machines. Supports cloning from templates, full guest OS customization (Linux and Windows), multiple disks, multiple NICs, resource reservations, tags, and advanced vSphere features.

Compatible with the [Terraform Registry](https://registry.terraform.io/) module format.

---

## Features

- Clone from VM template with full customization (Linux & Windows)
- Dynamic multi-disk configuration with per-disk overrides
- Dynamic multi-NIC configuration with static or DHCP IP assignment
- CPU/memory reservations, limits, and hot-add
- SCSI controller type selection (pvscsi, lsilogic, lsilogic-sas, buslogic)
- Tag management (category → tag mapping)
- Extra VMX config (`extra_config`)
- vApp property support for OVF/OVA deployments
- CDROM attachment (ISO file or client device)
- Nested virtualization, VBS, VT-d pass-through
- EFI/BIOS firmware selection
- Datastore cluster (Storage DRS) support

---

## Usage

```hcl
module "vm" {
  source  = "git::https://github.com/example/module-vmware-virtual-machine.git"

  # Infrastructure
  datacenter = "dc01"
  cluster    = "cluster01"
  datastore  = "datastore01"

  # VM identity
  vm_name  = "my-linux-vm"
  guest_id = "ubuntu64Guest"

  # Template
  template_name = "ubuntu-22.04-template"

  # Compute
  num_cpus = 4
  memory   = 8192

  # Disks
  disks = [
    {
      label       = "disk0"
      size        = 60
      unit_number = 0
    },
    {
      label       = "disk1"
      size        = 100
      unit_number = 1
    },
  ]

  # NICs
  network_interfaces = [
    { network_name = "VM Network" },
  ]

  # IP customization
  ip_settings = [
    { ipv4_address = "192.168.1.100", ipv4_netmask = 24 },
  ]
  ipv4_gateway = "192.168.1.1"
  dns_servers  = ["192.168.1.10", "192.168.1.11"]
}
```

See the fully annotated examples:

| Example | Description |
|---|---|
| [`examples/linux/`](examples/linux/) | RHEL/Ubuntu VM from a Linux template |
| [`examples/windows/`](examples/windows/) | Windows Server from a Windows template (Sysprep, workgroup) |
| [`examples/ova/`](examples/ova/) | Harbor container registry from an OVA — demonstrates `vapp_properties` |

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| vmware/vsphere | ~> 2.6 |

---

## State File Storage

Terraform state contains **plaintext secrets** — every sensitive variable value (vCenter password, Windows admin password, etc.) is written to state in cleartext. The state file must be stored securely and never committed to source control.

> **Add `*.tfstate`, `*.tfstate.backup`, `terraform.tfvars`, and `*.auto.tfvars` to your `.gitignore` immediately — state files and tfvars files can both contain plaintext secrets.**

### Option 1 — PostgreSQL (if you have an internal database)

Any PostgreSQL instance works — no cloud storage required.

```hcl
terraform {
  backend "pg" {
    conn_str = "postgres://terraform:password@postgres.example.com/tfstate?sslmode=require"
    # conn_str can also be set via PG_CONN_STR env var
  }
}
```

Create the schema once:

```sql
CREATE DATABASE tfstate;
CREATE USER terraform WITH ENCRYPTED PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE tfstate TO terraform;
```

---

### Option 2 — Local state (single operator / lab only)

The default when no backend is configured. State is written to `terraform.tfstate` in the working directory.

**Only appropriate for a single operator or lab work.** There is no locking — concurrent applies will corrupt state. Back the file up manually and exclude it from git.

```bash
# Recommended minimum: keep state in a dedicated directory, not the repo root
mkdir -p ~/.terraform-state/vmware-vms
# Then work from that directory, or use -chdir / -state flags
```

---

### State and sensitive values

Regardless of backend, be aware that:

- All `sensitive = true` variable values appear **in plaintext** in state — treat the state file with the same care as a password vault.
- The vSphere provider writes VM UUIDs, IP addresses, and tag IDs to state — state is your inventory; protect it accordingly.
- Rotate credentials (vCenter password, Windows admin password) after provisioning — changing them in vSphere does not automatically update state.

---

## Sensitive Variables — Use Environment Variables

**Never store secrets in `terraform.tfvars` or any file committed to source control.**
Set the following as shell environment variables before running `terraform plan` / `apply`.

### vCenter connection (both examples)

```bash
export TF_VAR_vsphere_password="your-vcenter-password"
```

### Windows guest customization

```bash
# Required for all Windows VMs (Sysprep fails without an admin password)
export TF_VAR_windows_admin_password="your-local-admin-password"

# Required only when joining an Active Directory domain
export TF_VAR_windows_domain_password="your-domain-join-password"
```

### Harbor OVA example

```bash
export TF_VAR_harbor_admin_password="your-harbor-admin-password"
export TF_VAR_harbor_db_password="your-harbor-db-password"
```

| Variable | When required | Terraform variable |
|---|---|---|
| `vsphere_password` | Always (provider auth) | `TF_VAR_vsphere_password` |
| `windows_admin_password` | When `is_windows = true` | `TF_VAR_windows_admin_password` |
| `windows_domain_password` | When `windows_domain` is set | `TF_VAR_windows_domain_password` |
| `harbor_admin_password` | Harbor OVA example | `TF_VAR_harbor_admin_password` |
| `harbor_db_password` | Harbor OVA example | `TF_VAR_harbor_db_password` |

> **Tip:** You can also use a `.env` file with [`direnv`](https://direnv.net/) or a secrets manager integration (e.g. Vault provider) to inject these at plan time without ever writing them to disk.

---

## Inputs

### vSphere Infrastructure

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `datacenter` | vSphere datacenter name | `string` | — | yes |
| `cluster` | Compute cluster name | `string` | `null` | no |
| `resource_pool` | Resource pool name or path | `string` | `null` | no |
| `datastore` | Primary datastore name | `string` | `null` | no |
| `datastore_cluster` | Datastore cluster name (Storage DRS) | `string` | `null` | no |
| `host` | ESXi host name for placement | `string` | `null` | no |

### VM Identity

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vm_name` | Virtual machine name | `string` | — | yes |
| `vm_folder` | vSphere folder path | `string` | `null` | no |
| `annotation` | VM notes / description | `string` | `null` | no |
| `tags` | Map of tag category → tag name | `map(string)` | `{}` | no |

### Template / Clone

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `template_name` | Template to clone from | `string` | — | yes |
| `template_datacenter` | Datacenter containing the template | `string` | `null` | no |
| `linked_clone` | Use linked clone | `bool` | `false` | no |

### CPU

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `num_cpus` | Total vCPUs | `number` | `2` | no |
| `num_cores_per_socket` | Cores per socket (defaults to `num_cpus` for single-socket topology) | `number` | `null` | no |
| `cpu_hot_add_enabled` | Allow CPU hot-add | `bool` | `false` | no |
| `cpu_hot_remove_enabled` | Allow CPU hot-remove | `bool` | `false` | no |
| `cpu_limit` | CPU limit in MHz (-1 = unlimited) | `number` | `-1` | no |
| `cpu_reservation` | Guaranteed CPU in MHz | `number` | `0` | no |
| `cpu_share_level` | CPU share level (low/normal/high/custom) | `string` | `"normal"` | no |
| `cpu_share_count` | Custom CPU share count | `number` | `null` | no |

### Memory

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `memory` | RAM in MB | `number` | `4096` | no |
| `memory_hot_add_enabled` | Allow memory hot-add | `bool` | `false` | no |
| `memory_limit` | Memory limit in MB (-1 = unlimited) | `number` | `-1` | no |
| `memory_reservation` | Guaranteed RAM in MB | `number` | `0` | no |
| `memory_share_level` | Memory share level | `string` | `"normal"` | no |
| `memory_share_count` | Custom memory share count | `number` | `null` | no |

### Disks

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `disks` | List of disk configurations (see variable description) | `list(object)` | `[]` | no |
| `scsi_type` | SCSI controller type | `string` | `"pvscsi"` | no |
| `scsi_controller_count` | Number of SCSI controllers (1–4) | `number` | `1` | no |
| `scsi_bus_sharing` | SCSI bus sharing mode | `string` | `"noSharing"` | no |

### Network Interfaces

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `network_interfaces` | List of NIC configurations (see variable description) | `list(object)` | — | yes |

### IP Customization

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `ip_settings` | Per-interface static IP settings | `list(object)` | `[]` | no |
| `ipv4_gateway` | Default IPv4 gateway | `string` | `null` | no |
| `dns_servers` | DNS server addresses | `list(string)` | `[]` | no |
| `dns_suffix_list` | DNS search suffixes | `list(string)` | `[]` | no |

### Guest OS Customization

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `guest_id` | VMware guest OS identifier | `string` | — | yes |
| `is_windows` | Enable Windows customization | `bool` | `false` | no |
| `computer_name` | Guest hostname (defaults to vm_name) | `string` | `null` | no |
| `domain` | DNS domain | `string` | `null` | no |
| `time_zone` | Time zone (Olson for Linux, index for Windows) | `string` | `null` | no |
| `windows_admin_password` | Windows local admin password (required when is_windows = true) | `string` | `null` | no |
| `windows_workgroup` | Windows workgroup | `string` | `"WORKGROUP"` | no |
| `windows_domain` | AD domain to join | `string` | `null` | no |
| `windows_domain_user` | Domain join user | `string` | `null` | no |
| `windows_domain_password` | Domain join password | `string` | `null` | no |
| `windows_auto_logon` | Enable auto-logon after customization | `bool` | `false` | no |
| `windows_auto_logon_count` | Auto-logon count | `number` | `1` | no |
| `windows_run_once` | Commands to run once post-customization | `list(string)` | `[]` | no |

### Hardware & Firmware

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `firmware` | Firmware type (bios/efi) | `string` | `"bios"` | no |
| `hardware_version` | Virtual hardware version | `number` | `null` | no |
| `tools_upgrade_policy` | VMware Tools upgrade policy (`manual` or `upgradeAtPowerCycle`) | `string` | `"manual"` | no |
| `nested_hv_enabled` | Nested hardware virtualization | `bool` | `false` | no |
| `vbs_enabled` | Virtualization-based Security | `bool` | `false` | no |
| `vvtd_enabled` | Intel VT-d pass-through | `bool` | `false` | no |
| `enable_disk_uuid` | Expose disk UUIDs to guest | `bool` | `true` | no |
| `enable_logging` | Enable VMX logging | `bool` | `false` | no |
| `swap_placement_policy` | Swap file placement | `string` | `"inherit"` | no |
| `shutdown_wait_timeout` | Graceful shutdown wait (seconds) | `number` | `3` | no |
| `force_power_off` | Force power off if shutdown fails | `bool` | `true` | no |
| `migrate_wait_timeout` | vMotion wait (seconds) | `number` | `30` | no |
| `wait_for_guest_net_timeout` | Wait for guest IP (seconds, -1 = skip) | `number` | `5` | no |
| `wait_for_guest_net_routable` | Require routable IP | `bool` | `true` | no |
| `wait_for_guest_ip_timeout` | Fallback IP wait (seconds) | `number` | `0` | no |

### CDROM

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cdrom_enabled` | Attach a CDROM device | `bool` | `false` | no |
| `cdrom_datastore_id` | Datastore object ID containing the ISO | `string` | `null` | no |
| `cdrom_path` | Path to the ISO file | `string` | `null` | no |
| `cdrom_client_device` | Use client-connected device | `bool` | `false` | no |

### Extra Config / vApp

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `extra_config` | Advanced VMX key/value pairs | `map(string)` | `{}` | no |
| `extra_config_reboot_required` | Reboot after extra_config changes | `bool` | `false` | no |
| `vapp_properties` | OVF/OVA vApp property key/values | `map(string)` | `{}` | no |

### Clone / Customization

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `customize_timeout` | Minutes to wait for guest customization to complete | `number` | `30` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `id` | VM managed object ID |
| `name` | VM name |
| `uuid` | VM BIOS UUID |
| `default_ip_address` | Primary IP address (from VMware Tools) |
| `guest_ip_addresses` | All guest IP addresses |
| `moid` | Managed object reference ID |
| `power_state` | Current power state |
| `datacenter_id` | Managed object ID of the vSphere datacenter |
| `cluster_id` | Managed object ID of the compute cluster (null if not set) |
| `resource_pool_id` | Managed object ID of the resource pool |
| `host_system_id` | Managed object ID of the ESXi host (null if not set) |
| `datastore_id` | Managed object ID of the primary datastore (null if using datastore_cluster) |
| `datastore_cluster_id` | Managed object ID of the datastore cluster (null if using datastore) |
| `network_ids` | Map of network name → managed object ID for each attached network |
| `template_id` | Managed object ID of the source VM template |
| `template_guest_id` | Guest OS identifier of the source VM template |
| `template_hardware_version` | Virtual hardware version of the source VM template |
| `tag_ids` | List of tag managed object IDs applied to the VM |

---

## Notes

- Either `cluster` or `resource_pool` must be set (or both, where `resource_pool` takes precedence).
- Either `datastore` or `datastore_cluster` must be set, but not both.
- `ip_settings` entries are matched positionally to `network_interfaces`. Interfaces without a matching entry use DHCP.
- `time_zone` for Windows must be a numeric string matching the [Microsoft time zone index](https://docs.microsoft.com/en-us/previous-versions/windows/embedded/ms912391(v=winembedded.11)).
- `linked_clone` requires the template to have at least one snapshot.
- The `clone` block is always required for this module (template-based deployment). For blank VM creation, fork and remove the clone block.

---

## License

Apache 2.0
