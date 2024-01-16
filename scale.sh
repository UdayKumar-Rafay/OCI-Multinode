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
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

echo $api_url
echo $api_key
echo $num_clusters

for ((i=1; i<=$num_clusters; i++)); do
  cluster_name="vyshak-mks-scale-1234-test${i}"  
  payload='{
    "name": "'"$cluster_name"'",
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
    "provision_k8s": "v1.28.1",
    "storage_class_map": {
      "HostPath": "/var/openebs/local/"
    }
  }'

  # POST request
  response=$(curl -s -X POST -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "$payload" "$api_url" | jq '.')
  if [[ $(echo "$response" | jq -r '.error') != "null" ]]; then
    echo "Error in API response: $(echo "$response" | jq -r '.error')"
  fi
  
  # Extracting an saving the edge_id
  edge_id=$(echo "$response" | jq -r '.edge_id' | awk -F'.' '{print $1}')
  echo "edge_id: $edge_id"
  echo $edge_id > "vyshak-mks-scale-1234-test${i}_edgeid.txt"
  sleep 10

  cert=$(echo "$response" | jq -r '.cert')
  echo "Certificate for Cluster $i: $cert"
  cat << EOF > "vyshak-mks-scale-1234-test${i}_cert.pem"
$cert
EOF
  #cat "$vyshak-mks-scale-123-test${i}_cert.pem"

  sleep 5
  # Extracting and saving the passphrase for the cluster
  passphrase=$(echo "$response" | jq -r '.passphrase')
  echo "passphrase: $passphrase"
  echo $passphrase > "vyshak-mks-scale-1234-test${i}_passphrase.txt"

  # Extracting and saving the Cluster Name into a file
  name=$(echo "$response" | jq -r '.name')
  echo "ClusterName: "vyshak-mks-scale-1234-test${i}_clustername.txt""
  echo "vyshak-mks-scale-1234-test${i}" > "vyshak-mks-scale-1234-test${i}_clustername.txt"

  cluster_url="$api_url$edge_id/"
  put_response=$(curl -s -X PUT -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "$response" "$cluster_url")

  # Print the PUT response
  #echo -e "\nPUT Response for Cluster $i:\n$put_response"

done

echo "Test Role Completion: Completed for $num_clusters clusters"
