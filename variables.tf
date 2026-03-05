variable "datacenter" {
  description = "Name of the vSphere datacenter."
  type        = string
}

variable "cluster" {
  description = "Name of the vSphere compute cluster. Required unless resource_pool is set to a full path."
  type        = string
  default     = null
}

variable "resource_pool" {
  description = "Name or path of the resource pool. Defaults to the root pool of the cluster when cluster is set."
  type        = string
  default     = null
}

variable "datastore" {
  description = "Name of the primary datastore. Mutually exclusive with datastore_cluster."
  type        = string
  default     = null
}

variable "datastore_cluster" {
  description = "Name of the datastore cluster (Storage DRS). Mutually exclusive with datastore."
  type        = string
  default     = null
}

variable "host" {
  description = "Name of the ESXi host for host-based placement. Optional."
  type        = string
  default     = null
}

variable "vm_name" {
  description = "Name of the virtual machine. Must be 1–80 characters (vSphere limit)."
  type        = string

  validation {
    condition     = length(var.vm_name) > 0 && length(var.vm_name) <= 80
    error_message = "vm_name must be between 1 and 80 characters."
  }
}

variable "vm_folder" {
  description = "Path to the vSphere VM folder. Optional."
  type        = string
  default     = null
}

variable "annotation" {
  description = "User-provided description / notes for the VM."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tag category name to tag name to apply to the VM."
  type        = map(string)
  default     = {}
}

variable "template_name" {
  description = "Name of the VM template to clone from."
  type        = string

  validation {
    condition     = length(trimspace(var.template_name)) > 0
    error_message = "template_name must not be empty."
  }
}

variable "template_datacenter" {
  description = "Datacenter containing the template. Defaults to the value of var.datacenter."
  type        = string
  default     = null
}

variable "linked_clone" {
  description = "Create a linked clone instead of a full clone."
  type        = bool
  default     = false
}

variable "num_cpus" {
  description = "Total number of virtual CPUs."
  type        = number
  default     = 2
}

variable "num_cores_per_socket" {
  description = "Number of cores per virtual socket."
  type        = number
  default     = 1
}

variable "cpu_hot_add_enabled" {
  description = "Allow vCPUs to be added while the VM is running."
  type        = bool
  default     = false
}

variable "cpu_hot_remove_enabled" {
  description = "Allow vCPUs to be removed while the VM is running."
  type        = bool
  default     = false
}

variable "cpu_limit" {
  description = "Upper limit of CPU resources in MHz. -1 = unlimited."
  type        = number
  default     = -1

  validation {
    condition     = var.cpu_limit == -1 || var.cpu_limit > 0
    error_message = "cpu_limit must be -1 (unlimited) or a positive value in MHz."
  }
}

variable "cpu_reservation" {
  description = "Guaranteed CPU resources in MHz."
  type        = number
  default     = 0
}

variable "cpu_share_level" {
  description = "CPU share allocation level. One of: low, normal, high, custom."
  type        = string
  default     = "normal"

  validation {
    condition     = contains(["low", "normal", "high", "custom"], var.cpu_share_level)
    error_message = "cpu_share_level must be one of: low, normal, high, custom."
  }
}

variable "cpu_share_count" {
  description = "Number of CPU shares. Used only when cpu_share_level = 'custom'."
  type        = number
  default     = null
}

variable "memory" {
  description = "Amount of RAM in MB. Must be a multiple of 4 (vSphere requirement)."
  type        = number
  default     = 4096

  validation {
    condition     = var.memory % 4 == 0
    error_message = "memory must be a multiple of 4 MB."
  }
}

variable "memory_hot_add_enabled" {
  description = "Allow memory to be added while the VM is running."
  type        = bool
  default     = false
}

variable "memory_limit" {
  description = "Upper limit of memory resources in MB. -1 = unlimited."
  type        = number
  default     = -1

  validation {
    condition     = var.memory_limit == -1 || var.memory_limit > 0
    error_message = "memory_limit must be -1 (unlimited) or a positive value in MB."
  }
}

