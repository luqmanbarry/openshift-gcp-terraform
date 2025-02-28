locals {

  cert_application_name               = format("%s-cert-manager-operator", var.cluster_name)
  cert_operator_name                  = "openshift-cert-manager-operator"
  cert_operator_ns                    = "cert-manager-operator"
  cert_ocp_gen_api_secret_name        = "openshift-api-certificate"
  cert_ocp_gen_ingress_secret_name    = "openshift-ingress-certificate"
  cert_manager_cluster_issuer_cr_name = format("%s-letsencrypt", local.cert_operator_name)

  cluster_details = {
    cluster_name      = trimspace(var.cluster_name)
    console_url       = jsondecode(data.azurerm_key_vault_secret.cluster_details.value).console_url
    api_server_url    = jsondecode(data.azurerm_key_vault_secret.cluster_details.value).api_server_url
    admin_username    = sensitive(jsondecode(data.azurerm_key_vault_secret.cluster_details.value).admin_username)
    admin_password    = sensitive(jsondecode(data.azurerm_key_vault_secret.cluster_details.value).admin_password)
  }

  derived_tags = {
      "organization"   = var.organization
      "environment"     = var.platform_environment
      "cost_center"     = var.cost_center
      "created_by"      = format("%s", data.azuread_user.current.user_principal_name)
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )
}