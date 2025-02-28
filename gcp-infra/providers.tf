terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6"
    }
  }
}

provider "google" {
  project     = var.cluster_project
  region      = var.region
  zone        = var.default_zone
}
