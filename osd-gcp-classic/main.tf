# Fetch the current client configuration
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

resource "random_string" "random_lower_str" {
  length           = 7
  numeric          = false
  special          = false
  upper            = false
}


data "google_project" "cluster_project" {
  project_id = var.cluster_project
}

data "google_secret_manager_secret_version" "ocm_token" {
  secret  = var.ocm_token_secret_name
  project = var.ocp_pull_secret_secret_project
}

data "google_secret_manager_secret_version" "cluster_sa_keyfile" {
  count        = var.enable_gcp_wif_authentication ? 0 : 1
  secret       = local.cluster_sa_keyfile_secret
  project      = var.cluster_project
}

resource "local_file" "gcp_sa_keyfile" {
  count        = var.enable_gcp_wif_authentication ? 0 : 1
  content  = base64decode(data.google_secret_manager_secret_version.cluster_sa_keyfile[0].secret_data)
  filename = local.gcp_sa_keyfile
}

resource "local_file" "additional_trust_bundle" {
  content      = var.proxy.enable ? var.proxy.additional_trust_bundle : ""
  filename     = local.additional_trust_bundle
}

# OSD Cluster
resource "shell_script" "cluster_install" {

  # interpreter = ["/bin/bash", "-c"]

  lifecycle_commands {
    create = file("${path.module}/scripts/cluster_install.sh")
    delete = file("${path.module}/scripts/cluster_destroy.sh")
  }

  environment = {
    ocm_token                 = data.google_secret_manager_secret_version.ocm_token.secret_data
    cluster_name              = var.cluster_name
    private_cluster           = var.private_cluster
    vpc                       = var.vpc
    cluster_project           = var.cluster_project
    version                   = var.ocp_version
    region                    = var.region
    master_subnet_name        = var.master_subnet_name
    worker_subnet_name        = var.worker_subnet_name
    worker_machine_type       = var.worker_machine_type
    worker_node_count         = var.worker_node_count
    domain_prefix             = var.use_auto_generated_domain ? var.default_domain_prefix : var.custom_dns_domain_prefix
    enable_autoscaling        = var.enable_autoscaling
    autoscaling_max_replicas  = var.autoscaling_max_replicas
    vpc_cidr                  = var.vpc_cidr
    pod_cidr                  = var.pod_cidr
    service_cidr              = var.service_cidr
    gcp_sa_keyfile            = local.gcp_sa_keyfile
    enable_gcp_wif_authentication  = var.enable_gcp_wif_authentication
    gcp_wif_config_name       = local.wif_sa_name
    wif_role_prefix           = substr(replace(var.cluster_name, "-", ""), 0, 8)
    http_proxy                = var.proxy.enable ? var.proxy.http_proxy : ""
    https_proxy               = var.proxy.enable ? var.proxy.https_proxy : ""
    no_proxy                  = var.proxy.enable ? var.proxy.no_proxy : ""
    additional_trust_bundle   = local.additional_trust_bundle
  }
}

resource "time_sleep" "wait_for_cluster" {
  depends_on      = [ shell_script.cluster_install ]
  create_duration = "300s"
}

