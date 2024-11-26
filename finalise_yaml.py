import json
import ruamel.yaml

# Path to the collected configurations file
collected_configs_file = '/tmp/collected_node_configs.json'
cluster_config_file = "/Users/uday/mks-scale/uday-nodes.yaml"

# Load collected configurations
with open(collected_configs_file, 'r') as f:
    collected_configs = json.load(f)

# Initialize YAML handler
yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=4, offset=2)

# Load or create config
try:
    with open(cluster_config_file, 'r') as file:
        config = yaml.load(file) or {'nodes': []}
except FileNotFoundError:
    config = {'nodes': []}

# Get existing nodes to avoid duplicates
existing_nodes = [node['privateip'] for node in config['nodes']]

# Add new nodes
for node in collected_configs:
    if node['privateip'] not in existing_nodes:
        new_node = {
            'arch': 'amd64',
            'hostname': node['hostname'],
            'operatingSystem': 'Ubuntu20.04',
            'privateip': node['privateip'],
            'ssh': {
                'ipAddress': node['publicip'],
                'port': '22',
                'username': 'ubuntu'
            }
        }
        config['nodes'].append(new_node)

# Write back to file
with open(cluster_config_file, 'w') as file:
    yaml.dump(config, file)

print(f"Updated {cluster_config_file} with new nodes.")