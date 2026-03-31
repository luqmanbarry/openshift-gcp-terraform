output "cluster_id" {
  value = module.core.cluster_id
}

output "cluster_name" {
  value = module.core.cluster_name
}

output "cluster_project" {
  value = module.core.cluster_project
}

output "api_url" {
  value     = module.core.api_url
  sensitive = true
}

output "console_url" {
  value     = module.core.console_url
  sensitive = true
}

output "api_server_url" {
  value     = module.core.api_server_url
  sensitive = true
}

output "domain" {
  value = module.core.domain
}

output "gitops_root_application_name" {
  value = local.gitops_bootstrap_enabled ? module.gitops_bootstrap[0].root_application_name : ""
}

output "acm_registration_enabled" {
  value = local.acm_enabled
}

output "vpc_name" {
  value = local.network_vpc_name
}

output "openshift_environment" {
  value = try(var.stack.environment, "dev")
}
