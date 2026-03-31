output "cluster_name" {
  value = var.cluster_name
}

output "cluster_id" {
  value = local.cluster_details.ocm_cluster_id
}

output "ocm_cluster_id" {
  value = local.cluster_details.ocm_cluster_id
}

output "domain" {
  value = trimspace(var.custom_dns_domain_name) != "" ? var.custom_dns_domain_name : format("%s.%s", var.default_domain_prefix, var.base_dns_zone_name)
}

output "custom_domain" {
  value = trimspace(var.custom_dns_domain_name) != "" ? var.custom_dns_domain_name : format("%s.%s", var.default_domain_prefix, var.base_dns_zone_name)
}

output "api_url" {
  value = local.cluster_details.api_server_url
}

output "console_url" {
  value = local.cluster_details.console_url
}

output "api_server_url" {
  value = local.cluster_details.api_server_url
}

output "ingress_lb_ip" {
  value = local.cluster_details.ingress_lb_ip
}

output "api_server_lb_ip" {
  value = local.cluster_details.api_server_lb_ip
}

output "admin_username" {
  value = local.cluster_details.admin_username
  # sensitive  = true
}

output "admin_password" {
  value     = local.cluster_details.admin_password
  sensitive = true
}

output "cluster_project" {
  value = var.cluster_project
}

output "cluster_service_account_name" {
  value = var.rh_cluster_sa_name
}
