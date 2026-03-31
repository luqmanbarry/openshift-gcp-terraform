terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
