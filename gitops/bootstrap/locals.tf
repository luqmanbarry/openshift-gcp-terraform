locals {
  gitops_install_helm_chart_dir = "${path.module}/openshift-gitops"
  gitops_root_app_chart_dir     = "${path.module}/root-app"

  cluster_values_prefix = var.cluster_group_path != "" ? format("clusters/%s/%s", var.cluster_group_path, var.cluster_name) : format("clusters/%s", var.cluster_name)
  gcp_auth = merge(
    {
      mode                        = "workload_identity_federation"
      service_account_name        = format("%s-day2-gitops", var.cluster_name)
      service_account_secret_name = format("%s-day2-gitops", var.cluster_name)
      workload_identity_federation = {
        pool_id     = format("%s-day2-gitops", var.cluster_name)
        provider_id = format("%s-day2-gitops", var.cluster_name)
      }
    },
    var.gcp_auth,
    {
      workload_identity_federation = merge(
        {
          pool_id     = format("%s-day2-gitops", var.cluster_name)
          provider_id = format("%s-day2-gitops", var.cluster_name)
        },
        try(var.gcp_auth.workload_identity_federation, {})
      )
    }
  )

  gcp_auth_mode                 = try(local.gcp_auth.mode, "workload_identity_federation")
  gcp_auth_service_account_name = try(local.gcp_auth.service_account_name, format("%s-day2-gitops", var.cluster_name))
  gcp_auth_secret_name          = try(local.gcp_auth.service_account_secret_name, format("%s-day2-gitops", var.cluster_name))
  wif_pool_id                   = try(local.gcp_auth.workload_identity_federation.pool_id, format("%s-day2-gitops", var.cluster_name))
  wif_provider_id               = try(local.gcp_auth.workload_identity_federation.provider_id, format("%s-day2-gitops", var.cluster_name))
  wif_subjects = [
    for binding in var.k8s_day2_gitops_gcp_sa_rbac_configs :
    format("system:serviceaccount:%s:%s", binding.k8s_namespace, binding.k8s_service_account)
  ]
  wif_attribute_condition = length(local.wif_subjects) > 0 ? format(
    "assertion.sub in [%s]",
    join(", ", [for subject in local.wif_subjects : format("'%s'", subject)])
  ) : null

  root_app_path = format("gitops/overlays/%s", try(var.gitops_values.overlay, "cluster-applications"))

  default_projects = [
    {
      name        = "platform"
      namespace   = "openshift-gitops"
      description = "Platform applications managed by the cluster factory."
      sourceRepos = ["*"]
    },
    {
      name        = "workloads"
      namespace   = "openshift-gitops"
      description = "Workload applications managed by the cluster factory."
      sourceRepos = ["*"]
    }
  ]

  platform_applications = [
    for index, app in try(var.gitops_values.applications.platform, []) : merge(
      {
        name      = app.name
        project   = "platform"
        namespace = try(app.namespace, "openshift-gitops")
        path      = format("gitops/apps/platform/%s", app.name)
        syncWave  = try(app.sync_wave, 100 + index)
        enabled   = try(app.enabled, true)
      },
      try(app.values_file, "") != "" ? {
        valueFiles = [
          startswith(app.values_file, "clusters/") ? app.values_file : format("%s/%s", local.cluster_values_prefix, app.values_file)
        ]
      } : {}
    )
  ]

  workload_applications = [
    for index, app in try(var.gitops_values.applications.workloads, []) : merge(
      {
        name      = app.name
        project   = "workloads"
        namespace = try(app.namespace, app.name)
        path      = format("gitops/apps/workloads/%s", app.name)
        syncWave  = try(app.sync_wave, 300 + index)
        enabled   = try(app.enabled, true)
      },
      try(app.values_file, "") != "" ? {
        valueFiles = [
          startswith(app.values_file, "clusters/") ? app.values_file : format("%s/%s", local.cluster_values_prefix, app.values_file)
        ]
      } : {}
    )
  ]

  overlay_values = {
    clusterName     = var.cluster_name
    gitopsNamespace = "openshift-gitops"
    git = {
      repoURL        = var.git_repository_url
      targetRevision = var.git_branch
    }
    projects     = try(var.gitops_values.projects, local.default_projects)
    applications = concat(local.platform_applications, local.workload_applications)
  }

  root_app_values = {
    rootApplication = {
      name                 = format("%s-root", var.cluster_name)
      namespace            = "openshift-gitops"
      destinationNamespace = "openshift-gitops"
      project              = "default"
      path                 = local.root_app_path
    }
    git = {
      repoURL        = var.git_repository_url
      targetRevision = var.git_branch
      username       = "git"
      password       = sensitive(data.google_secret_manager_secret_version.git_pat_secret.secret_data)
    }
    bootstrapValues = local.overlay_values
    syncPolicy = {
      automated   = true
      prune       = true
      selfHeal    = true
      syncOptions = ["CreateNamespace=true"]
    }
  }

  k8s_day2_gitops_gcp_sa_rbac_configs = [
    for binding in var.k8s_day2_gitops_gcp_sa_rbac_configs : {
      gcp_role            = binding.gcp_role
      k8s_service_account = binding.k8s_service_account
      k8s_namespace       = binding.k8s_namespace
    }
  ]

  scratch_dir             = "${path.module}/../.scratch_dir"
  root_app_values_file    = format("%s/root_app_values_%s.yaml", local.scratch_dir, var.cluster_name)
  oidc_configuration_file = format("%s/%s-oidc-configuration.json", local.scratch_dir, var.cluster_name)
  oidc_jwks_file          = format("%s/%s-oidc-jwks.json", local.scratch_dir, var.cluster_name)
}
