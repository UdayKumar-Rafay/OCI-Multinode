#!/bin/bash
set -x

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -api_url=*)
      api_url="${1#*=}"
      shift
      ;;
    -api_key=*)
      api_key="${1#*=}"
      shift
      ;;
    -num_clusters=*)
      num_clusters="${1#*=}"
      shift
      ;;
    -cluster_name=*)
      cluster_name="${1#*=}"
      shift
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

echo "API URL: $api_url"
echo "API Key: $api_key"
echo "Number of Clusters: $num_clusters"
echo "Cluster Name Prefix: $cluster_name"

for ((i=1; i<=$num_clusters; i++)); do
  full_cluster_name="${cluster_name}${i}"  
  payload='{
    "name": "'"$full_cluster_name"'",
    "description": "QE",
    "provision_params": {
      "provisionType": "CREATE",
      "provisionEnvironment": "ONPREM",
      "provisionPackageType": "LINUX",
      "environmentProvider": "",
      "kubernetesProvider": "MKS",
      "state": "CONFIG"
    },
    "cluster_type": "manual",
    "provision_os": "Ubuntu20.04",
    "cluster_blueprint": "default",
    "auto_approve_nodes": true,
    "provision_k8s": "v1.28.9",
    "storage_class_map": {
      "HostPath": "/var/openebs/local/"
    }
  }'

  # POST request
  response=$(curl -s -X POST -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "$payload" "$api_url")
  if [[ $(echo "$response" | jq -r '.error') != "null" ]]; then
    echo "Error in API response: $(echo "$response" | jq -r '.error')"
    exit 1
  fi
  
  # Extracting and saving the edge_id
  edge_id=$(echo "$response" | jq -r '.edge_id' | awk -F'.' '{print $1}')
  echo "edge_id: $edge_id"
  echo $edge_id > "${full_cluster_name}_edgeid.txt"
  sleep 10

  # Extracting and saving the cert
  cert=$(echo "$response" | jq -r '.cert')
  echo "Certificate for Cluster $i: $cert"
  cat << EOF > "${full_cluster_name}_cert.pem"
$cert
EOF

  sleep 5
  # Extracting and saving the passphrase for the cluster
  passphrase=$(echo "$response" | jq -r '.passphrase')
  echo "passphrase: $passphrase"
  echo $passphrase > "${full_cluster_name}_passphrase.txt"

  # Extracting and saving the Cluster Name into a file
  echo "ClusterName: ${full_cluster_name}_clustername.txt"
  echo "$full_cluster_name" > "${full_cluster_name}_clustername.txt"

  # PUT request
  cluster_url="${api_url}${edge_id}/"
  put_response=$(curl -s -X PUT -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "$response" "$cluster_url")

done

echo "Test Role Completion: Completed for $num_clusters clusters"
