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
