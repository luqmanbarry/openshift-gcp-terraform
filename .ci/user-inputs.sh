export TF_VAR_git_token_secret_name="git-github-pat"
export TF_VAR_git_token_secret_project="example-gcp-project"
export TF_VAR_department="sales" # This could be seen as a department/business_unit
export TF_VAR_cost_center="570633"

export TF_VAR_root_dns_domain="sama-wat.com" # FOR NOW USE DEFAULT AZURE PROVIDED DOMAIN

# OSD on GCP CLUSTER INFO
export TF_VAR_platform_environment="dev"
export TF_VAR_cluster_name="osd-lbarry-101" # Max str length 15 characters
export TF_VAR_enable_gcp_wif_authentication=true
export TF_VAR_cluster_project="example-gcp-project" # Can be different from cluster_name
export TF_VAR_ocm_token_secret_name="osd-gcp-ocm-token"
export TF_VAR_ocp_pull_secret_secret_name="osd-gcp-pull-secret"
export TF_VAR_ocp_pull_secret_secret_project="example-gcp-project"  # Project where the pull secret is located
export TF_VAR_private_cluster=false
export TF_VAR_ocp_version="4.18.4"
export TF_VAR_enable_autoscaling=true
export TF_VAR_default_domain_prefix=""  # Max 5 chars - Must be unique
export TF_VAR_autoscaling_max_replicas=12
export TF_VAR_use_auto_generated_domain=true # if set to false, you will have to configure DNS Zones
export TF_VAR_base_dns_name="openshift.example.com"
export TF_VAR_base_dns_zone_name="openshift.example.com"
export TF_VAR_base_dns_zone_resource_group="osd-dns-zones"
export TF_VAR_region="us-central1"
export TF_VAR_default_zone="us-central1-a"
export TF_VAR_availability_zones='["us-central1-a", "us-central1-b", "us-central1-c"]'
# Default VPC CIDR: 10.0.0.0/8
export TF_VAR_vpc_cidr="10.0.0.0/8"  ## Default value for GCP VPC
export TF_VAR_master_subnet_cidr="10.1.90.0/24"  # Use /24 or larger
export TF_VAR_worker_subnet_cidr="10.2.90.0/24"  # Use /24 or larger
export TF_VAR_worker_node_count=3
export TF_VAR_worker_machine_type="n2-standard-8"


# TF State Info
export TF_VAR_tfstate_project="example-gcp-project"
export TF_VAR_tfstate_storage_bucket_name="${TF_VAR_department}-${TF_VAR_platform_environment}-tfstate"

export TF_ENV="${TF_VAR_platform_environment}-${TF_VAR_cluster_name}"

# ACMHUB DETAILS
# Toggle this flag to true if you have an ACMHUB instance and it's credentials are available in KeyVault
export TF_VAR_acmhub_registration_enabled=true
export TF_VAR_acmhub_cluster_details_secret_name="openshift-dev-acmhub-lbarry01"
export TF_VAR_acmhub_cluster_name="acmhub-lbarry01"
export TF_VAR_acmhub_cluster_project="example-gcp-project"
export TF_VAR_acmhub_cluster_env="dev"

export TF_LOG="debug"