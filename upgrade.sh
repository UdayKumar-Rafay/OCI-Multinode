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
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

payload='{
  "version_name": "v1.29.0",
  "kubernetes_upgrade": {
    "strategy":"concurrent",
    "params":
    {
      "workerConcurrency":"20"
    }
  }
}'

for ((i=1; i<=$num_clusters; i++)); do
  edge_id=$(cat "vyshak-mks-scale-1234-test${i}_edgeid.txt")
  url="$api_url$edge_id/kubeupgrade/"
  echo "$url"

  response=$(curl -s -X POST -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "$payload" "$url")
  echo "curl -X POST -H \"Content-Type: application/json\" -H \"X-RAFAY-API-KEYID: $api_key\" -d '$payload' '$url'"
  echo $response
  # POST request
  response=$(curl -s -X POST -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" -d "$payload" "$url" | jq '.')
  if [[ $(echo "$response" | jq -r '.error') != "null" ]]; then
    echo "Error in API response: $(echo "$response" | jq -r '.error')"
  fi

done
