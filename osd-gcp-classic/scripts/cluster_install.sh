#!/bin/bash

set -x

# Check for OCM installation
ocm > /dev/null 2>&1 || echo "Please ensure ocm is installed"
# Check for jq
jq > /dev/null 2>&1 || echo "Please ensure jq is installed"

# Check for OCM connectivity
ocm logout
ocm login --token="${ocm_token}"

ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '${cluster_name}%'" | jq -re '.items[].name' && (echo 'Cluster seems to exist... please clean it up first or select a new name.'; exit 1; )

# Check the ocm user logged in
ocm whoami

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
  sleep 600

  echo "Creating Workload Identity Federation cluster..."
  ocm create cluster "${cluster_name}" \
    --provider=gcp \
    --debug \
    --vpc-name="${vpc}" \
    --region="${region}" \
    --control-plane-subnet="${master_subnet_name}" \
    --compute-subnet="${worker_subnet_name}" \
    --wif-config="${gcp_wif_config_name}" \
    --ccs \
    --marketplace-gcp-terms=true \
    --compute-machine-type="${worker_machine_type}" \
    --domain-prefix="${domain_prefix}" \
    --enable-autoscaling=${enable_autoscaling} \
    --max-replicas=${autoscaling_max_replicas} \
    --min-replicas=${worker_node_count} \
    --flavour="osd-4" \
    --version="${version}" \
    --machine-cidr="${vpc_cidr}" \
    --pod-cidr="${pod_cidr}" \
    --service-cidr="${service_cidr}" \
    --private=${private_cluster} \
    --http-proxy="${htt_proxy}" \
    --https-proxy="${htts_proxy}" \
    --no-proxy="${no_proxy}"

  if [ "$?" != "0" ];
  then
    echo "Cluster installation failed."
    exit 1
  fi

  echo "Waiting for cluster creation to complete..."
  sleep 3000

  echo "Enable delete protection..."
  CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '${cluster_name}%'" | jq -re '.items[].id')
  ocm edit cluster $CLUSTER_ID --enable-delete-protection
else
  # Get private key ID
  export PRIV_KEY_ID=$(cat ${gcp_sa_keyfile} | jq -r '.private_key_id')
  # Check if the GCP SA is valid
  curl -s $(cat ${gcp_sa_keyfile} | jq -r '.client_x509_cert_url') | jq -re --arg PRIV_KEY_ID "$PRIV_KEY_ID" '.[$PRIV_KEY_ID]' || echo 'Your service account specified at ${gcp_sa_keyfile} seems to be invalid or expired. Please check and try again'
  
  ocm create cluster "${cluster_name}" \
    --provider=gcp \
    --debug \
    --vpc-name="${vpc}" \
    --vpc-project-id="${cluster_project}" \
    --region="${region}" \
    --control-plane-subnet="${master_subnet_name}" \
    --compute-subnet="${worker_subnet_name}" \
    --service-account-file="${gcp_sa_keyfile}" \
    --ccs \
    --marketplace-gcp-terms=true \
    --compute-machine-type="${worker_machine_type}" \
    --domain-prefix="${domain_prefix}" \
    --enable-autoscaling=${enable_autoscaling} \
    --max-replicas=${autoscaling_max_replicas} \
    --min-replicas=${worker_node_count} \
    --flavour="osd-4" \
    --version="${version}" \
    --machine-cidr="${vpc_cidr}" \
    --pod-cidr="${pod_cidr}" \
    --service-cidr="${service_cidr}" \
    --private=${private_cluster} \
    --http-proxy="${htt_proxy}" \
    --https-proxy="${htts_proxy}" \
    --no-proxy="${no_proxy}"

  if [ "$?" != "0" ];
  then
    echo "Cluster installation failed."
    exit 1
  fi

  echo "Waiting for cluster creation to complete..."
  sleep 3000

  echo "Enable delete protection..."
  CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '${cluster_name}%'" | jq -re '.items[].id')
  ocm edit cluster $CLUSTER_ID --enable-delete-protection
fi 
  # --compute-nodes=${worker_node_count} \
  # \
  
