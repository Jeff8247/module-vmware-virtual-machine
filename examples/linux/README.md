# Example: Linux VM

Deploy a RHEL or Ubuntu Linux VM from an existing vSphere template.

## What this example demonstrates

- Linux template clone with VMware guest customization (hostname, domain, time zone)
- Multi-disk configuration (OS, data, and log volumes with per-disk IOPS cap)
- Dual-NIC with static IP addresses matched positionally to interfaces
- Extra VMX configuration keys via `extra_config`

## Prerequisites

- A Linux VM template already exists in vCenter with VMware Tools installed
- vSphere user has permissions to clone VMs and customize guest OS
- Terraform >= 1.3

## Usage

```bash
# 1. Copy the example vars file
cp terraform.tfvars.example terraform.tfvars

# 2. Fill in your vSphere connection, infrastructure, and VM details

# 3. Set the sensitive vSphere password as an environment variable
export TF_VAR_vsphere_password="your-vcenter-password"

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

## Key variables

| Variable | Example value | Description |
|---|---|---|
| `guest_id` | `rhel9_64Guest` / `ubuntu64Guest` | vSphere guest OS identifier |
| `time_zone` | `"America/New_York"` | Olson TZ string used by Linux guest customization |
| `template_name` | `"rhel-9-template"` | Name of the source VM template in vCenter |
| `disks` | see tfvars | List of disk objects; first entry is the OS disk |
| `network_interfaces` | see tfvars | List of NICs; order must match `ip_settings` |
| `extra_config` | `{"sched.mem.balloon.enable" = "FALSE"}` | Raw VMX key/value pairs |
