terraform {
  required_providers {

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2"
    }

  }
}

provider "kubernetes" {
  config_path        = var.managed_cluster_kubeconfig_filename
  insecure           = true
  alias              = "managed_cluster"
}

provider "kubernetes" {
  config_path      = var.acmhub_kubeconfig_filename
  insecure         = true
  alias            = "acmhub_cluster"
}