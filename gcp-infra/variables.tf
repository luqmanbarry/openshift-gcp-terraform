variable "platform_environment" {
  type = string
  description = "The OCP cluster environment"
  default = "dev"
}

variable "private_cluster" {
  type        = bool
  default     = false
  description = "Do you want this cluster to be private? true or false"
}

variable "region" {
  type    = string
  default = "us-south1" # https://googlecloudplatform.github.io/region-picker/
  description = "The region where the OSD cluster is created"
}

variable "default_zone" {
  type        = string
  default = "us-south1-a"
  description = "The GCP zone"
}

variable "availability_zones" {
  type        = list(string)
  default = ["us-south1-a", "us-south1-b", "us-south1-c"]
  description = "The GCP zones"
}

variable "company_name" {
  type = string
  default = "sama-wat-llc"
}

variable "resource_name_suffix" {
  type = string
  default = "platformops"
}

variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default = "sales"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "ocp_version" {
  type        = string
  default     = "4.17.0"
  description = "Desired version of OpenShift for the cluster, for example '4.17.0'."
}

variable "cluster_name" {
  type        = string
  description = "The name of the ARO cluster to create"
  default = "gcp-classic-001"
}

variable "cluster_project" {
  type        = string
  description = "The Cluster GCP project in which to create the cluster"
  default = "gcp-classic-001"
}

variable "vpc" {
  type        = string
  description = "Name of the VPC"
  default = ""
}

variable "vpc_routing_mode" {
  type        = string
  description = "VPC Routing Mode"
  default = "REGIONAL" # REGIONAL | GLOBAL
}

variable "master_subnet_cidr" {
  type        = string
  description = "IP Address space of the master subnet"
  default = "10.90.1.0/24"
}

variable "worker_subnet_cidr" {
  type        = string
  description = "IP Address space of the worker subnet"
  default = "10.90.2.0/24"
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
  }
  description = "Additional Azure resource tags"
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

variable "base_dns_zone_name" {
  type = string
  description = "The base DNS zone name; the parent DNS zone name."
  default = "example.com"
}

variable "base_dns_zone_project" {
  type = string
  description = "The Project of the base DNS zone name; the parent DNS zone name."
  default = "example.com"
}

variable "dns_ttl" {
  type = number
  description = "Default domain DNS TTL"
  default = 3600
}

variable "use_auto_generated_domain" {
  type = bool
  default = true
  description = "Do you want to provide your own domain? true or false"
}

variable "gcp_wif_config_name" {
  type = string
  description = "Specifies the GCP Workload Identity Federation config used for cloud authentication."
  default = ""
}

variable "rh_cluster_sa_name" {
  type = string
  description = "Service account name RedHat is expecting."
  default = "osd-ccs-admin"
}

variable "rh_cluster_sa_roles" {
  type = list(string)
  description = "Service account roles as described in the docs."
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

variable "enable_gcp_project_api_list" {
  type = list(string)
  description = "List of GCP APIs RedHat requires to be enabled at the project scope."
  default = [
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
    "iap.googleapis.com"
  ]
}

