import json
import ruamel.yaml
import random

# Path to the collected configurations file
collected_configs_file = '/tmp/collected_node_configs.json'

# Path to the YAML file
cluster_config_file = "/Users/manish/Desktop/rctl/mks-scale-1.yaml"

# Load collected configurations
with open(collected_configs_file, 'r') as f:
    collected_configs = json.load(f)

# Load YAML file
yaml = ruamel.yaml.YAML()
with open(cluster_config_file, 'r') as file:
    config = yaml.load(file)



# Check if 'nodes' exists in 'spec' > 'config', if not, initialize it
if 'spec' not in config:
    config['spec'] = {}
if 'config' not in config['spec']:
    config['spec']['config'] = {}
if 'nodes' not in config['spec']['config']:
    config['spec']['config']['nodes'] = []


#Clear the list of nodes
# config['spec']['config']['nodes'] = []

# Check for existing nodes to avoid duplicates
existing_nodes = [node['privateip'] for node in config['spec']['config']['nodes']]

random_number = random.randint(1, 99)

for node in collected_configs:
    if node['privateip'] not in existing_nodes:  # Avoid duplicate entries
        new_node = {
            'arch': 'amd64',
            'hostname': node['hostname'],
            'kubeletExtraArgs' : {
                'max-pods': '100',
                'cpu-manager-reconcile-period' : '10s'
            },
            'labels': {
                'testType': 'scale-testing',
            },
            'operatingSystem': 'Ubuntu20.04',
            'privateip': node['privateip'],
            'ssh': {
                'ipAddress': node['publicip'],
                'port': '22',
                'privateKeyPath': node['privatekeypath'],
                'username': 'ubuntu'
            },
            'roles': ['Worker']
        }

        if node['index'] in [3, 4, 5]:
            new_node['roles'] = ['Worker', 'Storage']

        if node['index'] == 0:
            # If index is 0, set the roles for the first node as "Master" and "Worker"
            config['metadata']['name'] = f'scale-mks-{random_number}'
            config['metadata']['project'] = 'scale'
            config['spec']['type'] = 'mks'
            config['spec']['blueprint']['name'] = 'default'
            config['spec']['blueprint']['version'] = 'latest'
            config['spec']['config']['autoApproveNodes'] = True
            config['spec']['config']['dedicatedMastersEnabled'] = False
            config['spec']['config']['highAvailability'] = True
            config['spec']['config']['kubernetesVersion'] = 'v1.30.4'
            config['spec']['config']['network']['cni']['name'] = 'Calico'
            config['spec']['config']['operating_system'] = 'Ubuntu20.04'
            
            # new_node['roles'] = ['Master', 'Worker']
        
        # Append new node to the list
        config['spec']['config']['nodes'].append(new_node)

# Add system_components_placement once, after processing all nodes
system_components_placement = {
    'node_selector': {
        'app': 'infra'
    },
    'tolerations': [
        {
            'effect': 'NoSchedule',
            'key': 'app',
            'operator': 'Equal',
            'value': 'infra'
        }
    ]
}

if 'system_components_placement' not in config['spec']['config']:
    config['spec']['config']['systemComponentsPlacement'] = system_components_placement

# Write the updated YAML back to the file
with open(cluster_config_file, 'w') as file:
    yaml.dump(config, file)

print(f"Updated {cluster_config_file} with new nodes.")