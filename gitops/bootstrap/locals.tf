locals {

  gitops_install_helm_chart_dir      = "${path.module}/openshift-gitops"
  gitops_config_helm_chart_dir       = "${path.module}/argocd-config"

  gitops_repo_name    = format("%s-gitops", var.cluster_name)
  git_repository_url  = format("%s/%s/%s.git", var.git_base_url, var.git_org, var.git_repository_name)

  cluster_sp_client_id = jsondecode(data.azurerm_key_vault_secret.cluster_details.value).cluster_sp_client_id
  cluster_sp_client_secret = jsondecode(data.azurerm_key_vault_secret.cluster_details.value).cluster_sp_client_secret
}