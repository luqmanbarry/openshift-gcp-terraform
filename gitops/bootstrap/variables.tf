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

variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster to create"
  default = "rosa-sts-001"
}

variable "cluster_project" {
  type        = string
  description = "The GCP project in which to create the cluster"
  default = "gcp-classic-001"
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

variable "git_token_secret_name" {
  type = string
  default = "git-github-pat"
}

variable "git_token_secret_project" {
  type = string
  description = "The project where the Git PAT secret is located."
  default = "changeme"
}

variable "tf_resources_namespace" {
  type = string
  description = "Namespace on OCP where TF will create resources used by cluster components"
  default = "ocp-tf-resources"
}

variable "k8s_day2_gitops_gcp_sa_rbac_configs" {
  type = list({
    gcp_role = string
    k8s_service_account = string
    k8s_namespace       = string
  })
  description = "Set of parameters describing K8S service account that need access to GCP services"
  default = [
    {
      gcp_role           = "roles/secretmanager.secretAccessor"
      k8s_service_account = "day2-gitops"
      k8s_namespace       = "tf-resources"
    }
  ]
}