variable "memory_reservation" {
  description = "Guaranteed memory resources in MB."
  type        = number
  default     = 0
}

variable "memory_share_level" {
  description = "Memory share allocation level. One of: low, normal, high, custom."
  type        = string
  default     = "normal"

  validation {
    condition     = contains(["low", "normal", "high", "custom"], var.memory_share_level)
    error_message = "memory_share_level must be one of: low, normal, high, custom."
  }
}

variable "memory_share_count" {
  description = "Number of memory shares. Used only when memory_share_level = 'custom'."
  type        = number
  default     = null
}

variable "disks" {
  description = <<-EOT
    List of disk configurations. Each disk object supports:
    - label            (required) Unique disk label.
    - size             (required) Disk size in GB.
    - unit_number      (required) SCSI unit number (0 = OS disk).
    - thin_provisioned         Thin-provision the disk (default: true).
    - eagerly_scrub            Eagerly zero the disk (default: false).
    - datastore_id             Per-disk datastore override (default: null).
    - storage_policy_id        Storage policy ID override (default: null).
    - keep_on_remove           Retain disk when VM is destroyed (default: false).
    - io_limit                 IOPS upper limit (-1 = unlimited, default: -1).
    - io_reservation           Guaranteed IOPS (default: 0).
    - io_share_level           Share level: low/normal/high/custom (default: normal).
    - io_share_count           Custom share count (default: 0).
    - disk_sharing             Disk sharing mode (default: sharingNone).
    - controller_type          scsi or ide (default: scsi).
  EOT
  type = list(object({
    label             = string
    size              = number
    unit_number       = number
    thin_provisioned  = optional(bool, true)
    eagerly_scrub     = optional(bool, false)
    datastore_id      = optional(string, null)
    storage_policy_id = optional(string, null)
    keep_on_remove    = optional(bool, false)
    io_limit          = optional(number, -1)
    io_reservation    = optional(number, 0)
    io_share_level    = optional(string, "normal")
    io_share_count    = optional(number, 0)
    disk_sharing      = optional(string, "sharingNone")
    controller_type   = optional(string, "scsi")
  }))
  default = []

  validation {
    condition     = alltrue([for d in var.disks : d.size > 0])
    error_message = "Each disk.size must be > 0 GB."
  }

  validation {
    condition     = alltrue([for d in var.disks : contains(["low", "normal", "high", "custom"], d.io_share_level)])
    error_message = "Each disk.io_share_level must be one of: low, normal, high, custom."
  }

  validation {
    condition     = alltrue([for d in var.disks : contains(["scsi", "ide"], d.controller_type)])
    error_message = "Each disk.controller_type must be one of: scsi, ide."
  }
}

variable "scsi_type" {
  description = "SCSI controller type. One of: pvscsi, lsilogic, lsilogic-sas, buslogic."
  type        = string
  default     = "pvscsi"

  validation {
    condition     = contains(["pvscsi", "lsilogic", "lsilogic-sas", "buslogic"], var.scsi_type)
    error_message = "scsi_type must be one of: pvscsi, lsilogic, lsilogic-sas, buslogic."
  }
}

variable "scsi_controller_count" {
  description = "Number of SCSI controllers (1–4)."
  type        = number
  default     = 1

  validation {
    condition     = var.scsi_controller_count >= 1 && var.scsi_controller_count <= 4
    error_message = "scsi_controller_count must be between 1 and 4."
  }
}

variable "scsi_bus_sharing" {
  description = "SCSI bus sharing mode. One of: noSharing, virtualSharing, physicalSharing."
  type        = string
  default     = "noSharing"

  validation {
    condition     = contains(["noSharing", "virtualSharing", "physicalSharing"], var.scsi_bus_sharing)
    error_message = "scsi_bus_sharing must be one of: noSharing, virtualSharing, physicalSharing."
  }
}

