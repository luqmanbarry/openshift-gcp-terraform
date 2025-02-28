variable "organization" {
  type        = string
  description = "The business unit that owns the cluster"
}

variable "azure_cloud_environment" {
  type = string
  description = "The Azure Cloud Environment. Options: environment=public|usgovernment|china|german"
  validation {
    condition = contains(["environment", "public", "usgovernment", "usgovernmentl4", "usgovernmentl5", "china", "german"], var.azure_cloud_environment)
    error_message = "Expected values are one of: environment, public, usgovernment, usgovernmentl4, usgovernmentl5, china, german"
  }
}

variable "location" {
  type    = string
  default = "eastus"
  description = "The location where the ARO cluster is created"
}

variable "ocp_version" {
  type        = string
  default     = "4.15.1"
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}

variable "cluster_resource_group" {
  type        = string
  description = "The resource in which to create the cluster"
  default = "aro-classic-001"
}

variable "main_vm_size" {
  type = string
  default = "Standard_D8s_v3"
}

variable "worker_vm_size" {
  type = string
  default = "Standard_D4s_v3"
}


variable "main_subnet_id" {
  type        = string
  description = "The main subnet ID"
  default = "looked-up"
}

variable "worker_subnet_id" {
  type        = string
  description = "The worker subnet ID"
  default = "looked-up"
}

variable "worker_node_count" {
  type = number
  description = "The worker node count"
  default = 3
}

variable "worker_disk_size_gb" {
  type = number
  description = "The worker node disk size in GB"
  default = 128
}

# ARO Cluster info
variable "cluster_name" {
  type        = string
  description = "The name of the ARO cluster to create"
  default = "aro-classic-101"
}

variable "cluster_service_principal" {
  type        = string
  description = "The service principal assigned to the ARO cluster"
  default = "aro-classic-101"
}

variable "cluster_sp_client_id" {
  type        = string
  description = "The cluster Service Principal ID"
  default = "looked-up"
}

variable "default_tags" {
  default = {
    Terraform   = "true"
    environment = "dev"
    contact     = "opensource@example.com"
  }
  description = "Additional AWS resource tags"
  type        = map(string)
}

variable "private_cluster" {
  type        = bool
  default     = false
  description = "Do you want this cluster to be private? true or false"
}

variable "fips_enabled" {
  type        = bool
  default     = false
  description = "Do you want to enable FIPS? true or false"
}

variable "pod_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Pods"
}

variable "service_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Services"
}

variable "cluster_details_vault_secret_name" {
  type = string
  default = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster admin details"
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


variable "key_vault_name" {
  type = string
  description = "The name of the Azure KV instance hosting OpenShift secrets"
  default = "derived"
}

variable "key_vault_resource_group" {
  type = string
  description = "The RG of the Azure KV instance hosting OpenShift secrets"
  default = "derived"
}

variable "key_vault_id" {
  type = string
  description = "The Azure KeyVault ID"
  default = "looked-up"
}

variable "redhatopenshift_sp_client_id" {
  type = string
  default = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
  description = "The SP client_id, Red Hat automation uses to build and monitor the cluster."
}

variable "root_dns_domain" {
  type = string
  default = "sama-wat.com"
  description = "The root domain name bought"
}

variable "dns_domain_registrar_api_key" {
  type = string
  default = "generated-from-registrar"
  description = "The domain registrar api key"
}

variable "dns_domain_registrar_api_secret" {
  type = string
  default = "generated-from-registrar"
  description = "The domain registrar api secret"
}

variable "use_azure_provided_domain" {
  type = bool
  default = true
  description = "Do you want to provide your own domain? true or false"
}

variable "ocp_pull_secret_kv_secret" {
  type        = string
  description = "The KV Secret name containing the cluster pull secret"
}