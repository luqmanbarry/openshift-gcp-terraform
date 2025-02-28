locals {
  default_domain  = format("%s-%s-%s", var.cluster_name, var.platform_environment, var.organization)
  # default_domain  = "poc-101"
  # ocp_pull_secret = "${path.module}/.pull-secret/pull-secret.json" # Read from local file
  
  tmp_secrets_dir                = "${path.module}/../.tmp"
  console_url_content_path       = "${local.tmp_secrets_dir}/console_url"
  latest_ocp_version             = "${local.tmp_secrets_dir}/latest_ocp_version"
  api_server_url_content_path    = "${local.tmp_secrets_dir}/api_server_url"
  admin_username_content_path    = "${local.tmp_secrets_dir}/admin_username"
  admin_password_content_path    = "${local.tmp_secrets_dir}/admin_password"
  ingress_lb_ip_content_path     = "${local.tmp_secrets_dir}/ingress_lb_ip"
  api_server_lb_ip_content_path  = "${local.tmp_secrets_dir}/api_server_lb_ip"

  derived_tags = {
    "organization"    = var.organization
    "environment"     = var.platform_environment
    "cost_center"     = var.cost_center
    "created_by"      = format("%s", data.azuread_user.current.user_principal_name)
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )

  managed_resource_group_name = format("%s-resources", var.cluster_resource_group)

  cluster_details = {
    cluster_name      = trimspace(var.cluster_name)
    console_url       = trimspace(data.local_file.console_url.content)
    api_server_url    = trimspace(data.local_file.api_server_url.content)
    admin_username    = trimspace(data.local_file.admin_username.content)
    admin_password    = trimspace(data.local_file.admin_password.content)
    ingress_lb_ip     = trimspace(data.local_file.ingress_lb_ip.content)
    api_server_lb_ip  = trimspace(data.local_file.api_server_lb_ip.content)
    openshift_version = length(var.ocp_version) > 0 ? var.ocp_version : local.openshift_version,
    cluster_sp_client_id = var.cluster_sp_client_id
    cluster_sp_client_secret = azuread_service_principal_password.current_cluster.value
  }
}