variable "network_interfaces" {
  description = <<-EOT
    List of network interface configurations. Each object supports:
    - network_name            (required) Port group or distributed port group name.
    - adapter_type                       NIC type: vmxnet3, e1000, e1000e (default: vmxnet3).
    - mac_address                        Static MAC address (default: null = auto-assigned).
    - use_static_mac                     Use a static MAC address (default: false).
    - bandwidth_limit                    Bandwidth upper limit in Mbps (-1 = unlimited, default: -1).
    - bandwidth_reservation              Guaranteed bandwidth in Mbps (default: 0).
    - bandwidth_share_level              Share level: low/normal/high/custom (default: normal).
    - bandwidth_share_count              Custom share count (default: 0).
  EOT
  type = list(object({
    network_name          = string
    adapter_type          = optional(string, "vmxnet3")
    mac_address           = optional(string, null)
    use_static_mac        = optional(bool, false)
    bandwidth_limit       = optional(number, -1)
    bandwidth_reservation = optional(number, 0)
    bandwidth_share_level = optional(string, "normal")
    bandwidth_share_count = optional(number, 0)
  }))

  validation {
    condition     = alltrue([for nic in var.network_interfaces : contains(["vmxnet3", "e1000", "e1000e"], nic.adapter_type)])
    error_message = "Each network_interface.adapter_type must be one of: vmxnet3, e1000, e1000e."
  }

  validation {
    condition     = alltrue([for nic in var.network_interfaces : contains(["low", "normal", "high", "custom"], nic.bandwidth_share_level)])
    error_message = "Each network_interface.bandwidth_share_level must be one of: low, normal, high, custom."
  }
}

variable "ip_settings" {
  description = <<-EOT
    Per-interface IPv4 settings. Ordered to match network_interfaces list.
    Empty list = DHCP on all interfaces.
    Each object:
    - ipv4_address  Static IPv4 address.
    - ipv4_netmask  Subnet prefix length (e.g. 24).
  EOT
  type = list(object({
    ipv4_address = string
    ipv4_netmask = number
  }))
  default = []
}

variable "ipv4_gateway" {
  description = "Default IPv4 gateway for guest customization."
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "List of DNS server IP addresses for guest customization. Defaults to empty list — an empty list leaves DNS unchanged (governed by DHCP or the template). Set explicitly for static DNS."
  type        = list(string)
  default     = []
}

variable "dns_suffix_list" {
  description = "List of DNS search suffixes for guest customization."
  type        = list(string)
  default     = []
}

variable "guest_id" {
  description = "VMware guest OS identifier (e.g. ubuntu64Guest, windows2019srv_64Guest)."
  type        = string
}

variable "is_windows" {
  description = "Set to true to enable Windows-specific guest customization."
  type        = bool
  default     = false
}

variable "computer_name" {
  description = "Hostname to set inside the guest OS. Defaults to vm_name."
  type        = string
  default     = null
}

variable "domain" {
  description = "DNS domain for the guest OS (e.g. example.com)."
  type        = string
  default     = null
}

variable "time_zone" {
  description = "Time zone. Linux: Olson format (e.g. America/New_York). Windows: numeric index (e.g. 85)."
  type        = string
  default     = null
}

variable "windows_admin_password" {
  description = "Local administrator password for Windows guest customization."
  type        = string
  sensitive   = true
  default     = null
}

variable "windows_workgroup" {
  description = "Workgroup for Windows guest (used when not joining a domain). Defaults to 'WORKGROUP'."
  type        = string
  default     = "WORKGROUP"
}

variable "windows_domain" {
  description = "Active Directory domain to join (Windows only)."
  type        = string
  default     = null
}

variable "windows_domain_user" {
  description = "User account for joining the Windows guest to a domain."
  type        = string
  default     = null
}

variable "windows_domain_password" {
  description = "Password for the domain join account (Windows only)."
  type        = string
  sensitive   = true
  default     = null
}

variable "windows_auto_logon" {
  description = "Enable auto-logon after Windows guest customization."
  type        = bool
  default     = false
}

variable "windows_auto_logon_count" {
  description = "Number of times to auto-logon after Windows guest customization."
  type        = number
  default     = 1

  validation {
    condition     = var.windows_auto_logon_count > 0
    error_message = "windows_auto_logon_count must be > 0."
  }
}

