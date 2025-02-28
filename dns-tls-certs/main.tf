# Get Cluster Details from Azure KeyVault
data "azurerm_key_vault_secret" "cluster_details" {
  name                = var.cluster_details_vault_secret_name
  key_vault_id        = var.key_vault_id
}

# Add CAA record
resource "azurerm_dns_caa_record" "add_caa_record" {
  name                = var.custom_dns_domain_name
  zone_name           = var.custom_dns_domain_name
  resource_group_name = var.base_dns_zone_resource_group
  ttl                 = var.dns_ttl
  record {
    flags = 0
    tag   = "issuewild"
    value = var.custom_dns_domain_name
  }

  tags                = local.resource_tags

  timeouts {
    create = "45m"
    delete = "30m"
    read   = "30m"
  }
}

# Create/Configure Service Principal for cert-manager operator
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}
data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}

resource "azuread_application" "aro_dns_cert_manager" {
  display_name      = local.cert_application_name
  owners            = toset( [ data.azuread_client_config.current.object_id ] )
}

resource "azuread_service_principal" "aro_dns_cert_manager" {
  client_id   = azuread_application.aro_dns_cert_manager.client_id
  description = "The service principal used by the OpenShift Cert-Manager operator to interact with Azure services"
  owners      = [ data.azuread_client_config.current.object_id ]
}

resource "azuread_service_principal_password" "aro_dns_cert_manager" {
  service_principal_id = azuread_service_principal.aro_dns_cert_manager.object_id
}

data "azurerm_dns_zone" "current_cluster" {
  name                = var.custom_dns_domain_name
  resource_group_name = var.base_dns_zone_resource_group
}

resource "azurerm_role_assignment" "role_network_contributor_rg" {
  scope                = data.azurerm_dns_zone.current_cluster.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.aro_dns_cert_manager.object_id
}