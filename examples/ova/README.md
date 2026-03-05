# Example: Harbor Container Registry (OVA)

Deploy the Harbor container registry appliance from a vSphere template created by importing the Harbor OVA.

## What this example demonstrates

- OVA-based deployment using `vapp_properties` to configure the appliance on first boot
- Harbor-specific configuration (hostname, admin password, DB password, log level, GC) injected via the OVF environment
- No extra disks (`disks = []`) — the OVA bundles its own storage volumes
- `linked_clone = false` (hardcoded) since OVA-derived templates do not support linked clones

## Prerequisites

- The Harbor OVA has been imported as a VM template in vCenter (see below)
- vSphere user has permissions to clone VMs and customize guest OS
- Terraform >= 1.3

### Importing the OVA (one-time setup)

```bash
# Download the OVA from https://github.com/goharbor/harbor/releases
govc import.ova \
  -name=harbor-2.12-template \
  -ds=datastore01 \
  harbor-offline-installer-v2.12.0.ova

govc vm.markastemplate harbor-2.12-template
```

To verify the exact vApp property keys for your OVA version:

```bash
govc import.spec harbor-offline-installer-v2.12.0.ova \
  | jq '.PropertyMapping[].Key'
```

## Usage

```bash
# 1. Copy the example vars file
cp terraform.tfvars.example terraform.tfvars

# 2. Fill in your vSphere connection, infrastructure, and Harbor details

# 3. Set sensitive passwords as environment variables
export TF_VAR_vsphere_password="your-vcenter-password"
export TF_VAR_harbor_admin_password="your-harbor-admin-password"
export TF_VAR_harbor_db_password="your-harbor-db-password"

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
| `TF_VAR_harbor_admin_password` | Harbor admin UI password |
| `TF_VAR_harbor_db_password` | Harbor internal PostgreSQL password |

## Key variables

| Variable | Example value | Description |
|---|---|---|
| `harbor_hostname` | `"harbor.example.com"` | FQDN that resolves to the VM's IP; used in Harbor's TLS cert |
| `harbor_log_level` | `"info"` | Harbor log verbosity: `debug` / `info` / `warning` / `error` / `fatal` |
| `harbor_gc_enabled` | `true` | Enable scheduled garbage collection for registry blobs |
| `vapp_properties` | see `main.tf` | Map of OVF property keys injected into the OVF environment on first boot |
| `disks` | `[]` | Leave empty to keep OVA's built-in disks; add entries for extra volumes |
| `firmware` | `"efi"` | Harbor OVA ships with EFI firmware; keep this value |
