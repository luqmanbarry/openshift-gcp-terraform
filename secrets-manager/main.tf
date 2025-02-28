# Provision Secrets Manager Instance

# Create a Secret Manager secret
resource "google_secret_manager_secret" "bu_keyvault" {
  secret_id = var.secret_manager_name # The ID of the secret
  project   = var.secret_manager_project

  labels    = local.derived_tags

  replication {
    auto {}
  }

  lifecycle {
    ignore_changes = [ labels ]
  }
}

# Grant IAM permissions for the secret
resource "google_secret_manager_secret_iam_binding" "bu_keyvault_secret_iam" {
  secret_id = google_secret_manager_secret.bu_keyvault.id
  role      = "roles/secretmanager.admin"

  members = [
    length(regexall(".iam.gserviceaccount.com$", local.current_user)) > 0 ? format("serviceAccount:%s", local.current_user) : format("user:%s", local.current_user)
  ]
}

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
