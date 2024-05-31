#!/bin/bash
#set -x

# Define input arguments
hostname=$1
privateip=$2
publicip=$3
privatekeypath=$4
num_nodes=$5

# Path to the YAML file
cluster_config_file="/Users/puvvada/Downloads/vasu-test-mks-salt-async-dec14-config.yaml"

# Update YAML file with provided arguments
yq eval ".spec.config.nodes.[$num_nodes].arch = \"amd64\"" -i "$cluster_config_file"
yq eval ".spec.config.nodes.[$num_nodes].hostname = \"$hostname\"" -i "$cluster_config_file"
yq eval ".spec.config.nodes.[$num_nodes].labels = {}" -i "$cluster_config_file"
yq eval ".spec.config.nodes.[$num_nodes].operatingSystem = \"Ubuntu22.04\"" -i "$cluster_config_file"
yq eval ".spec.config.nodes.[$num_nodes].privateip = \"$privateip\"" -i "$cluster_config_file"

if [ "$num_nodes" -eq 0 ]; then
    # If num_nodes is 0, set the roles for the first node as "Master" and subsequent nodes as "Worker"
    yq eval ".metadata.name = \"mks-cluster-1\"" -i "$cluster_config_file"
    yq eval ".metadata.project = \"venkat\"" -i "$cluster_config_file"
    yq eval ".spec.blueprint.name = \"default\"" -i "$cluster_config_file"
    yq eval ".spec.config.kubernetesVersion = \"v1.28.5\"" -i "$cluster_config_file"
    yq eval ".spec.config.network.cni.name = \"Calico\"" -i "$cluster_config_file"
    yq eval ".spec.config.operating_system = \"Ubuntu22.04\"" -i "$cluster_config_file"
    yq eval ".spec.config.nodes[$num_nodes].roles[0] = \"Master\"" -i "$cluster_config_file"
    yq eval ".spec.config.nodes[$num_nodes].roles[1] = \"Worker\"" -i "$cluster_config_file"
else
    yq eval ".spec.config.nodes[$num_nodes].roles[0] = \"Worker\"" -i "$cluster_config_file"

fi

yq eval ".spec.config.nodes.[$num_nodes].ssh.ipAddress = \"$publicip\"" -i "$cluster_config_file"
yq eval ".spec.config.nodes.[$num_nodes].ssh.port = \"22\"" -i "$cluster_config_file"
yq eval ".spec.config.nodes.[$num_nodes].ssh.privateKeyPath = \"$privatekeypath\"" -i "$cluster_config_file"
yq eval ".spec.config.nodes.[$num_nodes].ssh.username = \"ubuntu\"" -i "$cluster_config_file"