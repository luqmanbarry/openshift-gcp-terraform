#!/bin/bash

set -e

echo "#########################################################################################################"
echo "=================================================="
echo "==> Set Environment Variables"
echo "=================================================="
INPUTS="$1"

if [ -f $INPUTS ]; then
  . $INPUTS
else
  echo "Could not find the file. Check and try again..."
  echo "Example: .ci/pipeline-create.sh .ci/user-inputs.sh"
  exit 1
fi

WORKING_DIRECTORY="$(pwd)"
# export KUBECONFIG="${WORKING_DIRECTORY}/.kube"

echo "=================================================="
echo "==> GCP Authentication"
echo "=================================================="

# gcloud auth revoke --all || ( true && echo "Already logged out..." && echo)
# rm -rf ~/.config/gcloud || ( true && echo "Already logged out..." && echo)

# Logging in as a human user due to restrictions on my azure account.
## In Prod environments, a Service Account or  Workload Identity Federation authentication should be used instead
# gcloud auth login # Uncomment to login

## Sign-in as service account
# gcloud auth activate-service-account --key-file=<path-to-service-account-key.json>
# gcloud auth list
# gcloud config set project <your-project-id>

echo "#########################################################################################################"
TF_MODULE="osd-gcp-classic"
BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/computed/${TF_VAR_department}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_storage_bucket_name}" \
  -backend-config="prefix=${BACKEND_KEY}"
terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="gcp-infra"
BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/admin/admin.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="bucket=${TF_VAR_tfstate_storage_bucket_name}" \
  -backend-config="prefix=${BACKEND_KEY}"
terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}


# echo "#########################################################################################################"
# TF_MODULE="kube-config"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/computed/${TF_VAR_organization}/${TF_VAR_subscription_id}/${TF_VAR_cluster_name}.tfvars"
# echo "=================================================="
# echo "===========> Module - $TF_MODULE "
# echo "=================================================="
# cd "${TF_MODULE}"
# rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
# unset TF_WORKSPACE
# terraform init \
#   -backend-config="environment=${TF_VAR_azure_cloud_environment}" \
#   -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
#   -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
#   -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
#   -backend-config="key=${BACKEND_KEY}"
# terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# terraform apply "$TF_MODULE.plan"
# cd ${WORKING_DIRECTORY}


# # if [ "$TF_VAR_use_azure_provided_domain" = "false" ];
# # then
# #   echo "#########################################################################################################"
# #   TF_MODULE="dns-tls-certs"
# #   BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# #   BACKEND_PATH="${TF_MODULE}"
# #   TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/computed/${TF_VAR_organization}/${TF_VAR_subscription_id}/${TF_VAR_cluster_name}.tfvars"
# #   echo "=================================================="
# #   echo "===========> Module - $TF_MODULE "
# #   echo "=================================================="
# #   cd "${TF_MODULE}"
# #   rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
# #   unset TF_WORKSPACE
# #   terraform init \
# #     -backend-config="environment=${TF_VAR_azure_cloud_environment}" \
# #     -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
# #     -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
# #     -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
# #     -backend-config="key=${BACKEND_KEY}"
# #   terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# #   terraform apply "$TF_MODULE.plan"
# #   cd ${WORKING_DIRECTORY}
# # fi

# echo "#########################################################################################################"
# TF_MODULE="bootstrap"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/computed/${TF_VAR_organization}/${TF_VAR_subscription_id}/${TF_VAR_cluster_name}.tfvars"
# echo "=================================================="
# echo "===========> Module - $TF_MODULE "
# echo "=================================================="
# cd "gitops/${TF_MODULE}"
# rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
# unset TF_WORKSPACE
# terraform init \
#   -backend-config="environment=${TF_VAR_azure_cloud_environment}" \
#   -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
#   -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
#   -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
#   -backend-config="key=${BACKEND_KEY}"
# terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# terraform apply "$TF_MODULE.plan"
# cd ${WORKING_DIRECTORY}

# # if [ "$TF_VAR_acmhub_registration_enabled" = "true" ]; 
# # then
# #   echo "#########################################################################################################"
# #   TF_MODULE="acmhub-registration"
# #   BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# #   BACKEND_PATH="${TF_MODULE}"
# #   TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/computed/${TF_VAR_organization}/${TF_VAR_subscription_id}/${TF_VAR_cluster_name}.tfvars"
# #   echo "=================================================="
# #   echo "===========> Module - $TF_MODULE "
# #   echo "=================================================="
# #   cd "${TF_MODULE}"
# #   rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
# #   unset TF_WORKSPACE
# #   terraform init \
# #     -backend-config="environment=${TF_VAR_azure_cloud_environment}" \
# #     -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
# #     -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
# #     -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
# #     -backend-config="key=${BACKEND_KEY}"
# #   terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# #   terraform apply "$TF_MODULE.plan"
# # cd ${WORKING_DIRECTORY}
# # fi