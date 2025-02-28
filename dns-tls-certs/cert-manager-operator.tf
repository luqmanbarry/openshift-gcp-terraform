# Deploy Cert Manager Operator
## Create namespace
resource "kubectl_manifest" "cert_manager_namespace" {
  # provider    = kubernetes.managed_cluster
  yaml_body = <<YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: "${local.cert_operator_ns}"
      annotations:
        "openshift.io/display-name":  "Red Hat Certificate Manager Operator"
      labels:
        "openshift.io/cluster-monitoring": "true"
        ${yamlencode(local.resource_tags)}
  YAML
  # force_conflicts = true
  # wait = true
}
## Create OperatorGroup
resource "kubectl_manifest" "cert_manager_operator_group" {
  depends_on = [ kubectl_manifest.cert_manager_namespace ]
  # provider    = kubernetes.managed_cluster
  yaml_body = <<YAML
    apiVersion: "operators.coreos.com/v1"
    kind: "OperatorGroup"
    metadata:
      name: ${local.cert_operator_ns}
      namespace: ${local.cert_operator_ns}
    spec:
      targetNamespaces:
        - ${local.cert_operator_ns}
  YAML

  force_new       = true
  force_conflicts = true
  wait = true
}
## Create Subscription
resource "kubectl_manifest" "cert_manager_subscription" {
  depends_on = [ kubectl_manifest.cert_manager_operator_group ]
  # provider    = kubernetes.managed_cluster
  yaml_body = <<YAML
    apiVersion: "operators.coreos.com/v1alpha1"
    kind: "Subscription"
    metadata:
      name: ${local.cert_operator_name}
      namespace: ${local.cert_operator_ns}
    spec:
      channel: "stable-v1"
      installPlanApproval: "Automatic"
      name: ${local.cert_operator_name}
      source: "redhat-operators"
      sourceNamespace: "openshift-marketplace"
  YAML

  force_new       = true
  force_conflicts = true
  wait = true
}

# Configure Cert Manager with LetsEncrypt
## Create CertManager login secret with SP credentials
resource "kubectl_manifest" "aro_dns_cert_manager_sp_secret" {
  depends_on = [ kubectl_manifest.cert_manager_subscription ]
  # provider    = kubernetes.managed_cluster
  yaml_body = <<YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${local.cert_operator_name}
      namespace: "cert-manager"
    type: Opaque
    stringData:
      client-secret: ${azuread_service_principal_password.aro_dns_cert_manager.value}
  YAML
  force_new       = true
  force_conflicts = true
  wait = true
} 

resource "time_sleep" "wait_for_operator_install" {
  depends_on      = [ kubectl_manifest.aro_dns_cert_manager_sp_secret ]
  create_duration = "180s"
}

## Create/Configure ClusterIssuer CR with Let's Encrypt
resource "kubectl_manifest" "aro_dns_cert_manager_clusterissuer_letsencrypt" {
  depends_on  = [ time_sleep.wait_for_operator_install ]
  # provider    = kubernetes.managed_cluster
  yaml_body = <<YAML
    apiVersion: "cert-manager.io/v1"
    kind: "ClusterIssuer"
    metadata:
      name: ${local.cert_manager_cluster_issuer_cr_name}
    spec:
      acme:
        email: ${var.cert_issuer_email}
        privateKeySecretRef:
          name: ${format("%s-account-key", local.cert_manager_cluster_issuer_cr_name)}
        server: ${var.cert_issuer_server}
        solvers:
          - dns01:
              azureDNS:
                clientID: ${azuread_service_principal.aro_dns_cert_manager.client_id}
                clientSecretSecretRef:
                  key: "client-secret"
                  name: ${local.cert_operator_name}
                environment: ${var.azure_cloud_environment}
                hostedZoneName: ${data.azurerm_dns_zone.current_cluster.name}
                resourceGroupName: ${data.azurerm_dns_zone.current_cluster.resource_group_name}
                subscriptionID: ${data.azurerm_client_config.current.subscription_id}
                tenantID: ${azuread_service_principal.aro_dns_cert_manager.application_tenant_id}
  YAML
  force_new       = true
  force_conflicts = true
  wait = true
}