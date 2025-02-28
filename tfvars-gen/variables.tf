
variable "platform_environment" {
  type = string
  description = "The ARO cluster environment"
  default = "dev"
}

variable "region" {
  type    = string
  default = "eastus"
  description = "The region where the OSD cluster is created"
}

variable "default_zone" {
  type        = string
  default = "us-south1-a"
  description = "The GCP zone"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "ocp_version" {
  type        = string
  default     = "4.14.12"
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}

variable "master_subnet_name" {
  type        = string
  description = "Name of the master subnet"
  default = ""
}

variable "master_subnet_cidr" {
  type        = string
  description = "IP Address space of the master subnet"
  default = "10.90.1.0/24"
}

variable "master_subnet_router_nat" {
  type        = string
  description = "Name of the VPC master subnet router NAT"
  default = ""
}

variable "worker_subnet_name" {
  type        = string
  description = "Name of the worker subnet"
  default = ""
}

variable "worker_subnet_cidr" {
  type        = string
  description = "IP Address space of the worker subnet"
  default = "10.90.2.0/24"
}

variable "worker_subnet_router_nat" {
  type        = string
  description = "Name of the VPC worker subnet router NAT"
  default = ""
}

variable "worker_machine_type" {
  type = string
  description = "GCP compute machine types: gcloud compute machine-types list --filter='zone:( us-south1 )'"
  default = "n4-standard-8"
}

variable "worker_node_count" {
  type = number
  description = "The worker node count"
  default = 3
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
    "Contact"        = "opensource@example.com"
  }
  description = "Default Azure resource tags. Should be set at the admin level."
}

variable "vpc" {
  type        = string
  description = "Name of the VPC"
  default = ""
}

variable "vpc_router" {
  type        = string
  description = "Name of the VPC Router"
  default = ""
}

variable "vpc_project" {
  type        = string
  description = "Name of the VPC project. Must be set for Shared VPC"
  default = ""
}

variable "cluster_inbound_firewall_rules" {
  type = list(object({
    name              = string
    source_cidrs      = set(string)
    port_ranges       = set(string)
    protocol          = string
    direction         = string
  }))

  default = [
    {
      name              = "allow-inbound-from-ops-ocp"
      source_cidrs      = ["10.254.0.0/24"]
      port_ranges       = ["30000-32900"]
      protocol          = "tcp"
      direction         = "INGRESS"
    },
    {
      name              = "allow-inbound-from-vendor-svc"
      source_cidrs      = ["10.10.0.0/24"]
      port_ranges       = ["8000-9000"]
      protocol          = "tcp"
      direction         = "INGRESS"
    }
  ]
}

variable "tfstate_project" {
  type = string
  default = "osd-gcp-tfstate"
}

variable "cluster_project" {
  type        = string
  description = "The Cluster GCP project in which to create the cluster"
  default = "gcp-classic-001"
}


variable "cluster_details_secret_name" {
  type = string
  default = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster admin details"
}

variable "acmhub_details_secret_name" {
  type = string
  default = "openshift-OCP_ENV-ACMHUB_NAME-cluster-details"
  description = "The name of the secret that will hold the ACMHUB admin details"
}

variable "acmhub_registration_enabled" {
  type = bool
  description = "Do you want the cluster to be registered to ACM-HUB? true or false"
  default = false
}

variable "acmhub_cluster_name" {
  type = string
  default = "acmhub-101"
}

variable "ocp_pull_secret_secret_name" {
  type = string
  default = "osd-gcp-pull-secret"
}

variable "git_token_secret_name" {
  type = string
  default = "git-github-pat"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ARO cluster to create"
  default = "gcp-classic-001"
}

variable "cluster_service_account_name" {
  type        = string
  description = "The service account name assigned to the OSD cluster"
  default = "osd-gcp-101"
}

variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default = "changeme"
}

variable "git_token" {
  type          = string
  description   = "The GitHub Personal Access Token (PAT)"
  default = "my-personal-access-token"
}

variable "git_base_url" {
  type          = string
  description   = "This is the target GitHub base API endpoint. The value must end with a slash."
  default = "https://github.com/"
}

variable "git_org" {
  type = string
  description = "This is the target GitHub organization or individual user account to manage"
  default = "luqmanbarry"
}

variable "git_repository_name" {
  type = string
  description = "The GitHub Repository name"
  default = "osd-gcp-terraform"  
}

variable "git_branch" {
  type = string
  description = "The base branch" 
  default = "main" 
}

variable "git_action_taken" {
  type            = string
  description     = "The action the CI Job took: options: ROSAClusterCreate, ROSAClusterUpdate,,,etc"
  default         = "ROSAClusterCreate"
}

variable "private_cluster" {
  type        = bool
  description = "Do you want this cluster to be private? true or false"
  default = false
}

variable "pod_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Pods"
  default = ""
}

variable "service_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Services"
  default = ""
}

variable "acmhub_username" {
  type = string
  default = "changeme"
}

variable "acmhub_password" {
  type = string
  default = "changeme"
}

variable "acmhub_cluster_env" {
  type = string
  description = "ACMHUB Cluster Environment"
}

variable acmhub_api_server {
  type        = string
  description = "The ACMHUB api server hostname"
  default = ""
}

variable "root_dns_domain" {
  type = string
  default = "sama-wat.com"
  description = "The root domain name bought"
}

variable "base_dns_zone_name" {
  type = string
  description = "The base DNS zone name; the parent DNS zone name."
  default = "example.com"
}

variable "base_dns_zone_project" {
  type = string
  description = "The project of the base DNS zone name; the parent DNS zone name."
  default = ""
}

variable "use_auto_generated_domain" {
  type = bool
  default = true
  description = "Do you want to provide your own domain? true or false"
}

variable "enable_autoscaling" {
  type = bool
  default = true
  description = "Do you want to enable cluster autoscaling? true or false"
}

variable "autoscaling_max_replicas" {
  type = number
  description = "The maximum replicas count is autoscaling is enabled."
  default = 12
}

variable "gcp_wif_config_name" {
  type = string
  description = "Specifies the GCP Workload Identity Federation config used for cloud authentication."
  default = ""
}

