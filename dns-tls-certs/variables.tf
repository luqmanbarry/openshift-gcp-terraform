variable "azure_cloud_environment" {
  type = string
  description = "The Azure Cloud Environment. Options: environment=public|usgovernment|china|german"
  validation {
    condition = contains(["environment", "public", "usgovernment", "usgovernmentl4", "usgovernmentl5", "china", "german"], var.azure_cloud_environment)
    error_message = "Expected values are one of: environment, public, usgovernment, usgovernmentl4, usgovernmentl5, china, german"
  }
}

variable "platform_environment" {
  type = string
  description = "The ROSA cluster environment"
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
  description = "The location where the ARO cluster is created"
}

variable "organization" {
  type        = string
  description = "The region where the ROSA cluster is created"
  default = "sales"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster to create"
  default = "rosa-sts-001"
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
    "Contact"        = "opensource@example.com"
  }
  description = "Additional Azure resource tags"
}

variable "private_cluster" {
  type = bool
  description = "Make the ARO cluster public (internet access) or private"
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

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster_kube/config"
}

variable "cluster_details_vault_secret_name" {
  type = string
  default = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster admin details"
}

variable "key_vault_id" {
  type = string
  description = "The Azure KeyVault ID"
  default = "looked-up"
}

variable "custom_dns_domain_prefix" {
  type = string
  description = "The custoom DNS domain prefix specific to the cluster"
  default = "luqman"
}

variable "cluster_resource_group" {
  type        = string
  description = "The resource in which to create the cluster"
  default = "aro-classic-001"
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

variable "base_dns_zone_resource_group" {
  type = string
  description = "The resource group of the base DNS zone name; the parent DNS zone name."
  default = "aro-classic-101"
}

variable "cert_issuer_email" {
  type = string
  default = "cluster-admin@example.com"
}

variable "cert_issuer_server" {
  type = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "tls_certificates_ttl_seconds" {
  type = string
  description = "The TLS/SSL certificates duration."
  default = "31536000s"
}

variable "dns_tls_certificates_subject" {
  type = object({
    country = string
    locality = string
    organizationalUnit = string
    organization = string
    province = string
    postalCode = string
    streetAddresse = string
  })

  default = {
    country = "United States"
    locality = "Raleigh"
    organizationalUnit = "Research & Development (RND)"
    organization = "SAMA-WAT LLC"
    province = "North Carolina"
    postalCode = "27601"
    streetAddresse = "100 East Davie Street"
  }
}
