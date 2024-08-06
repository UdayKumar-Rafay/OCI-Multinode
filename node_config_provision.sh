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
    -num_clusters=*)
      num_clusters="${1#*=}"
      shift
      ;;
    -master_nodes=*)
      masters="${1#*=}"
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

for ((i=1; i<=$num_clusters; i++)); do
  edge_id=$(cat "$cluster_name${i}_edgeid.txt")
  url="$api_url$edge_id/"
  echo "$url"

  for ((i=0; i<$masters; i++)); do
    # GET request
    response=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$url" | jq '.')
    response=$(echo "$response" | jq '.nodes['$i'].roles += ["Master"]')
    echo "response: $response"

    # PUT request
    put_response=$(curl -s -X PUT -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "$response" "$url")
    echo "put_response: $put_response"
  done

  # PROVISION Request
  api_url2="$api_url$edge_id/provision-v2/"
  put_response2=$(curl -s -X PUT -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$api_url2")

  source /Users/puvvada/mks-scale/get_cluster_provision_status.sh  -api_url=$api_url  -api_key=$api_key -cluster_index=$i
done

