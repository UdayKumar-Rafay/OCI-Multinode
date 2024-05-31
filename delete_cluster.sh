#!/bin/bash

# api_key="ra2.4c3acc0fdb3618a70175e17b6d52d093eed86676.9496b771dad9fa49b0baf4c833237883e5aaf04c8b38e4ad5b5dfb01f9ea35b3"

api_key="ra2.2069a1734adf37ad31a9690a280aefd72747a660.458c0b4656fdee7e7249c9afe006a788786b06e1570fe3718ccb787d21a572fc"


api_url="https://console-venkat-tb-k8s130.dev.rafay-edge.net/edge/v1/projects/rx28oml/edges/?organization_id=&partner_id=&limit=200&offset=0&q=&sort_order=desc&sort_by=created_at&l="
echo "$api_url"

# Declare an array to store item details
declare -a items


# Make the GET request to get the count
count=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$api_url" | jq '.count')
echo $count


for ((i=0; i<$count; i++)); do
  # Make the GET request to get the details for each item
  edge_id=$(curl -s -X GET -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$api_url" | jq -r --argjson i "$i" '.results[$i].id')
  echo "response: $edge_id"
  api_url1="https://console-venkat-tb-k8s130.dev.rafay-edge.net/edge/v1/projects/rx28oml/edges/$edge_id/?force=true"
  items+=("$api_url1")
done


# Print the array elements
for item in "${items[@]}"; do
  echo "$item"
  # Make the DELETE request
  response=$(curl -s -X DELETE -H "Content-Type: application/json" -H "X-RAFAY-API-KEYID: $api_key" "$item" | jq '.')
  echo "response: $response"
done