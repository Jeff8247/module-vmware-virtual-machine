variable "vsphere_server" {
  description = "Hostname or IP of the vCenter Server."
  type        = string
}

variable "vsphere_user" {
  description = "vCenter username."
  type        = string
}

variable "vsphere_password" {
  description = "vCenter password."
  type        = string
  sensitive   = true
}

variable "vsphere_allow_unverified_ssl" {
  description = "Skip TLS certificate verification. Use only in lab environments."
  type        = bool
  default     = false
}

variable "datacenter" {
  description = "Name of the vSphere datacenter."
  type        = string
}

variable "cluster" {
  description = "Name of the vSphere compute cluster. Either cluster or resource_pool must be set."
  type        = string
  default     = null
}

variable "resource_pool" {
  description = "Name or path of the resource pool. Takes precedence over cluster when both are set."
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
  description = "Name of the ESXi host for placement. Optional."
  type        = string
  default     = null
}

variable "vm_name" {
  description = "Name of the virtual machine."
  type        = string
}

variable "vm_folder" {
  description = "vSphere folder path for the VM. Null places the VM in the datacenter root."
  type        = string
  default     = null
}

variable "annotation" {
  description = "User-provided description / notes for the VM."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tag category name to tag name to apply to the VM. Categories and tags must already exist in vCenter."
  type        = map(string)
  default     = {}
}

variable "template_name" {
  description = "Name of the Windows VM template to clone from. Must be Sysprepped or have a generalised snapshot."
  type        = string
}

variable "template_datacenter" {
  description = "Datacenter containing the template. Defaults to var.datacenter when null."
  type        = string
  default     = null
}

variable "linked_clone" {
  description = "Create a linked clone instead of a full clone. Requires the template to have a snapshot."
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

variable "cpu_reservation" {
  description = "Guaranteed CPU resources in MHz."
  type        = number
  default     = 0
}

variable "cpu_limit" {
  description = "Upper limit of CPU resources in MHz. -1 = unlimited."
  type        = number
  default     = -1
}

variable "cpu_share_level" {
  description = "CPU share allocation level. One of: low, normal, high, custom."
  type        = string
  default     = "normal"
}

variable "memory" {
  description = "Amount of RAM in MB."
  type        = number
  default     = 4096
}

variable "memory_hot_add_enabled" {
  description = "Allow memory to be added while the VM is running."
  type        = bool
  default     = false
}

variable "memory_reservation" {
  description = "Guaranteed memory resources in MB."
  type        = number
  default     = 0
}

variable "memory_limit" {
  description = "Upper limit of memory resources in MB. -1 = unlimited."
  type        = number
  default     = -1
}

variable "memory_share_level" {
  description = "Memory share allocation level. One of: low, normal, high, custom."
  type        = string
  default     = "normal"
}

variable "disks" {
  description = "List of disk configurations. See module variable description for all supported fields."
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
}

variable "scsi_type" {
  description = "SCSI controller type. One of: pvscsi, lsilogic, lsilogic-sas, buslogic."
  type        = string
  default     = "pvscsi"
}

variable "scsi_controller_count" {
  description = "Number of SCSI controllers (1–4)."
  type        = number
  default     = 1
}

variable "network_interfaces" {
  description = "List of network interface configurations. See module variable description for all supported fields."
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
}

variable "ip_settings" {
  description = "Per-interface static IPv4 settings, matched positionally to network_interfaces. Empty list = DHCP on all interfaces."
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
  description = "List of DNS server IP addresses for guest customization."
  type        = list(string)
  default     = []
}

variable "dns_suffix_list" {
  description = "List of DNS search suffixes for guest customization."
  type        = list(string)
  default     = []
}

variable "guest_id" {
  description = "VMware guest OS identifier (e.g. windows2022srvNext_64Guest, windows2019srv_64Guest)."
  type        = string
}

variable "computer_name" {
  description = "Computer name set by Sysprep on first boot. Defaults to vm_name when null. Maximum 15 characters for Windows."
  type        = string
  default     = null
}

variable "time_zone" {
  description = "Windows time zone as a numeric index string (e.g. '85' = Eastern Standard Time, '90' = Central Standard Time, '110' = GMT Standard Time)."
  type        = string
  default     = null
}

variable "windows_admin_password" {
  description = "Local administrator password set during Sysprep customization."
  type        = string
  sensitive   = true
}

variable "windows_domain" {
  description = "Active Directory domain to join during Sysprep customization. Requires windows_domain_user and windows_domain_password."
  type        = string
  default     = null
}

variable "windows_domain_user" {
  description = "User account with permission to join the machine to the domain."
  type        = string
  default     = null
}

variable "windows_domain_password" {
  description = "Password for the domain join account."
  type        = string
  sensitive   = true
  default     = null
}

variable "windows_workgroup" {
  description = "Workgroup for standalone Windows VMs. Used only when windows_domain is not set."
  type        = string
  default     = "WORKGROUP"
}

variable "windows_auto_logon" {
  description = "Enable automatic logon after Sysprep customization completes."
  type        = bool
  default     = false
}

variable "windows_auto_logon_count" {
  description = "Number of times to auto-logon after Sysprep customization."
  type        = number
  default     = 1
}

variable "windows_run_once" {
  description = "List of commands to run once after Sysprep customization completes (e.g. bootstrap scripts)."
  type        = list(string)
  default     = []
}

variable "firmware" {
  description = "VM firmware type. One of: bios, efi."
  type        = string
  default     = "efi"
}

variable "hardware_version" {
  description = "Virtual hardware version. Null inherits the template's hardware version."
  type        = number
  default     = null
}

variable "enable_disk_uuid" {
  description = "Expose disk UUIDs to the guest OS."
  type        = bool
  default     = true
}

variable "vbs_enabled" {
  description = "Enable Virtualization-based Security (requires efi firmware and compatible hardware version)."
  type        = bool
  default     = false
}

variable "wait_for_guest_net_timeout" {
  description = "Seconds to wait for VMware Tools to report a guest IP address. Set to -1 to skip."
  type        = number
  default     = 5
}

variable "wait_for_guest_net_routable" {
  description = "Require a routable (non-link-local) IP address before considering the VM ready."
  type        = bool
  default     = true
}

variable "customize_timeout" {
  description = "Minutes to wait for guest customization to complete. Increase for domain-join in slower environments."
  type        = number
  default     = 60
}

variable "domain" {
  description = "DNS domain suffix set on the guest OS (e.g. corp.example.com). Separate from the AD domain join controlled by windows_domain."
  type        = string
  default     = null
}

variable "extra_config" {
  description = "Map of advanced VMX configuration key/value pairs."
  type        = map(string)
  default     = {}
}
