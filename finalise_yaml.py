import json
import ruamel.yaml

# Path to the collected configurations file
collected_configs_file = '/tmp/collected_node_configs.json'

# Path to the YAML file
cluster_config_file = "/Users/puvvada/Downloads/vasu-test-mks-salt-async-dec14-config.yaml"

# Load collected configurations
with open(collected_configs_file, 'r') as f:
    collected_configs = json.load(f)

# Load YAML file
yaml = ruamel.yaml.YAML()
with open(cluster_config_file, 'r') as file:
    config = yaml.load(file)

# Clear the list of nodes
config['spec']['config']['nodes'] = []

# Update YAML file with collected node configurations
for node in collected_configs:
    new_node = {
        'arch': 'amd64',
        'hostname': node['hostname'],
        'labels': {},
        'operatingSystem': 'Ubuntu22.04',
        'privateip': node['privateip'],
        'ssh': {
            'ipAddress': node['publicip'],
            'port': '22',
            'privateKeyPath': node['privatekeypath'],
            'username': 'ubuntu'
        },
        'roles': ['Worker']
    }

    if node['index'] == 0:
        # If index is 0, set the roles for the first node as "Master" and "Worker"
        config['metadata']['name'] = 'mks-cluster-1'
        config['metadata']['project'] = 'venkat'
        config['spec']['blueprint']['name'] = 'default'
        config['spec']['config']['kubernetesVersion'] = 'v1.28.5'
        config['spec']['config']['network']['cni']['name'] = 'Calico'
        config['spec']['config']['operating_system'] = 'Ubuntu22.04'
        new_node['roles'] = ['Master', 'Worker']
    
    config['spec']['config']['nodes'].append(new_node)

# Write the updated YAML back to the file
with open(cluster_config_file, 'w') as file:
    yaml.dump(config, file)
