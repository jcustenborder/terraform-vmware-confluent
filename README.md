# Introduction 

This project is designed launch the Confluent platform on VMWare using Terraform and Ansible. 
Terraform is used to clone the virtual machines, and configure [VM anti affinity rules.](https://www.terraform.io/docs/providers/vsphere/r/compute_cluster_vm_anti_affinity_rule.html) 
so that nodes in the same role do not reside on the same host.

# Requirements

* [VMWare vCenter Server](https://www.vmware.com/products/vcenter-server.html)
* [Terraform](https://www.terraform.io/)
* [Ansible](https://www.ansible.com/)
* (RedHat|CentOS) 7 image.
    * Key based authentication
    * Super user capabilities. See [ansible_become](https://docs.ansible.com/ansible/latest/user_guide/become.html)

# Configure your environment

You need to fill out this information.

## Terraform connection to vCenter

edit terraform.tfvars
```hcl-terraform
vcenter_server = 
vcenter_username = 
vcenter_password = 
vcenter_datacenter = 
vcenter_cluster = 
vcenter_datastore = 
template_name = 
environment_name = 
vcenter_default_network = 
domain_name = 
ssh_username = 
ssh_key_file = 
```

```bash
virtualenv --python=python3.5 .
pip install -r requirements.txt 
cd library
git clone https://github.com/confluentinc/cp-ansible.git cp-ansible
cd ..
```

Provision Virtual Machines

```bash
terraform apply
```

Install the Confluent Platform

```bash
ansible-playbook -i ./inventory.py all.yml
```

Add 
