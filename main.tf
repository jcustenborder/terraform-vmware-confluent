provider "vsphere" {
  vsphere_server = "${var.vcenter_server}"
  password = "${var.vcenter_password}"
  user = "${var.vcenter_username}"
  allow_unverified_ssl = true,
}

data "vsphere_datacenter" "dc" {
  name = "${var.vcenter_datacenter}"
}

data "vsphere_datastore" "datastore" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  name = "${var.vcenter_datastore}"
}

data "vsphere_resource_pool" "pool" {
  name = "primary/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name = "${var.template_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name = "${var.vcenter_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_folder" "confluent_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "confluent"
  type = "vm",
}

resource "vsphere_folder" "environment_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.confluent_folder.path}/${var.environment_name}"
  type = "vm",
}

resource "vsphere_folder" "kafka_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.environment_folder.path}/kafka"
  type = "vm",
}

resource "vsphere_folder" "broker_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.kafka_folder.path}/broker"
  type = "vm",
}

resource "vsphere_folder" "connect_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.kafka_folder.path}/connect"
  type = "vm",
}

resource "vsphere_folder" "rest_proxy_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.kafka_folder.path}/rest-proxy"
  type = "vm",
}

resource "vsphere_folder" "zookeeper_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.environment_folder.path}/zookeeper"
  type = "vm",
}

resource "vsphere_folder" "schema_registry_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.environment_folder.path}/schema-registry"
  type = "vm",
}

resource "vsphere_folder" "control_center_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.environment_folder.path}/control-center"
  type = "vm",
}

resource "vsphere_folder" "ksql_folder" {
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  path = "${vsphere_folder.environment_folder.path}/ksql"
  type = "vm",
}

resource "vsphere_virtual_machine" "zookeeper" {
  name = "${var.environment_name}-zookeeper-${format("%03d", count.index+1)}"
  count = "${var.zookeeper_count}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${vsphere_folder.zookeeper_folder.path}"

  num_cpus = "${var.zookeeper_vcpu_count}"
  memory = "${var.zookeeper_memory_mb}"

  "disk" {
    label = "disk0"
    thin_provisioned = true
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}.${var.domain_name}",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    private_key = "${file(var.ssh_key_file)}"
  }
}

resource "vsphere_virtual_machine" "broker" {
  name = "${var.environment_name}-broker-${format("%03d", count.index+1)}"
  count = "${var.broker_count}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${vsphere_folder.broker_folder.path}"

  num_cpus = "${var.broker_vcpu_count}"
  memory = "${var.broker_memory_mb}"

  "disk" {
    label = "disk0"
    thin_provisioned = true
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}.${var.domain_name}",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    private_key = "${file(var.ssh_key_file)}"
  }
}

resource "vsphere_virtual_machine" "schema-registry" {
  name = "${var.environment_name}-schema-registry-${format("%03d", count.index+1)}"
  count = "${var.schema_registry_count}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${vsphere_folder.schema_registry_folder.path}"

  num_cpus = "${var.schema_registry_vcpu_count}"
  memory = "${var.schema_registry_memory_mb}"

  "disk" {
    label = "disk0"
    thin_provisioned = true
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}.${var.domain_name}",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    private_key = "${file(var.ssh_key_file)}"
  }
}

resource "vsphere_virtual_machine" "ksql" {
  name = "${var.environment_name}-ksql-${format("%03d", count.index+1)}"
  count = "${var.ksql_count}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${vsphere_folder.ksql_folder.path}"

  num_cpus = "${var.ksql_vcpu_count}"
  memory = "${var.ksql_memory_mb}"

  "disk" {
    label = "disk0"
    thin_provisioned = true
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}.${var.domain_name}",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    private_key = "${file(var.ssh_key_file)}"
  }
}

resource "vsphere_virtual_machine" "connect-distributed" {
  name = "${var.environment_name}-connect-${format("%03d", count.index+1)}"
  count = "${var.connect_count}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${vsphere_folder.connect_folder.path}"

  num_cpus = "${var.connect_vcpu_count}"
  memory = "${var.connect_memory_mb}"

  "disk" {
    label = "disk0"
    thin_provisioned = true
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}.${var.domain_name}",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    private_key = "${file(var.ssh_key_file)}"
  }
}

resource "vsphere_virtual_machine" "kafka-rest" {
  name = "${var.environment_name}-kafka-rest-${format("%03d", count.index+1)}"
  count = "${var.rest_proxy_count}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${vsphere_folder.rest_proxy_folder.path}"

  num_cpus = "${var.rest_proxy_vcpu_count}"
  memory = "${var.rest_proxy_memory_mb}"

  "disk" {
    label = "disk0"
    thin_provisioned = true
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}.${var.domain_name}",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    private_key = "${file(var.ssh_key_file)}"
  }
}

resource "vsphere_virtual_machine" "control-center" {
  name = "${var.environment_name}-control-center-${format("%03d", count.index+1)}"
  count = "${var.control_center_count}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder = "${vsphere_folder.control_center_folder.path}"

  num_cpus = "${var.control_center_vcpu_count}"
  memory = "${var.control_center_memory_mb}"

  "disk" {
    label = "disk0"
    thin_provisioned = true
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
  }

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}.${var.domain_name}",
    ]
  }

  connection {
    type = "ssh",
    user = "${var.ssh_username}",
    private_key = "${file(var.ssh_key_file)}"
  }
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "zookeeper" {
  compute_cluster_id = "${data.vsphere_compute_cluster.cluster.id}"
  name = "confluent_${var.environment_name}_zookeeper"
  virtual_machine_ids = [
    "${vsphere_virtual_machine.zookeeper.*.id}"]
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "broker" {
  compute_cluster_id = "${data.vsphere_compute_cluster.cluster.id}"
  name = "confluent_${var.environment_name}_broker"
  virtual_machine_ids = [
    "${vsphere_virtual_machine.broker.*.id}"]
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "schema_registry" {
  compute_cluster_id = "${data.vsphere_compute_cluster.cluster.id}"
  name = "confluent_${var.environment_name}_schema_registry"
  virtual_machine_ids = [
    "${vsphere_virtual_machine.schema-registry.*.id}"]
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "ksql" {
  compute_cluster_id = "${data.vsphere_compute_cluster.cluster.id}"
  name = "confluent_${var.environment_name}_ksql"
  virtual_machine_ids = [
    "${vsphere_virtual_machine.ksql.*.id}"]
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "connect-distributed" {
  compute_cluster_id = "${data.vsphere_compute_cluster.cluster.id}"
  name = "confluent_${var.environment_name}_connect_distributed"
  virtual_machine_ids = [
    "${vsphere_virtual_machine.connect-distributed.*.id}"]
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "kafka-rest" {
  compute_cluster_id = "${data.vsphere_compute_cluster.cluster.id}"
  name = "confluent_${var.environment_name}_kafka_rest"
  virtual_machine_ids = [
    "${vsphere_virtual_machine.kafka-rest.*.id}"]
}
