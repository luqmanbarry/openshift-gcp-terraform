
## GET AUTHN DETAILS FROM VAULT
data "google_secret_manager_secret_version" "cluster_details" {
  secret  = var.cluster_details_secret_name
  project = var.cluster_project
}

resource "time_sleep" "wait_for_locals" {
  depends_on      = [data.google_secret_manager_secret_version.cluster_details]
  create_duration = "30s"
}

resource "null_resource" "set_managed_cluster_kubeconfig" {
  depends_on = [data.google_secret_manager_secret_version.cluster_details, time_sleep.wait_for_locals]

  ## Ensure kube files exists and are empty
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      mkdir -p "$KUBECONFIG_DIR" && \
      chmod -R 744 "$KUBECONFIG_DIR" && \
      > $KUBECONFIG || true && \
      export KUBECONFIG="$KUBECONFIG" && \
      oc login -u "$USERNAME" -p "$PASSWORD" "$API_SERVER" --insecure-skip-tls-verify && \
      sleep 5 && \
      oc projects --insecure-skip-tls-verify | head
    EOT

    environment = {
      KUBECONFIG_DIR = dirname(pathexpand(var.default_kubeconfig_filename))
      KUBECONFIG     = pathexpand(var.default_kubeconfig_filename)
      USERNAME       = local.cluster_details.admin_username
      PASSWORD       = local.cluster_details.admin_password
      API_SERVER     = local.cluster_details.api_server_url
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}

resource "null_resource" "backup_managed_cluster_kubeconfig_file" {
  depends_on = [null_resource.set_managed_cluster_kubeconfig]
  ## Empty the ~/.kube/config file
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      mkdir -p "$DEST_DIR" && \
      cp -v "$SRC" "$DEST"
    EOT
    environment = {
      SRC      = pathexpand(var.default_kubeconfig_filename)
      DEST     = pathexpand(var.managed_cluster_kubeconfig_filename)
      DEST_DIR = dirname(pathexpand(var.managed_cluster_kubeconfig_filename))
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}
