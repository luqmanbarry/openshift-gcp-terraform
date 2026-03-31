locals {
  stack = var.stack
}

module "impl" {
  source = "../../gitops/bootstrap"

  cluster_name                        = local.stack.cluster_name
  cluster_group_path                  = try(local.stack.cluster_layout.group_path, "")
  cluster_project                     = local.stack.gcp_project_id
  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
  git_repository_url                  = local.stack.gitops.repository_url
  git_branch                          = local.stack.gitops.target_revision
  gitops_values                       = local.stack.gitops
  gcp_auth                            = try(local.stack.gitops.gcp_auth, {})
  git_token_secret_name               = local.stack.secrets.git_token_secret_name
  git_token_secret_project            = local.stack.secrets.git_token_secret_project
  tf_resources_namespace              = local.stack.gitops.tf_resources_namespace
  k8s_day2_gitops_gcp_sa_rbac_configs = local.stack.gitops.service_accounts
}
