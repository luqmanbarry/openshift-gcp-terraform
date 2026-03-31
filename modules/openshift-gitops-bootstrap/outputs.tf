output "cluster_name" {
  value = var.stack.cluster_name
}

output "root_application_name" {
  value = format("%s-root", var.stack.cluster_name)
}

output "gitops_namespace" {
  value = try(var.stack.gitops.tf_resources_namespace, "ocp-tf-resources")
}

output "gcp_auth_mode" {
  value = try(var.stack.gitops.gcp_auth.mode, "workload_identity_federation")
}
