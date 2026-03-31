variable "platform_environment" {
  type        = string
  description = "The OCP cluster environment"
  default     = "dev"
}

variable "private_cluster" {
  type        = bool
  default     = false
  description = "Do you want this cluster to be private? true or false"
}

variable "region" {
  type        = string
  default     = "us-south1" # https://googlecloudplatform.github.io/region-picker/
  description = "The region where the OSD cluster is created"
}

variable "default_zone" {
  type        = string
  default     = "us-south1-a"
  description = "The GCP zone"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-south1-a", "us-south1-b", "us-south1-c"]
  description = "The GCP zones"
}

variable "company_name" {
  type    = string
  default = ""
}

variable "resource_name_suffix" {
  type    = string
  default = ""
}

variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default     = ""
}

variable "cost_center" {
  type        = string
  default     = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "ocp_version" {
  type        = string
  default     = "4.17"
  description = "Desired OpenShift major.minor version for the cluster, for example '4.17'."
}

variable "cluster_name" {
  type        = string
  description = "The name of the OSD cluster to create"
  default     = ""
}

variable "cluster_project" {
  type        = string
  description = "The Cluster GCP project in which to create the cluster"
  default     = ""
}

variable "vpc" {
  type        = string
  description = "Name of the VPC"
  default     = ""
}

variable "vpc_routing_mode" {
  type        = string
  description = "VPC Routing Mode"
  default     = "REGIONAL" # REGIONAL | GLOBAL
}

variable "master_subnet_cidr" {
  type        = string
  description = "IP Address space of the master subnet"
  default     = "10.90.1.0/24"
}

variable "worker_subnet_cidr" {
  type        = string
  description = "IP Address space of the worker subnet"
  default     = "10.90.2.0/24"
}

variable "default_tags" {

  type = map(string)
  default = {
    "AutomationTool" = "Terraform"
  }
  description = "Additional GCP resource tags"
}

variable "cluster_inbound_firewall_rules" {
  type = list(object({
    name         = string
    source_cidrs = set(string)
    port_ranges  = set(string)
    protocol     = string
    direction    = string
  }))

  default = [
    {
      name         = "allow-inbound-from-ops-ocp"
      source_cidrs = ["10.254.0.0/24"]
      port_ranges  = ["30000-32900"]
      protocol     = "tcp"
      direction    = "INGRESS"
    },
    {
      name         = "allow-inbound-from-vendor-svc"
      source_cidrs = ["10.10.0.0/24"]
      port_ranges  = ["8000-9000"]
      protocol     = "tcp"
      direction    = "INGRESS"
    }
  ]
}

variable "base_dns_zone_name" {
  type        = string
  description = "The base DNS zone name; the parent DNS zone name."
  default     = ""
}

variable "base_dns_zone_project" {
  type        = string
  description = "The Project of the base DNS zone name; the parent DNS zone name."
  default     = ""
}

variable "dns_ttl" {
  type        = number
  description = "Default domain DNS TTL"
  default     = 3600
}

variable "use_auto_generated_domain" {
  type        = bool
  default     = true
  description = "Do you want to provide your own domain? true or false"
}

variable "enable_gcp_wif_authentication" {
  type        = bool
  description = "Specifies whether to enable GCP Workload Identity Federation based authentication."
  default     = true
}

variable "rh_cluster_sa_name" {
  type        = string
  description = "Service account name RedHat is expecting."
  default     = "osd-ccs-admin"
}

variable "rh_cluster_sa_roles" {
  type        = list(string)
  description = "Roles for Service Account based authentication"
  default = [
    "roles/compute.admin",
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
}

variable "wif_sa_roles" {
  type        = list(string)
  description = "Roles for Workload Identity Federation based authentication"
  default = [
    "roles/iam.roleAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ]
}

variable "enable_gcp_project_api_list" {
  type        = list(string)
  description = "List of GCP APIs RedHat requires to be enabled at the project scope."
  default = [
    "deploymentmanager.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "networksecurity.googleapis.com",
    "secretmanager.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "orgpolicy.googleapis.com",
    "iap.googleapis.com"
  ]
}
