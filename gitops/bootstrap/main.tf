
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
      GIT_TOKEN         = sensitive(var.git_token)
      SKIP_REPO_SECRET  = false
    }
  }

  triggers = {
    timestamp = timestamp()
  }
}


