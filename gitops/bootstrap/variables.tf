variable "cluster_name" {
  type        = string
  description = "The name of the OSD cluster to bootstrap"
  default     = "osd-gcp-001"
}

variable "cluster_project" {
  type        = string
  description = "The GCP project in which to create the cluster"
  default     = "gcp-classic-001"
}

variable "managed_cluster_kubeconfig_filename" {
  type    = string
  default = "~/.managed_cluster_kube/config"
}

variable "git_repository_url" {
  type        = string
  description = "Git repository URL that hosts the GitOps apps and overlays."
  default     = "https://corporate.github.com/org/my-repo.git"
}

variable "git_branch" {
  type        = string
  description = "The base branch"
  default     = "main"
}

variable "cluster_group_path" {
  type        = string
  description = "Group path under clusters/, for example dev or tenants/team-a."
  default     = ""
}

variable "gitops_values" {
  type        = any
  description = "Rendered GitOps values from the cluster stack."
  default     = {}
}

variable "gcp_auth" {
  type        = any
  description = "Rendered GitOps GCP auth settings from the cluster stack."
  default     = {}
}

variable "git_token_secret_name" {
  type    = string
  default = "git-github-pat"
}

variable "git_token_secret_project" {
  type        = string
  description = "The project where the Git PAT secret is located."
  default     = "changeme"
}

variable "tf_resources_namespace" {
  type        = string
  description = "Namespace on the managed cluster where Terraform creates bootstrap resources"
  default     = "ocp-tf-resources"
}

variable "k8s_day2_gitops_gcp_sa_rbac_configs" {
  type = list(object({
    gcp_role            = string
    k8s_service_account = string
    k8s_namespace       = string
  }))
  description = "Set of parameters describing Kubernetes service accounts that need access to GCP services"
  default = [
    {
      gcp_role            = "roles/secretmanager.secretAccessor"
      k8s_service_account = "day2-gitops"
      k8s_namespace       = "tf-resources"
    }
  ]
}
