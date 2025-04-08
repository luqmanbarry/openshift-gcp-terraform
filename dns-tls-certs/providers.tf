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

provider "google" {
  region      = var.region
  zone        = var.default_zone
}

provider "kubectl" {
  apply_retry_count  = 10
  config_path        = var.managed_cluster_kubeconfig_filename
  insecure           = true
  # alias              = "managed_cluster"
}