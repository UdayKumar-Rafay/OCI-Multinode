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
    -node_id=*)
      node_id="${1#*=}"
      shift
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

timeout=600  # Timeout in seconds (adjust as needed)
start_time=$(date +%s)

edge_id=$(cat "vyshak-mks-scale-1234-test${cluster_index}_edgeid.txt")
# PROVISION Request
api_url="$api_url$edge_id/"
api_url1="$api_url""nodes/$node_id/provision/"
echo $api_url1
put_response2=$(curl -s -X PUT -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$api_url1")
echo $put_response2

while true; do
    # Check the provision status
    response=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$api_url" | jq '.')
    status=$(echo "$response" | jq -r ".nodes[] | select(.id == \"$node_id\") | .status")
    echo $node_id:$status

    if [ "$status" == "READY" ]; then
        echo "Node Provisioned Succesfully"
        break
    fi

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ "$elapsed_time" -ge "$timeout" ]; then
        echo "Timeout reached. Exiting the loop."
        break
    fi

    echo "Waiting for provision_status to be READY. Elapsed time: $elapsed_time seconds."
    sleep 10
done