#!/bin/bash

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
    -cluster_index=*)
      cluster_index="${1#*=}"
      shift
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

edge_id=$(< "vyshak-mks-scale-1234-test${cluster_index}_edgeid.txt")
url="$api_url$edge_id/"
echo "$url"
response=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$url" | jq '.')
nodeids=$(echo "$response" | jq  -r '.nodes[] | select(.status != "READY") | .id')

# Run provision_node.sh in parallel using xargs
printf '%s\n' "$nodeids" | xargs -P 0 -I {} ./provision_node.sh -api_url="$api_url" -api_key="$api_key" -cluster_index="$cluster_index" -node_id={} &

# Wait for all background processes to finish
wait
echo "All provisioning processes have finished."
