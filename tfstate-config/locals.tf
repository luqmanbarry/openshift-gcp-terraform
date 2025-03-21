locals {

  scratch_dir                = "${path.module}/../.scratch_dir"
  current_user_file          = format("%s/current_user", local.scratch_dir)

  tfstate_resource_name      = format("%s-%s-tfstate", var.department, var.platform_environment)

  current_user               = trimspace(data.local_file.current_user.content)

  derived_tags = {
    "folder"          = var.department
    "environment"     = var.platform_environment
    "cost_center"     = var.cost_center
    "created_by"      = replace(replace(local.current_user, "@", "_"), ".", "-")
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )
}