# Get Cluster API Server
resource "null_resource" "get_cluster_details" {
  depends_on = [ time_sleep.wait_for_cluster ]

  # Get Cluster Console URL
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '$CLUSTER%'" | jq -r '.items[].id')
      ocm describe cluster $CLUSTER_ID --json | jq -r '.console.url' | xargs > $CONSOLE_URL_FILE
    EOT

    environment = {
      CLUSTER             = var.cluster_name
      CONSOLE_URL_FILE    = local.console_url_content_path
    }
  }

  # Get Cluster Ingress LB IP
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '$CLUSTER%'" | jq -r '.items[].id')
      ocm describe cluster $CLUSTER_ID --json | jq -r '.ingress.load_balancer_ip' | xargs > $INGRESS_IP_FILE
    EOT

    environment = {
      CLUSTER             = var.cluster_name
      INGRESS_IP_FILE     = local.ingress_lb_ip_content_path
    }
  }

  # Get Cluster API Server URL
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '$CLUSTER%'" | jq -r '.items[].id')
      ocm describe cluster $CLUSTER_ID --json | jq -r '.api.url' | xargs > $API_SERVER_URL_FILE
    EOT

    environment = {
      CLUSTER             = var.cluster_name
      API_SERVER_URL_FILE = local.api_server_url_content_path
    }
  }

  # Get Cluster API Server LB IP
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = <<EOT
      CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '$CLUSTER%'" | jq -r '.items[].id')
      ocm describe cluster $CLUSTER_ID --json | '.api.load_balancer_ip' | xargs > $API_SERVER_IP_FILE
    EOT

    environment = {
      CLUSTER             = var.cluster_name
      API_SERVER_IP_FILE  = local.api_server_lb_ip_content_path
    }
  }

  # Get Cluster kubeadmin username
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "echo 'kubeadmin' > $ADMIN_USERNAME_FILE"
    environment = {
      CLUSTER             = var.cluster_name
      ADMIN_USERNAME_FILE = local.admin_username_content_path
    }
  }

  # Get Cluster kubeadmin password
  provisioner "local-exec" {
    interpreter = [ "/bin/sh", "-c" ]
    command = "ocm describe cluster \"$CLUSTER\" --json | jq -r '.admin.password' | xargs > $ADMIN_PASSWORD_FILE"
    environment = {
      CLUSTER             = var.cluster_name
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

## Create Cluster Details Secret SecretManager
resource "google_secret_manager_secret" "cluster_details_secret" {
  depends_on      = [ data.local_file.admin_password ]
  secret_id = var.cluster_details_secret_name
  project   = var.cluster_project

  labels    = local.derived_tags

  replication {
    auto {}
  }

  lifecycle {
    ignore_changes = [ labels ]
  }
}

data "google_service_account" "cluster_service_account" {
  count      = var.enable_gcp_wif_authentication ? 0 : 1
  account_id = var.rh_cluster_sa_name
  project    = var.cluster_project
}

## Grant Cluster Details Secret SecretAccessor role
resource "google_secret_manager_secret_iam_binding" "cluster_details_secret_bindings" {
  count      = var.enable_gcp_wif_authentication ? 0 : 1
  project    = google_secret_manager_secret.cluster_details_secret.project
  secret_id  = google_secret_manager_secret.cluster_details_secret.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${data.google_service_account.cluster_service_account[0].email}",
    length(regexall(".iam.gserviceaccount.com$", local.current_user)) > 0 ? format("serviceAccount:%s", local.current_user) : format("user:%s", local.current_user)
  ]
  
}

## Store the Cluster Details
resource "google_secret_manager_secret_version" "store_cluster_details" {
  secret = google_secret_manager_secret.cluster_details_secret.id

  secret_data = jsonencode(local.cluster_details)
}

resource "time_sleep" "wait_for_secret_store" {
  depends_on      = [ google_secret_manager_secret_version.store_cluster_details ]
  create_duration = "60s"
}

# #===> UPDATE DNS RECORDS FOR CLUSTER INGRESS & API
# ## Create "A" record for cluster Ingress LB IP
# resource "azurerm_dns_a_record" "ingress_dns_record" {
#   depends_on          = [ time_sleep.wait_for_secret_store ]
#   count               = var.use_auto_generated_domain ? 0 : 1
#   # name                = format("*.apps.%s", var.custom_dns_domain)
#   name                = "*.apps"
#   resource_group_name = var.base_dns_zone_resource_group
#   zone_name           = var.custom_dns_domain_name
#   ttl                 = var.dns_ttl
#   records             = [ "${local.cluster_details.ingress_lb_ip}" ]

#   tags = local.resource_tags

#   lifecycle {
#     ignore_changes = [ tags ]
#   }

#   timeouts {
#     create = "45m"
#     delete = "30m"
#     read   = "30m"
#   }
# }

# ## Create "A" record for cluster API LB IP
# resource "azurerm_dns_a_record" "api_dns_record" {
#   depends_on          = [ time_sleep.wait_for_secret_store ]
#   count               = var.use_auto_generated_domain ? 0 : 1
#   # name                = format("api.%s", var.custom_dns_domain)
#   name                = "api"
#   resource_group_name = var.base_dns_zone_resource_group
#   zone_name           = var.custom_dns_domain_name
#   ttl                 = var.dns_ttl
#   records             = [ "${local.cluster_details.api_server_lb_ip}" ]

#   tags = local.resource_tags

#   lifecycle {
#     ignore_changes = [ tags ]
#   }

#   timeouts {
#     create = "45m"
#     delete = "30m"
#     read   = "30m"
#   }

# }

# Cleanup sensitive data from fileysystem
resource "null_resource" "cleanup_sensitive_data" {
  # depends_on = [ azurerm_dns_a_record.ingress_dns_record, azurerm_dns_a_record.api_dns_record ]

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
