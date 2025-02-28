terraform {
  required_providers {

    git = {
      source = "metio/git"
      version = "2024.9.13"
    }
  }
}

provider "git" {
  # Configuration options
}