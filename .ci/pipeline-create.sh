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
TF_MODULE="tfstate-config"
BACKEND_KEY="${TF_VAR_platform_environment}/${TF_VAR_cluster_name}/${TF_MODULE}.tfstate"
BACKEND_PATH="${TF_MODULE}"
TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/admin/admin.tfvars"
echo "=================================================="
echo "==> Module - $TF_MODULE"
echo "=================================================="

if gcloud storage buckets describe gs://${TF_VAR_tfstate_storage_bucket_name} > /dev/null 2>&1;
then
  echo "===> TFState storage bucket exists. Skipping..."
else
  echo "===> TFState storage account does not exists. Creating..."
  cd "${TF_MODULE}"
  rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
  unset TF_WORKSPACE
  terraform init
  ## ACTIVATE THIS IF IF YOU WANT TO CREATE A PROJECT FOR THE STATE FILES BUCKET
  # if gcloud projects describe ${TF_VAR_tfstate_project} > /dev/null 2>&1;
  # then
  #   echo "Project exists. Importing it into the state file..."
  #   PROJECT_ID=`gcloud projects list --filter="name:${TF_VAR_tfstate_project}" --format="value(projectId)"`
  #   terraform import "google_project.tfstate_project" "${PROJECT_ID}"
  # fi
  terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
  terraform apply "$TF_MODULE.plan"
  cd ${WORKING_DIRECTORY}
fi

# echo "#########################################################################################################"
# TF_MODULE="secrets-manager"
# BACKEND_KEY="${TF_VAR_platform_environment}/${TF_MODULE}.tfstate"
# BACKEND_PATH="${TF_MODULE}"
# TFVARS_FILE="${WORKING_DIRECTORY}/tfvars/admin/admin.tfvars"
# echo "=================================================="
# echo "==> Module - $TF_MODULE"
# echo "=================================================="
# cd "${TF_MODULE}"
# rm -rf .terraform || true && (rm -rf .terraform.lock.hcl || true) && (rm -rf terraform.tfstate.d || true) && (rm -rf *.tfstate || true) && (rm -rf *.tfstate.backup || true)
# unset TF_WORKSPACE
# terraform init \
#   -backend-config="bucket=${TF_VAR_tfstate_storage_bucket_name}" \
#   -backend-config="prefix=${BACKEND_KEY}"
# terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
# terraform apply "$TF_MODULE.plan"
# cd ${WORKING_DIRECTORY}

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
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
# if [ "$TF_VAR_use_azure_provided_domain" = "false" ];
# then
#   echo
#   echo "===> Cluster child DNS Zone provisonned successfully. Add the DNS Zone NS records to the domain resolver (registrar)."
#   echo "===> Use the nslookup command to verify the domain is resolvable: nslookup -type=NS mydoman.example.com"
#   read -p "===> Have you confirmed DNS resolution of the domain? Enter YES to continue, and any other character to quit: " USER_RES
#   if [ "$USER_RES" = "YES" ] || [ "$USER_RES" = "yes" ] || [ "$USER_RES" = "Yes" ];
#   then
#     echo "---> Proceeding to the remaining stages after a short pause..."
#     sleep 15
#     echo
#   else
#     echo "---> You did not enter 'YES'. Exiting..."
#     exit 1
#   fi
# fi
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="tfvars-gen"
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
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}

echo "#########################################################################################################"
TF_MODULE="git-tfvars-file"
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
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
terraform apply "$TF_MODULE.plan"
cd ${WORKING_DIRECTORY}

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
terraform plan -out "$TF_MODULE.plan" -var-file="$TFVARS_FILE"
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