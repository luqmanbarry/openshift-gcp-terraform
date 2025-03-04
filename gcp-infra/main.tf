# Fetch the current client configuration
data "google_client_config" "current" {}

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

# Create Cluster Folder/Project
# resource "google_project" "cluster_project" {
#   name          = local.cluster_project
#   project_id    = local.cluster_project
#   folder_id     = var.department
# }

resource "google_compute_network" "vpc_network" {
  project                   = local.cluster_project
  name                      = length(var.vpc) <= 0 ? format("%s-vpc", var.cluster_name) : var.vpc
  auto_create_subnetworks   = false
  routing_mode              = var.vpc_routing_mode
  mtu                       = 1460
}

resource "google_compute_subnetwork" "vpc_master_subnet" {
  project         = local.cluster_project
  name            = format("%s-master-subnet", var.cluster_name)
  ip_cidr_range   = var.master_subnet_cidr
  region          = var.region
  network         = google_compute_network.vpc_network.id
  
}

resource "google_compute_subnetwork" "vpc_worker_subnet" {
  project         = local.cluster_project
  name            = format("%s-worker-subnet", var.cluster_name)
  ip_cidr_range   = var.worker_subnet_cidr
  region          = var.region
  network         = google_compute_network.vpc_network.id
}

resource "google_compute_router" "router" {
  project   = local.cluster_project
  name      = format("%s-router", var.cluster_name)
  region    = var.region
  network   = google_compute_network.vpc_network.id
  
}

resource "google_compute_router_nat" "master_router_nat" {
  name                                = format("%s-nat-master", var.cluster_name)
  router                              = google_compute_router.router.name
  region                              = var.region
  nat_ip_allocate_option              = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                      = google_compute_subnetwork.vpc_master_subnet.id
    source_ip_ranges_to_nat   = ["ALL_IP_RANGES"]
  }
  min_ports_per_vm                      = "7168"
  enable_endpoint_independent_mapping   = false
}

resource "google_compute_router_nat" "worker_router_nat" {
  name                                = format("%s-nat-worker", var.cluster_name)
  router                              = google_compute_router.router.name
  region                              = var.region
  nat_ip_allocate_option              = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                      = google_compute_subnetwork.vpc_worker_subnet.id
    source_ip_ranges_to_nat   = ["ALL_IP_RANGES"]
  }
  min_ports_per_vm                      = "4096"
  enable_endpoint_independent_mapping   = false
}

resource "google_compute_firewall" "inbound_traffic_security" {
  name        = format("%s-%s", var.cluster_name, var.cluster_inbound_firewall_rules[count.index].name)
  project     = local.cluster_project
  network     = google_compute_network.vpc_network.name

  count       = length(var.cluster_inbound_firewall_rules)

  allow {
    protocol  = var.cluster_inbound_firewall_rules[count.index].protocol
    ports     = var.cluster_inbound_firewall_rules[count.index].port_ranges
  }

  direction     = var.cluster_inbound_firewall_rules[count.index].direction
  source_ranges = var.cluster_inbound_firewall_rules[count.index].source_cidrs
  priority      =  (100 + count.index)

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

}

# Enable OSD required APIs at project scope
resource "google_project_service" "project" {
  count   = length(var.enable_gcp_project_api_list)
  project = var.cluster_project
  service = var.enable_gcp_project_api_list[count.index]

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}

# Workload Identity Federation Configs

## Create the cluster Service Account
resource "google_service_account" "cluster_service_account" {
  account_id   = var.rh_cluster_sa_name
  display_name = format("%s OCP Service Account", var.cluster_name)
  description  = format("Service account for the %s OpenShift cluster", var.cluster_name)
}

## Assign roles to the service account - roles/compute.admin
resource "google_project_iam_binding" "cluster_sa_iam_bindings" {
  count   = length(var.rh_cluster_sa_roles)
  project = local.cluster_project
  role    = var.rh_cluster_sa_roles[count.index]

  members = [
    "serviceAccount:${google_service_account.cluster_service_account.email}",
    length(regexall(".iam.gserviceaccount.com$", local.current_user)) > 0 ? format("serviceAccount:%s", local.current_user) : format("user:%s", local.current_user)
  ]
}

## Generate a key file for the service account
resource "google_service_account_key" "cluster_sa_keyfile" {
  service_account_id = google_service_account.cluster_service_account.name
}

## Create Cluster SA Secret SecretManager
resource "google_secret_manager_secret" "cluster_sa_keyfile" {
  secret_id = local.cluster_sa_keyfile_secret
  project   = var.cluster_project

  labels    = local.derived_tags

  replication {
    auto {}
  }

  lifecycle {
    ignore_changes = [ labels ]
  }
}

## Grant Cluster SA Secret SecretAccessor role
resource "google_secret_manager_secret_iam_binding" "cluster_details_secret_bindings" {
  project = google_secret_manager_secret.cluster_sa_keyfile.project
  secret_id = google_secret_manager_secret.cluster_sa_keyfile.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${google_service_account.cluster_service_account.email}",
    length(regexall(".iam.gserviceaccount.com$", local.current_user)) > 0 ? format("serviceAccount:%s", local.current_user) : format("user:%s", local.current_user)
  ]
  
}

## Store the Cluster SA Keyfile
resource "google_secret_manager_secret_version" "store_cluster_keyfile" {
  secret = google_secret_manager_secret.cluster_sa_keyfile.id

  secret_data = google_service_account_key.cluster_sa_keyfile.private_key
}

## Create WIF Pool
resource "google_iam_workload_identity_pool" "osd_pool" {
  workload_identity_pool_id = var.gcp_wif_config_name
  display_name = format("%s OCP WIP Pool", var.cluster_name)
  description  = format("WIF Pool for the %s OpenShift cluster", var.cluster_name)
}

resource "google_iam_workload_identity_pool_provider" "osd_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.osd_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.cluster_name
  display_name = format("%s OCP WIF Provider", var.cluster_name)
  description  = format("WIF Provider for the %s OpenShift cluster", var.cluster_name)

  oidc {
    issuer_uri        = "https://kubernetes.default.svc"
    allowed_audiences = ["https://kubernetes.default.svc"]
  }

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }
}

resource "google_service_account_iam_member" "osd_service_account_workload_identity_user" {
  service_account_id = google_service_account.cluster_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.osd_pool.name}/*"
}

# Create child DNS Zone for the cluster
resource "google_dns_managed_zone" "cluster_dns_zone" {
  count               = var.use_auto_generated_domain ? 0 : 1
  name                = var.cluster_name
  project             = var.base_dns_zone_project
  dns_name            = local.custom_dns_domain_name

  visibility          = var.private_cluster ? "private" : "public"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.self_link
    }
  }

  cloud_logging_config {
    enable_logging = true
  }

  labels = local.resource_tags
}

## Create an NS record in the base DNS zone
resource "google_dns_record_set" "child_dns_zone" {
  depends_on          = [ google_dns_managed_zone.cluster_dns_zone ]
  count               = var.use_auto_generated_domain ? 0 : 1
  name                = local.custom_dns_domain_prefix
  managed_zone        = google_dns_managed_zone.cluster_dns_zone[0].name
  project             = google_dns_managed_zone.cluster_dns_zone[0].project
  type                = "NS"
  ttl                 = var.dns_ttl
  rrdatas             = google_dns_managed_zone.cluster_dns_zone[0].name_servers
  
}
