terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1"
    }
  }
}

provider "google" {
  region      = var.region
  zone        = var.default_zone
}