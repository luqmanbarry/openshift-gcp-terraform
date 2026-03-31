output "cluster_project" {
  value = local.cluster_project
}

output "vpc_name" {
  value = length(var.vpc) <= 0 ? format("%s-vpc", var.cluster_name) : var.vpc
}

output "master_subnet_name" {
  value = google_compute_subnetwork.vpc_master_subnet.name
}

output "worker_subnet_name" {
  value = google_compute_subnetwork.vpc_worker_subnet.name
}
