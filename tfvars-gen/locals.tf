locals {
  tags_query = {
    "cluster_name" = var.cluster_name
  }

  kube_home_dir                          = abspath(format("%s/../", path.module))
  default_kubeconfig_filename            = format("%s/.kube/config", local.kube_home_dir)
  managed_cluster_kubeconfig_filename    = format("%s/.kube/managed_cluster/config", local.kube_home_dir)
  acmhub_kubeconfig_filename             = format("%s/.kube/acm_hub/config", local.kube_home_dir)
  wif_sa_name                            = format("%s-%s-%s", var.department, var.platform_environment, var.cluster_name)

  
  scratch_dir                            = "${path.module}/../.scratch_dir"
  current_user_file                      = format("%s/current_user", local.scratch_dir)
  current_user                           = trimspace(data.local_file.current_user.content)

  # DERIVED VARS
  cluster_project                                  = length(var.cluster_project) > 0 ? var.cluster_project : var.cluster_name
  vpc                                              = data.google_compute_network.current_vpc.name
  custom_dns_domain_prefix                         = format("%s.%s.%s.%s", var.cluster_name, var.platform_environment, var.region, var.department)
  custom_dns_domain_name                           = format("%s.%s", local.custom_dns_domain_prefix, var.base_dns_zone_name)
  acmhub_cluster_env                               = var.platform_environment
  cluster_details_secret_name                      = replace(replace(var.cluster_details_secret_name, "OCP_ENV", var.platform_environment), "CLUSTER_NAME", var.cluster_name)
  acmhub_details_secret_name                       = replace(replace(var.acmhub_details_secret_name, "OCP_ENV", var.platform_environment), "ACMHUB_NAME", var.acmhub_cluster_name)

  derived_tags = {
      "cluster_name"   = var.cluster_name
      "organization"   = var.department
      "environment"    = var.platform_environment
      "cost_center"    = var.cost_center
      "created_by"     = replace(replace(local.current_user, "@", "_"), ".", "-")
  }

  cluster_infra_tags = merge(
    local.derived_tags,
    var.default_tags
  )


  # TFVARs Paths
  admin_tfvars_path                                = format("${path.module}/../tfvars/admin/admin.tfvars")
  final_tfvars_path                                = format("${path.module}/../tfvars/computed/%s/%s.tfvars", var.department, var.cluster_name)
  
  # FINAL OUTPUT
  admin_tfvars_content                            = [
    "#========================= BEGIN: STATIC VARIABLES ===================================",
    file(local.admin_tfvars_path),
    "#========================= END: STATIC VARIABLES ====================================="
  ]

  dynamic_tfvars_content                           = [
      "#%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",
      format("department=%q", var.department),
      format("git_token_secret_project=%q", var.git_token_secret_project),
      format("git_token_secret_name=%q", var.git_token_secret_name),
      format("private_cluster=%s", var.private_cluster),
      format("vpc=%q", data.google_compute_network.current_vpc.name),
      format("master_subnet_name=%q", data.google_compute_subnetwork.vpc_master_subnet.name),
      format("master_subnet_cidr=%q", data.google_compute_subnetwork.vpc_master_subnet.ip_cidr_range),
      format("master_subnet_id=%q", data.google_compute_subnetwork.vpc_master_subnet.subnetwork_id ),
      format("worker_subnet_name=%q", data.google_compute_subnetwork.vpc_worker_subnet.name),
      format("worker_subnet_cidr=%q", data.google_compute_subnetwork.vpc_worker_subnet.ip_cidr_range),
      format("worker_subnet_id=%q", data.google_compute_subnetwork.vpc_worker_subnet.subnetwork_id ),
      format("vpc_cidr=%q", var.vpc_cidr),
      format("region=%q", var.region),
      format("platform_environment=%q", var.platform_environment),
      format("cluster_name=%q", var.cluster_name),
      format("enable_gcp_wif_authentication=%s", var.enable_gcp_wif_authentication),
      format("ocp_pull_secret_secret_name=%q", var.ocp_pull_secret_secret_name),
      format("ocp_pull_secret_secret_project=%q", var.ocp_pull_secret_secret_project),
      format("ocm_token_secret_name=%q", var.ocm_token_secret_name),
      format("cluster_details_secret_name=%q", local.cluster_details_secret_name),
      format("acmhub_details_secret_name=%q", local.acmhub_details_secret_name),
      format("cluster_service_account_name=%q", var.enable_gcp_wif_authentication ? "" : data.google_service_account.cluster_service_account[0].name),
      format("cluster_project=%q", local.cluster_project),
      format("cost_center=%q", var.cost_center),
      format("ocp_version=%q", var.ocp_version),
      format("acmhub_registration_enabled=%s", var.acmhub_registration_enabled),
      format("kube_home_dir=%q", local.kube_home_dir),
      format("default_kubeconfig_filename=%q", local.default_kubeconfig_filename),
      format("managed_cluster_kubeconfig_filename=%q", local.managed_cluster_kubeconfig_filename),
      format("acmhub_kubeconfig_filename=%q", local.acmhub_kubeconfig_filename),
      format("acmhub_cluster_name=%q", var.acmhub_cluster_name),
      format("worker_machine_type=%q", var.worker_machine_type),
      format("worker_node_count=%s", var.worker_node_count),
      format("enable_autoscaling=%s", var.enable_autoscaling),
      format("autoscaling_max_replicas=%s", var.autoscaling_max_replicas),
      format("tfstate_project=%q", var.tfstate_project),
      format("base_dns_zone_name=%q", var.base_dns_zone_name),
      format("base_dns_zone_project=%q", var.base_dns_zone_project),
      format("root_dns_domain=%q", var.root_dns_domain),
      format("use_auto_generated_domain=%s", var.use_auto_generated_domain),
      format("default_domain_prefix=%q", var.default_domain_prefix),
      format("custom_dns_domain_prefix=%q", local.custom_dns_domain_prefix),
      format("custom_dns_domain_name=%q", local.custom_dns_domain_name),
      format("acmhub_cluster_env=%q", local.acmhub_cluster_env),
      replace(format("cluster_infra_tags=%v", local.cluster_infra_tags), ":", "="),
      "#%%%%%%%%%%%%%%%%%%%%%%%%% END: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    ]
  
  final_tfvars_content                             = join("\n\n",
    local.admin_tfvars_content, 
    local.dynamic_tfvars_content
  )

}
