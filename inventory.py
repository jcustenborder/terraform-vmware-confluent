#!/usr/bin/env python3

import argparse
import json
import os

allowed_types = {
    'vsphere_virtual_machine': {
        'attributes': {
            'name': 'host',
            'default_ip_address': 'ansible_host'
        }
    }
}


def load_state():
    tf_state_path = os.getenv('KEY_THAT_MIGHT_EXIST', 'terraform.tfstate')
    with open(tf_state_path) as f:
        return json.load(f)


def get_index(resource_key):
    parts = resource_key.split(".")
    if len(parts) == 3:
        return parts[2]
    else:
        return 0


def get_group(resource_key):
    return resource_key.split(".")[1]


def find_attributes(o):
    result = None
    for key, value in o.items():
        if key == 'attributes':
            result = value
            break
        elif isinstance(value, dict):
            result = find_attributes(value)
            if not result is None:
                break

    return result


def copy_attributes(type, group, index, i):
    result = {'group': group, 'index': index}
    attributes = allowed_types[type]['attributes']

    for source, target in attributes.items():
        result[target] = i[source]

    return result


def find_resources(data):
    output = {}
    for module in data['modules']:
        resources = module['resources']
        for resource_key, resource_properties in resources.items():
            if not resource_key.startswith('data.'):
                resource_type = resource_properties['type']
                if resource_type in allowed_types:
                    group = get_group(resource_key)
                    index = get_index(resource_key)
                    input_attributes = find_attributes(resource_properties)
                    attributes = copy_attributes(resource_type, group, index, input_attributes)
                    host = attributes['host']
                    output[host] = attributes

    return output


def list():
    data = load_state()
    resources = find_resources(data)
    output = {}
    for host, attributes in resources.items():
        group = attributes['group']
        if not group in output:
            output[group] = {'hosts': []}
        output[group]['hosts'].append(host)
        output[group]['hosts'].sort()
    print(json.dumps(output, indent=4, sort_keys=True))


def host(host):
    data = load_state()
    resources = find_resources(data)
    output = {}
    exclude = ['host', 'group', 'index']

    if host in resources:
        host_resources = resources[host]
        group = host_resources['group']
        index = host_resources['index']
        if group == 'broker':
            output['kafka'] = {
                'broker': {
                    'id': index
                }
            }
        for key, value in host_resources.items():
            if not key in exclude:
                output[key] = value

    print(json.dumps(output, indent=4, sort_keys=True))


#
#
# def load_state():
#     tf_state_path = os.getenv('KEY_THAT_MIGHT_EXIST', 'terraform.tfstate')
#
#     output = {}
#
#     with open(tf_state_path) as f:
#         data = json.load(f)
#
#     resources = data['modules'][0]['resources']
#
#     for resource_key, resource_properties in resources.items():
#         if resource_properties['type'] == 'vsphere_virtual_machine' and resource_key.startswith(
#                 'vsphere_virtual_machine.'):
#             group = resource_key.split(".")[1]
#             if not group in output:
#                 output[group] = {'hosts': []}
#             name = resource_properties['primary']['attributes']['name']
#             ip_address = resource_properties['primary']['attributes']['default_ip_address']
#
#             output[group][name] = {'ip': ip_address}
#
#     return output


parser = argparse.ArgumentParser(
    description='Dynamically generate inventory from a terraform state file.')
parser.add_argument('--list', action="store_true", help='list')
parser.add_argument('--host host', dest='host', action="store", help='list')

args = parser.parse_args()
if args.list:
    list()
elif not args.host is None:
    host(args.host)

#

#
#
#
#
#
#
#
# with open('terraform.tfstate') as f:
#     data = json.load(f)
#
# resources = data['modules'][0]['resources']
#
# inventory = {}
#
# for resource_key, resource_properties in resources.items():
#     if resource_properties['type'] == 'vsphere_virtual_machine' and resource_key.startswith(
#             'vsphere_virtual_machine.'):
#         group = resource_key.split(".")[1]
#         if not group in inventory:
#             inventory[group] = {'hosts': []}
#         name = resource_properties['primary']['attributes']['name']
#         ip_address = resource_properties['primary']['attributes']['default_ip_address']
#
#         inventory[group][name] = {'ip': ip_address}
#
# print(json.dumps(inventory, indent=4, sort_keys=True))
