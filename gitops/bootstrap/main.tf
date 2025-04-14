data "google_secret_manager_secret_version" "cluster_details" {
  secret  = var.cluster_details_secret_name
  project = var.cluster_project
}

## Create namespace
resource "kubectl_manifest" "create_tf_namespace" {
  # provider    = kubernetes.managed_cluster
  yaml_body = <<YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: "${var.tf_resources_namespace}"
      annotations:
        "openshift.io/display-name":  "TF managed cluster resources"
      labels:
        "openshift.io/cluster-monitoring": "true"
  YAML
  # force_conflicts = true
  # wait = true
}

## Create ServiceAccount for ESO operator AuthN
resource "kubectl_manifest" "secret_manager_access_sa" {
  # provider    = kubernetes.managed_cluster
  yaml_body = <<YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "${local.ocp_day2_service_account}"
      namespace: "${var.tf_resources_namespace}"
      annotations:
        "openshift.io/role-desc":  "SA for accessing GCP SecretManager"
        iam.gke.io/gcp-service-account: "${local.ocp_day2_service_account}@${var.cluster_project}.iam.gserviceaccount.com"
  YAML
  # force_conflicts = true
  # wait = true
}
data "google_project" "cluster_project" {
  project_id = var.cluster_project
}

# Create WIF Pool
resource "google_iam_workload_identity_pool" "day2_gitops" {
  workload_identity_pool_id = local.wif_config_name
  display_name              = local.wif_config_name
  description               = format("WIF Pool for the %s OpenShift cluster Day2 GitOps ServiceAccount", var.cluster_name)
}

resource "google_iam_workload_identity_pool_provider" "day2_gitops" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.day2_gitops.workload_identity_pool_id
  workload_identity_pool_provider_id = local.wif_config_name
  display_name                       = local.wif_config_name
  description                        = format("WIF Provider for the %s OpenShift cluster Day2 GitOps GCP Service Account", var.cluster_name)

  attribute_mapping = {
    # "google.subject"                = "system:serviceaccount:${var.tf_resources_namespace}:${local.ocp_day2_service_account}"
    "google.subject"                      = "assertion.sub"
    "attribute.aud"                       = "assertion.aud"
    "attribute.kubernetes_namespace"      = "assertion.namespace"
    "attribute.kubernetes_serviceaccount" = "assertion.serviceaccount"
  }

  # OIDC configuration for OpenShift
  oidc {
    issuer_uri        = "https://openshift.com"
    allowed_audiences = [ 
      "openshift", 
      "kubernetes", 
      "day2-gitops", 
      "openshift-workloads", 
      format("%s", local.ocp_day2_service_account),
      format("%s", var.tf_resources_namespace)
    ]
  }
}

## Create GCP ServiceAccount
resource "google_service_account" "day2_gitops_sa" {
  account_id   = local.ocp_day2_service_account
  display_name = local.ocp_day2_service_account
  description  = "Service Account used by Day2 GitOps modules to access GCP services"
}
# note this requires the terraform to be run regularly
resource "time_rotating" "sa_key_rotation" {
  rotation_days = 90
}
resource "google_service_account_key" "day2_gitops_sa" {
  service_account_id = google_service_account.day2_gitops_sa.name
  keepers = {
    rotation_time = time_rotating.sa_key_rotation.rotation_rfc3339
  }
}
## Create ServiceAccount Private Key
resource "kubectl_manifest" "sa_private_key_k8s_secret" {
  # provider    = kubernetes.managed_cluster
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: "${local.ocp_day2_service_account}"
      namespace: "${var.tf_resources_namespace}"
    type: Opaque
    data:
      credentials.json: "${google_service_account_key.day2_gitops_sa.private_key}"
  YAML
  # force_conflicts = true
  # wait = true
}
resource "google_service_account_iam_binding" "day2_gitops_k8s_sa_binding_wif" {
  count               = length(local.k8s_day2_gitops_gcp_sa_rbac_configs)
  service_account_id  = google_service_account.day2_gitops_sa.name
  role                = "roles/iam.workloadIdentityUser"
    
  members              = [ 
    # "serviceAccount:${google_iam_workload_identity_pool.day2_gitops.workload_identity_pool_id}[${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_namespace}/${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_service_account}]",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.day2_gitops.name}/attribute.kubernetes_namespace/${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_namespace}/attribute.k8s_serviceaccount/${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_service_account}"
  ]
}
resource "google_project_iam_member" "day2_gitops_sa_bindings" {
  count       = length(local.k8s_day2_gitops_gcp_sa_rbac_configs)
  project     = data.google_project.cluster_project.project_id
  role        = local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].gcp_role
  member      = "serviceAccount:${google_service_account.day2_gitops_sa.email}"
}

