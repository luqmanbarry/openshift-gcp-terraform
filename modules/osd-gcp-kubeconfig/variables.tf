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

variable "kube_home_dir" {
  type    = string
  default = "~/.kube"
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

variable "acmhub_registration_enabled" {
  type        = bool
  description = "Do you want the cluster to be registered to ACM-HUB? true or false"
  default     = false
}

variable "cluster_details_secret_name" {
  type        = string
  default     = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster authN details"
}

variable "cluster_project" {
  type        = string
  description = "The Cluster GCP project in which to create the cluster"
  default     = "gcp-classic-001"
}

variable "acmhub_details_secret_name" {
  type        = string
  default     = "openshift-OCP_ENV-ACMHUB_NAME-cluster-details"
  description = "The name of the secret that holds the ACMHUB cluster authN details"
}

variable "acmhub_cluster_project" {
  type        = string
  description = "The ACM-HUB Cluster GCP project"
  default     = "acmhub-cluster-001"
}

