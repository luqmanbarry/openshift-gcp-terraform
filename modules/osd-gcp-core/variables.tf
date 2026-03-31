variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default     = ""
}

variable "region" {
  type        = string
  default     = "us-south1"
  description = "The region where the OSD cluster is created"
}

variable "default_zone" {
  type        = string
  default     = "us-south1-a"
  description = "The GCP zone"
}

variable "ocp_version" {
  type        = string
  default     = "4.17"
  description = "Desired OpenShift major.minor version for the cluster, for example '4.17'. If the requested version is greater than the currently running version, an upgrade will be scheduled."
}

variable "cluster_project" {
  type        = string
  description = "The Cluster GCP project in which to create the cluster"
  default     = ""
}

variable "worker_machine_type" {
  type        = string
  description = "GCP compute machine types: gcloud compute machine-types list --filter='zone:( us-south1 )'"
  default     = "n4-standard-8"
}

variable "master_subnet_name" {
  type        = string
  description = "Name of the master subnet"
  default     = ""
}

variable "worker_subnet_name" {
  type        = string
  description = "Name of the worker subnet"
  default     = ""
}

variable "worker_node_count" {
  type        = number
  description = "The worker node count"
  default     = 3
}

variable "cluster_name" {
  type        = string
  description = "The name of the OSD cluster to create"
  default     = ""
}

variable "cluster_service_account_name" {
  type        = string
  description = "The service account name assigned to the OSD cluster"
  default     = "osd-ccs-admin"
}

variable "default_tags" {

  type = map(string)
  default = {
    "AutomationTool" = "Terraform"
  }
  description = "Default GCP resource tags. Should be set at the admin level."
}

variable "private_cluster" {
  type        = bool
  default     = false
  description = "Do you want this cluster to be private? true or false"
}

variable "vpc" {
  type        = string
  description = "Name of the VPC"
  default     = ""
}

variable "vpc_project_id" {
  type        = string
  description = "Project ID that contains the existing VPC when using customer-provided networking."
  default     = ""
}

variable "psc_subnet_name" {
  type        = string
  description = "Existing subnet name to use for Private Service Connect when PSC is enabled."
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "Block of IP addresses used by OpenShift while installing the cluster"
  default     = "10.0.0.0/8"
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
  type        = string
  default     = ""
  description = "The name of the secret that will hold the cluster authN details"
}

variable "platform_environment" {
  type        = string
  description = "The enviornment name"
  default     = "dev"
}

variable "base_dns_zone_name" {
  type        = string
  description = "The base DNS zone name; the parent DNS zone name."
  default     = ""
}

variable "base_dns_zone_resource_group" {
  type        = string
  description = "Legacy field retained for compatibility; not used for GCP DNS."
  default     = ""
}

variable "dns_ttl" {
  type        = number
  description = "Default domain DNS TTL"
  default     = 3600
}

variable "custom_dns_domain_name" {
  type        = string
  description = "The custoom DNS domain specific to the cluster"
  default     = ""
}

variable "custom_dns_domain_prefix" {
  type        = string
  description = "The custom DNS domain prefix specific to the cluster"
  default     = ""
}

variable "default_domain_prefix" {
  type        = string
  description = "The default DNS domain prefix specific to the cluster"
  default     = ""
}

variable "cost_center" {
  type        = string
  default     = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "root_dns_domain" {
  type        = string
  default     = ""
  description = "The root domain name bought"
}

variable "use_auto_generated_domain" {
  type        = bool
  default     = true
  description = "Do you want to provide your own domain? true or false"
}

variable "ocp_pull_secret_secret_name" {
  type    = string
  default = "osd-gcp-pull-secret"
}

variable "ocp_pull_secret_secret_project" {
  type    = string
  default = ""
}

variable "ocm_token_secret_name" {
  type        = string
  description = "OCM Token. Store it in the same project as the pull-secret"
  default     = "osd-gcp-ocm-token"
}

variable "enable_autoscaling" {
  type        = bool
  default     = true
  description = "Do you want to enable cluster autoscaling? true or false"
}

variable "autoscaling_max_replicas" {
  type        = number
  description = "The maximum replicas count is autoscaling is enabled."
  default     = 12
}

variable "gcp_wif_config_name" {
  type        = string
  description = "Specifies the GCP Workload Identity Federation config used for cloud authentication."
  default     = ""
}

variable "rh_cluster_sa_name" {
  type        = string
  description = "Service account name RedHat is expecting."
  default     = "osd-ccs-admin"
}

variable "enable_gcp_wif_authentication" {
  type        = bool
  description = "Specifies whether to enable GCP Workload Identity Federation based authentication."
  default     = true
}

variable "private_service_connect_enabled" {
  type        = bool
  description = "Whether to enable Private Service Connect for a private OSD cluster on GCP."
  default     = false
}

variable "proxy" {
  default     = null
  description = "cluster-wide HTTP or HTTPS proxy settings"
  type = object({
    enable                  = bool
    http_proxy              = string           # required  http proxy
    https_proxy             = string           # required  https proxy
    additional_trust_bundle = optional(string) # a string contains contains a PEM-encoded X.509 certificate bundle that will be added to the nodes' trusted certificate store.
    no_proxy                = optional(string) # no proxy
  })
}

