terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "~> 2"
    }
  }
}

provider "kubectl" {
  apply_retry_count  = 3
  config_path        = var.managed_cluster_kubeconfig_filename
  insecure           = true
}

provider "google" {
  project     = var.cluster_project
  region      = var.region
  zone        = var.default_zone
}
