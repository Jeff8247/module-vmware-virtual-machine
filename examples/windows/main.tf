module "vm" {
  source = "../.."

  datacenter        = var.datacenter
  cluster           = var.cluster
  resource_pool     = var.resource_pool
  datastore         = var.datastore
  datastore_cluster = var.datastore_cluster
  host              = var.host

  vm_name    = var.vm_name
  vm_folder  = var.vm_folder
  annotation = var.annotation
  tags       = var.tags

  template_name       = var.template_name
  template_datacenter = var.template_datacenter
  linked_clone        = var.linked_clone

  num_cpus             = var.num_cpus
  num_cores_per_socket = var.num_cores_per_socket
  cpu_hot_add_enabled  = var.cpu_hot_add_enabled
  cpu_reservation      = var.cpu_reservation
  cpu_limit            = var.cpu_limit
  cpu_share_level      = var.cpu_share_level

  memory                 = var.memory
  memory_hot_add_enabled = var.memory_hot_add_enabled
  memory_reservation     = var.memory_reservation
  memory_limit           = var.memory_limit
  memory_share_level     = var.memory_share_level

  disks                 = var.disks
  scsi_type             = var.scsi_type
  scsi_controller_count = var.scsi_controller_count

  network_interfaces = var.network_interfaces
  ip_settings        = var.ip_settings
  ipv4_gateway       = var.ipv4_gateway
  dns_servers        = var.dns_servers
  dns_suffix_list    = var.dns_suffix_list

  guest_id                 = var.guest_id
  is_windows               = true
  computer_name            = var.computer_name
  domain                   = var.domain
  time_zone                = var.time_zone
  windows_admin_password   = var.windows_admin_password
  windows_domain           = var.windows_domain
  windows_domain_user      = var.windows_domain_user
  windows_domain_password  = var.windows_domain_password
  windows_workgroup        = var.windows_workgroup
  windows_auto_logon       = var.windows_auto_logon
  windows_auto_logon_count = var.windows_auto_logon_count
  windows_run_once         = var.windows_run_once

  firmware                    = var.firmware
  hardware_version            = var.hardware_version
  enable_disk_uuid            = var.enable_disk_uuid
  vbs_enabled                 = var.vbs_enabled
  wait_for_guest_net_timeout  = var.wait_for_guest_net_timeout
  wait_for_guest_net_routable = var.wait_for_guest_net_routable

  customize_timeout = var.customize_timeout

  extra_config = var.extra_config
}
