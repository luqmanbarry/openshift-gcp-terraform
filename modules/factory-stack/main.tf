locals {
  stack = var.stack

  business_unit            = try(local.stack.business_metadata.business_unit, "platform")
  openshift_environment    = try(local.stack.environment, "dev")
  create_gcp_resources     = try(local.stack.infrastructure.create_gcp_resources, false)
  acm_enabled              = try(local.stack.acm.enabled, false)
  gitops_bootstrap_enabled = try(local.stack.gitops.bootstrap_enabled, false)
  default_kubeconfig_path  = pathexpand(var.default_kubeconfig_filename)
  managed_kubeconfig_path  = pathexpand(var.managed_cluster_kubeconfig_filename)
  acmhub_kubeconfig_path   = pathexpand(var.acmhub_kubeconfig_filename)

  additional_tags = merge(
    {
      Terraform   = "true"
      environment = local.openshift_environment
    },
    try(local.stack.cluster.additional_tags, {}),
    try(local.stack.default_tags, {}),
    try(local.stack.additional_tags, {})
  )
}

module "infra" {
  count  = local.create_gcp_resources ? 1 : 0
  source = "../osd-gcp-infra"

  platform_environment           = local.stack.environment
  private_cluster                = local.stack.cluster.private
  region                         = local.stack.gcp_region
  default_zone                   = local.stack.gcp_default_zone
  availability_zones             = local.stack.network.availability_zones
  department                     = local.stack.business_metadata.business_unit
  cost_center                    = local.stack.business_metadata.cost_center
  cluster_name                   = local.stack.cluster_name
  cluster_project                = local.stack.gcp_project_id
  vpc                            = local.stack.network.vpc_name
  vpc_routing_mode               = local.stack.infrastructure.vpc_routing_mode
  master_subnet_cidr             = local.stack.network.master_subnet_cidr
  worker_subnet_cidr             = local.stack.network.worker_subnet_cidr
  base_dns_zone_name             = local.stack.network.base_dns_domain
  base_dns_zone_project          = local.stack.network.base_dns_zone_project
  dns_ttl                        = local.stack.network.dns_ttl
  use_auto_generated_domain      = local.stack.use_auto_generated_domain
  enable_gcp_wif_authentication  = local.stack.identity.gcp_workload_identity.enabled
  rh_cluster_sa_name             = local.stack.identity.gcp_workload_identity.cluster_service_account_name
  cluster_inbound_firewall_rules = local.stack.network.inbound_firewall_rules
  default_tags                   = local.additional_tags
}

locals {
  cluster_project            = local.create_gcp_resources ? module.infra[0].cluster_project : local.stack.gcp_project_id
  network_vpc_name           = local.create_gcp_resources ? module.infra[0].vpc_name : local.stack.network.vpc_name
  network_master_subnet_name = local.create_gcp_resources ? module.infra[0].master_subnet_name : local.stack.network.master_subnet_name
  network_worker_subnet_name = local.create_gcp_resources ? module.infra[0].worker_subnet_name : local.stack.network.worker_subnet_name

  core_stack = merge(
    local.stack,
    {
      gcp_project_id = local.cluster_project
      default_tags   = local.additional_tags
      network = merge(
        local.stack.network,
        {
          vpc_name           = local.network_vpc_name
          master_subnet_name = local.network_master_subnet_name
          worker_subnet_name = local.network_worker_subnet_name
        }
      )
    }
  )
}

module "core" {
  source = "../osd-gcp-core"

  department                      = local.core_stack.business_metadata.business_unit
  region                          = local.core_stack.gcp_region
  default_zone                    = local.core_stack.gcp_default_zone
  ocp_version                     = local.core_stack.openshift_version
  cluster_project                 = local.core_stack.gcp_project_id
  worker_machine_type             = local.core_stack.cluster.machine_type
  master_subnet_name              = local.core_stack.network.master_subnet_name
  worker_subnet_name              = local.core_stack.network.worker_subnet_name
  worker_node_count               = local.core_stack.cluster.worker_node_replicas
  cluster_name                    = local.core_stack.cluster_name
  default_tags                    = local.core_stack.default_tags
  private_cluster                 = local.core_stack.cluster.private
  private_service_connect_enabled = try(local.core_stack.cluster.private_service_connect_enabled, false)
  vpc                             = local.core_stack.network.vpc_name
  vpc_project_id                  = try(local.core_stack.network.vpc_project_id, "")
  psc_subnet_name                 = try(local.core_stack.network.psc_subnet_name, "")
  vpc_cidr                        = local.core_stack.network.vpc_cidr_block
  pod_cidr                        = local.core_stack.cluster.pod_cidr
  service_cidr                    = local.core_stack.cluster.service_cidr
  cluster_details_secret_name     = local.core_stack.cluster.details_secret_name
  platform_environment            = local.core_stack.environment
  base_dns_zone_name              = local.core_stack.network.base_dns_domain
  custom_dns_domain_prefix        = local.core_stack.cluster_name
  default_domain_prefix           = local.core_stack.cluster_name
  cost_center                     = local.core_stack.business_metadata.cost_center
  use_auto_generated_domain       = local.core_stack.use_auto_generated_domain
  ocp_pull_secret_secret_name     = local.core_stack.secrets.pull_secret_secret_name
  ocp_pull_secret_secret_project  = local.core_stack.secrets.pull_secret_secret_project
  ocm_token_secret_name           = local.core_stack.secrets.ocm_token_secret_name
  enable_autoscaling              = local.core_stack.cluster.autoscaling_enabled
  autoscaling_max_replicas        = local.core_stack.cluster.max_replicas
  enable_gcp_wif_authentication   = local.core_stack.identity.gcp_workload_identity.enabled
  rh_cluster_sa_name              = local.core_stack.identity.gcp_workload_identity.cluster_service_account_name
  cluster_service_account_name    = local.core_stack.identity.gcp_workload_identity.cluster_service_account_name
  proxy                           = local.core_stack.proxy
}

module "kubeconfig" {
  source = "../osd-gcp-kubeconfig"

  default_kubeconfig_filename         = local.default_kubeconfig_path
  managed_cluster_kubeconfig_filename = local.managed_kubeconfig_path
  acmhub_kubeconfig_filename          = local.acmhub_kubeconfig_path
  acmhub_registration_enabled         = local.core_stack.acm.enabled
  cluster_details_secret_name         = local.core_stack.cluster.details_secret_name
  cluster_project                     = local.core_stack.gcp_project_id
  acmhub_details_secret_name          = local.core_stack.acm.hub_cluster_secret_name
  acmhub_cluster_project              = local.core_stack.acm.hub_cluster_project
}

module "acm_registration" {
  count  = local.acm_enabled ? 1 : 0
  source = "../osd-gcp-acm-registration"
  providers = {
    kubernetes.acmhub_cluster = kubernetes.acmhub_cluster
  }

  department                          = local.core_stack.business_metadata.business_unit
  cluster_name                        = local.core_stack.cluster_name
  default_kubeconfig_filename         = local.default_kubeconfig_path
  managed_cluster_kubeconfig_filename = local.managed_kubeconfig_path
  acmhub_kubeconfig_filename          = local.acmhub_kubeconfig_path
  platform_environment                = local.core_stack.environment
}

module "gitops_bootstrap" {
  count  = local.gitops_bootstrap_enabled ? 1 : 0
  source = "../openshift-gitops-bootstrap"

  stack                               = local.core_stack
  managed_cluster_kubeconfig_filename = local.managed_kubeconfig_path
}
