output "cluster_name" {
  value = var.cluster_name
}

output "tf_resources_namespace" {
  value = var.tf_resources_namespace
}

output "gcp_auth_mode" {
  value = local.gcp_auth_mode
}

output "workload_identity_pool_name" {
  value = try(google_iam_workload_identity_pool.day2_gitops[0].name, null)
}

output "workload_identity_provider_name" {
  value = try(google_iam_workload_identity_pool_provider.day2_gitops[0].name, null)
}

output "workload_identity_audience" {
  value = try(format("//iam.googleapis.com/%s", google_iam_workload_identity_pool_provider.day2_gitops[0].name), null)
}

output "service_account_key_secret_name" {
  value = local.gcp_auth_mode == "service_account_key" ? local.gcp_auth_secret_name : null
}

output "service_account_email" {
  value = try(google_service_account.day2_gitops_sa[0].email, null)
}
