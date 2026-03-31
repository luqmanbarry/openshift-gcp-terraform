#!/bin/bash

set -euo pipefail
set -x

find_cluster_id() {
  ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '${cluster_name}%'" \
    | jq -re --arg NAME "${cluster_name}" '.items[] | select(.name == $NAME) | .id' \
    | head -n1
}

wait_for_cluster_id() {
  local attempts=60
  local sleep_seconds=30
  local cluster_id=""

  for _ in $(seq 1 "${attempts}"); do
    if cluster_id="$(find_cluster_id 2>/dev/null)"; then
      printf '%s\n' "${cluster_id}"
      return 0
    fi
    sleep "${sleep_seconds}"
  done

  echo "Timed out waiting for cluster '${cluster_name}' to appear in OCM" >&2
  return 1
}

# Check for OCM installation
ocm > /dev/null 2>&1 || echo "Please ensure ocm is installed"
# Check for jq
jq > /dev/null 2>&1 || echo "Please ensure jq is installed"

# Check for OCM connectivity
ocm logout
ocm login --token="${ocm_token}"

find_cluster_id > /dev/null 2>&1 && (echo 'Cluster seems to exist... please clean it up first or select a new name.'; exit 1; )

# Check the ocm user logged in
ocm whoami

proxy_args=()
if [ "${http_proxy:-}" != "" ]; then
  proxy_args+=(--http-proxy="${http_proxy}")
fi
if [ "${https_proxy:-}" != "" ]; then
  proxy_args+=(--https-proxy="${https_proxy}")
fi
if [ "${no_proxy:-}" != "" ]; then
  proxy_args+=(--no-proxy="${no_proxy}")
fi
if [ -n "${additional_trust_bundle:-}" ] && [ -f "${additional_trust_bundle}" ] && [ -s "${additional_trust_bundle}" ]; then
  proxy_args+=(--additional-trust-bundle-file="${additional_trust_bundle}")
fi

scaling_args=()
if [ "${enable_autoscaling}" == "true" ]; then
  scaling_args+=(--enable-autoscaling)
  scaling_args+=(--max-replicas="${autoscaling_max_replicas}")
  scaling_args+=(--min-replicas="${worker_node_count}")
else
  scaling_args+=(--compute-nodes="${worker_node_count}")
fi

network_args=(
  --provider=gcp
  --debug
  --vpc-name="${vpc}"
  --region="${region}"
  --control-plane-subnet="${master_subnet_name}"
  --compute-subnet="${worker_subnet_name}"
  --ccs
  --marketplace-gcp-terms=true
  --compute-machine-type="${worker_machine_type}"
  --domain-prefix="${domain_prefix}"
  --flavour="osd-4"
  --version="${version}"
  --machine-cidr="${vpc_cidr}"
  --pod-cidr="${pod_cidr}"
  --service-cidr="${service_cidr}"
  --private="${private_cluster}"
)

if [ -n "${vpc_project_id:-}" ]; then
  network_args+=(--vpc-project-id="${vpc_project_id}")
fi

if [ "${private_cluster}" == "true" ] && [ "${private_service_connect_enabled}" == "true" ]; then
  network_args+=(--psc-subnet="${psc_subnet_name}")
fi

# Create the cluster
if [ "$enable_gcp_wif_authentication" == "true" ];
then
  echo "Creating the Workload Identity Federation config..."

  ocm gcp delete wif-config "${gcp_wif_config_name}" || true

  sleep 30

  ocm gcp create wif-config \
    --name="${gcp_wif_config_name}" \
    --project="${cluster_project}" \
    --mode="auto" \
    --role-prefix="${wif_role_prefix}"
  
  echo "Waiting for WIF service accounts to sync across the GCP environment"
  sleep 60

  echo "Creating Workload Identity Federation cluster..."
  ocm create cluster "${cluster_name}" \
    "${network_args[@]}" \
    --wif-config="${gcp_wif_config_name}" \
    "${scaling_args[@]}" \
    "${proxy_args[@]}"

  echo "Enable delete protection..."
  CLUSTER_ID="$(wait_for_cluster_id)"
  ocm edit cluster "${CLUSTER_ID}" --enable-delete-protection
else
  # Get private key ID
  export PRIV_KEY_ID=$(cat ${gcp_sa_keyfile} | jq -r '.private_key_id')
  # Check if the GCP SA is valid
  curl -s $(cat ${gcp_sa_keyfile} | jq -r '.client_x509_cert_url') | jq -re --arg PRIV_KEY_ID "$PRIV_KEY_ID" '.[$PRIV_KEY_ID]' || echo 'Your service account specified at ${gcp_sa_keyfile} seems to be invalid or expired. Please check and try again'
  
  ocm create cluster "${cluster_name}" \
    "${network_args[@]}" \
    --service-account-file="${gcp_sa_keyfile}" \
    "${scaling_args[@]}" \
    "${proxy_args[@]}"

  echo "Enable delete protection..."
  CLUSTER_ID="$(wait_for_cluster_id)"
  ocm edit cluster "${CLUSTER_ID}" --enable-delete-protection
fi 
  # --compute-nodes=${worker_node_count} \
  # \
  
