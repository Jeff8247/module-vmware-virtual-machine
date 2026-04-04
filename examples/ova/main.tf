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
  linked_clone        = false

  num_cpus             = var.num_cpus
  num_cores_per_socket = var.num_cores_per_socket
  cpu_reservation      = var.cpu_reservation
  cpu_limit            = var.cpu_limit

  memory             = var.memory
  memory_reservation = var.memory_reservation
  memory_limit       = var.memory_limit

  disks                 = var.disks
  scsi_type             = var.scsi_type
  scsi_controller_count = var.scsi_controller_count

  network_interfaces = var.network_interfaces
  ip_settings        = var.ip_settings
  ipv4_gateway       = var.ipv4_gateway
  dns_servers        = var.dns_servers
  dns_suffix_list    = var.dns_suffix_list

  guest_id      = var.guest_id
  is_windows    = false
  computer_name = var.computer_name
  domain        = var.domain
  time_zone     = var.time_zone

  firmware                    = var.firmware
  hardware_version            = var.hardware_version
  enable_disk_uuid            = var.enable_disk_uuid
  wait_for_guest_net_timeout  = var.wait_for_guest_net_timeout
  wait_for_guest_net_routable = var.wait_for_guest_net_routable

  customize_timeout = var.customize_timeout

  vapp_properties = {
    "hostname"              = var.harbor_hostname
    "harbor_admin_password" = var.harbor_admin_password
    "db_password"           = var.harbor_db_password
    "log_level"             = var.harbor_log_level
    "gc_enabled"            = tostring(var.harbor_gc_enabled)
  }
}
