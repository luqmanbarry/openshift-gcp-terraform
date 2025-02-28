company_name                  = "sama-wat"
resource_name_suffix          = "platformops"
cert_issuer_email             = "cluster-admin@example.com"
cert_issuer_server            = "https://acme-v02.api.letsencrypt.org/directory"
tf_resources_namespace        = "ocp-tf-resources"
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

#================= GIT MGMT OF TFVARS ================================================
git_base_url            = "https://github.com/"
git_repository_url      = "https://github.com/luqmanbarry/aro-classic-terraform.git"
git_org                 = "luqmanbarry"
git_username            = "git"
git_repository_name     = "osd-classic-gcp-terraform"
git_branch              = "main"
git_commit_email        = "cluster-admin@example.com"
