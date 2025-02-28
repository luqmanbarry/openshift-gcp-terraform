locals {

  cluster_details = {
    cluster_name      = jsondecode(data.azurerm_key_vault_secret.cluster_details.value).cluster_name
    console_url       = jsondecode(data.azurerm_key_vault_secret.cluster_details.value).console_url
    api_server_url    = jsondecode(data.azurerm_key_vault_secret.cluster_details.value).api_server_url
    admin_username    = sensitive(jsondecode(data.azurerm_key_vault_secret.cluster_details.value).admin_username)
    admin_password    = sensitive(jsondecode(data.azurerm_key_vault_secret.cluster_details.value).admin_password)
  }

  acmhub_details = {
    cluster_name      = length(data.azurerm_key_vault_secret.acmhub_details) > 0 ? jsondecode(data.azurerm_key_vault_secret.acmhub_details[0].value).cluster_name : ""
    console_url       = length(data.azurerm_key_vault_secret.acmhub_details) > 0 ? jsondecode(data.azurerm_key_vault_secret.acmhub_details[0].value).console_url : ""
    api_server_url    = length(data.azurerm_key_vault_secret.acmhub_details) > 0 ? jsondecode(data.azurerm_key_vault_secret.acmhub_details[0].value).api_server_url : ""
    admin_username    = length(data.azurerm_key_vault_secret.acmhub_details) > 0 ? sensitive(jsondecode(data.azurerm_key_vault_secret.acmhub_details[0].value).admin_username) : ""
    admin_password    = length(data.azurerm_key_vault_secret.acmhub_details) > 0 ? sensitive(jsondecode(data.azurerm_key_vault_secret.acmhub_details[0].value).admin_password) : ""
  }
  
}