module "vm" {
  source = "../.."

  # ---- Infrastructure ----------------------------------------
  datacenter        = var.datacenter
  cluster           = var.cluster
  resource_pool     = var.resource_pool
  datastore         = var.datastore
  datastore_cluster = var.datastore_cluster
  host              = var.host

  # ---- VM Identity -------------------------------------------
  vm_name    = var.vm_name
  vm_folder  = var.vm_folder
  annotation = var.annotation
  tags       = var.tags

  # ---- Template ----------------------------------------------
  template_name       = var.template_name
  template_datacenter = var.template_datacenter
  linked_clone        = var.linked_clone

  # ---- CPU ---------------------------------------------------
  num_cpus             = var.num_cpus
  num_cores_per_socket = var.num_cores_per_socket
  cpu_hot_add_enabled  = var.cpu_hot_add_enabled
  cpu_reservation      = var.cpu_reservation
  cpu_limit            = var.cpu_limit
  cpu_share_level      = var.cpu_share_level

  # ---- Memory ------------------------------------------------
  memory                 = var.memory
  memory_hot_add_enabled = var.memory_hot_add_enabled
  memory_reservation     = var.memory_reservation
  memory_limit           = var.memory_limit
  memory_share_level     = var.memory_share_level

  # ---- Disks -------------------------------------------------
  disks                 = var.disks
  scsi_type             = var.scsi_type
  scsi_controller_count = var.scsi_controller_count

  # ---- Network -----------------------------------------------
  network_interfaces = var.network_interfaces
  ip_settings        = var.ip_settings
  ipv4_gateway       = var.ipv4_gateway
  dns_servers        = var.dns_servers
  dns_suffix_list    = var.dns_suffix_list

  # ---- Guest OS — Linux --------------------------------------
  guest_id      = var.guest_id
  is_windows    = false
  computer_name = var.computer_name
  domain        = var.domain
  time_zone     = var.time_zone

  # ---- Hardware & Firmware -----------------------------------
  firmware                    = var.firmware
  hardware_version            = var.hardware_version
  enable_disk_uuid            = var.enable_disk_uuid
  nested_hv_enabled           = var.nested_hv_enabled
  wait_for_guest_net_timeout  = var.wait_for_guest_net_timeout
  wait_for_guest_net_routable = var.wait_for_guest_net_routable

  # ---- Clone / Customization ---------------------------------
  customize_timeout = var.customize_timeout

  # ---- Extra Config ------------------------------------------
  extra_config = var.extra_config
}
