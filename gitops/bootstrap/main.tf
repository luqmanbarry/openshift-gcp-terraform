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
        ${yamlencode(local.resource_tags)}
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
      name: "${var.cluster_name}"
      namespace: "${var.tf_resources_namespace}"
      labels:
        "openshift.io/role-desc":  "SA for accessing GCP SecretManager"
        ${yamlencode(local.resource_tags)}
  YAML
  # force_conflicts = true
  # wait = true
}

## Create GCP ServiceAccount
resource "google_service_account" "day2_gitops_sa" {
  account_id   = format("%s-day2-gitops", var.cluster_name)
  display_name = format("%s-day2-gitops", var.cluster_name)
  description  = "Service Account used by Day2 GitOps modules to access GCP services"
}
resource "google_service_account_iam_member" "day2_gitops_k8s_sa_binding_wif" {
  count               = length(var.k8s_day2_gitops_gcp_sa_rbac_configs)
  service_account_id  = data.google_service_account.day2_gitops_sa.name
  role                = "roles/iam.workloadIdentityUser"
  member              = "serviceAccount:${data.google_project.cluster_project.project_id}.svc.id.goog[${var.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_namespace}/${var.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_service_account}]"
}
resource "google_project_iam_member" "day2_gitops_sa_bindings" {
  count       = length(var.k8s_day2_gitops_gcp_sa_rbac_configs)
  project     = data.google_project.cluster_project.project_id
  role        = var.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].gcp_role
  member      = "serviceAccount:${google_service_account.day2_gitops_sa.email}"
}

## Assign roles to the K8S service account
resource "google_project_iam_member" "day2_gitops_role_assignments" {
  count        = length(var.k8s_day2_gitops_gcp_sa_rbac_configs)
  project      = var.cluster_project
  role         = var.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].gcp_role

  member       = "principal://iam.googleapis.com/projects/${data.google_project.cluster_project.number}/locations/global/workloadIdentityPools/${data.google_project.cluster_project.project_id}.svc.id.goog/subject/ns/${var.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_namespace}/sa/${var.k8s_day2_gitops_gcp_sa_rbac_configs[count.index].k8s_service_account}"
}

## Get the git PAT secret
data "google_secret_manager_secret_version" "git_pat_secret" {
  secret  = var.git_token_secret_name
  project = var.git_token_secret_project
}

resource "null_resource" "deploy_openshift_gitops" {

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


