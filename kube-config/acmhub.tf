
## GET AUTHN DETAILS FROM VAULT
data "azurerm_key_vault_secret" "acmhub_details" {
  count = var.acmhub_registration_enabled ? 1 : 0
  depends_on          = [ null_resource.backup_managed_cluster_kubeconfig_file ]
  name                = var.acmhub_details_vault_secret_name
  key_vault_id        = var.key_vault_id
}

resource "time_sleep" "wait_30_seconds" {
  # depends_on      = [ azurerm_redhat_openshift_cluster.current_cluster ]
  depends_on      = [ data.azurerm_key_vault_secret.acmhub_details ]
  create_duration = "30s"
}

resource "null_resource" "set_acmhub_cluster_kubeconfig" {
  count = var.acmhub_registration_enabled ? 1 : 0

  depends_on = [ data.azurerm_key_vault_secret.acmhub_details, time_sleep.wait_30_seconds ]

  ## Ensure kube files exists and are empty
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "mkdir -p \"$KUBECONFIG_DIR\" && > $KUBECONFIG || true"
    environment = {
      KUBECONFIG_DIR  = dirname(var.default_kubeconfig_filename)
    }
  }

  # Login to the kube cluster - New kubeconfig file will be created
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "export KUBECONFIG=\"$KUBECONFIG\" && oc login -u \"$USERNAME\" -p \"$PASSWORD\" \"$API_SERVER\" --insecure-skip-tls-verify"

    environment = {
      USERNAME   = local.acmhub_details.admin_username
      PASSWORD   = local.acmhub_details.admin_password
      API_SERVER = local.acmhub_details.api_server_url
      KUBECONFIG = var.default_kubeconfig_filename

    }
  }

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "oc projects --insecure-skip-tls-verify | head"
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
    command = "mkdir -p \"$DEST_DIR\" && cp -v \"$SRC\" \"$DEST\" "

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
