locals {
  default_domain  = format("%s-%s-%s", var.cluster_name, var.platform_environment, var.department)
  # default_domain  = "poc-101"
  # ocp_pull_secret = "${path.module}/.pull-secret/pull-secret.json" # Read from local file
  
  scratch_dir                = "${path.module}/../.tmp"
  current_user_file          = format("%s/current_user.txt", local.scratch_dir)
  current_user               = trimspace(data.local_file.current_user.content)
  ocp_pull_secret_file       = format("%s/ocp_pull_secret.txt", local.scratch_dir)
  gcp_sa_keyfile             = format("%s/gcp_sa_keyfile.txt", local.scratch_dir)

  console_url_content_path       = "${local.scratch_dir}/console_url"
  api_server_url_content_path    = "${local.scratch_dir}/api_server_url"
  admin_username_content_path    = "${local.scratch_dir}/admin_username"
  admin_password_content_path    = "${local.scratch_dir}/admin_password"
  ingress_lb_ip_content_path     = "${local.scratch_dir}/ingress_lb_ip"
  api_server_lb_ip_content_path  = "${local.scratch_dir}/api_server_lb_ip"

  cluster_sa_keyfile_secret  = format("%s-%s-%s-keyfile", var.department, var.platform_environment, var.cluster_name)

  derived_tags = {
    "cluster_name"    = var.cluster_name
    "folder"          = var.department
    "environment"     = var.platform_environment
    "cost_center"     = var.cost_center
    "created_by"      = replace(replace(local.current_user, "@", "_"), ".", "-")
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )

  managed_resource_group_name = format("%s-resources", var.cluster_project)

  cluster_details = {
    cluster_name      = trimspace(var.cluster_name)
    console_url       = trimspace(data.local_file.console_url.content)
    api_server_url    = trimspace(data.local_file.api_server_url.content)
    admin_username    = trimspace(data.local_file.admin_username.content)
    admin_password    = trimspace(data.local_file.admin_password.content)
    ingress_lb_ip     = trimspace(data.local_file.ingress_lb_ip.content)
    api_server_lb_ip  = trimspace(data.local_file.api_server_lb_ip.content)
    openshift_version = var.ocp_version
    service_account_name    = var.cluster_service_account_name
    service_account_keyfile = data.google_secret_manager_secret_version.cluster_sa_keyfile.secret_data
  }
}