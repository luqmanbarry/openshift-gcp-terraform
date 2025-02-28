
# Cluster Service Principal
data "azuread_service_principal" "current_cluster" {
  client_id = var.cluster_sp_client_id
}

data "azuread_client_config" "current" {}

data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}

resource "azuread_service_principal_password" "current_cluster" {
  service_principal_id = data.azuread_service_principal.current_cluster.object_id
}

# # Cluster Pull Secret
# data "local_file" "ocp_pull_secret" {
#   filename = local.ocp_pull_secret
# }

resource "random_string" "random_lower_str" {
  length           = 7
  numeric          = false
  special          = false
  upper            = false
}

resource "null_resource" "get_latest_openshift_version" {
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "az aro get-versions --location $LOCATION -ojson > $OUTPUT_LOCATION "

    environment = {
      LOCATION        = var.location
      OUTPUT_LOCATION = local.latest_ocp_version
    }
  }
}

data "local_file" "get_latest_openshift_version" {
  depends_on  = [ null_resource.get_latest_openshift_version ]
  filename    = local.latest_ocp_version
}


data "azurerm_resource_group" "cluster_resource_group" {
  name = var.cluster_name
}

locals {
  depends_on = [ data.local_file.get_latest_openshift_version ]
  openshift_versions  = sort(jsondecode(trimspace(data.local_file.get_latest_openshift_version.content)))
  openshift_version   = local.openshift_versions[0]
}

data "azurerm_key_vault_secret" "ocp_pull_secret_kv_secret" {
  name                = var.ocp_pull_secret_kv_secret
  key_vault_id        = var.key_vault_id
}

# ARO Cluster
resource "azurerm_redhat_openshift_cluster" "current_cluster" {

  depends_on = [ 
    data.local_file.get_latest_openshift_version,
    azurerm_policy_definition.rg_tagging_policy_definition,
    azurerm_subscription_policy_assignment.rg_tagging_policy_assignment,
    data.azurerm_key_vault_secret.ocp_pull_secret_kv_secret
  ]

  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.cluster_resource_group

  cluster_profile {
    managed_resource_group_name = local.managed_resource_group_name
    domain                      =  var.use_azure_provided_domain ? local.default_domain : var.custom_dns_domain_name
    version                     = length(var.ocp_version) > 0 ? var.ocp_version : local.openshift_version
    # pull_secret                 = file(local.ocp_pull_secret) # Read from local file
    pull_secret                 = data.azurerm_key_vault_secret.ocp_pull_secret_kv_secret.value
    fips_enabled                = var.fips_enabled
  }

  network_profile {
    pod_cidr     = var.pod_cidr
    service_cidr = var.service_cidr
  }

  main_profile {
    vm_size   = var.main_vm_size
    subnet_id = var.main_subnet_id
    encryption_at_host_enabled = false
  }

  worker_profile {
    vm_size      = var.worker_vm_size
    disk_size_gb = var.worker_disk_size_gb
    node_count   = var.worker_node_count
    subnet_id    = var.worker_subnet_id
    encryption_at_host_enabled = false
  }
  
  api_server_profile {
    visibility = var.private_cluster ? "Private" : "Public"
  }

  ingress_profile {
    visibility = var.private_cluster ? "Private" : "Public"
  }

  service_principal {
    client_id     = data.azuread_service_principal.current_cluster.client_id
    client_secret = azuread_service_principal_password.current_cluster.value
  }

  tags            = local.resource_tags
}

resource "time_sleep" "wait_5min" {
  # depends_on      = [ azurerm_redhat_openshift_cluster.current_cluster ]
  depends_on      = [ azurerm_redhat_openshift_cluster.current_cluster ]
  create_duration = "300s"
}

# Get Cluster API Server
resource "null_resource" "get_cluster_details" {
  depends_on = [ time_sleep.wait_5min ]

  # Get Cluster Console URL
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "az aro show --name $CLUSTER --resource-group $RESOURCEGROUP --query consoleProfile.url -o tsv | xargs > $CONSOLE_URL_FILE"
    environment = {
      CLUSTER             = var.cluster_name
      RESOURCEGROUP       = var.cluster_resource_group
      CONSOLE_URL_FILE    = local.console_url_content_path
    }
  }

  # Get Cluster Ingress LB IP
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "az aro show --name $CLUSTER --resource-group $RESOURCEGROUP --query ingressProfiles[0].ip -o tsv | xargs > $INGRESS_IP_FILE"
    environment = {
      CLUSTER             = var.cluster_name
      RESOURCEGROUP       = var.cluster_resource_group
      INGRESS_IP_FILE     = local.ingress_lb_ip_content_path
    }
  }

  # Get Cluster API Server URL
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "az aro show --name $CLUSTER --resource-group $RESOURCEGROUP --query apiserverProfile.url -o tsv | xargs > $API_SERVER_URL_FILE"
    environment = {
      CLUSTER             = var.cluster_name
      RESOURCEGROUP       = var.cluster_resource_group
      API_SERVER_URL_FILE = local.api_server_url_content_path
    }
  }

  # Get Cluster API Server LB IP
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "az aro show --name $CLUSTER --resource-group $RESOURCEGROUP --query apiserverProfile.ip -o tsv | xargs > $API_SERVER_IP_FILE"
    environment = {
      CLUSTER             = var.cluster_name
      RESOURCEGROUP       = var.cluster_resource_group
      API_SERVER_IP_FILE  = local.api_server_lb_ip_content_path
    }
  }

  # Get Cluster kubeadmin username
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP --query kubeadminUsername -o tsv | xargs > $ADMIN_USERNAME_FILE"
    environment = {
      CLUSTER             = var.cluster_name
      RESOURCEGROUP       = var.cluster_resource_group
      ADMIN_USERNAME_FILE = local.admin_username_content_path
    }
  }

  # Get Cluster kubeadmin password
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP --query kubeadminPassword -o tsv | xargs > $ADMIN_PASSWORD_FILE"
    environment = {
      CLUSTER             = var.cluster_name
      RESOURCEGROUP       = var.cluster_resource_group
      ADMIN_PASSWORD_FILE = local.admin_password_content_path
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}

