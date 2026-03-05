output "id" {
  description = "The managed object ID of the virtual machine."
  value       = vsphere_virtual_machine.this.id
}

output "name" {
  description = "The name of the virtual machine."
  value       = vsphere_virtual_machine.this.name
}

output "uuid" {
  description = "The BIOS UUID of the virtual machine."
  value       = vsphere_virtual_machine.this.uuid
}

output "default_ip_address" {
  description = "The primary IPv4 address reported by VMware Tools."
  value       = vsphere_virtual_machine.this.default_ip_address
}

output "guest_ip_addresses" {
  description = "All IP addresses reported by VMware Tools across all guest NICs."
  value       = vsphere_virtual_machine.this.guest_ip_addresses
}

output "moid" {
  description = "The managed object reference ID of the virtual machine."
  value       = vsphere_virtual_machine.this.moid
}

output "power_state" {
  description = "The current power state of the virtual machine."
  value       = vsphere_virtual_machine.this.power_state
}

output "datacenter_id" {
  description = "The managed object ID of the vSphere datacenter."
  value       = data.vsphere_datacenter.this.id
}

output "cluster_id" {
  description = "The managed object ID of the compute cluster. Null if cluster was not specified."
  value       = try(data.vsphere_compute_cluster.this[0].id, null)
}

output "resource_pool_id" {
  description = "The managed object ID of the resource pool used by the virtual machine."
  value       = local.resource_pool_id
}

output "host_system_id" {
  description = "The managed object ID of the ESXi host. Null if host was not specified."
  value       = local.host_system_id
}

output "datastore_id" {
  description = "The managed object ID of the primary datastore. Null if datastore_cluster was used instead."
  value       = local.datastore_id
}

output "datastore_cluster_id" {
  description = "The managed object ID of the datastore cluster. Null if datastore was used instead."
  value       = local.datastore_cluster_id
}

output "network_ids" {
  description = "Map of network name to managed object ID for each network attached to the virtual machine."
  value       = { for name, ds in data.vsphere_network.this : name => ds.id }
}

output "template_id" {
  description = "The managed object ID of the source VM template."
  value       = data.vsphere_virtual_machine.template.id
}

output "template_guest_id" {
  description = "The guest OS identifier of the source VM template."
  value       = data.vsphere_virtual_machine.template.guest_id
}

output "template_hardware_version" {
  description = "The virtual hardware version of the source VM template."
  value       = data.vsphere_virtual_machine.template.hardware_version
}

output "tag_ids" {
  description = "List of tag managed object IDs applied to the virtual machine."
  value       = local.tag_ids
}
