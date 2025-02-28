## Declare common vars
locals {
  local_repository_dir      = "${path.module}/.."
  tfvars_file               = abspath(format("${path.module}/../tfvars/computed/%s/%s/%s.tfvars", var.organization, var.subscription_id, var.cluster_name))
  action_taken              = var.git_action_taken
  custom_cluster_name       = format("%s-%s-%s", var.organization, var.platform_environment, var.cluster_name)
  feature_branch            = format("%s/%s/CIJob-%s", local.action_taken, local.custom_cluster_name, var.git_ci_job_number)
  pr_title                  = replace(local.feature_branch, "/", " - ")
  tfvar_message             = format("TFVars for cluster: '%s'", local.custom_cluster_name)
  ci_message                = format("CI Job Identifier: %s", var.git_ci_job_identifier)
  message                   = format("Action Taken: %s\n%s\n%s", local.action_taken, local.tfvar_message, local.ci_message)
}