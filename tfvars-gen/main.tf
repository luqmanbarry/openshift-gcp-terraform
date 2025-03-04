# Use a local-exec provisioner to get the logged-in username
resource "null_resource" "get_current_user" {
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "gcloud auth list --filter=status:ACTIVE --format=\"value(account)\" > $CURRENT_USER_FILE"
    environment = {
      CURRENT_USER_FILE = local.current_user_file
    }
  }

}

# Read the current user from the file
data "local_file" "current_user" {
  filename = local.current_user_file
  depends_on = [null_resource.get_current_user]
}

# VPC
data "google_compute_network" "current_vpc" {
  name                = length(var.vpc) <= 0 ? format("%s-vpc", var.cluster_name) : var.vpc
  project             = local.cluster_project
}

## Master Subnet
data "google_compute_subnetwork" "vpc_master_subnet" {
  name                 = length(var.master_subnet_name) > 0 ? var.master_subnet_name : format("%s-master-subnet", var.cluster_name)
  region               = var.region
  project              = local.cluster_project
}

## Worker Subnet
data "google_compute_subnetwork" "vpc_worker_subnet" {
  name                 = length(var.worker_subnet_name) > 0 ? var.worker_subnet_name : format("%s-worker-subnet", var.cluster_name)
  region               = var.region
  project              = local.cluster_project
}

## VPC Router
data "google_compute_router" "router" {
  name                = length(var.vpc_router) > 0 ? var.vpc_router : format("%s-router", var.cluster_name)
  network             = length(var.vpc) <= 0 ? format("%s-vpc", var.cluster_name) : var.vpc
  project             = local.cluster_project
}


## Master Router NAT
data "google_compute_router_nat" "master_subnet_router_nat" {
  name                = length(var.master_subnet_router_nat) > 0 ? var.master_subnet_router_nat : format("%s-nat-master", var.cluster_name)
  router              = length(var.vpc_router) > 0 ? var.vpc_router : format("%s-router", var.cluster_name)
  project             = local.cluster_project
}

## Worker Router NAT
data "google_compute_router_nat" "worker_subnet_router_nat" {
  name                = length(var.worker_subnet_router_nat) > 0 ? var.worker_subnet_router_nat : format("%s-nat-master", var.cluster_name)
  router              = length(var.vpc_router) > 0 ? var.vpc_router : format("%s-router", var.cluster_name)
  project             = local.cluster_project
}

## Service Account
data "google_service_account" "cluster_service_account" {
  account_id   = var.rh_cluster_sa_name
  project      = local.cluster_project
}

## Local Filesystem: Write combined tfvars to file
resource "local_file" "write_output" {
  content = local.final_tfvars_content
  filename = local.final_tfvars_path
}
