variable "organization" {
  type        = string
  description = "The business unit that owns the cluster."
  default = "sales"
}

variable "cluster_name" {
  default     = "aro-classic-101"
  type        = string
  description = "The name of the ARO cluster to create"
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

variable "platform_environment" {
  type = string
  description = "The cluster environment"
  default = "dev"
}