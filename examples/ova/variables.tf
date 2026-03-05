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
  description = "Name of the Harbor OVA template to clone from. Must have been deployed and marked as a template in vCenter."
  type        = string
}

variable "template_datacenter" {
  description = "Datacenter containing the template. Defaults to var.datacenter when null."
  type        = string
  default     = null
}

variable "num_cpus" {
  description = "Total number of virtual CPUs. Harbor minimum is 2."
  type        = number
  default     = 2
}

variable "num_cores_per_socket" {
  description = "Number of cores per virtual socket."
  type        = number
  default     = 1
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

variable "memory" {
  description = "Amount of RAM in MB. Harbor minimum is 4096 MB."
  type        = number
  default     = 8192
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

variable "disks" {
  description = "List of disk configurations. Harbor ships with a pre-sized OS disk; add extra disks for registry data if needed."
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
  description = "SCSI controller type."
  type        = string
  default     = "pvscsi"
}

variable "scsi_controller_count" {
  description = "Number of SCSI controllers (1–4)."
  type        = number
  default     = 1
}

variable "network_interfaces" {
  description = "List of network interface configurations."
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
  description = "Default IPv4 gateway."
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "List of DNS server IP addresses."
  type        = list(string)
  default     = []
}

variable "dns_suffix_list" {
  description = "List of DNS search suffixes."
  type        = list(string)
  default     = []
}

variable "guest_id" {
  description = "VMware guest OS identifier. Harbor 2.x runs on Photon OS 4 (vmwarePhoton64Guest)."
  type        = string
  default     = "vmwarePhoton64Guest"
}

variable "computer_name" {
  description = "Hostname to set inside the guest OS. Defaults to vm_name when null."
  type        = string
  default     = null
}

variable "domain" {
  description = "DNS domain for the guest OS (e.g. example.com)."
  type        = string
  default     = null
}

variable "time_zone" {
  description = "Olson time zone string for the guest OS (e.g. America/New_York)."
  type        = string
  default     = null
}

variable "firmware" {
  description = "VM firmware type. One of: bios, efi."
  type        = string
  default     = "efi"
}

variable "hardware_version" {
  description = "Virtual hardware version. Null inherits from the template."
  type        = number
  default     = null
}

variable "enable_disk_uuid" {
  description = "Expose disk UUIDs to the guest OS."
  type        = bool
  default     = true
}

variable "wait_for_guest_net_timeout" {
  description = "Seconds to wait for VMware Tools to report a guest IP. Set to -1 to skip."
  type        = number
  default     = 5
}

variable "wait_for_guest_net_routable" {
  description = "Require a routable (non-link-local) IP before considering the VM ready."
  type        = bool
  default     = true
}

variable "customize_timeout" {
  description = "Minutes to wait for guest customization to complete."
  type        = number
  default     = 30
}

variable "harbor_hostname" {
  description = "Fully-qualified hostname or IP address used as Harbor's external URL and TLS SAN. Must be reachable by clients."
  type        = string
}

variable "harbor_admin_password" {
  description = "Initial password for the Harbor 'admin' account. Change immediately after first login."
  type        = string
  sensitive   = true
}

variable "harbor_db_password" {
  description = "Password for Harbor's internal PostgreSQL database."
  type        = string
  sensitive   = true
}

variable "harbor_log_level" {
  description = "Harbor log level. One of: debug, info, warning, error, fatal."
  type        = string
  default     = "info"
}

variable "harbor_gc_enabled" {
  description = "Enable scheduled garbage collection to reclaim unused blob storage."
  type        = bool
  default     = true
}
