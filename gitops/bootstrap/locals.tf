locals {

  gitops_install_helm_chart_dir      = "${path.module}/openshift-gitops"
  gitops_config_helm_chart_dir       = "${path.module}/argocd-config"

  gitops_repo_name          = format("%s-gitops", var.cluster_name)
  git_repository_url        = format("%s/%s/%s.git", var.git_base_url, var.git_org, var.git_repository_name)
  wif_config_name           = format("%s-day2-gitops", var.cluster_name)
  ocp_day2_service_account  = format("%s-day2-gitops", var.cluster_name)

  k8s_day2_gitops_gcp_sa_rbac_configs = [
  {
    gcp_role           = "roles/secretmanager.secretAccessor"
    k8s_service_account = local.ocp_day2_service_account
    k8s_namespace       = var.tf_resources_namespace
  },
  {
    gcp_role           = "roles/iam.serviceAccountTokenCreator"
    k8s_service_account = local.ocp_day2_service_account
    k8s_namespace       = var.tf_resources_namespace
  },
  {
    gcp_role           = "roles/iam.workloadIdentityUser"
    k8s_service_account = local.ocp_day2_service_account
    k8s_namespace       = var.tf_resources_namespace
  }
  
]

  cluster_details = {
    cluster_name      = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).cluster_name
    console_url       = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).console_url
    api_server_url    = jsondecode(base64decode(data.google_secret_manager_secret_version.cluster_details.secret_data)).api_server_url
  }
}