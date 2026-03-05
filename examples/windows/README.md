# Example: Windows Server VM

Deploy a Windows Server VM from an existing vSphere template using Sysprep-based customization.

## What this example demonstrates

- Windows Server Sysprep customization (computer rename, workgroup mode)
- Numeric Windows time zone index (vs. Olson strings used by Linux)
- Auto-logon after Sysprep with a RunOnce bootstrap command
- EFI firmware and optional Virtualization-based Security (`vbs_enabled`)

## Prerequisites

- A Windows Server VM template already exists in vCenter with VMware Tools installed
- The template is in a generalized (Sysprepped) state or has a clean snapshot
- vSphere user has permissions to clone VMs and customize guest OS
- Terraform >= 1.3

## Usage

```bash
# 1. Copy the example vars file
cp terraform.tfvars.example terraform.tfvars

# 2. Fill in your vSphere connection, infrastructure, and VM details

# 3. Set sensitive passwords as environment variables
export TF_VAR_vsphere_password="your-vcenter-password"
export TF_VAR_windows_admin_password="your-local-admin-password"

# 4. Initialize and deploy
terraform init
terraform plan
terraform apply
```

## Sensitive variables

Set these via environment variables — do not store them in `terraform.tfvars`:

| Environment variable | Description |
|---|---|
| `TF_VAR_vsphere_password` | vCenter administrator password |
| `TF_VAR_windows_admin_password` | Local administrator password set by Sysprep |

## Key variables

| Variable | Example value | Description |
|---|---|---|
| `is_windows` | `true` | Switches customization to Sysprep mode (hardcoded in `main.tf`) |
| `guest_id` | `"windows2022srvNext_64Guest"` | vSphere guest OS identifier |
| `time_zone` | `"85"` | Numeric Windows time zone index (85 = Eastern, 105 = Pacific) |
| `windows_workgroup` | `"WORKGROUP"` | Workgroup name for standalone VMs (set `windows_domain` to join AD instead) |
| `windows_auto_logon` | `true` | Auto-logon after Sysprep for running bootstrap scripts |
| `windows_run_once` | see tfvars | List of commands to run once after Sysprep completes |
| `firmware` | `"efi"` | EFI firmware recommended for Windows Server 2022 |
| `vbs_enabled` | `false` | Enable Virtualization-based Security (requires nested virt support) |
