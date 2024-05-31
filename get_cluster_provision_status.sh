#!/bin/bash
set -e

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
timeout=18000  # Timeout in seconds (adjust as needed)
start_time=$(date +%s)
while true; do
    # Check the provision status
    provision_status=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$url" | jq -r '.health')
    echo $edge_id:$provision_status

    if [ "$provision_status" == 1 ]; then
        echo "Cluster is READY."
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
