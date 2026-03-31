#!/bin/bash

set -euo pipefail
set -x

find_cluster_id() {
  ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '${cluster_name}%'" \
    | jq -re --arg NAME "${cluster_name}" '.items[] | select(.name == $NAME) | .id' \
    | head -n1
}

wait_for_cluster_absent() {
  local attempts=80
  local sleep_seconds=30

  for _ in $(seq 1 "${attempts}"); do
    if ! find_cluster_id > /dev/null 2>&1; then
      return 0
    fi
    sleep "${sleep_seconds}"
  done

  echo "Timed out waiting for cluster '${cluster_name}' to be deleted" >&2
  return 1
}

# Check for OCM installation
ocm > /dev/null 2>&1 || { echo "Please verify ocm is installed"; exit 1; }
# Check for jq
jq > /dev/null 2>&1 || { echo "Please verify jq is installed"; exit 1; }

# Check for OCM connectivity
ocm login --token="${ocm_token}"
find_cluster_id > /dev/null 2>&1 || { echo 'Cluster not found. Verify your inputs'; exit 1; }

# Disable delete protection
CLUSTER_ID="$(find_cluster_id)"
ocm patch "/api/clusters_mgmt/v1/clusters/${CLUSTER_ID}" < '{"delete_protection": {"enabled": false}}'

sleep 30

# Delete the cluster
ocm delete cluster "${CLUSTER_ID}"

if [ "${enable_gcp_wif_authentication:-false}" == "true" ];
then
  wait_for_cluster_absent
  ocm gcp delete wif-config "${gcp_wif_config_name}" || true
fi
