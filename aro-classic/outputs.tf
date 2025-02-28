output "cluster_name" {
  value = var.cluster_name
}

output "custom_domain" {
  value = var.custom_dns_domain_name
}

output "console_url" {
  value      = local.cluster_details.console_url
}

output "api_server_url" {
  value      = local.cluster_details.api_server_url
}

output "ingress_lb_ip" {
  value      = local.cluster_details.ingress_lb_ip
}

output "api_server_lb_ip" {
  value      = local.cluster_details.api_server_lb_ip
}

output "admin_username" {
  value      = local.cluster_details.admin_username
  # sensitive  = true
}

output "admin_password" {
  value      = local.cluster_details.admin_password
  # sensitive  = true
}

output "cluster_resource_group" {
  value = var.cluster_resource_group
}

output "cluster_service_principal_name" {
  value = var.cluster_name
}




