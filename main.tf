locals {
  resource_pool_id = (
    var.resource_pool != null
    ? data.vsphere_resource_pool.this[0].id
    : (
      var.cluster != null
      ? data.vsphere_compute_cluster.this[0].resource_pool_id
      : null
    )
  )

  datastore_id         = var.datastore != null ? data.vsphere_datastore.this[0].id : null
  datastore_cluster_id = var.datastore_cluster != null ? data.vsphere_datastore_cluster.this[0].id : null

  host_system_id = var.host != null ? data.vsphere_host.this[0].id : null

  # Hostname used inside the guest — falls back to vm_name if not explicitly set
  computer_name = var.computer_name != null ? var.computer_name : var.vm_name

  tag_ids = [for k, _ in var.tags : data.vsphere_tag.this[k].id]

  # Map of network_name → network_id consumed by the NIC dynamic block
  network_ids = { for nic in var.network_interfaces : nic.network_name => data.vsphere_network.this[nic.network_name].id }

  # Default num_cores_per_socket to num_cpus (single socket) when not explicitly set
  num_cores_per_socket = var.num_cores_per_socket != null ? var.num_cores_per_socket : var.num_cpus

  # Inherit guest_id from the source template when not explicitly set
  guest_id = var.guest_id != null ? var.guest_id : data.vsphere_virtual_machine.template.guest_id

  # Pair each NIC with its IP settings; interfaces without an entry fall back to DHCP (null values)
  nic_ip_settings = [
    for i, nic in var.network_interfaces : (
      length(var.ip_settings) > i
      ? var.ip_settings[i]
      : { ipv4_address = null, ipv4_netmask = null }
    )
  ]

}

