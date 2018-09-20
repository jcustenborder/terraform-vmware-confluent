variable "vcenter_server" {
  description = "Host running VmWare VCenter"
}

variable "vcenter_username" {
  description = "Username to connect with VCenter with."
}

variable "vcenter_password" {
  description = "Password to connect with VCenter with."
}

variable "vcenter_datacenter" {
  description = "Datacenter in VSphere"
}

variable "vcenter_cluster" {
  description = "Cluster in vsphere"
}

variable "vcenter_datastore" {
  description = "Datastore to store things on"
}

variable "vcenter_default_network" {
  description = "Network to attach the virtual machines to"
}

variable "domain_name" {
  description = "The DNS domain name for the virtual machines."
}

variable "environment_name" {
  description = "The name of the environment for this cluster."
}

variable "template_name" {
  description = "The name of the template in vsphere"
}

variable "ssh_username" {
  description = "The username to ssh to the instance with."
}

variable "ssh_key_file" {
  description = "The path on the local file system for the private ssh key to authenticate with."
}

variable "zookeeper_memory_mb" {
  default = 8192
  description = "The amount of memory in mb to allocate to zookeeper instances."
}

variable "zookeeper_vcpu_count" {
  default = 2,
  description = "The number of vcpu(s) to allocate to zookeeper instances."
}

variable "zookeeper_count" {
  default = 3,
  description = "The number of zookeeper instances to launch."
}

variable "broker_memory_mb" {
  default = 16384
  description = "The amount of memory in mb to allocate to broker instances."
}

variable "broker_vcpu_count" {
  default = 4
  description = "The number of vcpu(s) to allocate to broker instances."
}

variable "broker_count" {
  default = 3,
  description = "The number of broker instances to launch."
}

variable "schema_registry_memory_mb" {
  default = 4096
  description = "The amount of memory in mb to allocate to schema registry instances."
}

variable "schema_registry_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to schema registry instances."
}

variable "schema_registry_count" {
  default = 2
  description = "The number of schema registry instances to launch."
}


variable "control_center_memory_mb" {
  default = 8192
  description = "The number of vcpu(s) to allocate to control center instances."
}

variable "control_center_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to control center instances."
}

variable "control_center_count" {
  default = 1
  description = "The number of control center instances to launch."
}

variable "connect_memory_mb" {
  default = 8192
  description = "The amount of memory in mb to allocate to kafka connect instances."
}

variable "connect_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to kafka connect instances."
}
variable "connect_count" {
  default = 2
  description = "The number of Kafka Connect instances to launch."
}

variable "rest_proxy_memory_mb" {
  default = 8192
  description = "The amount of memory in mb to allocate to kafka rest_proxy instances."
}

variable "rest_proxy_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to kafka rest_proxy instances."
}
variable "rest_proxy_count" {
  default = 2
  description = "The number of Kafka Connect instances to launch."
}

variable "ksql_memory_mb" {
  default = 8192
  description = "The number of vcpu(s) to allocate to control center instances."
}

variable "ksql_vcpu_count" {
  default = 2
  description = "The number of vcpu(s) to allocate to control center instances."
}
variable "ksql_count" {
  default = 2
  description = "The number of KSQL instances to launch"
}