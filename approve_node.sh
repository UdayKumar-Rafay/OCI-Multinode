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


edge_id=$(cat "vyshak-mks-scale-1234-test${cluster_index}_edgeid.txt")
url="$api_url$edge_id/"
echo "$url"
#Approve Nodes
response=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$url" | jq '.')
noofnodes=$(echo "$response" | jq -r '.nodes | length')
echo "no_of_nodes: $noofnodes"
response=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$url" | jq '.')
nodeids=$(echo "$response" | jq -r '.nodes[*].id')
echo $nodeids
for node_id in $nodeids; do
  echo $nodeid
  approve_uri="$api_url$edge_id/nodes/$nodeid/approve/"
  echo $approve_uri
  # PUT request
  put_response=$(curl -s -X PUT -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "{}" "$approve_uri")
  echo "put_response: $put_response"
  timeout=300  # Timeout in seconds (adjust as needed)
  start_time=$(date +%s)
  while true; do
    # Check the provision status
    approve_status=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$url" | jq '.')
    
    echo $nodeid:$approve_status

    if [ "$approve_status" == "Approved" ]; then
        echo "Node is Approved"
        break
    fi

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ "$elapsed_time" -ge "$timeout" ]; then
        echo "Timeout reached. Exiting the loop."
        break
    fi

    echo "Waiting for Node to be Approved. Elapsed time: $elapsed_time seconds."
    sleep 10
  done
done
