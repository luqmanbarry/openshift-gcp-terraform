variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default = "changeme"
}

variable "region" {
  type    = string
  default = "us-south1"
  description = "The region where the OSD cluster is created"
}

variable "default_zone" {
  type        = string
  default = "us-south1-a"
  description = "The GCP zone"
}

variable "ocp_version" {
  type        = string
  default     = "4.17.0"
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}

variable "cluster_project" {
  type        = string
  description = "The Cluster GCP project in which to create the cluster"
  default = "gcp-classic-001"
}

variable "worker_machine_type" {
  type = string
  description = "GCP compute machine types: gcloud compute machine-types list --filter='zone:( us-south1 )'"
  default = "n4-standard-8"
}

variable "master_subnet_name" {
  type        = string
  description = "Name of the master subnet"
  default = ""
}

variable "worker_subnet_name" {
  type        = string
  description = "Name of the worker subnet"
  default = ""
}

variable "worker_node_count" {
  type = number
  description = "The worker node count"
  default = 3
}

variable "cluster_name" {
  type        = string
  description = "The name of the ARO cluster to create"
  default = "osd-classic-001"
}

variable "cluster_service_account_name" {
  type        = string
  description = "The service account name assigned to the OSD cluster"
  default = "osd-gcp-101"
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
  }
  description = "Default Azure resource tags. Should be set at the admin level."
}

variable "private_cluster" {
  type        = bool
  default     = false
  description = "Do you want this cluster to be private? true or false"
}

variable "vpc" {
  type        = string
  description = "Name of the VPC"
  default = ""
}

variable "pod_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Pods"
}

variable "service_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Services"
}

variable "cluster_details_secret_name" {
  type = string
  default = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster authN details"
}

variable "platform_environment" {
  type = string
  description = "The enviornment name"
  default = "dev"
}

variable "base_dns_zone_name" {
  type = string
  description = "The base DNS zone name; the parent DNS zone name."
  default = "example.com"
}

variable "base_dns_zone_resource_group" {
  type = string
  description = "The resource group of the base DNS zone name; the parent DNS zone name."
  default = "aro-classic-101"
}

variable "dns_ttl" {
  type = number
  description = "Default domain DNS TTL"
  default = 3600
}

variable "custom_dns_domain_name" {
  type = string
  description = "The custoom DNS domain specific to the cluster"
  default = "aro-classic1.dev.estus.rnd.openshift.sama-wat.com"
}

variable "custom_dns_domain_prefix" {
  type = string
  description = "The custoom DNS domain prefix specific to the cluster"
  default = "luqman"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "root_dns_domain" {
  type = string
  default = "sama-wat.com"
  description = "The root domain name bought"
}

variable "use_auto_generated_domain" {
  type = bool
  default = true
  description = "Do you want to provide your own domain? true or false"
}

variable "ocp_pull_secret_secret_name" {
  type = string
  default = "osd-gcp-pull-secret"
}

variable "ocp_pull_secret_secret_project" {
  type = string
  default = "changeme"
}

variable "ocm_token_secret_name" {
  type = string
  description = "OCM Token. Store it in the same project as the pull-secret"
  default = "osd-gcp-ocm-token"
}