variable "windows_run_once" {
  description = "List of commands to run once after Windows guest customization completes."
  type        = list(string)
  default     = []
}

variable "firmware" {
  description = "VM firmware type. One of: bios, efi."
  type        = string
  default     = "bios"

  validation {
    condition     = contains(["bios", "efi"], var.firmware)
    error_message = "firmware must be either 'bios' or 'efi'."
  }
}

variable "hardware_version" {
  description = "Virtual hardware version. Null inherits the template's hardware version."
  type        = number
  default     = null
}

variable "nested_hv_enabled" {
  description = "Enable nested hardware virtualization (expose VMX flag to guest)."
  type        = bool
  default     = false
}

variable "vbs_enabled" {
  description = "Enable Virtualization-based Security (Windows only)."
  type        = bool
  default     = false
}

variable "vvtd_enabled" {
  description = "Enable Intel VT-d pass-through (I/O MMU)."
  type        = bool
  default     = false
}

variable "enable_disk_uuid" {
  description = "Expose disk UUIDs to the guest OS. Required for some applications."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable VMX logging for the virtual machine."
  type        = bool
  default     = false
}

variable "swap_placement_policy" {
  description = "VM swap file placement policy. One of: inherit, hostLocal, vmDirectory."
  type        = string
  default     = "inherit"

  validation {
    condition     = contains(["inherit", "hostLocal", "vmDirectory"], var.swap_placement_policy)
    error_message = "swap_placement_policy must be one of: inherit, hostLocal, vmDirectory."
  }
}

variable "shutdown_wait_timeout" {
  description = "Seconds to wait for a graceful guest OS shutdown before taking further action."
  type        = number
  default     = 3
}

variable "force_power_off" {
  description = "Force power off the VM if graceful shutdown fails within shutdown_wait_timeout."
  type        = bool
  default     = true
}

variable "migrate_wait_timeout" {
  description = "Seconds to wait for a vMotion migration to complete."
  type        = number
  default     = 30
}

variable "wait_for_guest_net_timeout" {
  description = "Seconds to wait for a guest network IP to be reported. Set to -1 to skip."
  type        = number
  default     = 5

  validation {
    condition     = var.wait_for_guest_net_timeout == -1 || var.wait_for_guest_net_timeout > 0
    error_message = "wait_for_guest_net_timeout must be -1 (to skip) or > 0."
  }
}

variable "wait_for_guest_net_routable" {
  description = "Require a routable (non-link-local) IP address before considering the VM ready."
  type        = bool
  default     = true
}

variable "wait_for_guest_ip_timeout" {
  description = "Seconds to wait for a guest IP address when wait_for_guest_net_timeout is -1."
  type        = number
  default     = 0
}

variable "cdrom_enabled" {
  description = "Attach a CDROM device to the virtual machine."
  type        = bool
  default     = false
}

variable "cdrom_datastore_id" {
  description = "Managed object ID of the datastore containing the ISO file."
  type        = string
  default     = null
}

variable "cdrom_path" {
  description = "Datastore path to the ISO file (e.g. '[datastore] ISOs/ubuntu.iso')."
  type        = string
  default     = null
}

variable "cdrom_client_device" {
  description = "Use a client-connected device instead of an ISO file."
  type        = bool
  default     = false
}

variable "extra_config" {
  description = "Map of advanced VMX configuration key/value pairs."
  type        = map(string)
  default     = {}
}

variable "extra_config_reboot_required" {
  description = "Reboot the VM after applying extra_config changes."
  type        = bool
  default     = false
}

variable "vapp_properties" {
  description = "Map of OVF/OVA vApp property keys to values."
  type        = map(string)
  default     = {}
}

variable "customize_timeout" {
  description = "Minutes to wait for guest customization to complete. Increase for Windows Sysprep + domain join in slower environments."
  type        = number
  default     = 30

  validation {
    condition     = var.customize_timeout > 0
    error_message = "customize_timeout must be a positive integer (minutes)."
  }
}
