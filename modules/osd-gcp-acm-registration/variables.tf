variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default     = "changeme"
}

variable "cluster_name" {
  default     = "osd-classic-101"
  type        = string
  description = "The name of the OSD cluster to register"
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

variable "platform_environment" {
  type        = string
  description = "The cluster environment"
  default     = "dev"
}
