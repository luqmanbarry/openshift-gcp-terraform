#!/bin/bash

set -x

# Check for OCM installation
ocm > /dev/null 2>&1 || echo "Please verify ocm is installed"
# Check for jq
jq > /dev/null 2>&1 || echo "Please verify jq is installed"

# Check for OCM connectivity
ocm login --token="${ocm_token}"
ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '${cluster_name}%'" | jq -r '.items[].name' || ( echo 'Cluster not found. Verify your inputs' && exit 1)

# Disable delete protection
CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters --parameter search=\"name like '$cluster_name%'\" | jq -r '.items[].id')
ocm patch /api/clusters_mgmt/v1/clusters/$CLUSTER_ID < '{"delete_protection": {"enabled": false}}'

sleep 30

# Delete the cluster
ocm delete cluster $CLUSTER_ID

if [ "$?" == "0" ];
then
  sleep 1200
  ocm gcp delete wif-config "${gcp_wif_config_name}" || true
fi