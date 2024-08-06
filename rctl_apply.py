import argparse
import json
import os

# Parse input arguments
parser = argparse.ArgumentParser(description='Collect node configuration.')
parser.add_argument('hostname', type=str, help='Hostname of the node')
parser.add_argument('privateip', type=str, help='Private IP address of the node')
parser.add_argument('publicip', type=str, help='Public IP address of the node')
parser.add_argument('privatekeypath', type=str, help='Path to the private key')
parser.add_argument('index', type=int, help='Node index')

args = parser.parse_args()

# Define node configuration
node_config = {
    'hostname': args.hostname,
    'privateip': args.privateip,
    'publicip': args.publicip,
    'privatekeypath': args.privatekeypath,
    'index': args.index
}

# Path to the collected configurations file
collected_configs_file = '/tmp/collected_node_configs.json'

# Load existing configurations if the file exists
if os.path.exists(collected_configs_file):
    with open(collected_configs_file, 'r') as f:
        collected_configs = json.load(f)
else:
    collected_configs = []

# Append new configuration
collected_configs.append(node_config)

# Save updated configurations
with open(collected_configs_file, 'w') as f:
    json.dump(collected_configs, f, indent=2)
