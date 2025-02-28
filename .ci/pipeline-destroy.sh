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
  echo "Example: .ci/pipeline-destroy.sh .ci/user-inputs.sh"
  exit 1
fi

WORKING_DIRECTORY="$(pwd)"

echo "=================================================="
echo "==> Azure Authentication"
echo "=================================================="

# az logout || ( true && echo "Already logged out..." && echo)
# az account clear || ( true && echo "Already logged out..." && echo)

# Logging in as a human user due to restrictions on my azure account.
# In Prod environments, a Service Principal should be used instead
# az login # Uncomment to login

## PROPER WAY OF LOGGING IN
# az login --service-principal -u $ROBOT_SP_CLIENT_ID -p $ROBOT_SP_CLIENT_SECRET --tenant $TENANT

# echo "#########################################################################################################"
# TF_MODULE="acmhub-registration"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="../tfvars/computed/${TF_VAR_organization}/${TF_VAR_subscription_id}/${TF_VAR_cluster_name}.tfvars"
# echo "=================================================="
# echo "===========> Module - $TF_MODULE "
# echo "=================================================="
# cd "${TF_MODULE}"
# rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
# unset TF_WORKSPACE
# terraform init \
#   -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
#   -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
#   -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
#   -backend-config="key=${BACKEND_KEY}"
# terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# terraform apply "$TF_MODULE.plan"
# cd ${WORKING_DIRECTORY}

# echo "#########################################################################################################"
# TF_MODULE="dns-tls-certs"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="../tfvars/computed/${TF_VAR_organization}/${TF_VAR_subscription_id}/${TF_VAR_cluster_name}.tfvars"
# echo "=================================================="
# echo "===========> Module - $TF_MODULE "
# echo "=================================================="
# cd "${TF_MODULE}"
# rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
# unset TF_WORKSPACE
# terraform init \
#   -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
#   -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
#   -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
#   -backend-config="key=${BACKEND_KEY}"
# terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# terraform apply "$TF_MODULE.plan"
# cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="aro-classic"
BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="../tfvars/computed/${TF_VAR_organization}/${TF_VAR_subscription_id}/${TF_VAR_cluster_name}.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="
cd "${TF_MODULE}"
rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
unset TF_WORKSPACE
terraform init \
  -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
  -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
  -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
  -backend-config="key=${BACKEND_KEY}"
terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan" | tee "${TF_VAR_cluster_name}-logs.out"
terraform output -json | tee "${TF_VAR_cluster_name}-output.out"
cd ${WORKING_DIRECTORY}

# echo "#########################################################################################################"
# TF_MODULE="aro-infra"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="../tfvars/admin/admin.tfvars"
# echo "=================================================="
# echo "==> Module - $TF_MODULE"
# echo "=================================================="
# cd "${TF_MODULE}"
# rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
# unset TF_WORKSPACE
# terraform init \
#   -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
#   -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
#   -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
#   -backend-config="key=${BACKEND_KEY}"
# terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# terraform apply "$TF_MODULE.plan"
# cd ${WORKING_DIRECTORY}

# echo "#########################################################################################################"
# TF_MODULE="key-vault"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="../tfvars/admin/admin.tfvars"
# echo "=================================================="
# echo "==> Module - $TF_MODULE"
# echo "=================================================="
# cd "${TF_MODULE}"
# rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true)
# unset TF_WORKSPACE
# terraform init \
#   -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group}" \
#   -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
#   -backend-config="container_name=${TF_VAR_tfstate_storage_container}" \
#   -backend-config="key=${BACKEND_KEY}"
# terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# terraform apply "$TF_MODULE.plan"
# cd ${WORKING_DIRECTORY}


# echo "#########################################################################################################"
# TF_MODULE="tfstate-config"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="../tfvars/admin/admin.tfvars"
# echo "=================================================="
# echo "==> Module - $TF_MODULE"
# echo "=================================================="
# STORAGE_ACCOUNT_NAME_AVAILABLE=$(az storage account check-name --name "${TF_VAR_tfstate_storage_account_name}" --subscription "${TF_VAR_subscription_id}" --query 'nameAvailable')
# if [ "$STORAGE_ACCOUNT_NAME_AVAILABLE" = "true" ];
# then
#   echo "===> TFState storage account does not exists. Creating..."
#   cd "${TF_MODULE}"
#   rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
#   unset TF_WORKSPACE
#   terraform init
#   terraform plan -destroy -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
#   terraform apply "$TF_MODULE.plan"
#   cd ${WORKING_DIRECTORY}
# else
#   echo "===> TFState storage account exists. Skipping..."
# fi