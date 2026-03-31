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

data "google_project" "cluster_project" {
  project_id = var.cluster_project
}

resource "null_resource" "discover_oidc_documents" {
  count = local.gcp_auth_mode == "workload_identity_federation" ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      set -euo pipefail
      mkdir -p "$(dirname "$OIDC_FILE")"
      oc --kubeconfig "$KUBECONFIG" get --raw /.well-known/openid-configuration > "$OIDC_FILE"
      oc --kubeconfig "$KUBECONFIG" get --raw /openid/v1/jwks > "$JWKS_FILE"
    EOT
    environment = {
      KUBECONFIG = var.managed_cluster_kubeconfig_filename
      OIDC_FILE  = local.oidc_configuration_file
      JWKS_FILE  = local.oidc_jwks_file
    }
  }

  triggers = {
    cluster_name = var.cluster_name
    kubeconfig   = var.managed_cluster_kubeconfig_filename
  }
}

data "local_file" "oidc_configuration" {
  count      = local.gcp_auth_mode == "workload_identity_federation" ? 1 : 0
  filename   = local.oidc_configuration_file
  depends_on = [null_resource.discover_oidc_documents]
}

data "local_file" "oidc_jwks" {
  count      = local.gcp_auth_mode == "workload_identity_federation" ? 1 : 0
  filename   = local.oidc_jwks_file
  depends_on = [null_resource.discover_oidc_documents]
}

resource "google_iam_workload_identity_pool" "day2_gitops" {
  count                     = local.gcp_auth_mode == "workload_identity_federation" ? 1 : 0
  project                   = var.cluster_project
  workload_identity_pool_id = local.wif_pool_id
  display_name              = local.wif_pool_id
  description               = format("Workload identity pool for the %s cluster GitOps workloads", var.cluster_name)
}

resource "google_iam_workload_identity_pool_provider" "day2_gitops" {
  count                              = local.gcp_auth_mode == "workload_identity_federation" ? 1 : 0
  project                            = var.cluster_project
  workload_identity_pool_id          = google_iam_workload_identity_pool.day2_gitops[0].workload_identity_pool_id
  workload_identity_pool_provider_id = local.wif_provider_id
  display_name                       = local.wif_provider_id
  description                        = format("OIDC provider for the %s cluster GitOps workloads", var.cluster_name)
  attribute_mapping = {
    "google.subject"                 = "assertion.sub"
    "attribute.namespace"            = "assertion['kubernetes.io']['namespace']"
    "attribute.service_account_name" = "assertion['kubernetes.io']['serviceaccount']['name']"
  }
  attribute_condition = local.wif_attribute_condition

  oidc {
    issuer_uri        = jsondecode(data.local_file.oidc_configuration[0].content).issuer
    allowed_audiences = []
    jwks_json         = data.local_file.oidc_jwks[0].content
  }
}

## Create GCP ServiceAccount for opt-in static-key auth
resource "google_service_account" "day2_gitops_sa" {
  count        = local.gcp_auth_mode == "service_account_key" ? 1 : 0
  account_id   = local.gcp_auth_service_account_name
  project      = var.cluster_project
  display_name = local.gcp_auth_service_account_name
  description  = "Service account used by GitOps-managed workloads to access GCP services with a key-based fallback"
}

resource "time_rotating" "sa_key_rotation" {
  count         = local.gcp_auth_mode == "service_account_key" ? 1 : 0
  rotation_days = 90
}

resource "google_service_account_key" "day2_gitops_sa" {
  count              = local.gcp_auth_mode == "service_account_key" ? 1 : 0
  service_account_id = google_service_account.day2_gitops_sa[0].name
  keepers = {
    rotation_time = time_rotating.sa_key_rotation[0].rotation_rfc3339
  }
}

## Create ServiceAccount Private Key K8S Secret for opt-in static-key auth
resource "kubectl_manifest" "sa_private_key_k8s_secret" {
  count = local.gcp_auth_mode == "service_account_key" ? 1 : 0
  # provider    = kubernetes.managed_cluster
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: "${local.gcp_auth_secret_name}"
      namespace: "${var.tf_resources_namespace}"
    type: Opaque
    data:
      credentials.json: "${google_service_account_key.day2_gitops_sa[0].private_key}"
  YAML
  # force_conflicts = true
  # wait = true
}

resource "google_project_iam_member" "day2_gitops_service_account_bindings" {
  count   = local.gcp_auth_mode == "service_account_key" ? length(local.k8s_day2_gitops_gcp_sa_rbac_configs) : 0
  project = var.cluster_project
  role    = local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].gcp_role
  member  = "serviceAccount:${google_service_account.day2_gitops_sa[0].email}"
}

resource "google_project_iam_member" "day2_gitops_workload_identity_bindings" {
  count   = local.gcp_auth_mode == "workload_identity_federation" ? length(local.k8s_day2_gitops_gcp_sa_rbac_configs) : 0
  project = var.cluster_project
  role    = local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].gcp_role
  member = format(
    "principal://iam.googleapis.com/projects/%s/locations/global/workloadIdentityPools/%s/subject/%s",
    data.google_project.cluster_project.number,
    google_iam_workload_identity_pool.day2_gitops[0].workload_identity_pool_id,
    format(
      "system:serviceaccount:%s:%s",
      local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_namespace,
      local.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_service_account
    )
  )
}

## Get the git PAT secret
data "google_secret_manager_secret_version" "git_pat_secret" {
  secret  = var.git_token_secret_name
  project = var.git_token_secret_project
}

resource "null_resource" "deploy_openshift_gitops" {

  depends_on = [
    google_project_iam_member.day2_gitops_service_account_bindings,
    google_project_iam_member.day2_gitops_workload_identity_bindings,
    google_iam_workload_identity_pool_provider.day2_gitops,
    kubectl_manifest.sa_private_key_k8s_secret
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      helm template --kubeconfig $KUBECONFIG $RELEASE_NAME $CHART_DIR \
        --values "$CHART_DIR/values.yaml" | oc apply -f -
    EOT
    environment = {
      KUBECONFIG   = var.managed_cluster_kubeconfig_filename
      RELEASE_NAME = "openshift-gitops-operator"
      CHART_DIR    = local.gitops_install_helm_chart_dir
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}

resource "time_sleep" "wait_for_operator" {
  depends_on      = [null_resource.deploy_openshift_gitops]
  create_duration = "120s"

  triggers = {
    timestamp = timestamp()
  }
}

resource "null_resource" "deploy_openshift_gitops_argocd_configs" {
  depends_on = [time_sleep.wait_for_operator]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      mkdir -p "$(dirname "$VALUES_FILE")"
      printf '%s\n' "$ROOT_APP_VALUES" > "$VALUES_FILE"
      helm template --kubeconfig $KUBECONFIG $RELEASE_NAME $CHART_DIR \
        --values "$VALUES_FILE" | oc apply -f -
    EOT
    environment = {
      KUBECONFIG      = var.managed_cluster_kubeconfig_filename
      RELEASE_NAME    = format("%s-root-app", var.cluster_name)
      CHART_DIR       = local.gitops_root_app_chart_dir
      VALUES_FILE     = local.root_app_values_file
      ROOT_APP_VALUES = yamlencode(local.root_app_values)
    }
  }

  triggers = {
    root_app_values = sha256(yamlencode(local.root_app_values))
  }
}
