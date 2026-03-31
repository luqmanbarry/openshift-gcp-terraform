locals {

  custom_dns_domain_prefix = format("%s.%s.%s.%s", var.cluster_name, var.platform_environment, var.region, var.department)
  custom_dns_domain_name   = format("%s.%s", local.custom_dns_domain_prefix, var.base_dns_zone_name)

  scratch_dir           = "${path.module}/../.scratch_dir"
  current_user_file     = format("%s/current_user", local.scratch_dir)
  cluster_sa_check_file = format("%s/cluster_sa_check_file.txt", local.scratch_dir)
  wif_pool_check_file   = format("%s/wif_pool_check_file.txt", local.scratch_dir)

  current_user = trimspace(data.local_file.current_user.content)

  cluster_sa_keyfile_secret = format("%s-%s-%s-keyfile", var.department, var.platform_environment, var.cluster_name)
  wif_sa_name               = format("%s-%s-%s", var.department, var.platform_environment, var.cluster_name)
  cluster_project           = length(var.cluster_project) > 0 ? var.cluster_project : var.cluster_name

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
}