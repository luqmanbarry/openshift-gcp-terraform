locals {

  scratch_dir                = "${path.module}/../.tmp"
  current_user_file          = format("%s/current_user.txt", local.scratch_dir)
  current_user               = trimspace(data.local_file.current_user.content)

  derived_tags = {
    "department"          = var.department
    "environment"     = var.platform_environment
    "cost_center"     = var.cost_center
    "created_by"      = replace(replace(local.current_user, "@", "_"), ".", "-")
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )
}