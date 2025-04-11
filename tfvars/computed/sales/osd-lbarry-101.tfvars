#========================= BEGIN: STATIC VARIABLES ===================================

company_name                  = "sama-wat"
resource_name_suffix          = "platformops"
cert_issuer_email             = "cluster-admin@example.com"
cert_issuer_server            = "https://acme-v02.api.letsencrypt.org/directory"
tf_resources_namespace        = "ocp-tf-resources"
rh_cluster_sa_name            = "osd-ccs-admin"
rh_cluster_sa_roles           = [
  "roles/compute.admin",
  "roles/compute.networkAdmin",
  "roles/compute.securityAdmin",
  "roles/dns.admin",
  "roles/orgpolicy.policyViewer",
  "roles/servicemanagement.admin",
  "roles/serviceusage.serviceUsageAdmin",
  "roles/storage.admin",
  "roles/compute.loadBalancerAdmin",
  "roles/viewer",
  "roles/iam.roleAdmin",
  "roles/iam.securityAdmin",
  "roles/iam.serviceAccountKeyAdmin",
  "roles/iam.serviceAccountAdmin",
  "roles/iam.serviceAccountUser"
]

wif_sa_roles                  = [
  "roles/iam.roleAdmin",
  "roles/iam.serviceAccountAdmin",
  "roles/iam.workloadIdentityPoolAdmin",
  "roles/resourcemanager.projectIamAdmin"
]

enable_gcp_project_api_list   = [
  "deploymentmanager.googleapis.com",
  "compute.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "dns.googleapis.com",
  "iamcredentials.googleapis.com",
  "iam.googleapis.com",
  "servicemanagement.googleapis.com",
  "serviceusage.googleapis.com",
  "storage-api.googleapis.com",
  "storage-component.googleapis.com",
  "orgpolicy.googleapis.com",
  "iap.googleapis.com",
  "cloudapis.googleapis.com",
  "networksecurity.googleapis.com"
]

#================ OCP CLUSTER =========================================================
dns_ttl                       = 300
tls_certificates_ttl_seconds  = "15638400s"
autoscaling_enabled           = true
dns_tls_certificates_subject = {
  country = "United States"
  locality = "Raleigh"
  organizationalUnit = "Research & Development (RND)"
  organization = "SAMA-WAT LLC"
  province = "North Carolina"
  postalCode = "27601"
  streetAddresse = "100 East Davie Street"
}

pod_cidr                      = "172.128.0.0/14"
service_cidr                  = "172.127.0.0/16"

cluster_inbound_firewall_rules = [
    {
      name              = "allow-inbound-from-operations-ocp"
      source_cidrs      = ["10.254.0.0/24"]
      port_ranges       = ["30000-32900"]
      protocol          = "Tcp"
      direction         = "INGRESS"
    },
    {
      name              = "allow-inbound-from-vendor-endpoints"
      source_cidrs      = ["10.254.0.0/24"]
      port_ranges       = ["8000-9000"]
      protocol          = "Tcp"
      direction         = "INGRESS"
    }
]

default_tags = {
  "team_owner" = "platform-ops"
  "cluster_type" = "osd-gcp"
  # More default tags here
}

proxy           = {
  enable        = false
  http_proxy    = "http://proxy.corporate.com"
  https_proxy   = "http://proxy.corporate.com"
  no_proxy      = "kubernetes.default.svc,*.googleapis.com"
  additional_trust_bundle = ""
}


#================= GIT MGMT OF TFVARS ================================================
git_base_url            = "https://github.com/"
git_repository_url      = "https://github.com/luqmanbarry/osd-classic-gcp-terraform.git"
git_org                 = "luqmanbarry"
git_username            = "git"
git_repository_name     = "osd-classic-gcp-terraform"
git_branch              = "main"
git_commit_email        = "cluster-admin@example.com"


#========================= END: STATIC VARIABLES =====================================

#%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

department="sales"

git_token_secret_project="example-gcp-project"

git_token_secret_name="git-github-pat"

private_cluster=false

vpc="osd-lbarry-101-vpc"

master_subnet_name="osd-lbarry-101-master-subnet"

master_subnet_cidr="10.1.90.0/24"

master_subnet_id="2414344627934995292"

worker_subnet_name="osd-lbarry-101-worker-subnet"

worker_subnet_cidr="10.2.90.0/24"

worker_subnet_id="5844553755335336796"

vpc_cidr="10.0.0.0/8"

region="us-central1"

platform_environment="dev"

cluster_name="osd-lbarry-101"

enable_gcp_wif_authentication=true

ocp_pull_secret_secret_name="osd-gcp-pull-secret"

ocp_pull_secret_secret_project="example-gcp-project"

ocm_token_secret_name="osd-gcp-ocm-token"

cluster_details_secret_name="openshift-dev-osd-lbarry-101-cluster-details"

acmhub_details_secret_name="openshift-dev-acmhub-lbarry01-cluster-details"

cluster_service_account_name=""

cluster_project="example-gcp-project"

cost_center="570633"

ocp_version="4.18.4"

acmhub_registration_enabled=false

kube_home_dir="/Users/luqman/workspace/guides/osd-classic-gcp-terraform"

default_kubeconfig_filename="/Users/luqman/workspace/guides/osd-classic-gcp-terraform/.kube/config"

managed_cluster_kubeconfig_filename="/Users/luqman/workspace/guides/osd-classic-gcp-terraform/.kube/managed_cluster/config"

acmhub_kubeconfig_filename="/Users/luqman/workspace/guides/osd-classic-gcp-terraform/.kube/acm_hub/config"

acmhub_cluster_name="acmhub-lbarry01"

worker_machine_type="n2-standard-8"

worker_node_count=3

enable_autoscaling=true

autoscaling_max_replicas=12

tfstate_project="example-gcp-project"

base_dns_zone_name="openshift.example.com"

base_dns_zone_project=""

root_dns_domain="sama-wat.com"

use_auto_generated_domain=true

default_domain_prefix=""

custom_dns_domain_prefix="osd-lbarry-101.dev.us-central1.sales"

custom_dns_domain_name="osd-lbarry-101.dev.us-central1.sales.openshift.example.com"

acmhub_cluster_env="dev"

cluster_infra_tags={"cluster_name"="osd-lbarry-101","cluster_type"="osd-gcp","cost_center"="570633","created_by"="lbarry_redhat-com","environment"="dev","organization"="sales","team_owner"="platform-ops"}

#%%%%%%%%%%%%%%%%%%%%%%%%% END: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%