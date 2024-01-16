#!/bin/bash

api_key="ra2.ca015fea0506e4a223916a56783b560267bbe31f.241093fb50bd59ba9e3adf499e169f52272f99db347839739cd43fe4b9e3e9a8"

for ((i=1; i<=100; i++)); do
  edge_id=$(cat "vyshak-mks-scale-1234-test${i}_edgeid.txt")
  api_url="https://console-vasu-tb.dev.rafay-edge.net/edge/v1/projects/4qkolkn/edges/$edge_id/?force=false"
  echo "$api_url"
  # Make the DELETE request
  response=$(curl -s -X DELETE -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$api_url" | jq '.')
  #echo "response: $response"

done
rm -rf vyshak-mks-scale-1234-test*