# Read all cluster details files
data "local_file" "console_url" {
  depends_on  = [ null_resource.get_cluster_details ]
  filename    = local.console_url_content_path
}
data "local_file" "ingress_lb_ip" {
  depends_on  = [ null_resource.get_cluster_details, data.local_file.console_url ]
  filename    = local.ingress_lb_ip_content_path
}
data "local_file" "api_server_url" {
  depends_on  = [ null_resource.get_cluster_details, data.local_file.ingress_lb_ip ]
  filename    = local.api_server_url_content_path
}
data "local_file" "api_server_lb_ip" {
  depends_on  = [ null_resource.get_cluster_details, data.local_file.api_server_url ]
  filename    = local.api_server_lb_ip_content_path
}
data "local_file" "admin_username" {
  depends_on  = [ null_resource.get_cluster_details, data.local_file.api_server_lb_ip ]
  filename    = local.admin_username_content_path
}
data "local_file" "admin_password" {
  depends_on  = [ null_resource.get_cluster_details, data.local_file.admin_username ]
  filename    = local.admin_password_content_path
}

# Save cluster details to AZ KV
resource "azurerm_key_vault_secret" "vault_save_cluster_details" {
  depends_on = [ null_resource.get_cluster_details, data.local_file.admin_password ]

  name                = var.cluster_details_vault_secret_name
  value               = jsonencode(local.cluster_details)
  key_vault_id        = var.key_vault_id
  content_type        = "json"
  tags                = local.resource_tags
}

resource "time_sleep" "wait_for_vault" {
  depends_on      = [ azurerm_key_vault_secret.vault_save_cluster_details ]
  create_duration = "60s"
}

#===> UPDATE DNS RECORDS FOR CLUSTER INGRESS & API
## Create "A" record for cluster Ingress LB IP
resource "azurerm_dns_a_record" "ingress_dns_record" {
  depends_on          = [ time_sleep.wait_for_vault ]
  count               = var.use_azure_provided_domain ? 0 : 1
  # name                = format("*.apps.%s", var.custom_dns_domain)
  name                = "*.apps"
  resource_group_name = var.base_dns_zone_resource_group
  zone_name           = var.custom_dns_domain_name
  ttl                 = var.dns_ttl
  records             = [ "${local.cluster_details.ingress_lb_ip}" ]

  tags = local.resource_tags

  lifecycle {
    ignore_changes = [ tags ]
  }

  timeouts {
    create = "45m"
    delete = "30m"
    read   = "30m"
  }
}

## Create "A" record for cluster API LB IP
resource "azurerm_dns_a_record" "api_dns_record" {
  depends_on          = [ time_sleep.wait_for_vault ]
  count               = var.use_azure_provided_domain ? 0 : 1
  # name                = format("api.%s", var.custom_dns_domain)
  name                = "api"
  resource_group_name = var.base_dns_zone_resource_group
  zone_name           = var.custom_dns_domain_name
  ttl                 = var.dns_ttl
  records             = [ "${local.cluster_details.api_server_lb_ip}" ]

  tags = local.resource_tags

  lifecycle {
    ignore_changes = [ tags ]
  }

  timeouts {
    create = "45m"
    delete = "30m"
    read   = "30m"
  }

}

# Cleanup sensitive data from fileysystem
resource "null_resource" "cleanup_sensitive_data" {
  depends_on = [ azurerm_dns_a_record.ingress_dns_record, azurerm_dns_a_record.api_dns_record ]

  # Get Cluster Console URL
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "echo 'DO NOT DELETE' > $CONSOLE_URL_FILE;echo 'DO NOT DELETE' > $INGRESS_IP_FILE;echo 'DO NOT DELETE' > $API_SERVER_URL_FILE;echo 'DO NOT DELETE' > $API_SERVER_IP_FILE;echo 'DO NOT DELETE' > $ADMIN_USERNAME_FILE;echo 'DO NOT DELETE' > $ADMIN_PASSWORD_FILE;"
    environment = {
      CONSOLE_URL_FILE    = local.console_url_content_path
      INGRESS_IP_FILE     = local.ingress_lb_ip_content_path
      API_SERVER_URL_FILE = local.api_server_url_content_path
      API_SERVER_IP_FILE  = local.api_server_lb_ip_content_path
      ADMIN_USERNAME_FILE = local.admin_username_content_path
      ADMIN_PASSWORD_FILE = local.admin_password_content_path
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}
