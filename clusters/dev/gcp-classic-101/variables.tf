variable "stack" {
  description = "Rendered effective OSD-on-GCP stack config."
  type        = any
}

variable "default_kubeconfig_filename" {
  type    = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type    = string
  default = "~/.managed_cluster_kube/config"
}

variable "acmhub_kubeconfig_filename" {
  type    = string
  default = "~/.acmhub_kube/config"
}
