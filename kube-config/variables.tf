variable "azure_cloud_environment" {
  type = string
  description = "The Azure Cloud Environment. Options: environment=public|usgovernment|china|german"
  validation {
    condition = contains(["environment", "public", "usgovernment", "usgovernmentl4", "usgovernmentl5", "china", "german"], var.azure_cloud_environment)
    error_message = "Expected values are one of: environment, public, usgovernment, usgovernmentl4, usgovernmentl5, china, german"
  }
}

variable "kube_home_dir" {
  type = string
  default = "~/.kube"
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster_kube/config"
}

variable "acmhub_kubeconfig_filename" {
  type = string
  default = "~/.acmhub_kube/config"
}

variable "acmhub_registration_enabled" {
  type = bool
  description = "Do you want the cluster to be registered to ACM-HUB? true or false"
  default = false
}

variable "cluster_details_vault_secret_name" {
  type = string
  default = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster admin details"
}

variable "acmhub_details_vault_secret_name" {
  type = string
  default = "openshift-OCP_ENV-ACMHUB_NAME-cluster-details"
  description = "The name of the KV secret that will hold the ACMHUB admin details"
}

variable "key_vault_id" {
  type = string
  description = "The Azure KeyVault ID"
  default = "looked-up"
}