resource "vsphere_virtual_machine" "this" {
  name                 = var.vm_name
  resource_pool_id     = local.resource_pool_id
  datastore_id         = local.datastore_id
  datastore_cluster_id = local.datastore_cluster_id
  host_system_id       = local.host_system_id
  folder               = var.vm_folder
  annotation           = var.annotation
  tags                 = local.tag_ids

  guest_id = local.guest_id

  firmware             = var.firmware
  hardware_version     = var.hardware_version
  tools_upgrade_policy = var.tools_upgrade_policy

  num_cpus               = var.num_cpus
  num_cores_per_socket   = local.num_cores_per_socket
  cpu_hot_add_enabled    = var.cpu_hot_add_enabled
  cpu_hot_remove_enabled = var.cpu_hot_remove_enabled
  cpu_limit              = var.cpu_limit
  cpu_reservation        = var.cpu_reservation
  cpu_share_level        = var.cpu_share_level
  cpu_share_count        = var.cpu_share_level == "custom" ? var.cpu_share_count : null

  memory                 = var.memory
  memory_hot_add_enabled = var.memory_hot_add_enabled
  memory_limit           = var.memory_limit
  memory_reservation     = var.memory_reservation
  memory_share_level     = var.memory_share_level
  memory_share_count     = var.memory_share_level == "custom" ? var.memory_share_count : null

  scsi_type             = var.scsi_type
  scsi_controller_count = var.scsi_controller_count
  scsi_bus_sharing      = var.scsi_bus_sharing

  nested_hv_enabled       = var.nested_hv_enabled
  vbs_enabled             = var.vbs_enabled
  vvtd_enabled            = var.vvtd_enabled
  efi_secure_boot_enabled = var.efi_secure_boot_enabled
  enable_disk_uuid        = var.enable_disk_uuid
  enable_logging          = var.enable_logging
  swap_placement_policy   = var.swap_placement_policy

  shutdown_wait_timeout       = var.shutdown_wait_timeout
  force_power_off             = var.force_power_off
  migrate_wait_timeout        = var.migrate_wait_timeout
  wait_for_guest_net_timeout  = var.wait_for_guest_net_timeout
  wait_for_guest_net_routable = var.wait_for_guest_net_routable
  wait_for_guest_ip_timeout   = var.wait_for_guest_ip_timeout

  extra_config                 = var.extra_config
  extra_config_reboot_required = var.extra_config_reboot_required

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      network_id            = local.network_ids[network_interface.value.network_name]
      adapter_type          = network_interface.value.adapter_type
      mac_address           = network_interface.value.use_static_mac ? network_interface.value.mac_address : null
      use_static_mac        = network_interface.value.use_static_mac
      bandwidth_limit       = network_interface.value.bandwidth_limit
      bandwidth_reservation = network_interface.value.bandwidth_reservation
      bandwidth_share_level = network_interface.value.bandwidth_share_level
      bandwidth_share_count = network_interface.value.bandwidth_share_level == "custom" ? network_interface.value.bandwidth_share_count : null
    }
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      label             = disk.value.label
      size              = disk.value.size
      unit_number       = disk.value.unit_number
      thin_provisioned  = disk.value.thin_provisioned
      eagerly_scrub     = disk.value.eagerly_scrub
      datastore_id      = disk.value.datastore_id
      storage_policy_id = disk.value.storage_policy_id
      keep_on_remove    = disk.value.keep_on_remove
      io_limit          = disk.value.io_limit
      io_reservation    = disk.value.io_reservation
      io_share_level    = disk.value.io_share_level
      io_share_count    = disk.value.io_share_level == "custom" ? disk.value.io_share_count : null
      disk_sharing      = disk.value.disk_sharing
      controller_type   = disk.value.controller_type
    }
  }

  dynamic "cdrom" {
    for_each = var.cdrom_enabled ? [1] : []
    content {
      client_device = var.cdrom_client_device
      datastore_id  = var.cdrom_client_device ? null : var.cdrom_datastore_id
      path          = var.cdrom_client_device ? null : var.cdrom_path
    }
  }

  dynamic "vapp" {
    for_each = length(var.vapp_properties) > 0 ? [1] : []
    content {
      properties = var.vapp_properties
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone  = var.linked_clone

    customize {
      timeout = var.customize_timeout

      # Linux: set hostname (falls back to vm_name) and domain
      dynamic "linux_options" {
        for_each = var.is_windows ? [] : [1]
        content {
          host_name   = local.computer_name
          domain      = var.domain
          time_zone   = var.time_zone
          script_text = var.linux_script_text
        }
      }

      # Windows: rename computer via Sysprep and optionally join domain
      dynamic "windows_options" {
        for_each = var.is_windows ? [1] : []
        content {
          computer_name         = local.computer_name
          admin_password        = var.windows_admin_password
          workgroup             = var.windows_domain == null ? var.windows_workgroup : null
          join_domain           = var.windows_domain
          domain_admin_user     = var.windows_domain_user
          domain_admin_password = var.windows_domain_password
          domain_ou             = var.windows_domain_ou
          auto_logon            = var.windows_auto_logon
          auto_logon_count      = var.windows_auto_logon ? var.windows_auto_logon_count : null
          time_zone             = var.time_zone != null ? tonumber(var.time_zone) : null
          run_once_command_list = var.windows_run_once
        }
      }

      # Per-interface IP settings; interfaces without an entry use DHCP
      dynamic "network_interface" {
        for_each = local.nic_ip_settings
        content {
          ipv4_address = network_interface.value.ipv4_address
          ipv4_netmask = network_interface.value.ipv4_netmask
        }
      }

      ipv4_gateway    = var.ipv4_gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = var.dns_suffix_list
    }
  }

  # The customize block is a one-time operation at clone time; vSphere does not
  # persist it back to state, causing drift on every subsequent plan.
  # ignore_changes requires a static list.
  lifecycle {
    ignore_changes = [clone[0].customize]

    precondition {
      condition     = var.cluster != null || var.resource_pool != null
      error_message = "Either cluster or resource_pool must be specified."
    }

    precondition {
      condition     = var.datastore != null || var.datastore_cluster != null
      error_message = "Either datastore or datastore_cluster must be specified."
    }

    precondition {
      condition     = !(var.datastore != null && var.datastore_cluster != null)
      error_message = "Only one of datastore or datastore_cluster may be specified, not both."
    }

    # Windows: computer rename is always applied via Sysprep (computer_name / local.computer_name).
    # Domain join requires credentials when a domain is specified.
    precondition {
      condition     = !var.is_windows || var.windows_domain == null || (var.windows_domain_user != null && var.windows_domain_password != null)
      error_message = "windows_domain_user and windows_domain_password must both be set when windows_domain is specified."
    }

    # Linux: hostname is always set via local.computer_name (falls back to vm_name).
    # Guard against an explicitly supplied empty string.
    precondition {
      condition     = var.computer_name == null || length(trimspace(var.computer_name)) > 0
      error_message = "computer_name must not be an empty string."
    }

    # num_cpus must be evenly divisible by num_cores_per_socket (vSphere API requirement).
    precondition {
      condition     = var.num_cpus % local.num_cores_per_socket == 0
      error_message = "num_cpus must be evenly divisible by num_cores_per_socket."
    }

    # Windows time_zone must be a numeric string (e.g. '85'); Olson strings are Linux-only.
    precondition {
      condition     = !var.is_windows || var.time_zone == null || can(tonumber(var.time_zone))
      error_message = "time_zone must be a numeric string when is_windows = true (e.g. '85' for Eastern Standard Time)."
    }

    # VBS requires EFI firmware; BIOS + VBS will fail at the vSphere API level.
    precondition {
      condition     = !var.vbs_enabled || var.firmware == "efi"
      error_message = "vbs_enabled = true requires firmware = 'efi'."
    }

    # Secure Boot requires EFI firmware.
    precondition {
      condition     = !var.efi_secure_boot_enabled || var.firmware == "efi"
      error_message = "efi_secure_boot_enabled = true requires firmware = 'efi'."
    }

    # When CDROM is enabled without client_device, an ISO path must be provided.
    precondition {
      condition     = !var.cdrom_enabled || var.cdrom_client_device || var.cdrom_path != null
      error_message = "cdrom_path must be set when cdrom_enabled = true and cdrom_client_device = false."
    }

    # Custom CPU share level requires a positive share count.
    precondition {
      condition     = var.cpu_share_level != "custom" || (var.cpu_share_count != null && var.cpu_share_count > 0)
      error_message = "cpu_share_count must be > 0 when cpu_share_level = 'custom'."
    }

    # Custom memory share level requires a positive share count.
    precondition {
      condition     = var.memory_share_level != "custom" || (var.memory_share_count != null && var.memory_share_count > 0)
      error_message = "memory_share_count must be > 0 when memory_share_level = 'custom'."
    }

    # Custom NIC bandwidth share level requires a positive share count.
    precondition {
      condition     = alltrue([for nic in var.network_interfaces : nic.bandwidth_share_level != "custom" || nic.bandwidth_share_count > 0])
      error_message = "bandwidth_share_count must be > 0 for each NIC when bandwidth_share_level = 'custom'."
    }

    # Custom disk I/O share level requires a positive share count.
    precondition {
      condition     = alltrue([for d in var.disks : d.io_share_level != "custom" || d.io_share_count > 0])
      error_message = "io_share_count must be > 0 for each disk when io_share_level = 'custom'."
    }

    # Static MAC address must be provided when use_static_mac = true.
    precondition {
      condition     = alltrue([for nic in var.network_interfaces : !nic.use_static_mac || nic.mac_address != null])
      error_message = "mac_address must be set when use_static_mac = true."
    }

    # Windows Sysprep requires an admin password.
    precondition {
      condition     = !var.is_windows || var.windows_admin_password != null
      error_message = "windows_admin_password must be set when is_windows = true."
    }

    # Windows Sysprep requires either a domain or a workgroup.
    precondition {
      condition     = !var.is_windows || var.windows_domain != null || var.windows_workgroup != null
      error_message = "Either windows_domain or windows_workgroup must be specified when is_windows = true."
    }
  }
}
