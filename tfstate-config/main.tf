# Create/Read Cluster Folder/Project
data "google_project" "tfstate_project" {
  project_id    = var.tfstate_project
}

# Create a GCS bucket for Terraform state storage
resource "google_storage_bucket" "terraform_state" {
  name          = var.tfstate_storage_bucket_name # Must be globally unique
  project       = data.google_project.tfstate_project.name
  location      = "US"
  force_destroy = false
  versioning {
    enabled = true # Enable versioning for state file backups
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 # Delete old state files after 30 days
    }
  }

  labels = local.resource_tags
}

data "google_client_config" "current" {}

# Use a local-exec provisioner to get the logged-in username
resource "null_resource" "get_current_user" {
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "gcloud auth list --filter=status:ACTIVE --format=\"value(account)\" > $CURRENT_USER_FILE"
    environment = {
      CURRENT_USER_FILE = local.current_user_file
    }
  }

}

# Read the current user from the file
data "local_file" "current_user" {
  filename = local.current_user_file
  depends_on = [null_resource.get_current_user]
}
