variable "azure_cloud_environment" {
  type = string
  description = "The Azure Cloud Environment. Options: environment=public|usgovernment|china|german"
  validation {
    condition = contains(["environment", "public", "usgovernment", "usgovernmentl4", "usgovernmentl5", "china", "german"], var.azure_cloud_environment)
    error_message = "Expected values are one of: environment, public, usgovernment, usgovernmentl4, usgovernmentl5, china, german"
  }
}

variable "organization" {
  type        = string
  description = "The region where the ROSA cluster is created"
  default = "sales"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster to create"
  default = "rosa-sts-001"
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster_kube/config"
}

variable "git_token" {
  type          = string
  description   = "The GitHub Personal Access Token (PAT)"
  default = "my-personal-access-token"
}

variable "git_repository_url" {
  type          = string
  description   = "This is the target GitHub base API endpoint. The value must end with a slash."
  default = "https://corporate.github.com/org/my-repo.git"
}

variable "git_base_url" {
  type          = string
  description   = "This is the target GitHub base API endpoint. The value must end with a slash."
  default = "https://corporate.github.com/"
}

variable "git_org" {
  type = string
  description = "This is the target GitHub organization or individual user account to manage"
  default = "platform-ops"
}

variable "git_repository_name" {
  type = string
  description = "The GitHub Repository name"
  default = "rosa-sts-terraform"  
}

variable "git_branch" {
  type = string
  description = "The base branch" 
  default = "main" 
}

variable "cluster_sp_k8s_secret_name" {
  type = string
  description = "The k8s secret name containing the cluster ServicePrincipal client_id & client_secret"
  default = "cluster-sp-secret"
}

variable "tf_resources_namespace" {
  type = string
  description = "The default namespace used by the Terraform Helm provider"
  default = "ocp-tf-resources"
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