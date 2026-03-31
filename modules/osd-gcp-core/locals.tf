locals {
  default_domain = format("%s-%s-%s", var.cluster_name, var.platform_environment, var.department)
  # default_domain  = "poc-101"
  # ocp_pull_secret = "${path.module}/.pull-secret/pull-secret.json" # Read from local file

  scratch_dir                   = "${path.module}/../.scratch_dir"
  ocm_token_file                = format("%s/ocm_token_file", local.scratch_dir)
  current_user_file             = format("%s/current_user", local.scratch_dir)
  current_user                  = trimspace(data.local_file.current_user.content)
  ocp_pull_secret_file          = format("%s/ocp_pull_secret", local.scratch_dir)
  gcp_sa_keyfile                = format("%s/gcp_sa_keyfile", local.scratch_dir)
  additional_trust_bundle       = format("%s/additional_trust_bundle.pem", local.scratch_dir)
  cluster_id_file               = format("%s/cluster_id_file", local.scratch_dir)
  default_idp_id_file           = format("%s/default_idp_id_file", local.scratch_dir)
  default_admin_user_id_file    = format("%s/default_admin_user_id_file", local.scratch_dir)
  htpasswd_file                 = format("%s/htpasswd_file", local.scratch_dir)
  htpasswd_idp_payload_file     = format("%s/htpasswd_idp_payload.json", local.scratch_dir)
  idp_cluster_admin_tenant_file = format("%s/idp_cluster_admin_tenant_file.json", local.scratch_dir)
  default_idp_name              = "system-admin"
  default_user_group            = "cluster-admins"
  htpasswd_idp_payload_json = jsonencode({
    type           = "HTPasswdIdentityProvider"
    mapping_method = "claim"
    name           = local.default_idp_name
    htpasswd = {
      username = format("%s", random_uuid.admin_username.result)
      password = format("%s", random_password.admin_password.result)
    }
  })
  idp_cluster_admin_tenant = jsonencode({
    id = format("%s", random_uuid.admin_username.result)
  })


  cluster_sa_keyfile_secret = format("%s-%s-%s-keyfile", var.department, var.platform_environment, var.cluster_name)

  wif_sa_name = format("%s-%s-%s", var.department, var.platform_environment, var.cluster_name)

  console_url_content_path      = "${local.scratch_dir}/console_url"
  api_server_url_content_path   = "${local.scratch_dir}/api_server_url"
  admin_username_content_path   = "${local.scratch_dir}/admin_username"
  admin_password_content_path   = "${local.scratch_dir}/admin_password"
  ingress_lb_ip_content_path    = "${local.scratch_dir}/ingress_lb_ip"
  api_server_lb_ip_content_path = "${local.scratch_dir}/api_server_lb_ip"

  derived_tags = {
    "cluster_name" = var.cluster_name
    "folder"       = var.department
    "environment"  = var.platform_environment
    "cost_center"  = var.cost_center
    "created_by"   = replace(replace(local.current_user, "@", "_"), ".", "-")
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )

  managed_resource_group_name = format("%s-resources", var.cluster_project)
}