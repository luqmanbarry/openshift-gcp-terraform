output "cluster_id" {
  value = module.factory_stack.cluster_id
}

output "cluster_name" {
  value = module.factory_stack.cluster_name
}

output "cluster_project" {
  value = module.factory_stack.cluster_project
}

output "api_url" {
  value     = module.factory_stack.api_url
  sensitive = true
}

output "console_url" {
  value     = module.factory_stack.console_url
  sensitive = true
}

output "api_server_url" {
  value     = module.factory_stack.api_server_url
  sensitive = true
}

output "domain" {
  value = module.factory_stack.domain
}

output "gitops_root_application_name" {
  value = module.factory_stack.gitops_root_application_name
}
