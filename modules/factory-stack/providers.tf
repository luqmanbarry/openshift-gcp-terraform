terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
}

provider "google" {
  project = try(var.stack.gcp_project_id, "")
  region  = try(var.stack.gcp_region, "")
  zone    = try(var.stack.gcp_default_zone, "")
}

provider "kubectl" {
  apply_retry_count = 10
  config_path       = pathexpand(var.managed_cluster_kubeconfig_filename)
  insecure          = true
}

provider "kubernetes" {
  config_path = pathexpand(var.managed_cluster_kubeconfig_filename)
  insecure    = true
}

provider "kubernetes" {
  alias       = "acmhub_cluster"
  config_path = pathexpand(var.acmhub_kubeconfig_filename)
  insecure    = true
}