# Assign roles to the K8S service account
resource "google_project_iam_member" "day2_gitops_role_assignments" {
  count        = length(local.k8s_day2_gitops_gcp_sa_rbac_configs)
  project      = var.cluster_project
  role         = local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].gcp_role
  # member       = "principal://iam.googleapis.com/projects/${data.google_project.cluster_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.day2_gitops.id}.svc.id.goog/subject/ns/${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_namespace}/sa/${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_service_account}"
  member       = "principalSet://iam.googleapis.com/projects/${data.google_project.cluster_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.day2_gitops.workload_identity_pool_id}/attribute.kubernetes_namespace/${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_namespace}/attribute.k8s_serviceaccount/${local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_service_account}"
}

## Get the git PAT secret
data "google_secret_manager_secret_version" "git_pat_secret" {
  secret  = var.git_token_secret_name
  project = var.git_token_secret_project
}

resource "null_resource" "deploy_openshift_gitops" {

  depends_on = [ 
    # google_project_iam_member.day2_gitops_role_assignments,
    google_project_iam_member.day2_gitops_sa_bindings,
    google_service_account_iam_binding.day2_gitops_k8s_sa_binding_wif,
    google_iam_workload_identity_pool_provider.day2_gitops
  ]

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      helm template --kubeconfig $KUBECONFIG $RELEASE_NAME $CHART_DIR \
        --values "$CHART_DIR/values.yaml" | oc apply -f -
    EOT
    environment = {
      KUBECONFIG      = var.managed_cluster_kubeconfig_filename
      RELEASE_NAME    = "openshift-gitops-operator"
      CHART_DIR       = local.gitops_install_helm_chart_dir
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}

resource "time_sleep" "wait_for_operator" {
  depends_on = [ null_resource.deploy_openshift_gitops ]
  create_duration = "120s"

  triggers = {
    timestamp = timestamp()
  }
}

resource "null_resource" "deploy_openshift_gitops_argocd_configs" {
  depends_on = [ time_sleep.wait_for_operator ]
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      helm template --kubeconfig $KUBECONFIG $RELEASE_NAME $CHART_DIR \
        --values "$CHART_DIR/values.yaml" \
        --values "$CHART_DIR/values.$CLUSTER_NAME.yaml" \
        --set git.repository.repoURL="$GIT_REPOSITORY" \
        --set git.repository.targetRevision="$GIT_BRANCH" \
        --set git.repository.username="$GIT_USERNAME" \
        --set git.repository.password="$GIT_TOKEN" \
        --set skipArgoCDSync=$SKIP_REPO_SECRET | oc apply -f -
    EOT
    environment = {
      KUBECONFIG        = var.managed_cluster_kubeconfig_filename
      RELEASE_NAME      = "openshift-gitops-config"
      CHART_DIR         = local.gitops_config_helm_chart_dir
      CLUSTER_NAME      = var.cluster_name
      GIT_REPOSITORY    = var.git_repository_url
      GIT_BRANCH        = var.git_branch
      GIT_USERNAME      = "git"
      GIT_TOKEN         = sensitive(data.google_secret_manager_secret_version.git_pat_secret.secret_data)
      SKIP_REPO_SECRET  = false
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}


