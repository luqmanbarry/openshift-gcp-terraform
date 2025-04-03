
## GET AUTHN DETAILS FROM VAULT
data "google_secret_manager_secret_version" "acmhub_details" {
  depends_on    = [ null_resource.backup_managed_cluster_kubeconfig_file ]
  count         = var.acmhub_registration_enabled ? 1 : 0
  secret        = var.acmhub_details_secret_name
  project       = var.acmhub_cluster_project
}

resource "time_sleep" "wait_30_seconds" {
  # depends_on      = [ azurerm_redhat_openshift_cluster.current_cluster ]
  depends_on      = [ data.google_secret_manager_secret_version.acmhub_details ]
  create_duration = "30s"
}

resource "null_resource" "set_acmhub_cluster_kubeconfig" {
  count = var.acmhub_registration_enabled ? 1 : 0

  depends_on = [ data.google_secret_manager_secret_version.acmhub_details, time_sleep.wait_30_seconds ]

  ## Ensure kube files exists and are empty
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      mkdir -p "$KUBECONFIG_DIR" && \
      chmod -R 744 "$KUBECONFIG_DIR" && \
      > $KUBECONFIG || true && \
      export KUBECONFIG="$KUBECONFIG" && \
      oc login -u "$USERNAME" -p "$PASSWORD" "$API_SERVER" --insecure-skip-tls-verify && \
      sleep 5 && \
      oc projects --insecure-skip-tls-verify | head
    EOT
    environment = {
      KUBECONFIG_DIR  = dirname(var.default_kubeconfig_filename)
      KUBECONFIG      = var.default_kubeconfig_filename
      USERNAME        = local.acmhub_details.admin_username
      PASSWORD        = local.acmhub_details.admin_password
      API_SERVER      = local.acmhub_details.api_server_url
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}

resource "null_resource" "backup_acmhub_cluster_kubeconfig_file" {
  count = var.acmhub_registration_enabled ? 1 : 0

  depends_on = [ null_resource.set_acmhub_cluster_kubeconfig ]
  
  ## Empty the ~/.kube/config file
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      mkdir -p "$DEST_DIR" && \
      cp -v "$SRC" "$DEST"
    EOT

    environment = {
      SRC       = var.default_kubeconfig_filename
      DEST      = var.acmhub_kubeconfig_filename
      DEST_DIR  = dirname(var.acmhub_kubeconfig_filename)

    }
  }

  triggers = {
    timestamp = timestamp()
  }
}
