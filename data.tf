data "vsphere_datacenter" "this" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "this" {
  count         = var.cluster != null ? 1 : 0
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_host" "this" {
  count         = var.host != null ? 1 : 0
  name          = var.host
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_resource_pool" "this" {
  count         = var.resource_pool != null ? 1 : 0
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore" "this" {
  count         = var.datastore != null ? 1 : 0
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore_cluster" "this" {
  count         = var.datastore_cluster != null ? 1 : 0
  name          = var.datastore_cluster
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  for_each      = toset([for nic in var.network_interfaces : nic.network_name])
  name          = each.key
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datacenter" "template" {
  count = var.template_datacenter != null ? 1 : 0
  name  = var.template_datacenter
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = var.template_datacenter != null ? data.vsphere_datacenter.template[0].id : data.vsphere_datacenter.this.id
}

data "vsphere_tag_category" "this" {
  for_each = var.tags
  name     = each.key
}

data "vsphere_tag" "this" {
  for_each    = var.tags
  name        = each.value
  category_id = data.vsphere_tag_category.this[each.key].id
}
